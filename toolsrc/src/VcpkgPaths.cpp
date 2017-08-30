#include "pch.h"

#include "PackageSpec.h"
#include "VcpkgPaths.h"
#include "metrics.h"
#include "vcpkg_Files.h"
#include "vcpkg_System.h"
#include "vcpkg_Util.h"
#include "vcpkg_expected.h"

namespace vcpkg
{
    static std::string WORKAROUND_ISSUE_1712(const std::string& line)
    {
        auto colon_pos = line.find(':');
        if (colon_pos != std::string::npos && colon_pos > 0)
        {
            return line.substr(colon_pos - 1);
        }
        return line;
    }

    static bool exists_and_has_equal_or_greater_version(const std::wstring& version_cmd,
                                                        const std::array<int, 3>& expected_version)
    {
        static const std::regex re(R"###((\d+)\.(\d+)\.(\d+))###");

        auto rc = System::cmd_execute_and_capture_output(Strings::wformat(LR"(%s)", version_cmd));
        if (rc.exit_code != 0)
        {
            return false;
        }

        std::match_results<std::string::const_iterator> match;
        auto found = std::regex_search(rc.output, match, re);
        if (!found)
        {
            return false;
        }

        int d1 = atoi(match[1].str().c_str());
        int d2 = atoi(match[2].str().c_str());
        int d3 = atoi(match[3].str().c_str());
        if (d1 > expected_version[0] || (d1 == expected_version[0] && d2 > expected_version[1]) ||
            (d1 == expected_version[0] && d2 == expected_version[1] && d3 >= expected_version[2]))
        {
            // satisfactory version found
            return true;
        }

        return false;
    }

    static Optional<fs::path> find_if_has_equal_or_greater_version(const std::vector<fs::path>& candidate_paths,
                                                                   const std::wstring& version_check_arguments,
                                                                   const std::array<int, 3>& expected_version)
    {
        auto it = Util::find_if(candidate_paths, [&](const fs::path& p) {
            const std::wstring cmd = Strings::wformat(LR"("%s" %s)", p.native(), version_check_arguments);
            return exists_and_has_equal_or_greater_version(cmd, expected_version);
        });

        if (it != candidate_paths.cend())
        {
            return std::move(*it);
        }

        return nullopt;
    }

    static std::vector<fs::path> find_from_PATH(const std::wstring& name)
    {
        const std::wstring cmd = Strings::wformat(L"where.exe %s", name);
        auto out = System::cmd_execute_and_capture_output(cmd);
        if (out.exit_code != 0)
        {
            return {};
        }

        return Util::fmap(Strings::split(out.output, "\n"), [](auto&& s) { return fs::path(s); });
    }

    static fs::path fetch_dependency(const fs::path& scripts_folder,
                                     const std::wstring& tool_name,
                                     const fs::path& expected_downloaded_path,
                                     const std::array<int, 3>& version)
    {
        const fs::path script = scripts_folder / "fetchDependency.ps1";
        auto install_cmd = System::create_powershell_script_cmd(script, Strings::wformat(L"-Dependency %s", tool_name));
        System::ExitCodeAndOutput rc = System::cmd_execute_and_capture_output(install_cmd);
        if (rc.exit_code)
        {
            const std::string version_as_string = Strings::format("%d.%d.%d", version[0], version[1], version[2]);

            System::println(System::Color::error,
                            "Launching powershell failed or was denied when trying to fetch %s version %s.\n"
                            "(No sufficient installed version was found)",
                            Strings::to_utf8(tool_name),
                            version_as_string);
            {
                auto locked_metrics = Metrics::g_metrics.lock();
                locked_metrics->track_property("error", "powershell install failed");
                locked_metrics->track_property("dependency", tool_name);
            }
            Checks::exit_with_code(VCPKG_LINE_INFO, rc.exit_code);
        }

        const fs::path actual_downloaded_path = WORKAROUND_ISSUE_1712(Strings::trimmed(rc.output));
        std::error_code ec;
        auto eq = fs::stdfs::equivalent(expected_downloaded_path, actual_downloaded_path, ec);
        Checks::check_exit(VCPKG_LINE_INFO,
                           eq && !ec,
                           "Expected dependency downloaded path to be %s, but was %s",
                           expected_downloaded_path.u8string(),
                           actual_downloaded_path.u8string());
        return actual_downloaded_path;
    }

    static fs::path get_cmake_path(const fs::path& downloads_folder, const fs::path& scripts_folder)
    {
        static constexpr std::array<int, 3> expected_version = {3, 9, 1};
        static const std::wstring version_check_arguments = L"--version";

        const fs::path downloaded_copy = downloads_folder / "cmake-3.9.1-win32-x86" / "bin" / "cmake.exe";
        const std::vector<fs::path> from_path = find_from_PATH(L"cmake");

        std::vector<fs::path> candidate_paths;
        candidate_paths.push_back(downloaded_copy);
        candidate_paths.insert(candidate_paths.end(), from_path.cbegin(), from_path.cend());
        candidate_paths.push_back(System::get_ProgramFiles_platform_bitness() / "CMake" / "bin" / "cmake.exe");
        candidate_paths.push_back(System::get_ProgramFiles_32_bit() / "CMake" / "bin");

        const Optional<fs::path> path =
            find_if_has_equal_or_greater_version(candidate_paths, version_check_arguments, expected_version);
        if (auto p = path.get())
        {
            return *p;
        }

        return fetch_dependency(scripts_folder, L"cmake", downloaded_copy, expected_version);
    }

    fs::path get_nuget_path(const fs::path& downloads_folder, const fs::path& scripts_folder)
    {
        static constexpr std::array<int, 3> expected_version = {4, 1, 0};
        static const std::wstring version_check_arguments = Strings::WEMPTY;

        const fs::path downloaded_copy = downloads_folder / "nuget-4.1.0" / "nuget.exe";
        const std::vector<fs::path> from_path = find_from_PATH(L"nuget");

        std::vector<fs::path> candidate_paths;
        candidate_paths.push_back(downloaded_copy);
        candidate_paths.insert(candidate_paths.end(), from_path.cbegin(), from_path.cend());

        auto path = find_if_has_equal_or_greater_version(candidate_paths, version_check_arguments, expected_version);
        if (auto p = path.get())
        {
            return *p;
        }

        return fetch_dependency(scripts_folder, L"nuget", downloaded_copy, expected_version);
    }

    fs::path get_git_path(const fs::path& downloads_folder, const fs::path& scripts_folder)
    {
        static constexpr std::array<int, 3> expected_version = {2, 14, 1};
        static const std::wstring version_check_arguments = L"--version";

        const fs::path downloaded_copy = downloads_folder / "MinGit-2.14.1-32-bit" / "cmd" / "git.exe";
        const std::vector<fs::path> from_path = find_from_PATH(L"git");

        std::vector<fs::path> candidate_paths;
        candidate_paths.push_back(downloaded_copy);
        candidate_paths.insert(candidate_paths.end(), from_path.cbegin(), from_path.cend());
        candidate_paths.push_back(System::get_ProgramFiles_platform_bitness() / "git" / "cmd" / "git.exe");
        candidate_paths.push_back(System::get_ProgramFiles_32_bit() / "git" / "cmd" / "git.exe");

        const Optional<fs::path> path =
            find_if_has_equal_or_greater_version(candidate_paths, version_check_arguments, expected_version);
        if (auto p = path.get())
        {
            return *p;
        }

        return fetch_dependency(scripts_folder, L"git", downloaded_copy, expected_version);
    }

    Expected<VcpkgPaths> VcpkgPaths::create(const fs::path& vcpkg_root_dir)
    {
        std::error_code ec;
        const fs::path canonical_vcpkg_root_dir = fs::stdfs::canonical(vcpkg_root_dir, ec);
        if (ec)
        {
            return ec;
        }

        VcpkgPaths paths;
        paths.root = canonical_vcpkg_root_dir;

        if (paths.root.empty())
        {
            Metrics::g_metrics.lock()->track_property("error", "Invalid vcpkg root directory");
            Checks::exit_with_message(VCPKG_LINE_INFO, "Invalid vcpkg root directory: %s", paths.root.string());
        }

        paths.packages = paths.root / "packages";
        paths.buildtrees = paths.root / "buildtrees";
        paths.downloads = paths.root / "downloads";
        paths.ports = paths.root / "ports";
        paths.installed = paths.root / "installed";
        paths.triplets = paths.root / "triplets";
        paths.scripts = paths.root / "scripts";

        paths.buildsystems = paths.scripts / "buildsystems";
        paths.buildsystems_msbuild_targets = paths.buildsystems / "msbuild" / "vcpkg.targets";

        paths.vcpkg_dir = paths.installed / "vcpkg";
        paths.vcpkg_dir_status_file = paths.vcpkg_dir / "status";
        paths.vcpkg_dir_info = paths.vcpkg_dir / "info";
        paths.vcpkg_dir_updates = paths.vcpkg_dir / "updates";

        paths.ports_cmake = paths.scripts / "ports.cmake";

        return paths;
    }

    fs::path VcpkgPaths::package_dir(const PackageSpec& spec) const { return this->packages / spec.dir(); }

    fs::path VcpkgPaths::port_dir(const PackageSpec& spec) const { return this->ports / spec.name(); }
    fs::path VcpkgPaths::port_dir(const std::string& name) const { return this->ports / name; }

    fs::path VcpkgPaths::build_info_file_path(const PackageSpec& spec) const
    {
        return this->package_dir(spec) / "BUILD_INFO";
    }

    fs::path VcpkgPaths::listfile_path(const BinaryParagraph& pgh) const
    {
        return this->vcpkg_dir_info / (pgh.fullstem() + ".list");
    }

    bool VcpkgPaths::is_valid_triplet(const Triplet& t) const
    {
        for (auto&& path : get_filesystem().get_files_non_recursive(this->triplets))
        {
            std::string triplet_file_name = path.stem().generic_u8string();
            if (t.canonical_name() == triplet_file_name) // TODO: fuzzy compare
            {
                // t.value = triplet_file_name; // NOTE: uncomment when implementing fuzzy compare
                return true;
            }
        }
        return false;
    }

    const fs::path& VcpkgPaths::get_cmake_exe() const
    {
        return this->cmake_exe.get_lazy([this]() { return get_cmake_path(this->downloads, this->scripts); });
    }

    const fs::path& VcpkgPaths::get_git_exe() const
    {
        return this->git_exe.get_lazy([this]() { return get_git_path(this->downloads, this->scripts); });
    }

    const fs::path& VcpkgPaths::get_nuget_exe() const
    {
        return this->nuget_exe.get_lazy([this]() { return get_nuget_path(this->downloads, this->scripts); });
    }

    static std::vector<std::string> get_VS2017_installation_instances(const VcpkgPaths& paths)
    {
        const fs::path script = paths.scripts / "findVisualStudioInstallationInstances.ps1";
        const std::wstring cmd = System::create_powershell_script_cmd(script);
        System::ExitCodeAndOutput ec_data = System::cmd_execute_and_capture_output(cmd);
        Checks::check_exit(VCPKG_LINE_INFO, ec_data.exit_code == 0, "Could not run script to detect VS 2017 instances");
        return Util::fmap(Strings::split(ec_data.output, "\n"), WORKAROUND_ISSUE_1712);
    }

    static Optional<fs::path> get_VS2015_installation_instance()
    {
        const Optional<std::wstring> vs2015_cmntools_optional = System::get_environment_variable(L"VS140COMNTOOLS");
        if (auto v = vs2015_cmntools_optional.get())
        {
            const fs::path vs2015_cmntools = fs::path(*v).parent_path(); // The call to parent_path() is needed because
                                                                         // the env variable has a trailing backslash
            return vs2015_cmntools.parent_path().parent_path();
        }

        return nullopt;
    }

    static std::vector<Toolset> find_toolset_instances(const VcpkgPaths& paths)
    {
        using CPU = System::CPUArchitecture;

        const auto& fs = paths.get_filesystem();

        const std::vector<std::string> vs2017_installation_instances = get_VS2017_installation_instances(paths);
        // Note: this will contain a mix of vcvarsall.bat locations and dumpbin.exe locations.
        std::vector<fs::path> paths_examined;

        std::vector<Toolset> found_toolsets;

        // VS2015
        const Optional<fs::path> vs_2015_installation_instance = get_VS2015_installation_instance();
        if (auto v = vs_2015_installation_instance.get())
        {
            const fs::path vs2015_vcvarsall_bat = *v / "VC" / "vcvarsall.bat";

            paths_examined.push_back(vs2015_vcvarsall_bat);
            if (fs.exists(vs2015_vcvarsall_bat))
            {
                const fs::path vs2015_dumpbin_exe = *v / "VC" / "bin" / "dumpbin.exe";
                paths_examined.push_back(vs2015_dumpbin_exe);

                const fs::path vs2015_bin_dir = vs2015_vcvarsall_bat.parent_path() / "bin";
                std::vector<ToolsetArchOption> supported_architectures;
                if (fs.exists(vs2015_bin_dir / "vcvars32.bat"))
                    supported_architectures.push_back({L"x86", CPU::X86, CPU::X86});
                if (fs.exists(vs2015_bin_dir / "amd64\\vcvars64.bat"))
                    supported_architectures.push_back({L"x64", CPU::X64, CPU::X64});
                if (fs.exists(vs2015_bin_dir / "x86_amd64\\vcvarsx86_amd64.bat"))
                    supported_architectures.push_back({L"x86_amd64", CPU::X86, CPU::X64});
                if (fs.exists(vs2015_bin_dir / "x86_arm\\vcvarsx86_arm.bat"))
                    supported_architectures.push_back({L"x86_arm", CPU::X86, CPU::ARM});
                if (fs.exists(vs2015_bin_dir / "amd64_x86\\vcvarsamd64_x86.bat"))
                    supported_architectures.push_back({L"amd64_x86", CPU::X64, CPU::X86});
                if (fs.exists(vs2015_bin_dir / "amd64_arm\\vcvarsamd64_arm.bat"))
                    supported_architectures.push_back({L"amd64_arm", CPU::X64, CPU::ARM});

                if (fs.exists(vs2015_dumpbin_exe))
                {
                    found_toolsets.push_back(
                        {vs2015_dumpbin_exe, vs2015_vcvarsall_bat, L"v140", supported_architectures});
                }
            }
        }

        // VS2017
        Optional<Toolset> vs2017_toolset;
        for (const fs::path& instance : vs2017_installation_instances)
        {
            const fs::path vc_dir = instance / "VC";

            // Skip any instances that do not have vcvarsall.
            const fs::path vcvarsall_dir = vc_dir / "Auxiliary" / "Build";
            const fs::path vcvarsall_bat = vcvarsall_dir / "vcvarsall.bat";
            paths_examined.push_back(vcvarsall_bat);
            if (!fs.exists(vcvarsall_bat)) continue;

            // Get all supported architectures
            std::vector<ToolsetArchOption> supported_architectures;
            if (fs.exists(vcvarsall_dir / "vcvars32.bat"))
                supported_architectures.push_back({L"x86", CPU::X86, CPU::X86});
            if (fs.exists(vcvarsall_dir / "vcvars64.bat"))
                supported_architectures.push_back({L"amd64", CPU::X64, CPU::X64});
            if (fs.exists(vcvarsall_dir / "vcvarsx86_amd64.bat"))
                supported_architectures.push_back({L"x86_amd64", CPU::X86, CPU::X64});
            if (fs.exists(vcvarsall_dir / "vcvarsx86_arm.bat"))
                supported_architectures.push_back({L"x86_arm", CPU::X86, CPU::ARM});
            if (fs.exists(vcvarsall_dir / "vcvarsamd64_x86.bat"))
                supported_architectures.push_back({L"amd64_x86", CPU::X64, CPU::X86});
            if (fs.exists(vcvarsall_dir / "vcvarsamd64_arm.bat"))
                supported_architectures.push_back({L"amd64_arm", CPU::X64, CPU::ARM});

            // Locate the "best" MSVC toolchain version
            const fs::path msvc_path = vc_dir / "Tools" / "MSVC";
            std::vector<fs::path> msvc_subdirectories = fs.get_files_non_recursive(msvc_path);
            Util::unstable_keep_if(msvc_subdirectories, [&fs](const fs::path& path) { return fs.is_directory(path); });

            // Sort them so that latest comes first
            std::sort(msvc_subdirectories.begin(),
                      msvc_subdirectories.end(),
                      [](const fs::path& left, const fs::path& right) { return left.filename() > right.filename(); });

            for (const fs::path& subdir : msvc_subdirectories)
            {
                const fs::path dumpbin_path = subdir / "bin" / "HostX86" / "x86" / "dumpbin.exe";
                paths_examined.push_back(dumpbin_path);
                if (fs.exists(dumpbin_path))
                {
                    vs2017_toolset = Toolset{dumpbin_path, vcvarsall_bat, L"v141", supported_architectures};
                    break;
                }
            }
            if (auto value = vs2017_toolset.get())
            {
                found_toolsets.push_back(*value);
                break;
            }
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

    const Toolset& VcpkgPaths::get_toolset(const std::string& toolset_version) const
    {
        // Invariant: toolsets are non-empty and sorted with newest at back()
        const auto& vs_toolsets = this->toolsets.get_lazy([this]() { return find_toolset_instances(*this); });

        if (toolset_version.empty())
        {
            return vs_toolsets.back();
        }
        else
        {
            const auto toolset = Util::find_if(vs_toolsets, [&](const Toolset& toolset) {
                return toolset_version == Strings::to_utf8(toolset.version);
            });
            Checks::check_exit(
                VCPKG_LINE_INFO, toolset != vs_toolsets.end(), "Could not find toolset '%s'", toolset_version);
            return *toolset;
        }
    }

    Files::Filesystem& VcpkgPaths::get_filesystem() const { return Files::get_real_filesystem(); }
}
