#include "pch.h"

#if defined(_WIN32)

#include <vcpkg/base/sortedvector.h>
#include <vcpkg/base/stringrange.h>
#include <vcpkg/base/util.h>
#include <vcpkg/visualstudio.h>

namespace vcpkg::VisualStudio
{
    static constexpr CStringView V_120 = "v120";
    static constexpr CStringView V_140 = "v140";
    static constexpr CStringView V_141 = "v141";
    static constexpr CStringView V_142 = "v142";

    static constexpr std::array<CStringView, 4> preferred_toolsets{V_142, V_141, V_140, V_120};

    static constexpr CStringView cmake_V_120_x86 = "Visual Studio 12 2013";
    static constexpr CStringView cmake_V_120_x64 = "Visual Studio 12 2013 Win64";
    static constexpr CStringView cmake_V_120_ARM = "Visual Studio 12 2013 ARM";

    static constexpr CStringView cmake_V_140_x86 = "Visual Studio 14 2015";
    static constexpr CStringView cmake_V_140_x64 = "Visual Studio 14 2015 Win64";
    static constexpr CStringView cmake_V_140_ARM = "Visual Studio 14 2015 ARM";

    static constexpr CStringView cmake_V_141_x86 = "Visual Studio 15 2017";
    static constexpr CStringView cmake_V_141_x64 = "Visual Studio 15 2017 Win64";
    static constexpr CStringView cmake_V_141_ARM = "Visual Studio 15 2017 ARM";
    static constexpr CStringView cmake_V_141_ARM64 = "Visual Studio 15 2017";

    static constexpr CStringView unknown = "unknown";

    const std::array<CStringView, 4>& get_preferred_toolset_names() noexcept { return preferred_toolsets; }

    struct VisualStudioInstance
    {
        enum class ReleaseType
        {
            STABLE,
            PRERELEASE,
            LEGACY
        };

        static std::string release_type_to_string(const ReleaseType& release_type)
        {
            switch (release_type)
            {
                case ReleaseType::STABLE: return "STABLE";
                case ReleaseType::PRERELEASE: return "PRERELEASE";
                case ReleaseType::LEGACY: return "LEGACY";
                default: Checks::unreachable(VCPKG_LINE_INFO);
            }
        }

        static bool preferred_first_comparator(const VisualStudioInstance& left, const VisualStudioInstance& right)
        {
            const auto get_preference_weight = [](const ReleaseType& type) -> int {
                switch (type)
                {
                    case ReleaseType::STABLE: return 3;
                    case ReleaseType::PRERELEASE: return 2;
                    case ReleaseType::LEGACY: return 1;
                    default: Checks::unreachable(VCPKG_LINE_INFO);
                }
            };

            if (left.release_type != right.release_type)
            {
                return get_preference_weight(left.release_type) > get_preference_weight(right.release_type);
            }

            return left.version > right.version;
        }

        VisualStudioInstance(fs::path&& root_path, std::string&& version, const ReleaseType& release_type)
            : root_path(std::move(root_path)), version(std::move(version)), release_type(release_type)
        {
        }

        fs::path root_path;
        std::string version;
        ReleaseType release_type;

        std::string to_string() const
        {
            return Strings::format("%s, %s, %s", root_path.u8string(), version, release_type_to_string(release_type));
        }

        std::string major_version() const { return version.substr(0, 2); }
    };

    static std::vector<VisualStudioInstance> get_visual_studio_instances_internal(const VcpkgPaths& paths)
    {
        const auto& fs = paths.get_filesystem();
        std::vector<VisualStudioInstance> instances;

        const auto& program_files_32_bit = System::get_program_files_32_bit().value_or_exit(VCPKG_LINE_INFO);

        // Instances from vswhere
        const fs::path vswhere_exe = program_files_32_bit / "Microsoft Visual Studio" / "Installer" / "vswhere.exe";
        if (fs.exists(vswhere_exe))
        {
            const auto code_and_output = System::cmd_execute_and_capture_output(
                Strings::format(R"("%s" -all -prerelease -legacy -products * -format xml)", vswhere_exe.u8string()));
            Checks::check_exit(VCPKG_LINE_INFO,
                               code_and_output.exit_code == 0,
                               "Running vswhere.exe failed with message:\n%s",
                               code_and_output.output);

            const auto instance_entries =
                StringRange::find_all_enclosed(code_and_output.output, "<instance>", "</instance>");
            for (const StringRange& instance : instance_entries)
            {
                auto maybe_is_prerelease =
                    StringRange::find_at_most_one_enclosed(instance, "<isPrerelease>", "</isPrerelease>");

                VisualStudioInstance::ReleaseType release_type = VisualStudioInstance::ReleaseType::LEGACY;
                if (const auto p = maybe_is_prerelease.get())
                {
                    const auto s = p->to_string();
                    if (s == "0")
                        release_type = VisualStudioInstance::ReleaseType::STABLE;
                    else if (s == "1")
                        release_type = VisualStudioInstance::ReleaseType::PRERELEASE;
                    else
                        Checks::unreachable(VCPKG_LINE_INFO);
                }

                instances.emplace_back(
                    StringRange::find_exactly_one_enclosed(instance, "<installationPath>", "</installationPath>")
                        .to_string(),
                    StringRange::find_exactly_one_enclosed(instance, "<installationVersion>", "</installationVersion>")
                        .to_string(),
                    release_type);
            }
        }

        const auto append_if_has_cl = [&](fs::path&& path_root) {
            const auto cl_exe = path_root / "VC" / "bin" / "cl.exe";
            const auto vcvarsall_bat = path_root / "VC" / "vcvarsall.bat";

            if (fs.exists(cl_exe) && fs.exists(vcvarsall_bat))
                instances.emplace_back(std::move(path_root), "14.0", VisualStudioInstance::ReleaseType::LEGACY);
        };

        // VS2015 instance from environment variable
        auto maybe_vs140_comntools = System::get_environment_variable("vs140comntools");
        if (const auto path_as_string = maybe_vs140_comntools.get())
        {
            // We want lexically_normal(), but it is not available
            // Correct root path might be 2 or 3 levels up, depending on if the path has trailing backslash. Try both.
            auto common7_tools = fs::path{*path_as_string};
            append_if_has_cl(fs::path{*path_as_string}.parent_path().parent_path());
            append_if_has_cl(fs::path{*path_as_string}.parent_path().parent_path().parent_path());
        }

        // VS2015 instance from Program Files
        append_if_has_cl(program_files_32_bit / "Microsoft Visual Studio 14.0");

        return instances;
    }

    std::vector<std::string> get_visual_studio_instances(const VcpkgPaths& paths)
    {
        std::vector<VisualStudioInstance> sorted{get_visual_studio_instances_internal(paths)};
        std::sort(sorted.begin(), sorted.end(), VisualStudioInstance::preferred_first_comparator);
        return Util::fmap(sorted, [](const VisualStudioInstance& instance) { return instance.to_string(); });
    }

    std::vector<Toolset> find_toolset_instances_preferred_first(const VcpkgPaths& paths)
    {
        using CPU = System::CPUArchitecture;

        const auto& fs = paths.get_filesystem();

        // Note: this will contain a mix of vcvarsall.bat locations and dumpbin.exe locations.
        std::vector<fs::path> paths_examined;

        std::vector<Toolset> found_toolsets;
        std::vector<Toolset> excluded_toolsets;

        const SortedVector<VisualStudioInstance> sorted{get_visual_studio_instances_internal(paths),
                                                        VisualStudioInstance::preferred_first_comparator};

        const bool v140_is_available = Util::find_if(sorted, [&](const VisualStudioInstance& vs_instance) {
                                           return vs_instance.major_version() == "14";
                                       }) != sorted.end();

        for (const VisualStudioInstance& vs_instance : sorted)
        {
            const std::string major_version = vs_instance.major_version();
            if (major_version >= "15")
            {
                const fs::path vc_dir = vs_instance.root_path / "VC";

                // Skip any instances that do not have vcvarsall.
                const fs::path vcvarsall_dir = vc_dir / "Auxiliary" / "Build";
                const fs::path vcvarsall_bat = vcvarsall_dir / "vcvarsall.bat";
                paths_examined.push_back(vcvarsall_bat);
                if (!fs.exists(vcvarsall_bat)) continue;

                // Get all supported architectures
                std::vector<ArchOption> supported_architectures;
                if (fs.exists(vcvarsall_dir / "vcvars32.bat"))
                    supported_architectures.push_back({"x86", CPU::X86, CPU::X86});
                if (fs.exists(vcvarsall_dir / "vcvars64.bat"))
                    supported_architectures.push_back({"amd64", CPU::X64, CPU::X64});
                if (fs.exists(vcvarsall_dir / "vcvarsx86_amd64.bat"))
                    supported_architectures.push_back({"x86_amd64", CPU::X86, CPU::X64});
                if (fs.exists(vcvarsall_dir / "vcvarsx86_arm.bat"))
                    supported_architectures.push_back({"x86_arm", CPU::X86, CPU::ARM});
                if (fs.exists(vcvarsall_dir / "vcvarsx86_arm64.bat"))
                    supported_architectures.push_back({"x86_arm64", CPU::X86, CPU::ARM64});
                if (fs.exists(vcvarsall_dir / "vcvarsamd64_x86.bat"))
                    supported_architectures.push_back({"amd64_x86", CPU::X64, CPU::X86});
                if (fs.exists(vcvarsall_dir / "vcvarsamd64_arm.bat"))
                    supported_architectures.push_back({"amd64_arm", CPU::X64, CPU::ARM});
                if (fs.exists(vcvarsall_dir / "vcvarsamd64_arm64.bat"))
                    supported_architectures.push_back({"amd64_arm64", CPU::X64, CPU::ARM64});

                // Discover available platform toolsets
                for (ArchOption& arch : supported_architectures)
                {
                    const auto vs_arch = [](const ArchOption& arch) noexcept
                    {
                        switch (arch.target_arch)
                        {
                            case CPU::X86: return "Win32";
                            case CPU::X64: return "x64";
                            case CPU::ARM: return "ARM";
                            case CPU::ARM64: return "ARM64";
                            default: return unknown.c_str(); //<- Please update if you see that;
                        };
                    };
                    const auto vs15_cmake = [](const ArchOption& arch) noexcept
                    {
                        switch (arch.target_arch)
                        {
                            case CPU::X86: return cmake_V_141_x86;
                            case CPU::X64: return cmake_V_141_x64;
                            case CPU::ARM: return cmake_V_141_ARM;
                            case CPU::ARM64: return cmake_V_141_ARM64;
                            default: return unknown; //<- Please update if you see that;
                        };
                    };

                    const fs::path platformpath = vs_instance.root_path / "Common7" / "IDE" / "VC" / "VCTargets" /
                                                  "Platforms" / vs_arch(arch) / "PlatformToolsets";
                    if (fs.exists(platformpath))
                    {
                        std::vector<fs::path> platformsubdirs = fs.get_files_non_recursive(platformpath);
                        Util::erase_remove_if(platformsubdirs,
                                               [&fs](const fs::path& path) { return !fs.is_directory(path); });

                        for (const fs::path& platform : platformsubdirs)
                        {
                            const auto tmp = platform.filename();
                            const ToolsetMinimal Toolmin{tmp.u8string(), major_version, vs15_cmake(arch).c_str()};
                            arch.supported_toolsets.push_back(Toolmin);
                        }
                    }
                }

                // Locate the "best" MSVC toolchain version
                const fs::path msvc_path = vc_dir / "Tools" / "MSVC";
                std::vector<fs::path> msvc_subdirectories = fs.get_files_non_recursive(msvc_path);
                Util::erase_remove_if(msvc_subdirectories,
                                      [&fs](const fs::path& path) { return !fs.is_directory(path); });

                // Sort them so that latest comes first
                std::sort(
                    msvc_subdirectories.begin(),
                    msvc_subdirectories.end(),
                    [](const fs::path& left, const fs::path& right) { return left.filename() > right.filename(); });

                for (const fs::path& subdir : msvc_subdirectories)
                {
//<<<<<<< HEAD
                    auto toolset_version_full = subdir.filename().u8string();
                    auto toolset_version_prefix = toolset_version_full.substr(0, 4);
                    CStringView toolset_version;
                    std::string vcvars_option;
                    if (toolset_version_prefix.size() != 4)
                    {
                        // unknown toolset
                        continue;
                    }
                    else if (toolset_version_prefix[3] == '1')
                    {
                        toolset_version = V_141;
                        vcvars_option = "-vcvars_ver=14.1";
                    }
                    else if (toolset_version_prefix[3] == '2')
                    {
                        toolset_version = V_142;
                        vcvars_option = "-vcvars_ver=14.2";
                    }
                    else
                    {
                        // unknown toolset minor version
                        continue;
                    }
//                    const fs::path dumpbin_path = subdir / "bin" / "HostX86" / "x86" / "dumpbin.exe";
//                    paths_examined.push_back(dumpbin_path);
//                    if (fs.exists(dumpbin_path))
//                    {
//                        Toolset toolset{vs_instance.root_path,
//                                        dumpbin_path,
//                                        vcvarsall_bat,
//                                        {vcvars_option},
//                                        toolset_version,
//                                        supported_architectures};
//
//                        const auto english_language_pack = dumpbin_path.parent_path() / "1033";
//=======
                    for (const ArchOption& arch : supported_architectures)
                    {
                        const std::string Host_arch = "Host" + System::to_string(arch.host_arch);
                        const fs::path dumpbin_path = subdir / "bin" / Host_arch.c_str() /
                                                      System::to_string(arch.target_arch).c_str() / "dumpbin.exe";
//>>>>>>> Allows vcpkg to compile cmake ports with all installed costum toolset. (Only VS2017)

                        paths_examined.push_back(dumpbin_path);
                        if (fs.exists(dumpbin_path))
                        {
//<<<<<<< HEAD
//                            excluded_toolsets.push_back(std::move(toolset));
//                            continue;
//                        }
//
//                        found_toolsets.push_back(std::move(toolset));
//

//
//                        continue;
//=======
                            for (const ToolsetMinimal& MinTool : arch.supported_toolsets)
                            {
                                const auto english_language_pack = dumpbin_path.parent_path() / "1033";
                                const bool english_language_pack_available = fs.exists(english_language_pack);

                                if (v140_is_available)
                                {
                                    const Toolset toolset{vs_instance.root_path,
                                                          dumpbin_path,
                                                          vcvarsall_bat,
                                                          {"-vcvars_ver=14.0"},
                                                          MinTool.name,
                                                          MinTool.vsversion,
                                                          MinTool.cmake_generator,
                                                          arch};
                                    found_toolsets.push_back(toolset);
                                    if (!english_language_pack_available)
                                    {
                                        excluded_toolsets.push_back(toolset);
                                        break;
                                    }
                                }

                                const Toolset toolset{vs_instance.root_path,
                                                      dumpbin_path,
                                                      vcvarsall_bat,
                                                      {vcvars_option},
                                                      MinTool.name,
                                                      MinTool.vsversion,
                                                      MinTool.cmake_generator,
                                                      arch};                                

                                if (!english_language_pack_available)
                                {
                                    excluded_toolsets.push_back(toolset);
                                    break;
                                }

                                found_toolsets.push_back(toolset);
                            }
                        }
//>>>>>>> Allows vcpkg to compile cmake ports with all installed costum toolset. (Only VS2017)
                    }
                }
            }

            if (major_version == "14" || major_version == "12")
            {
                const fs::path vcvarsall_bat = vs_instance.root_path / "VC" / "vcvarsall.bat";

                paths_examined.push_back(vcvarsall_bat);
                if (fs.exists(vcvarsall_bat))
                {
                    const fs::path vs_dumpbin_exe = vs_instance.root_path / "VC" / "bin" / "dumpbin.exe";
                    paths_examined.push_back(vs_dumpbin_exe);

                    const fs::path vs_bin_dir = vcvarsall_bat.parent_path() / "bin";
                    std::vector<ArchOption> supported_architectures;
                    if (fs.exists(vs_bin_dir / "vcvars32.bat"))
                        supported_architectures.push_back({"x86", CPU::X86, CPU::X86});
                    if (fs.exists(vs_bin_dir / "amd64\\vcvars64.bat"))
                        supported_architectures.push_back({"x64", CPU::X64, CPU::X64});
                    if (fs.exists(vs_bin_dir / "x86_amd64\\vcvarsx86_amd64.bat"))
                        supported_architectures.push_back({"x86_amd64", CPU::X86, CPU::X64});
                    if (fs.exists(vs_bin_dir / "x86_arm\\vcvarsx86_arm.bat"))
                        supported_architectures.push_back({"x86_arm", CPU::X86, CPU::ARM});
                    if (fs.exists(vs_bin_dir / "amd64_x86\\vcvarsamd64_x86.bat"))
                        supported_architectures.push_back({"amd64_x86", CPU::X64, CPU::X86});
                    if (fs.exists(vs_bin_dir / "amd64_arm\\vcvarsamd64_arm.bat"))
                        supported_architectures.push_back({"amd64_arm", CPU::X64, CPU::ARM});

                    if (fs.exists(vs_dumpbin_exe))
                    {
                        for (const auto& arch : supported_architectures)
                        {
                            const bool is_vs_14{major_version == "14"};
                            const auto vs12or14_cmake = [&is_vs_14](const ArchOption& arch) noexcept
                            {
                                switch (arch.target_arch)
                                {
                                    case CPU::X86: return is_vs_14 ? cmake_V_140_x86 : cmake_V_120_x86;
                                    case CPU::X64: return is_vs_14 ? cmake_V_140_x64 : cmake_V_120_x64;
                                    case CPU::ARM: return is_vs_14 ? cmake_V_140_ARM : cmake_V_120_ARM;
                                    default: return unknown; //<- Please update if you see that;
                                };
                            };

                            const Toolset toolset = {vs_instance.root_path,
                                                     vs_dumpbin_exe,
                                                     vcvarsall_bat,
                                                     {},
                                                     is_vs_14 ? V_140.c_str() : V_120.c_str(),
                                                     major_version,
                                                     vs12or14_cmake(arch).c_str(),
                                                     arch};

                            const auto english_language_pack = vs_dumpbin_exe.parent_path() / "1033";

                            if (!fs.exists(english_language_pack))
                            {
                                excluded_toolsets.push_back(toolset);
                                break;
                            }

                            found_toolsets.push_back(toolset);
                        }
                    }
                }
            }
        }

        if (!excluded_toolsets.empty())
        {
            System::println(
                System::Color::warning,
                "Warning: The following VS instances are excluded because the English language pack is unavailable.");
            for (const Toolset& toolset : excluded_toolsets)
            {
                System::println("    %s", toolset.visual_studio_root_path.u8string());
            }
            System::println(System::Color::warning, "Please install the English language pack.");
        }

        if (found_toolsets.empty())
        {
            System::println(System::Color::error, "Could not locate a complete toolset.");
            System::println("The following paths were examined:");
            for (const fs::path& path : paths_examined)
            {
                System::println("    %s", path.u8string());
            }
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        return found_toolsets;
    }
}

#endif
