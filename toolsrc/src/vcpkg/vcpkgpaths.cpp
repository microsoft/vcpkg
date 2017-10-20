#include "pch.h"

#include <vcpkg/base/expected.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/system.h>
#include <vcpkg/base/util.h>
#include <vcpkg/metrics.h>
#include <vcpkg/packagespec.h>
#include <vcpkg/vcpkgpaths.h>

namespace vcpkg
{
    static constexpr CStringView V_120 = "v120";
    static constexpr CStringView V_140 = "v140";
    static constexpr CStringView V_141 = "v141";

    static bool exists_and_has_equal_or_greater_version(const std::string& version_cmd,
                                                        const std::array<int, 3>& expected_version)
    {
        static const std::regex RE(R"###((\d+)\.(\d+)\.(\d+))###");

        const auto rc = System::cmd_execute_and_capture_output(Strings::format(R"(%s)", version_cmd));
        if (rc.exit_code != 0)
        {
            return false;
        }

        std::match_results<std::string::const_iterator> match;
        const auto found = std::regex_search(rc.output, match, RE);
        if (!found)
        {
            return false;
        }

        const int d1 = atoi(match[1].str().c_str());
        const int d2 = atoi(match[2].str().c_str());
        const int d3 = atoi(match[3].str().c_str());
        if (d1 > expected_version[0] || (d1 == expected_version[0] && d2 > expected_version[1]) ||
            (d1 == expected_version[0] && d2 == expected_version[1] && d3 >= expected_version[2]))
        {
            // satisfactory version found
            return true;
        }

        return false;
    }

    static Optional<fs::path> find_if_has_equal_or_greater_version(const std::vector<fs::path>& candidate_paths,
                                                                   const std::string& version_check_arguments,
                                                                   const std::array<int, 3>& expected_version)
    {
        auto it = Util::find_if(candidate_paths, [&](const fs::path& p) {
            const std::string cmd = Strings::format(R"("%s" %s)", p.u8string(), version_check_arguments);
            return exists_and_has_equal_or_greater_version(cmd, expected_version);
        });

        if (it != candidate_paths.cend())
        {
            return std::move(*it);
        }

        return nullopt;
    }

    static fs::path fetch_dependency(const fs::path& scripts_folder,
                                     const std::string& tool_name,
                                     const fs::path& expected_downloaded_path,
                                     const std::array<int, 3>& version)
    {
        const std::string version_as_string = Strings::format("%d.%d.%d", version[0], version[1], version[2]);
        System::println("A suitable version of %s was not found (required v%s). Downloading portable %s v%s...",
                        tool_name,
                        version_as_string,
                        tool_name,
                        version_as_string);
        const fs::path script = scripts_folder / "fetchDependency.ps1";
        const System::ExitCodeAndOutput rc =
            System::powershell_execute_and_capture_output(script, Strings::format("-Dependency %s", tool_name));
        if (rc.exit_code)
        {
            System::println(System::Color::error,
                            "Launching powershell failed or was denied when trying to fetch %s version %s.\n"
                            "(No sufficient installed version was found)",
                            tool_name,
                            version_as_string);
            {
                auto locked_metrics = Metrics::g_metrics.lock();
                locked_metrics->track_property("error", "powershell install failed");
                locked_metrics->track_property("dependency", tool_name);
            }
            Checks::exit_with_code(VCPKG_LINE_INFO, rc.exit_code);
        }

        const fs::path actual_downloaded_path = Strings::trim(std::string{rc.output});
        std::error_code ec;
        const auto eq = fs::stdfs::equivalent(expected_downloaded_path, actual_downloaded_path, ec);
        Checks::check_exit(VCPKG_LINE_INFO,
                           eq && !ec,
                           "Expected dependency downloaded path to be %s, but was %s",
                           expected_downloaded_path.u8string(),
                           actual_downloaded_path.u8string());
        return actual_downloaded_path;
    }

    static fs::path get_cmake_path(const fs::path& downloads_folder, const fs::path& scripts_folder)
    {
        static constexpr std::array<int, 3> EXPECTED_VERSION = {3, 9, 4};
        static const std::string VERSION_CHECK_ARGUMENTS = "--version";

        const fs::path downloaded_copy = downloads_folder / "cmake-3.9.4-win32-x86" / "bin" / "cmake.exe";
        const std::vector<fs::path> from_path = Files::find_from_PATH("cmake");

        std::vector<fs::path> candidate_paths;
        candidate_paths.push_back(downloaded_copy);
        candidate_paths.insert(candidate_paths.end(), from_path.cbegin(), from_path.cend());
#if defined(_WIN32)
        candidate_paths.push_back(System::get_program_files_platform_bitness() / "CMake" / "bin" / "cmake.exe");
        candidate_paths.push_back(System::get_program_files_32_bit() / "CMake" / "bin");
#endif

        const Optional<fs::path> path =
            find_if_has_equal_or_greater_version(candidate_paths, VERSION_CHECK_ARGUMENTS, EXPECTED_VERSION);
        if (const auto p = path.get())
        {
            return *p;
        }

        return fetch_dependency(scripts_folder, "cmake", downloaded_copy, EXPECTED_VERSION);
    }

    fs::path get_nuget_path(const fs::path& downloads_folder, const fs::path& scripts_folder)
    {
        static constexpr std::array<int, 3> EXPECTED_VERSION = {4, 4, 0};

        const fs::path downloaded_copy = downloads_folder / "nuget-4.4.0" / "nuget.exe";
        const std::vector<fs::path> from_path = Files::find_from_PATH("nuget");

        std::vector<fs::path> candidate_paths;
        candidate_paths.push_back(downloaded_copy);
        candidate_paths.insert(candidate_paths.end(), from_path.cbegin(), from_path.cend());

        auto path = find_if_has_equal_or_greater_version(candidate_paths, "", EXPECTED_VERSION);
        if (const auto p = path.get())
        {
            return *p;
        }

        return fetch_dependency(scripts_folder, "nuget", downloaded_copy, EXPECTED_VERSION);
    }

    fs::path get_git_path(const fs::path& downloads_folder, const fs::path& scripts_folder)
    {
        static constexpr std::array<int, 3> EXPECTED_VERSION = {2, 14, 2};
        static const std::string VERSION_CHECK_ARGUMENTS = "--version";

        const fs::path downloaded_copy = downloads_folder / "MinGit-2.14.2.3-32-bit" / "cmd" / "git.exe";
        const std::vector<fs::path> from_path = Files::find_from_PATH("git");

        std::vector<fs::path> candidate_paths;
        candidate_paths.push_back(downloaded_copy);
        candidate_paths.insert(candidate_paths.end(), from_path.cbegin(), from_path.cend());
#if defined(_WIN32)
        candidate_paths.push_back(System::get_program_files_platform_bitness() / "git" / "cmd" / "git.exe");
        candidate_paths.push_back(System::get_program_files_32_bit() / "git" / "cmd" / "git.exe");
#endif

        const Optional<fs::path> path =
            find_if_has_equal_or_greater_version(candidate_paths, VERSION_CHECK_ARGUMENTS, EXPECTED_VERSION);
        if (const auto p = path.get())
        {
            return *p;
        }

        return fetch_dependency(scripts_folder, "git", downloaded_copy, EXPECTED_VERSION);
    }

    static fs::path get_ifw_installerbase_path(const fs::path& downloads_folder, const fs::path& scripts_folder)
    {
        static constexpr std::array<int, 3> EXPECTED_VERSION = {3, 1, 81};
        static const std::string VERSION_CHECK_ARGUMENTS = "--framework-version";

        const fs::path downloaded_copy =
            downloads_folder / "QtInstallerFramework-win-x86" / "bin" / "installerbase.exe";

        std::vector<fs::path> candidate_paths;
        candidate_paths.push_back(downloaded_copy);
        // TODO: Uncomment later
        // const std::vector<fs::path> from_path = Files::find_from_PATH("installerbase");
        // candidate_paths.insert(candidate_paths.end(), from_path.cbegin(), from_path.cend());
        // candidate_paths.push_back(fs::path(System::get_environment_variable("HOMEDRIVE").value_or("C:")) / "Qt" /
        // "Tools" / "QtInstallerFramework" / "3.1" / "bin" / "installerbase.exe");
        // candidate_paths.push_back(fs::path(System::get_environment_variable("HOMEDRIVE").value_or("C:")) / "Qt" /
        // "QtIFW-3.1.0" / "bin" / "installerbase.exe");

        const Optional<fs::path> path =
            find_if_has_equal_or_greater_version(candidate_paths, VERSION_CHECK_ARGUMENTS, EXPECTED_VERSION);
        if (const auto p = path.get())
        {
            return *p;
        }

        return fetch_dependency(scripts_folder, "installerbase", downloaded_copy, EXPECTED_VERSION);
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

    const std::vector<std::string>& VcpkgPaths::get_available_triplets() const
    {
        return this->available_triplets.get_lazy([this]() -> std::vector<std::string> {

            std::vector<std::string> output;
            for (auto&& path : this->get_filesystem().get_files_non_recursive(this->triplets))
            {
                output.push_back(path.stem().filename().string());
            }

            return output;
        });
    }

    bool VcpkgPaths::is_valid_triplet(const Triplet& t) const
    {
        auto it = Util::find_if(this->get_available_triplets(),
                                [&](auto&& available_triplet) { return t.canonical_name() == available_triplet; });
        return it != this->get_available_triplets().cend();
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

    const fs::path& VcpkgPaths::get_ifw_installerbase_exe() const
    {
        return this->ifw_installerbase_exe.get_lazy(
            [this]() { return get_ifw_installerbase_path(this->downloads, this->scripts); });
    }

    const fs::path& VcpkgPaths::get_ifw_binarycreator_exe() const
    {
        return this->ifw_binarycreator_exe.get_lazy(
            [this]() { return get_ifw_installerbase_exe().parent_path() / "binarycreator.exe"; });
    }

    const fs::path& VcpkgPaths::get_ifw_repogen_exe() const
    {
        return this->ifw_repogen_exe.get_lazy(
            [this]() { return get_ifw_installerbase_exe().parent_path() / "repogen.exe"; });
    }

    struct VisualStudioInstance
    {
        fs::path root_path;
        std::string version;
        std::string release_type;
        std::string preference_weight; // Mostly unused, just for verification that order is as intended

        std::string major_version() const { return version.substr(0, 2); }
    };

    static std::vector<VisualStudioInstance> get_visual_studio_instances(const VcpkgPaths& paths)
    {
        const fs::path script = paths.scripts / "findVisualStudioInstallationInstances.ps1";
        const System::ExitCodeAndOutput ec_data = System::powershell_execute_and_capture_output(script);
        Checks::check_exit(
            VCPKG_LINE_INFO, ec_data.exit_code == 0, "Could not run script to detect Visual Studio instances");

        const std::vector<std::string> instances_as_strings = Strings::split(ec_data.output, "::<eol>");
        Checks::check_exit(
            VCPKG_LINE_INFO, !instances_as_strings.empty(), "Could not detect any Visual Studio instances.\n");

        std::vector<VisualStudioInstance> output;
        for (const std::string& instance_as_string : instances_as_strings)
        {
            const std::vector<std::string> split = Strings::split(instance_as_string, "::");
            Checks::check_exit(VCPKG_LINE_INFO,
                               split.size() == 4,
                               "Invalid Visual Studio instance format.\n"
                               "Expected: PreferenceWeight::ReleaseType::Version::PathToVisualStudio\n"
                               "Actual  : %s\n",
                               instance_as_string);
            output.push_back({split.at(3), split.at(2), split.at(1), split.at(0)});
        }

        return output;
    }

    static std::vector<Toolset> find_toolset_instances(const VcpkgPaths& paths)
    {
        using CPU = System::CPUArchitecture;

        const auto& fs = paths.get_filesystem();

        // Note: this will contain a mix of vcvarsall.bat locations and dumpbin.exe locations.
        std::vector<fs::path> paths_examined;

        std::vector<Toolset> found_toolsets;

        const std::vector<VisualStudioInstance> vs_instances = get_visual_studio_instances(paths);
        const bool v140_is_available = Util::find_if(vs_instances, [&](const VisualStudioInstance& vs_instance) {
                                           return vs_instance.major_version() == "14";
                                       }) != vs_instances.cend();

        for (const VisualStudioInstance& vs_instance : vs_instances)
        {
            const std::string major_version = vs_instance.major_version();
            if (major_version == "15")
            {
                const fs::path vc_dir = vs_instance.root_path / "VC";

                // Skip any instances that do not have vcvarsall.
                const fs::path vcvarsall_dir = vc_dir / "Auxiliary" / "Build";
                const fs::path vcvarsall_bat = vcvarsall_dir / "vcvarsall.bat";
                paths_examined.push_back(vcvarsall_bat);
                if (!fs.exists(vcvarsall_bat)) continue;

                // Get all supported architectures
                std::vector<ToolsetArchOption> supported_architectures;
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

                // Locate the "best" MSVC toolchain version
                const fs::path msvc_path = vc_dir / "Tools" / "MSVC";
                std::vector<fs::path> msvc_subdirectories = fs.get_files_non_recursive(msvc_path);
                Util::unstable_keep_if(msvc_subdirectories,
                                       [&fs](const fs::path& path) { return fs.is_directory(path); });

                // Sort them so that latest comes first
                std::sort(
                    msvc_subdirectories.begin(),
                    msvc_subdirectories.end(),
                    [](const fs::path& left, const fs::path& right) { return left.filename() > right.filename(); });

                for (const fs::path& subdir : msvc_subdirectories)
                {
                    const fs::path dumpbin_path = subdir / "bin" / "HostX86" / "x86" / "dumpbin.exe";
                    paths_examined.push_back(dumpbin_path);
                    if (fs.exists(dumpbin_path))
                    {
                        found_toolsets.push_back(Toolset{
                            vs_instance.root_path, dumpbin_path, vcvarsall_bat, {}, V_141, supported_architectures});

                        if (v140_is_available)
                        {
                            found_toolsets.push_back(Toolset{vs_instance.root_path,
                                                             dumpbin_path,
                                                             vcvarsall_bat,
                                                             {"-vcvars_ver=14.0"},
                                                             V_140,
                                                             supported_architectures});
                        }

                        break;
                    }
                }

                continue;
            }

            if (major_version == "14")
            {
                const fs::path vcvarsall_bat = vs_instance.root_path / "VC" / "vcvarsall.bat";

                paths_examined.push_back(vcvarsall_bat);
                if (fs.exists(vcvarsall_bat))
                {
                    const fs::path vs2015_dumpbin_exe = vs_instance.root_path / "VC" / "bin" / "dumpbin.exe";
                    paths_examined.push_back(vs2015_dumpbin_exe);

                    const fs::path vs2015_bin_dir = vcvarsall_bat.parent_path() / "bin";
                    std::vector<ToolsetArchOption> supported_architectures;
                    if (fs.exists(vs2015_bin_dir / "vcvars32.bat"))
                        supported_architectures.push_back({"x86", CPU::X86, CPU::X86});
                    if (fs.exists(vs2015_bin_dir / "amd64\\vcvars64.bat"))
                        supported_architectures.push_back({"x64", CPU::X64, CPU::X64});
                    if (fs.exists(vs2015_bin_dir / "x86_amd64\\vcvarsx86_amd64.bat"))
                        supported_architectures.push_back({"x86_amd64", CPU::X86, CPU::X64});
                    if (fs.exists(vs2015_bin_dir / "x86_arm\\vcvarsx86_arm.bat"))
                        supported_architectures.push_back({"x86_arm", CPU::X86, CPU::ARM});
                    if (fs.exists(vs2015_bin_dir / "amd64_x86\\vcvarsamd64_x86.bat"))
                        supported_architectures.push_back({"amd64_x86", CPU::X64, CPU::X86});
                    if (fs.exists(vs2015_bin_dir / "amd64_arm\\vcvarsamd64_arm.bat"))
                        supported_architectures.push_back({"amd64_arm", CPU::X64, CPU::ARM});

                    if (fs.exists(vs2015_dumpbin_exe))
                    {
                        found_toolsets.push_back({vs_instance.root_path,
                                                  vs2015_dumpbin_exe,
                                                  vcvarsall_bat,
                                                  {},
                                                  V_140,
                                                  supported_architectures});
                    }
                }
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

    const Toolset& VcpkgPaths::get_toolset(const Optional<std::string>& toolset_version,
                                           const Optional<fs::path>& visual_studio_path) const
    {
        // Invariant: toolsets are non-empty and sorted with newest at back()
        const std::vector<Toolset>& vs_toolsets =
            this->toolsets.get_lazy([this]() { return find_toolset_instances(*this); });

        std::vector<const Toolset*> candidates = Util::element_pointers(vs_toolsets);
        const auto tsv = toolset_version.get();
        const auto vsp = visual_studio_path.get();

        if (tsv && vsp)
        {
            Util::stable_keep_if(
                candidates, [&](const Toolset* t) { return *tsv == t->version && *vsp == t->visual_studio_root_path; });
            Checks::check_exit(VCPKG_LINE_INFO,
                               !candidates.empty(),
                               "Could not find Visual Studio instace at %s with %s toolset.",
                               vsp->u8string(),
                               *tsv);

            Checks::check_exit(VCPKG_LINE_INFO, candidates.size() == 1);
            return *candidates.back();
        }

        if (tsv)
        {
            Util::stable_keep_if(candidates, [&](const Toolset* t) { return *tsv == t->version; });
            Checks::check_exit(
                VCPKG_LINE_INFO, !candidates.empty(), "Could not find Visual Studio instace with %s toolset.", *tsv);
        }

        if (vsp)
        {
            const fs::path vs_root_path = *vsp;
            Util::stable_keep_if(candidates,
                                 [&](const Toolset* t) { return vs_root_path == t->visual_studio_root_path; });
            Checks::check_exit(VCPKG_LINE_INFO,
                               !candidates.empty(),
                               "Could not find Visual Studio instace at %s.",
                               vs_root_path.generic_string());
        }

        return *candidates.front();
    }

    Files::Filesystem& VcpkgPaths::get_filesystem() const { return Files::get_real_filesystem(); }
}
