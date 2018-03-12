#include "pch.h"

#include <vcpkg/base/expected.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/system.h>
#include <vcpkg/base/util.h>
#include <vcpkg/build.h>
#include <vcpkg/metrics.h>
#include <vcpkg/packagespec.h>
#include <vcpkg/vcpkgpaths.h>

namespace vcpkg
{
    static constexpr CStringView V_120 = "v120";
    static constexpr CStringView V_140 = "v140";
    static constexpr CStringView V_141 = "v141";

    struct ToolData
    {
        std::array<int, 3> required_version;
        fs::path downloaded_exe_path;
    };

    static Optional<std::array<int, 3>> parse_version_string(const std::string& version_as_string)
    {
        static const std::regex RE(R"###((\d+)\.(\d+)\.(\d+))###");

        std::match_results<std::string::const_iterator> match;
        const auto found = std::regex_search(version_as_string, match, RE);
        if (!found)
        {
            return {};
        }

        const int d1 = atoi(match[1].str().c_str());
        const int d2 = atoi(match[2].str().c_str());
        const int d3 = atoi(match[3].str().c_str());
        const std::array<int, 3> result = {d1, d2, d3};
        return result;
    }

    static ToolData parse_tool_data_from_xml(const VcpkgPaths& paths, const std::string& tool)
    {
        static const fs::path XML_PATH = paths.scripts / "vcpkgTools.xml";

        const auto get_string_inside_tags =
            [](const std::string& input, const std::regex& regex, const std::string& tag_name) -> std::string {
            std::smatch match;
            const bool has_match = std::regex_search(input.cbegin(), input.cend(), match, regex);
            Checks::check_exit(
                VCPKG_LINE_INFO, has_match, "Could not find tag <%s> in %s", tag_name, XML_PATH.generic_string());

            return match[1];
        };

        static const std::string XML = paths.get_filesystem().read_contents(XML_PATH).value_or_exit(VCPKG_LINE_INFO);
        static const std::regex VERSION_REGEX{
            Strings::format(R"###(<requiredVersion>([\s\S]*?)</requiredVersion>)###", tool)};
        static const std::regex EXE_RELATIVE_PATH_REGEX{
            Strings::format(R"###(<exeRelativePath>([\s\S]*?)</exeRelativePath>)###", tool)};

        const std::regex tool_regex{Strings::format(R"###(<tool[\s]+name="%s">([\s\S]*?)</tool>)###", tool)};

        std::smatch match_tool;
        const bool has_match_tool = std::regex_search(XML.cbegin(), XML.cend(), match_tool, tool_regex);
        Checks::check_exit(VCPKG_LINE_INFO,
                           has_match_tool,
                           "Could not find entry for tool [%s] in %s",
                           tool,
                           XML_PATH.generic_string());

        const std::string tool_data_as_string = get_string_inside_tags(XML, tool_regex, tool);

        const std::string required_version_as_string =
            get_string_inside_tags(tool_data_as_string, VERSION_REGEX, "requiredVersion");

        const std::string exe_relative_path =
            get_string_inside_tags(tool_data_as_string, EXE_RELATIVE_PATH_REGEX, "exeRelativePath");

        const Optional<std::array<int, 3>> required_version = parse_version_string(required_version_as_string);
        Checks::check_exit(VCPKG_LINE_INFO,
                           required_version.has_value(),
                           "Could not parse version for tool %s. Version string was: %s",
                           tool,
                           required_version_as_string);

        const fs::path exe_path = paths.downloads / exe_relative_path;
        return ToolData{*required_version.get(), exe_path};
    }

    static bool exists_and_has_equal_or_greater_version(const std::string& version_cmd,
                                                        const std::array<int, 3>& expected_version)
    {
        const auto rc = System::cmd_execute_and_capture_output(Strings::format(R"(%s)", version_cmd));
        if (rc.exit_code != 0)
        {
            return false;
        }

        const Optional<std::array<int, 3>> v = parse_version_string(rc.output);
        if (!v.has_value())
        {
            return false;
        }

        const std::array<int, 3> actual_version = *v.get();
        return (actual_version[0] > expected_version[0] ||
                (actual_version[0] == expected_version[0] && actual_version[1] > expected_version[1]) ||
                (actual_version[0] == expected_version[0] && actual_version[1] == expected_version[1] &&
                 actual_version[2] >= expected_version[2]));
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

    static std::vector<std::string> keep_data_lines(const std::string& data_blob)
    {
        static const std::regex DATA_LINE_REGEX(R"(<sol>::(.+?)(?=::<eol>))");

        std::vector<std::string> data_lines;

        const std::sregex_iterator it(data_blob.cbegin(), data_blob.cend(), DATA_LINE_REGEX);
        const std::sregex_iterator end;
        for (std::sregex_iterator i = it; i != end; ++i)
        {
            const std::smatch match = *i;
            data_lines.push_back(match[1].str());
        }

        return data_lines;
    }

    static fs::path fetch_tool(const fs::path& scripts_folder, const std::string& tool_name, const ToolData& tool_data)
    {
        const std::array<int, 3>& version = tool_data.required_version;

        const std::string version_as_string = Strings::format("%d.%d.%d", version[0], version[1], version[2]);
        System::println("A suitable version of %s was not found (required v%s). Downloading portable %s v%s...",
                        tool_name,
                        version_as_string,
                        tool_name,
                        version_as_string);
        const fs::path script = scripts_folder / "fetchtool.ps1";
        const std::string title = Strings::format(
            "Fetching %s version %s (No sufficient installed version was found)", tool_name, version_as_string);
        const System::PowershellParameter tool_param("tool", tool_name);
        const std::string output = System::powershell_execute_and_capture_output(title, script, {tool_param});

        const std::vector<std::string> tool_path = keep_data_lines(output);
        Checks::check_exit(VCPKG_LINE_INFO, tool_path.size() == 1, "Expected tool path, but got %s", output);

        const fs::path actual_downloaded_path = Strings::trim(std::string{tool_path.at(0)});
        const fs::path& expected_downloaded_path = tool_data.downloaded_exe_path;
        std::error_code ec;
        const auto eq = fs::stdfs::equivalent(expected_downloaded_path, actual_downloaded_path, ec);
        Checks::check_exit(VCPKG_LINE_INFO,
                           eq && !ec,
                           "Expected tool downloaded path to be %s, but was %s",
                           expected_downloaded_path.u8string(),
                           actual_downloaded_path.u8string());
        return actual_downloaded_path;
    }

    static fs::path get_cmake_path(const VcpkgPaths& paths)
    {
#if defined(_WIN32)
        static const ToolData TOOL_DATA = parse_tool_data_from_xml(paths, "cmake");
#else
        static const ToolData TOOL_DATA = ToolData{{3, 5, 1}, ""};
#endif
        static const std::string VERSION_CHECK_ARGUMENTS = "--version";

        std::vector<fs::path> candidate_paths;
#if defined(_WIN32)
        candidate_paths.push_back(TOOL_DATA.downloaded_exe_path);
#endif
        const std::vector<fs::path> from_path = Files::find_from_PATH("cmake");
        candidate_paths.insert(candidate_paths.end(), from_path.cbegin(), from_path.cend());
#if defined(_WIN32)
        candidate_paths.push_back(System::get_program_files_platform_bitness() / "CMake" / "bin" / "cmake.exe");
        candidate_paths.push_back(System::get_program_files_32_bit() / "CMake" / "bin");
#endif

        const Optional<fs::path> path =
            find_if_has_equal_or_greater_version(candidate_paths, VERSION_CHECK_ARGUMENTS, TOOL_DATA.required_version);
        if (const auto p = path.get())
        {
            return *p;
        }

        return fetch_tool(paths.scripts, "cmake", TOOL_DATA);
    }

    static fs::path get_7za_path(const VcpkgPaths& paths)
    {
#if defined(_WIN32)
        static const ToolData TOOL_DATA = parse_tool_data_from_xml(paths, "7zip");
        if (!paths.get_filesystem().exists(TOOL_DATA.downloaded_exe_path))
        {
            return fetch_tool(paths.scripts, "7zip", TOOL_DATA);
        }
        return TOOL_DATA.downloaded_exe_path;
#else
        Checks::exit_with_message(VCPKG_LINE_INFO, "Cannot download 7zip for non-Windows platforms.");
#endif
    }

    static fs::path get_nuget_path(const VcpkgPaths& paths)
    {
        static const ToolData TOOL_DATA = parse_tool_data_from_xml(paths, "nuget");

        std::vector<fs::path> candidate_paths;
        candidate_paths.push_back(TOOL_DATA.downloaded_exe_path);
        const std::vector<fs::path> from_path = Files::find_from_PATH("nuget");
        candidate_paths.insert(candidate_paths.end(), from_path.cbegin(), from_path.cend());

        auto path = find_if_has_equal_or_greater_version(candidate_paths, "", TOOL_DATA.required_version);
        if (const auto p = path.get())
        {
            return *p;
        }

        return fetch_tool(paths.scripts, "nuget", TOOL_DATA);
    }

    static fs::path get_git_path(const VcpkgPaths& paths)
    {
#if defined(_WIN32)
        static const ToolData TOOL_DATA = parse_tool_data_from_xml(paths, "git");
#else
        static const ToolData TOOL_DATA = ToolData{{2, 7, 4}, ""};
#endif
        static const std::string VERSION_CHECK_ARGUMENTS = "--version";

        std::vector<fs::path> candidate_paths;
#if defined(_WIN32)
        candidate_paths.push_back(TOOL_DATA.downloaded_exe_path);
#endif
        const std::vector<fs::path> from_path = Files::find_from_PATH("git");
        candidate_paths.insert(candidate_paths.end(), from_path.cbegin(), from_path.cend());
#if defined(_WIN32)
        candidate_paths.push_back(System::get_program_files_platform_bitness() / "git" / "cmd" / "git.exe");
        candidate_paths.push_back(System::get_program_files_32_bit() / "git" / "cmd" / "git.exe");
#endif

        const Optional<fs::path> path =
            find_if_has_equal_or_greater_version(candidate_paths, VERSION_CHECK_ARGUMENTS, TOOL_DATA.required_version);
        if (const auto p = path.get())
        {
            return *p;
        }

        return fetch_tool(paths.scripts, "git", TOOL_DATA);
    }

    static fs::path get_ifw_installerbase_path(const VcpkgPaths& paths)
    {
        static const ToolData TOOL_DATA = parse_tool_data_from_xml(paths, "installerbase");

        static const std::string VERSION_CHECK_ARGUMENTS = "--framework-version";

        std::vector<fs::path> candidate_paths;
        candidate_paths.push_back(TOOL_DATA.downloaded_exe_path);
        // TODO: Uncomment later
        // const std::vector<fs::path> from_path = Files::find_from_PATH("installerbase");
        // candidate_paths.insert(candidate_paths.end(), from_path.cbegin(), from_path.cend());
        // candidate_paths.push_back(fs::path(System::get_environment_variable("HOMEDRIVE").value_or("C:")) / "Qt" /
        // "Tools" / "QtInstallerFramework" / "3.1" / "bin" / "installerbase.exe");
        // candidate_paths.push_back(fs::path(System::get_environment_variable("HOMEDRIVE").value_or("C:")) / "Qt" /
        // "QtIFW-3.1.0" / "bin" / "installerbase.exe");

        const Optional<fs::path> path =
            find_if_has_equal_or_greater_version(candidate_paths, VERSION_CHECK_ARGUMENTS, TOOL_DATA.required_version);
        if (const auto p = path.get())
        {
            return *p;
        }

        return fetch_tool(paths.scripts, "installerbase", TOOL_DATA);
    }

    Expected<VcpkgPaths> VcpkgPaths::create(const fs::path& vcpkg_root_dir, const std::string& default_vs_path)
    {
        std::error_code ec;
        const fs::path canonical_vcpkg_root_dir = fs::stdfs::canonical(vcpkg_root_dir, ec);
        if (ec)
        {
            return ec;
        }

        VcpkgPaths paths;
        paths.root = canonical_vcpkg_root_dir;
        paths.default_vs_path = default_vs_path;

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

    const fs::path& VcpkgPaths::get_7za_exe() const
    {
        return this->_7za_exe.get_lazy([this]() { return get_7za_path(*this); });
    }

    const fs::path& VcpkgPaths::get_cmake_exe() const
    {
        return this->cmake_exe.get_lazy([this]() { return get_cmake_path(*this); });
    }

    const fs::path& VcpkgPaths::get_git_exe() const
    {
        return this->git_exe.get_lazy([this]() { return get_git_path(*this); });
    }

    const fs::path& VcpkgPaths::get_nuget_exe() const
    {
        return this->nuget_exe.get_lazy([this]() { return get_nuget_path(*this); });
    }

    const fs::path& VcpkgPaths::get_ifw_installerbase_exe() const
    {
        return this->ifw_installerbase_exe.get_lazy([this]() { return get_ifw_installerbase_path(*this); });
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
        const std::string output =
            System::powershell_execute_and_capture_output("Detecting Visual Studio instances", script);

        const std::vector<std::string> instances_as_strings = keep_data_lines(output);
        Checks::check_exit(VCPKG_LINE_INFO,
                           !instances_as_strings.empty(),
                           "Could not detect any Visual Studio instances.\n"
                           "Powershell script:\n"
                           "    %s\n"
                           "returned:\n"
                           "%s",
                           script.generic_string(),
                           output);

        std::vector<VisualStudioInstance> instances;
        for (const std::string& instance_as_string : instances_as_strings)
        {
            const std::vector<std::string> split = Strings::split(instance_as_string, "::");
            Checks::check_exit(VCPKG_LINE_INFO,
                               split.size() == 4,
                               "Invalid Visual Studio instance format.\n"
                               "Expected: PreferenceWeight::ReleaseType::Version::PathToVisualStudio\n"
                               "Actual  : %s\n",
                               instance_as_string);
            instances.push_back({split.at(3), split.at(2), split.at(1), split.at(0)});
        }

        return instances;
    }

    static std::vector<Toolset> find_toolset_instances(const VcpkgPaths& paths)
    {
        using CPU = System::CPUArchitecture;

        const auto& fs = paths.get_filesystem();

        // Note: this will contain a mix of vcvarsall.bat locations and dumpbin.exe locations.
        std::vector<fs::path> paths_examined;

        std::vector<Toolset> found_toolsets;
        std::vector<Toolset> excluded_toolsets;

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
                        const Toolset v141toolset = Toolset{
                            vs_instance.root_path, dumpbin_path, vcvarsall_bat, {}, V_141, supported_architectures};

                        auto english_language_pack = dumpbin_path.parent_path() / "1033";

                        if (!fs.exists(english_language_pack))
                        {
                            excluded_toolsets.push_back(v141toolset);
                            break;
                        }

                        found_toolsets.push_back(v141toolset);

                        if (v140_is_available)
                        {
                            const Toolset v140toolset = Toolset{vs_instance.root_path,
                                                                dumpbin_path,
                                                                vcvarsall_bat,
                                                                {"-vcvars_ver=14.0"},
                                                                V_140,
                                                                supported_architectures};
                            found_toolsets.push_back(v140toolset);
                        }

                        break;
                    }
                }

                continue;
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
                    std::vector<ToolsetArchOption> supported_architectures;
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
                        const Toolset toolset = {vs_instance.root_path,
                                                 vs_dumpbin_exe,
                                                 vcvarsall_bat,
                                                 {},
                                                 major_version == "14" ? V_140 : V_120,
                                                 supported_architectures};

                        auto english_language_pack = vs_dumpbin_exe.parent_path() / "1033";

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

    const Toolset& VcpkgPaths::get_toolset(const Build::PreBuildInfo& prebuildinfo) const
    {
        if (prebuildinfo.external_toolchain_file ||
            (!prebuildinfo.cmake_system_name.empty() && prebuildinfo.cmake_system_name != "WindowsStore"))
        {
            static Toolset external_toolset = []() -> Toolset {
                Toolset ret;
                ret.dumpbin = "";
                ret.supported_architectures = {
                    ToolsetArchOption{"", System::get_host_processor(), System::get_host_processor()}};
                ret.vcvarsall = "";
                ret.vcvarsall_options = {};
                ret.version = "external";
                ret.visual_studio_root_path = "";
                return ret;
            }();
            return external_toolset;
        }

        // Invariant: toolsets are non-empty and sorted with newest at back()
        const std::vector<Toolset>& vs_toolsets =
            this->toolsets.get_lazy([this]() { return find_toolset_instances(*this); });

        std::vector<const Toolset*> candidates = Util::element_pointers(vs_toolsets);
        const auto tsv = prebuildinfo.platform_toolset.get();
        auto vsp = prebuildinfo.visual_studio_path.get();
        if (!vsp && !default_vs_path.empty())
        {
            vsp = &default_vs_path;
        }

        if (tsv && vsp)
        {
            Util::stable_keep_if(
                candidates, [&](const Toolset* t) { return *tsv == t->version && *vsp == t->visual_studio_root_path; });
            Checks::check_exit(VCPKG_LINE_INFO,
                               !candidates.empty(),
                               "Could not find Visual Studio instance at %s with %s toolset.",
                               vsp->u8string(),
                               *tsv);

            Checks::check_exit(VCPKG_LINE_INFO, candidates.size() == 1);
            return *candidates.back();
        }

        if (tsv)
        {
            Util::stable_keep_if(candidates, [&](const Toolset* t) { return *tsv == t->version; });
            Checks::check_exit(
                VCPKG_LINE_INFO, !candidates.empty(), "Could not find Visual Studio instance with %s toolset.", *tsv);
        }

        if (vsp)
        {
            const fs::path vs_root_path = *vsp;
            Util::stable_keep_if(candidates,
                                 [&](const Toolset* t) { return vs_root_path == t->visual_studio_root_path; });
            Checks::check_exit(VCPKG_LINE_INFO,
                               !candidates.empty(),
                               "Could not find Visual Studio instance at %s.",
                               vs_root_path.generic_string());
        }

        Checks::check_exit(VCPKG_LINE_INFO, !candidates.empty(), "No suitable Visual Studio instances were found");
        return *candidates.front();
    }

    Files::Filesystem& VcpkgPaths::get_filesystem() const { return Files::get_real_filesystem(); }
}
