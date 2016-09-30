#include <filesystem>
#include "vcpkg_paths.h"
#include "package_spec.h"
#include <iterator>
#include <functional>
#include "vcpkg_System.h"

namespace fs = std::tr2::sys;

namespace vcpkg
{
    enum class lint_status
    {
        SUCCESS = 0,
        ERROR = 1
    };

    static const fs::path DUMPBIN_EXE = R"(%VS140COMNTOOLS%\..\..\VC\bin\dumpbin.exe)";

    namespace
    {
        void print_vector_of_files(const std::vector<fs::path>& paths)
        {
            System::println("");
            for (const fs::path& p : paths)
            {
                System::println("    %s", p.generic_string());
            }
            System::println("");
        }

        template <class Pred>
        void recursive_find_matching_paths_in_dir(const fs::path& dir, const Pred predicate, std::vector<fs::path>& output)
        {
            std::copy_if(fs::recursive_directory_iterator(dir), fs::recursive_directory_iterator(), std::back_inserter(output), predicate);
        }

        void recursive_find_files_with_extension_in_dir(const fs::path& dir, const std::string& extension, std::vector<fs::path>& output)
        {
            recursive_find_matching_paths_in_dir(dir, [&extension](const fs::path& current)
                                                 {
                                                     return !fs::is_directory(current) && current.extension() == extension;
                                                 }, output);
        }
    }

    static lint_status check_for_files_in_include_directory(const package_spec& spec, const vcpkg_paths& paths)
    {
        const fs::path include_dir = paths.packages / spec.dir() / "include";
        if (!fs::exists(include_dir) || fs::is_empty(include_dir))
        {
            System::println(System::color::warning, "The folder /include is empty. This indicates the library was not correctly installed.");
            return lint_status::ERROR;
        }

        return lint_status::SUCCESS;
    }

    static lint_status check_for_files_in_debug_include_directory(const package_spec& spec, const vcpkg_paths& paths)
    {
        const fs::path debug_include_dir = paths.packages / spec.dir() / "debug" / "include";
        std::vector<fs::path> files_found;

        recursive_find_matching_paths_in_dir(debug_include_dir, [&](const fs::path& current)
                                             {
                                                 return !fs::is_directory(current) && current.extension() != ".ifc";
                                             }, files_found);

        if (!files_found.empty())
        {
            System::println(System::color::warning, "Include files should not be duplicated into the /debug/include directory. If this cannot be disabled in the project cmake, use\n"
                            "    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)"
            );
            return lint_status::ERROR;
        }

        return lint_status::SUCCESS;
    }

    static lint_status check_for_files_in_debug_share_directory(const package_spec& spec, const vcpkg_paths& paths)
    {
        const fs::path debug_share = paths.packages / spec.dir() / "debug" / "share";

        if (fs::exists(debug_share) && !fs::is_empty(debug_share))
        {
            System::println(System::color::warning, "No files should be present in /debug/share");
            return lint_status::ERROR;
        }

        return lint_status::SUCCESS;
    }

    static lint_status check_folder_lib_cmake(const package_spec& spec, const vcpkg_paths& paths)
    {
        const fs::path lib_cmake = paths.packages / spec.dir() / "lib" / "cmake";
        if (fs::exists(lib_cmake))
        {
            System::println(System::color::warning, "The /lib/cmake folder should be moved to just /cmake");
            return lint_status::ERROR;
        }

        return lint_status::SUCCESS;
    }

    static lint_status check_for_misplaced_cmake_files(const package_spec& spec, const vcpkg_paths& paths)
    {
        const fs::path current_packages_dir = paths.packages / spec.dir();
        std::vector<fs::path> misplaced_cmake_files;
        recursive_find_files_with_extension_in_dir(current_packages_dir / "cmake", ".cmake", misplaced_cmake_files);
        recursive_find_files_with_extension_in_dir(current_packages_dir / "debug" / "cmake", ".cmake", misplaced_cmake_files);
        recursive_find_files_with_extension_in_dir(current_packages_dir / "lib" / "cmake", ".cmake", misplaced_cmake_files);
        recursive_find_files_with_extension_in_dir(current_packages_dir / "debug" / "lib" / "cmake", ".cmake", misplaced_cmake_files);

        if (!misplaced_cmake_files.empty())
        {
            System::println(System::color::warning, "The following cmake files were found outside /share/%s. Please place cmake files in /share/%s.", spec.name, spec.name);
            print_vector_of_files(misplaced_cmake_files);
            return lint_status::ERROR;
        }

        return lint_status::SUCCESS;
    }

    static lint_status check_folder_debug_lib_cmake(const package_spec& spec, const vcpkg_paths& paths)
    {
        const fs::path lib_cmake_debug = paths.packages / spec.dir() / "debug" / "lib" / "cmake";
        if (fs::exists(lib_cmake_debug))
        {
            System::println(System::color::warning, "The /debug/lib/cmake folder should be moved to just /debug/cmake");
            return lint_status::ERROR;
        }

        return lint_status::SUCCESS;
    }

    static lint_status check_for_dlls_in_lib_dirs(const package_spec& spec, const vcpkg_paths& paths)
    {
        std::vector<fs::path> dlls;
        recursive_find_files_with_extension_in_dir(paths.packages / spec.dir() / "lib", ".dll", dlls);
        recursive_find_files_with_extension_in_dir(paths.packages / spec.dir() / "debug" / "lib", ".dll", dlls);

        if (!dlls.empty())
        {
            System::println(System::color::warning, "\nThe following dlls were found in /lib and /debug/lib. Please move them to /bin or /debug/bin, respectively.");
            print_vector_of_files(dlls);
            return lint_status::ERROR;
        }

        return lint_status::SUCCESS;
    }

    static lint_status check_for_copyright_file(const package_spec& spec, const vcpkg_paths& paths)
    {
        const fs::path copyright_file = paths.packages / spec.dir() / "share" / spec.name / "copyright";
        if (fs::exists(copyright_file))
        {
            return lint_status::SUCCESS;
        }
        const fs::path current_buildtrees_dir = paths.buildtrees / spec.name;
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

        System::println(System::color::warning, "The software license must be available at ${CURRENT_PACKAGES_DIR}/share/%s/copyright .", spec.name);
        if (potential_copyright_files.size() == 1) // if there is only one candidate, provide the cmake lines needed to place it in the proper location
        {
            const fs::path found_file = potential_copyright_files[0];
            const fs::path relative_path = found_file.string().erase(0, current_buildtrees_dir.string().size() + 1); // The +1 is needed to remove the "/"
            System::println("\n    file(COPY ${CURRENT_BUILDTREES_DIR}/%s DESTINATION ${CURRENT_PACKAGES_DIR}/share/%s)\n"
                            "    file(RENAME ${CURRENT_PACKAGES_DIR}/share/%s/%s ${CURRENT_PACKAGES_DIR}/share/%s/copyright)",
                            relative_path.generic_string(), spec.name, spec.name, found_file.filename().generic_string(), spec.name);
            return lint_status::ERROR;
        }

        if (potential_copyright_files.size() > 1)
        {
            System::println(System::color::warning, "The following files are potential copyright files:");
            print_vector_of_files(potential_copyright_files);
        }

        const fs::path current_packages_dir = paths.packages / spec.dir();
        System::println("    %s/share/%s/copyright", current_packages_dir.generic_string(), spec.name);

        return lint_status::ERROR;
    }

    static lint_status check_for_exes(const package_spec& spec, const vcpkg_paths& paths)
    {
        std::vector<fs::path> exes;
        recursive_find_files_with_extension_in_dir(paths.packages / spec.dir() / "bin", ".exe", exes);
        recursive_find_files_with_extension_in_dir(paths.packages / spec.dir() / "debug" / "bin", ".exe", exes);

        if (!exes.empty())
        {
            System::println(System::color::warning, "The following EXEs were found in /bin and /debug/bin. EXEs are not valid distribution targets.");
            print_vector_of_files(exes);
            return lint_status::ERROR;
        }

        return lint_status::SUCCESS;
    }

    static lint_status check_exports_of_dlls(const std::vector<fs::path>& dlls)
    {
        std::vector<fs::path> dlls_with_no_exports;
        for (const fs::path& dll : dlls)
        {
            const std::wstring cmd_line = Strings::wformat(LR"("%s" /exports "%s")", DUMPBIN_EXE.native(), dll.native());
            System::exit_code_and_output ec_data = System::cmd_execute_and_capture_output(cmd_line);
            Checks::check_exit(ec_data.exit_code == 0, "Running command:\n   %s\n failed", Strings::utf16_to_utf8(cmd_line));

            if (ec_data.output.find("ordinal hint RVA      name") == std::string::npos)
            {
                dlls_with_no_exports.push_back(dll);
            }
        }

        if (!dlls_with_no_exports.empty())
        {
            System::println(System::color::warning, "The following DLLs have no exports:");
            print_vector_of_files(dlls_with_no_exports);
            System::println(System::color::warning, "DLLs without any exports are likely a bug in the build script.");
            return lint_status::ERROR;
        }

        return lint_status::SUCCESS;
    }

    static lint_status check_uwp_bit_of_dlls(const std::string& expected_system_name, const std::vector<fs::path>& dlls)
    {
        if (expected_system_name != "uwp")
        {
            return lint_status::SUCCESS;
        }

        std::vector<fs::path> dlls_with_improper_uwp_bit;
        for (const fs::path& dll : dlls)
        {
            const std::wstring cmd_line = Strings::wformat(LR"("%s" /headers "%s")", DUMPBIN_EXE.native(), dll.native());
            System::exit_code_and_output ec_data = System::cmd_execute_and_capture_output(cmd_line);
            Checks::check_exit(ec_data.exit_code == 0, "Running command:\n   %s\n failed", Strings::utf16_to_utf8(cmd_line));

            if (ec_data.output.find("App Container") == std::string::npos)
            {
                dlls_with_improper_uwp_bit.push_back(dll);
            }
        }

        if (!dlls_with_improper_uwp_bit.empty())
        {
            System::println(System::color::warning, "The following DLLs do not have the App Container bit set:");
            print_vector_of_files(dlls_with_improper_uwp_bit);
            System::println(System::color::warning, "This bit is required for Windows Store apps.");
            return lint_status::ERROR;
        }

        return lint_status::SUCCESS;
    }

    struct file_and_arch
    {
        fs::path file;
        std::string actual_arch;
    };

    static lint_status check_architecture(const std::string& expected_architecture, const std::vector<fs::path>& files)
    {
        std::vector<file_and_arch> binaries_with_invalid_architecture;
        for (const fs::path& f : files)
        {
            const std::wstring cmd_line = Strings::wformat(LR"("%s" /headers "%s" | findstr machine)", DUMPBIN_EXE.native(), f.native());
            System::exit_code_and_output ec_data = System::cmd_execute_and_capture_output(cmd_line);
            Checks::check_exit(ec_data.exit_code == 0, "Running command:\n   %s\n failed", Strings::utf16_to_utf8(cmd_line));

            if (Strings::case_insensitive_find(ec_data.output, expected_architecture) == ec_data.output.end())
            {
                binaries_with_invalid_architecture.push_back({f, ec_data.output});
            }
        }

        if (!binaries_with_invalid_architecture.empty())
        {
            System::println(System::color::warning, "The following files were built for an incorrect architecture:");
            System::println("");
            for (const file_and_arch& b : binaries_with_invalid_architecture)
            {
                System::println("    %s", b.file.generic_string());
                System::println("Expected %s, but was:\n %s", expected_architecture, b.actual_arch);
            }
            System::println("");

            return lint_status::ERROR;
        }

        return lint_status::SUCCESS;
    }

    static void operator +=(unsigned int& left, const lint_status& right)
    {
        left += static_cast<unsigned int>(right);
    }

    void perform_all_checks(const package_spec& spec, const vcpkg_paths& paths)
    {
        System::println("-- Performing post-build validation");
        unsigned int error_count = 0;
        error_count += check_for_files_in_include_directory(spec, paths);
        error_count += check_for_files_in_debug_include_directory(spec, paths);
        error_count += check_for_files_in_debug_share_directory(spec, paths);
        error_count += check_folder_lib_cmake(spec, paths);
        error_count += check_for_misplaced_cmake_files(spec, paths);
        error_count += check_folder_debug_lib_cmake(spec, paths);
        error_count += check_for_dlls_in_lib_dirs(spec, paths);
        error_count += check_for_copyright_file(spec, paths);
        error_count += check_for_exes(spec, paths);

        std::vector<fs::path> dlls;
        recursive_find_files_with_extension_in_dir(paths.packages / spec.dir() / "bin", ".dll", dlls);
        recursive_find_files_with_extension_in_dir(paths.packages / spec.dir() / "debug" / "bin", ".dll", dlls);

        error_count += check_exports_of_dlls(dlls);
        error_count += check_uwp_bit_of_dlls(spec.target_triplet.system(), dlls);
        error_count += check_architecture(spec.target_triplet.architecture(), dlls);

        std::vector<fs::path> libs;
        recursive_find_files_with_extension_in_dir(paths.packages / spec.dir() / "lib", ".lib", libs);
        recursive_find_files_with_extension_in_dir(paths.packages / spec.dir() / "debug" / "lib", ".lib", libs);

        error_count += check_architecture(spec.target_triplet.architecture(), libs);

        if (error_count != 0)
        {
            const fs::path portfile = paths.ports / spec.name / "portfile.cmake";
            System::println(System::color::error, "Found %d error(s). Please correct the portfile:\n    %s", error_count, portfile.string());
            exit(EXIT_FAILURE);
        }

        System::println("-- Performing post-build validation done");
    }
}
