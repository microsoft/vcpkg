#include "pch.h"
#include "VcpkgPaths.h"
#include "PackageSpec.h"
#include "vcpkg_Files.h"
#include "vcpkg_System.h"
#include "coff_file_reader.h"
#include "PostBuildLint_BuildInfo.h"
#include "PostBuildLint_BuildType.h"
#include "PostBuildLint.h"

namespace vcpkg::PostBuildLint
{
    enum class LintStatus
    {
        SUCCESS = 0,
        ERROR_DETECTED = 1
    };

    struct OutdatedDynamicCrt
    {
        std::string name;
        std::regex regex;

        OutdatedDynamicCrt(const std::string& name, const std::string& regex_as_string)
            : name(name),
              regex(std::regex(regex_as_string, std::regex_constants::icase)) {}
    };

    const std::vector<OutdatedDynamicCrt>& get_outdated_dynamic_crts()
    {
        static const std::vector<OutdatedDynamicCrt> v = {
            { "msvcp100.dll", R"(msvcp100\.dll)" },
            { "msvcp100d.dll", R"(msvcp100d\.dll)" },
            { "msvcp110.dll", R"(msvcp110\.dll)" },
            { "msvcp110_win.dll", R"(msvcp110_win\.dll)" },
            { "msvcp120.dll", R"(msvcp120\.dll)" },
            { "msvcp120_clr0400.dll", R"(msvcp120_clr0400\.dll)" },
            { "msvcp60.dll", R"(msvcp60\.dll)" },
            { "msvcp60.dll", R"(msvcp60\.dll)" },

            { "msvcr100.dll", R"(msvcr100\.dll)" },
            { "msvcr100d.dll", R"(msvcr100d\.dll)" },
            { "msvcr100_clr0400.dll", R"(msvcr100_clr0400\.dll)" },
            { "msvcr110.dll", R"(msvcr110\.dll)" },
            { "msvcr120.dll", R"(msvcr120\.dll)" },
            { "msvcr120_clr0400.dll", R"(msvcr120_clr0400\.dll)" },
            { "msvcrt.dll", R"(msvcrt\.dll)" },
            { "msvcrt20.dll", R"(msvcrt20\.dll)" },
            { "msvcrt40.dll", R"(msvcrt40\.dll)" }
        };

        return v;
    }

    template <class T>
    static bool contains_and_enabled(const std::map<T, OptBoolT> map, const T& key)
    {
        auto it = map.find(key);
        if (it != map.cend() && it->second == OptBoolT::ENABLED)
        {
            return true;
        }

        return false;
    }

    static LintStatus check_for_files_in_include_directory(const std::map<BuildPolicies::Type, OptBoolT>& policies, const fs::path& package_dir)
    {
        if (contains_and_enabled(policies, BuildPolicies::EMPTY_INCLUDE_FOLDER))
        {
            return LintStatus::SUCCESS;
        }

        const fs::path include_dir = package_dir / "include";
        if (!fs::exists(include_dir) || fs::is_empty(include_dir))
        {
            System::println(System::Color::warning, "The folder /include is empty. This indicates the library was not correctly installed.");
            return LintStatus::ERROR_DETECTED;
        }

        return LintStatus::SUCCESS;
    }

    static LintStatus check_for_files_in_debug_include_directory(const fs::path& package_dir)
    {
        const fs::path debug_include_dir = package_dir / "debug" / "include";
        std::vector<fs::path> files_found;

        Files::recursive_find_matching_paths_in_dir(debug_include_dir, [&](const fs::path& current)
                                                    {
                                                        return !fs::is_directory(current) && current.extension() != ".ifc";
                                                    }, &files_found);

        if (!files_found.empty())
        {
            System::println(System::Color::warning, "Include files should not be duplicated into the /debug/include directory. If this cannot be disabled in the project cmake, use\n"
                            "    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)"
            );
            return LintStatus::ERROR_DETECTED;
        }

        return LintStatus::SUCCESS;
    }

    static LintStatus check_for_files_in_debug_share_directory(const fs::path& package_dir)
    {
        const fs::path debug_share = package_dir / "debug" / "share";

        if (fs::exists(debug_share) && !fs::is_empty(debug_share))
        {
            System::println(System::Color::warning, "/debug/share should not exist. Please reorganize any important files, then use\n"
                            "    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)");
            return LintStatus::ERROR_DETECTED;
        }

        return LintStatus::SUCCESS;
    }

    static LintStatus check_folder_lib_cmake(const fs::path& package_dir, const PackageSpec& spec)
    {
        const fs::path lib_cmake = package_dir / "lib" / "cmake";
        if (fs::exists(lib_cmake))
        {
            System::println(System::Color::warning, "The /lib/cmake folder should be moved to /share/%s/cmake.", spec.name());
            return LintStatus::ERROR_DETECTED;
        }

        return LintStatus::SUCCESS;
    }

    static LintStatus check_for_misplaced_cmake_files(const fs::path& package_dir, const PackageSpec& spec)
    {
        std::vector<fs::path> misplaced_cmake_files;
        Files::recursive_find_files_with_extension_in_dir(package_dir / "cmake", ".cmake", &misplaced_cmake_files);
        Files::recursive_find_files_with_extension_in_dir(package_dir / "debug" / "cmake", ".cmake", &misplaced_cmake_files);
        Files::recursive_find_files_with_extension_in_dir(package_dir / "lib" / "cmake", ".cmake", &misplaced_cmake_files);
        Files::recursive_find_files_with_extension_in_dir(package_dir / "debug" / "lib" / "cmake", ".cmake", &misplaced_cmake_files);

        if (!misplaced_cmake_files.empty())
        {
            System::println(System::Color::warning, "The following cmake files were found outside /share/%s. Please place cmake files in /share/%s.", spec.name(), spec.name());
            Files::print_paths(misplaced_cmake_files);
            return LintStatus::ERROR_DETECTED;
        }

        return LintStatus::SUCCESS;
    }

    static LintStatus check_folder_debug_lib_cmake(const fs::path& package_dir)
    {
        const fs::path lib_cmake_debug = package_dir / "debug" / "lib" / "cmake";
        if (fs::exists(lib_cmake_debug))
        {
            System::println(System::Color::warning, "The /debug/lib/cmake folder should be moved to just /debug/cmake");
            return LintStatus::ERROR_DETECTED;
        }

        return LintStatus::SUCCESS;
    }

    static LintStatus check_for_dlls_in_lib_dirs(const fs::path& package_dir)
    {
        std::vector<fs::path> dlls;
        Files::recursive_find_files_with_extension_in_dir(package_dir / "lib", ".dll", &dlls);
        Files::recursive_find_files_with_extension_in_dir(package_dir / "debug" / "lib", ".dll", &dlls);

        if (!dlls.empty())
        {
            System::println(System::Color::warning, "\nThe following dlls were found in /lib and /debug/lib. Please move them to /bin or /debug/bin, respectively.");
            Files::print_paths(dlls);
            return LintStatus::ERROR_DETECTED;
        }

        return LintStatus::SUCCESS;
    }

    static LintStatus check_for_copyright_file(const PackageSpec& spec, const VcpkgPaths& paths)
    {
        const fs::path packages_dir = paths.packages / spec.dir();
        const fs::path copyright_file = packages_dir / "share" / spec.name() / "copyright";
        if (fs::exists(copyright_file))
        {
            return LintStatus::SUCCESS;
        }
        const fs::path current_buildtrees_dir = paths.buildtrees / spec.name();
        const fs::path current_buildtrees_dir_src = current_buildtrees_dir / "src";

        std::vector<fs::path> potential_copyright_files;
        // Only searching one level deep
        for (auto it = fs::recursive_directory_iterator(current_buildtrees_dir_src); it != fs::recursive_directory_iterator(); ++it)
        {
            if (it.depth() > 1)
            {
                continue;
            }

            const std::string filename = it->path().filename().string();
            if (filename == "LICENSE" || filename == "LICENSE.txt" || filename == "COPYING")
            {
                potential_copyright_files.push_back(it->path());
            }
        }

        System::println(System::Color::warning, "The software license must be available at ${CURRENT_PACKAGES_DIR}/share/%s/copyright .", spec.name());
        if (potential_copyright_files.size() == 1) // if there is only one candidate, provide the cmake lines needed to place it in the proper location
        {
            const fs::path found_file = potential_copyright_files[0];
            const fs::path relative_path = found_file.string().erase(0, current_buildtrees_dir.string().size() + 1); // The +1 is needed to remove the "/"
            System::println("\n    file(COPY ${CURRENT_BUILDTREES_DIR}/%s DESTINATION ${CURRENT_PACKAGES_DIR}/share/%s)\n"
                            "    file(RENAME ${CURRENT_PACKAGES_DIR}/share/%s/%s ${CURRENT_PACKAGES_DIR}/share/%s/copyright)",
                            relative_path.generic_string(), spec.name(), spec.name(), found_file.filename().generic_string(), spec.name());
            return LintStatus::ERROR_DETECTED;
        }

        if (potential_copyright_files.size() > 1)
        {
            System::println(System::Color::warning, "The following files are potential copyright files:");
            Files::print_paths(potential_copyright_files);
        }

        System::println("    %s/share/%s/copyright", packages_dir.generic_string(), spec.name());
        return LintStatus::ERROR_DETECTED;
    }

    static LintStatus check_for_exes(const fs::path& package_dir)
    {
        std::vector<fs::path> exes;
        Files::recursive_find_files_with_extension_in_dir(package_dir / "bin", ".exe", &exes);
        Files::recursive_find_files_with_extension_in_dir(package_dir / "debug" / "bin", ".exe", &exes);

        if (!exes.empty())
        {
            System::println(System::Color::warning, "The following EXEs were found in /bin and /debug/bin. EXEs are not valid distribution targets.");
            Files::print_paths(exes);
            return LintStatus::ERROR_DETECTED;
        }

        return LintStatus::SUCCESS;
    }

    static LintStatus check_exports_of_dlls(const std::vector<fs::path>& dlls, const fs::path& dumpbin_exe)
    {
        std::vector<fs::path> dlls_with_no_exports;
        for (const fs::path& dll : dlls)
        {
            const std::wstring cmd_line = Strings::wformat(LR"("%s" /exports "%s")", dumpbin_exe.native(), dll.native());
            System::ExitCodeAndOutput ec_data = System::cmd_execute_and_capture_output(cmd_line);
            Checks::check_exit(VCPKG_LINE_INFO, ec_data.exit_code == 0, "Running command:\n   %s\n failed", Strings::utf16_to_utf8(cmd_line));

            if (ec_data.output.find("ordinal hint RVA      name") == std::string::npos)
            {
                dlls_with_no_exports.push_back(dll);
            }
        }

        if (!dlls_with_no_exports.empty())
        {
            System::println(System::Color::warning, "The following DLLs have no exports:");
            Files::print_paths(dlls_with_no_exports);
            System::println(System::Color::warning, "DLLs without any exports are likely a bug in the build script.");
            return LintStatus::ERROR_DETECTED;
        }

        return LintStatus::SUCCESS;
    }

    static LintStatus check_uwp_bit_of_dlls(const std::string& expected_system_name, const std::vector<fs::path>& dlls, const fs::path dumpbin_exe)
    {
        if (expected_system_name != "uwp")
        {
            return LintStatus::SUCCESS;
        }

        std::vector<fs::path> dlls_with_improper_uwp_bit;
        for (const fs::path& dll : dlls)
        {
            const std::wstring cmd_line = Strings::wformat(LR"("%s" /headers "%s")", dumpbin_exe.native(), dll.native());
            System::ExitCodeAndOutput ec_data = System::cmd_execute_and_capture_output(cmd_line);
            Checks::check_exit(VCPKG_LINE_INFO, ec_data.exit_code == 0, "Running command:\n   %s\n failed", Strings::utf16_to_utf8(cmd_line));

            if (ec_data.output.find("App Container") == std::string::npos)
            {
                dlls_with_improper_uwp_bit.push_back(dll);
            }
        }

        if (!dlls_with_improper_uwp_bit.empty())
        {
            System::println(System::Color::warning, "The following DLLs do not have the App Container bit set:");
            Files::print_paths(dlls_with_improper_uwp_bit);
            System::println(System::Color::warning, "This bit is required for Windows Store apps.");
            return LintStatus::ERROR_DETECTED;
        }

        return LintStatus::SUCCESS;
    }

    struct FileAndArch
    {
        fs::path file;
        std::string actual_arch;
    };

    static std::string get_actual_architecture(const MachineType& machine_type)
    {
        switch (machine_type)
        {
            case MachineType::AMD64:
            case MachineType::IA64:
                return "x64";
            case MachineType::I386:
                return "x86";
            case MachineType::ARM:
            case MachineType::ARMNT:
                return "arm";
            default:
                return "Machine Type Code = " + std::to_string(static_cast<uint16_t>(machine_type));
        }
    }

    static void print_invalid_architecture_files(const std::string& expected_architecture, std::vector<FileAndArch> binaries_with_invalid_architecture)
    {
        System::println(System::Color::warning, "The following files were built for an incorrect architecture:");
        System::println("");
        for (const FileAndArch& b : binaries_with_invalid_architecture)
        {
            System::println("    %s", b.file.generic_string());
            System::println("Expected %s, but was: %s", expected_architecture, b.actual_arch);
            System::println("");
        }
    }

    static LintStatus check_dll_architecture(const std::string& expected_architecture, const std::vector<fs::path>& files)
    {
        std::vector<FileAndArch> binaries_with_invalid_architecture;

        for (const fs::path& file : files)
        {
            Checks::check_exit(VCPKG_LINE_INFO, file.extension() == ".dll", "The file extension was not .dll: %s", file.generic_string());
            COFFFileReader::DllInfo info = COFFFileReader::read_dll(file);
            const std::string actual_architecture = get_actual_architecture(info.machine_type);

            if (expected_architecture != actual_architecture)
            {
                binaries_with_invalid_architecture.push_back({ file, actual_architecture });
            }
        }

        if (!binaries_with_invalid_architecture.empty())
        {
            print_invalid_architecture_files(expected_architecture, binaries_with_invalid_architecture);
            return LintStatus::ERROR_DETECTED;
        }

        return LintStatus::SUCCESS;
    }

    static LintStatus check_lib_architecture(const std::string& expected_architecture, const std::vector<fs::path>& files)
    {
        std::vector<FileAndArch> binaries_with_invalid_architecture;

        for (const fs::path& file : files)
        {
            Checks::check_exit(VCPKG_LINE_INFO, file.extension() == ".lib", "The file extension was not .lib: %s", file.generic_string());
            COFFFileReader::LibInfo info = COFFFileReader::read_lib(file);
            Checks::check_exit(VCPKG_LINE_INFO, info.machine_types.size() == 1, "Found more than 1 architecture in file %s", file.generic_string());

            const std::string actual_architecture = get_actual_architecture(info.machine_types.at(0));
            if (expected_architecture != actual_architecture)
            {
                binaries_with_invalid_architecture.push_back({ file, actual_architecture });
            }
        }

        if (!binaries_with_invalid_architecture.empty())
        {
            print_invalid_architecture_files(expected_architecture, binaries_with_invalid_architecture);
            return LintStatus::ERROR_DETECTED;
        }

        return LintStatus::SUCCESS;
    }

    static LintStatus check_no_dlls_present(const std::vector<fs::path>& dlls)
    {
        if (dlls.empty())
        {
            return LintStatus::SUCCESS;
        }

        System::println(System::Color::warning, "DLLs should not be present in a static build, but the following DLLs were found:");
        Files::print_paths(dlls);
        return LintStatus::ERROR_DETECTED;
    }

    static LintStatus check_matching_debug_and_release_binaries(const std::vector<fs::path>& debug_binaries, const std::vector<fs::path>& release_binaries)
    {
        const size_t debug_count = debug_binaries.size();
        const size_t release_count = release_binaries.size();
        if (debug_count == release_count)
        {
            return LintStatus::SUCCESS;
        }

        System::println(System::Color::warning, "Mismatching number of debug and release binaries. Found %d for debug but %d for release.", debug_count, release_count);
        System::println("Debug binaries");
        Files::print_paths(debug_binaries);

        System::println("Release binaries");
        Files::print_paths(release_binaries);

        if (debug_count == 0)
        {
            System::println(System::Color::warning, "Debug binaries were not found");
        }
        if (release_count == 0)
        {
            System::println(System::Color::warning, "Release binaries were not found");
        }

        System::println("");

        return LintStatus::ERROR_DETECTED;
    }

    static LintStatus check_lib_files_are_available_if_dlls_are_available(const std::map<BuildPolicies::Type, OptBoolT>& policies, const size_t lib_count, const size_t dll_count, const fs::path& lib_dir)
    {
        auto it = policies.find(BuildPolicies::DLLS_WITHOUT_LIBS);
        if (it != policies.cend() && it->second == OptBoolT::ENABLED)
        {
            return LintStatus::SUCCESS;
        }

        if (lib_count == 0 && dll_count != 0)
        {
            System::println(System::Color::warning, "Import libs were not present in %s", lib_dir.generic_string());
            System::println(System::Color::warning,
                            "If this is intended, add the following line in the portfile:\n"
                            "    SET(%s enabled)", BuildPolicies::DLLS_WITHOUT_LIBS.cmake_variable());
            return LintStatus::ERROR_DETECTED;
        }

        return LintStatus::SUCCESS;
    }

    static LintStatus check_bin_folders_are_not_present_in_static_build(const fs::path& package_dir)
    {
        const fs::path bin = package_dir / "bin";
        const fs::path debug_bin = package_dir / "debug" / "bin";

        if (!fs::exists(bin) && !fs::exists(debug_bin))
        {
            return LintStatus::SUCCESS;
        }

        if (fs::exists(bin))
        {
            System::println(System::Color::warning, R"(There should be no bin\ directory in a static build, but %s is present.)", bin.generic_string());
        }

        if (fs::exists(debug_bin))
        {
            System::println(System::Color::warning, R"(There should be no debug\bin\ directory in a static build, but %s is present.)", debug_bin.generic_string());
        }

        System::println(System::Color::warning, R"(If the creation of bin\ and/or debug\bin\ cannot be disabled, use this in the portfile to remove them)" "\n"
                        "\n"
                        R"###(    if(VCPKG_LIBRARY_LINKAGE STREQUAL static))###""\n"
                        R"###(        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin))###""\n"
                        R"###(    endif())###"
                        "\n"
        );

        return LintStatus::ERROR_DETECTED;
    }

    static LintStatus check_no_empty_folders(const fs::path& dir)
    {
        const std::vector<fs::path> empty_directories = Files::recursive_find_matching_paths_in_dir(dir, [](const fs::path& current)
                                                                                                    {
                                                                                                        return fs::is_directory(current) && fs::is_empty(current);
                                                                                                    });

        if (!empty_directories.empty())
        {
            System::println(System::Color::warning, "There should be no empty directories in %s", dir.generic_string());
            System::println("The following empty directories were found: ");
            Files::print_paths(empty_directories);
            System::println(System::Color::warning, "If a directory should be populated but is not, this might indicate an error in the portfile.\n"
                            "If the directories are not needed and their creation cannot be disabled, use something like this in the portfile to remove them:\n"
                            "\n"
                            R"###(    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/a/dir ${CURRENT_PACKAGES_DIR}/some/other/dir))###""\n"
                            "\n");
            return LintStatus::ERROR_DETECTED;
        }

        return LintStatus::SUCCESS;
    }

    struct BuildType_and_file
    {
        fs::path file;
        BuildType::Type build_type;
    };

    static LintStatus check_crt_linkage_of_libs(const BuildType::Type& expected_build_type, const std::vector<fs::path>& libs, const fs::path dumpbin_exe)
    {
        std::vector<BuildType::Type> bad_build_types(BuildType::values.cbegin(), BuildType::values.cend());
        bad_build_types.erase(std::remove(bad_build_types.begin(), bad_build_types.end(), expected_build_type), bad_build_types.end());

        std::vector<BuildType_and_file> libs_with_invalid_crt;

        for (const fs::path& lib : libs)
        {
            const std::wstring cmd_line = Strings::wformat(LR"("%s" /directives "%s")", dumpbin_exe.native(), lib.native());
            System::ExitCodeAndOutput ec_data = System::cmd_execute_and_capture_output(cmd_line);
            Checks::check_exit(VCPKG_LINE_INFO, ec_data.exit_code == 0, "Running command:\n   %s\n failed", Strings::utf16_to_utf8(cmd_line));

            for (const BuildType::Type& bad_build_type : bad_build_types)
            {
                if (std::regex_search(ec_data.output.cbegin(), ec_data.output.cend(), bad_build_type.crt_regex()))
                {
                    libs_with_invalid_crt.push_back({ lib, bad_build_type });
                    break;
                }
            }
        }

        if (!libs_with_invalid_crt.empty())
        {
            System::println(System::Color::warning, "Expected %s crt linkage, but the following libs had invalid crt linkage:", expected_build_type.to_string());
            System::println("");
            for (const BuildType_and_file btf : libs_with_invalid_crt)
            {
                System::println("    %s: %s", btf.file.generic_string(), btf.build_type.to_string());
            }
            System::println("");

            System::println(System::Color::warning, "To inspect the lib files, use:\n    dumpbin.exe /directives mylibfile.lib");
            return LintStatus::ERROR_DETECTED;
        }

        return LintStatus::SUCCESS;
    }

    struct OutdatedDynamicCrt_and_file
    {
        fs::path file;
        OutdatedDynamicCrt outdated_crt;

        OutdatedDynamicCrt_and_file() = delete;
    };

    static LintStatus check_outdated_crt_linkage_of_dlls(const std::vector<fs::path>& dlls, const fs::path dumpbin_exe)
    {
        const std::vector<OutdatedDynamicCrt>& outdated_crts = get_outdated_dynamic_crts();

        std::vector<OutdatedDynamicCrt_and_file> dlls_with_outdated_crt;

        for (const fs::path& dll : dlls)
        {
            const std::wstring cmd_line = Strings::wformat(LR"("%s" /dependents "%s")", dumpbin_exe.native(), dll.native());
            System::ExitCodeAndOutput ec_data = System::cmd_execute_and_capture_output(cmd_line);
            Checks::check_exit(VCPKG_LINE_INFO, ec_data.exit_code == 0, "Running command:\n   %s\n failed", Strings::utf16_to_utf8(cmd_line));

            for (const OutdatedDynamicCrt& outdated_crt : outdated_crts)
            {
                if (std::regex_search(ec_data.output.cbegin(), ec_data.output.cend(), outdated_crt.regex))
                {
                    dlls_with_outdated_crt.push_back({ dll, outdated_crt });
                    break;
                }
            }
        }

        if (!dlls_with_outdated_crt.empty())
        {
            System::println(System::Color::warning, "Detected outdated dynamic CRT in the following files:");
            System::println("");
            for (const OutdatedDynamicCrt_and_file btf : dlls_with_outdated_crt)
            {
                System::println("    %s: %s", btf.file.generic_string(), btf.outdated_crt.name);
            }
            System::println("");

            System::println(System::Color::warning, "To inspect the dll files, use:\n    dumpbin.exe /dependents mydllfile.dll");
            return LintStatus::ERROR_DETECTED;
        }

        return LintStatus::SUCCESS;
    }

    static LintStatus check_no_files_in_package_dir_and_debug_dir(const fs::path& package_dir)
    {
        std::vector<fs::path> misplaced_files;

        Files::non_recursive_find_matching_paths_in_dir(package_dir, [](const fs::path& current)
                                                        {
                                                            const std::string filename = current.filename().generic_string();
                                                            return !fs::is_directory(current) && !((_stricmp(filename.c_str(), "CONTROL") == 0 || _stricmp(filename.c_str(), "BUILD_INFO") == 0));
                                                        }, &misplaced_files);

        const fs::path debug_dir = package_dir / "debug";
        Files::non_recursive_find_all_files_in_dir(debug_dir, &misplaced_files);

        if (!misplaced_files.empty())
        {
            System::println(System::Color::warning, "The following files are placed in\n%s and\n%s: ", package_dir.generic_string(), debug_dir.generic_string());
            Files::print_paths(misplaced_files);
            System::println(System::Color::warning, "Files cannot be present in those directories.\n");
            return LintStatus::ERROR_DETECTED;
        }

        return LintStatus::SUCCESS;
    }

    static void operator +=(size_t& left, const LintStatus& right)
    {
        left += static_cast<size_t>(right);
    }

    static size_t perform_all_checks_and_return_error_count(const PackageSpec& spec, const VcpkgPaths& paths)
    {
        // for dumpbin
        const Toolset& toolset = paths.get_toolset();

        BuildInfo build_info = read_build_info(paths.get_filesystem(), paths.build_info_file_path(spec));
        const fs::path package_dir = paths.package_dir(spec);

        size_t error_count = 0;

        if (contains_and_enabled(build_info.policies, BuildPolicies::EMPTY_PACKAGE))
        {
            return error_count;
        }

        error_count += check_for_files_in_include_directory(build_info.policies, package_dir);
        error_count += check_for_files_in_debug_include_directory(package_dir);
        error_count += check_for_files_in_debug_share_directory(package_dir);
        error_count += check_folder_lib_cmake(package_dir, spec);
        error_count += check_for_misplaced_cmake_files(package_dir, spec);
        error_count += check_folder_debug_lib_cmake(package_dir);
        error_count += check_for_dlls_in_lib_dirs(package_dir);
        error_count += check_for_copyright_file(spec, paths);
        error_count += check_for_exes(package_dir);

        const fs::path debug_lib_dir = package_dir / "debug" / "lib";
        const fs::path release_lib_dir = package_dir / "lib";
        const fs::path debug_bin_dir = package_dir / "debug" / "bin";
        const fs::path release_bin_dir = package_dir / "bin";

        const std::vector<fs::path> debug_libs = Files::recursive_find_files_with_extension_in_dir(debug_lib_dir, ".lib");
        const std::vector<fs::path> release_libs = Files::recursive_find_files_with_extension_in_dir(release_lib_dir, ".lib");

        error_count += check_matching_debug_and_release_binaries(debug_libs, release_libs);

        std::vector<fs::path> libs;
        libs.insert(libs.cend(), debug_libs.cbegin(), debug_libs.cend());
        libs.insert(libs.cend(), release_libs.cbegin(), release_libs.cend());

        error_count += check_lib_architecture(spec.target_triplet().architecture(), libs);

        switch (build_info.library_linkage)
        {
            case LinkageType::BackingEnum::DYNAMIC:
                {
                    const std::vector<fs::path> debug_dlls = Files::recursive_find_files_with_extension_in_dir(debug_bin_dir, ".dll");
                    const std::vector<fs::path> release_dlls = Files::recursive_find_files_with_extension_in_dir(release_bin_dir, ".dll");

                    error_count += check_matching_debug_and_release_binaries(debug_dlls, release_dlls);

                    error_count += check_lib_files_are_available_if_dlls_are_available(build_info.policies, debug_libs.size(), debug_dlls.size(), debug_lib_dir);
                    error_count += check_lib_files_are_available_if_dlls_are_available(build_info.policies, release_libs.size(), release_dlls.size(), release_lib_dir);

                    std::vector<fs::path> dlls;
                    dlls.insert(dlls.cend(), debug_dlls.cbegin(), debug_dlls.cend());
                    dlls.insert(dlls.cend(), release_dlls.cbegin(), release_dlls.cend());

                    error_count += check_exports_of_dlls(dlls, toolset.dumpbin);
                    error_count += check_uwp_bit_of_dlls(spec.target_triplet().system(), dlls, toolset.dumpbin);
                    error_count += check_dll_architecture(spec.target_triplet().architecture(), dlls);

                    error_count += check_outdated_crt_linkage_of_dlls(dlls, toolset.dumpbin);
                    break;
                }
            case LinkageType::BackingEnum::STATIC:
                {
                    std::vector<fs::path> dlls;
                    Files::recursive_find_files_with_extension_in_dir(package_dir, ".dll", &dlls);
                    error_count += check_no_dlls_present(dlls);

                    error_count += check_bin_folders_are_not_present_in_static_build(package_dir);

                    if (!contains_and_enabled(build_info.policies, BuildPolicies::ONLY_RELEASE_CRT))
                    {
                        error_count += check_crt_linkage_of_libs(BuildType::value_of(ConfigurationType::DEBUG, build_info.crt_linkage), debug_libs, toolset.dumpbin);
                    }
                    error_count += check_crt_linkage_of_libs(BuildType::value_of(ConfigurationType::RELEASE, build_info.crt_linkage), release_libs, toolset.dumpbin);
                    break;
                }
            case LinkageType::BackingEnum::NULLVALUE:
            default:
                Checks::unreachable(VCPKG_LINE_INFO);
        }

        error_count += check_no_empty_folders(package_dir);
        error_count += check_no_files_in_package_dir_and_debug_dir(package_dir);

        return error_count;
    }

    size_t perform_all_checks(const PackageSpec& spec, const VcpkgPaths& paths)
    {
        System::println("-- Performing post-build validation");
        const size_t error_count = perform_all_checks_and_return_error_count(spec, paths);

        if (error_count != 0)
        {
            const fs::path portfile = paths.ports / spec.name() / "portfile.cmake";
            System::println(System::Color::error, "Found %u error(s). Please correct the portfile:\n    %s", error_count, portfile.string());
        }

        System::println("-- Performing post-build validation done");

        return error_count;
    }
}
