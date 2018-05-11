#include "pch.h"

#include <vcpkg/base/checks.h>
#include <vcpkg/base/strings.h>
#include <vcpkg/base/system.h>
#include <vcpkg/base/util.h>
#include <vcpkg/commands.h>
#include <vcpkg/help.h>

namespace vcpkg::Commands::Fetch
{
    static constexpr CStringView V_120 = "v120";
    static constexpr CStringView V_140 = "v140";
    static constexpr CStringView V_141 = "v141";

    struct ToolData
    {
        std::array<int, 3> version;
        fs::path exe_path;
        std::string url;
        fs::path download_path;
        fs::path tool_dir_path;
        std::string sha512;
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

    static Optional<std::string> extract_string_between_delimiters(const std::string& input,
                                                                   const std::string& left_delim,
                                                                   const std::string& right_delim,
                                                                   const size_t& starting_offset = 0)
    {
        const size_t from = input.find(left_delim, starting_offset);
        if (from == std::string::npos) return nullopt;

        const size_t substring_start = from + left_delim.length();

        const size_t to = input.find(right_delim, substring_start);
        if (from == std::string::npos) return nullopt;

        return input.substr(substring_start, to - substring_start);
    }

    static ToolData parse_tool_data_from_xml(const VcpkgPaths& paths, const std::string& tool)
    {
#if defined(_WIN32)
        static constexpr StringLiteral OS_STRING = "windows";
#elif defined(__APPLE__)
        static constexpr StringLiteral OS_STRING = "osx";
#elif defined(__linux__)
        static constexpr StringLiteral OS_STRING = "linux";
#else
        return ToolData{};
#endif

#if defined(_WIN32) || defined(__APPLE__) || defined(__linux__)
        static const std::string XML_VERSION = "2";
        static const fs::path XML_PATH = paths.scripts / "vcpkgTools.xml";

        const auto get_string_inside_tags =
            [](const std::string& input, const std::string& left_delim, const std::string& right_delim) -> std::string {
            Optional<std::string> result = extract_string_between_delimiters(input, left_delim, right_delim);
            Checks::check_exit(VCPKG_LINE_INFO,
                               result.has_value(),
                               "Could not find tag <%s>.*<%s> in %s",
                               left_delim,
                               right_delim,
                               XML_PATH.generic_string());

            auto r = *result.get();
            return Strings::trim(std::move(r));
        };

        static const std::regex XML_VERSION_REGEX{R"###(<tools[\s]+version="([^"]+)">)###"};
        static const std::string XML = paths.get_filesystem().read_contents(XML_PATH).value_or_exit(VCPKG_LINE_INFO);
        std::smatch match_xml_version;
        const bool has_xml_version = std::regex_search(XML.cbegin(), XML.cend(), match_xml_version, XML_VERSION_REGEX);
        Checks::check_exit(VCPKG_LINE_INFO,
                           has_xml_version,
                           R"(Could not find <tools version="%s"> in %s)",
                           XML_VERSION,
                           XML_PATH.generic_string());
        Checks::check_exit(VCPKG_LINE_INFO,
                           XML_VERSION == match_xml_version[1],
                           "Expected %s version: [%s], but was [%s]. Please re-run bootstrap-vcpkg.",
                           XML_PATH.generic_string(),
                           XML_VERSION,
                           match_xml_version[1]);

        const std::regex tool_regex{Strings::format(R"###(<tool[\s]+name="%s"[\s]+os="%s">)###", tool, OS_STRING)};
        std::smatch match_tool_entry;
        const bool has_tool_entry = std::regex_search(XML.cbegin(), XML.cend(), match_tool_entry, tool_regex);
        Checks::check_exit(VCPKG_LINE_INFO,
                           has_tool_entry,
                           "Could not find entry for tool [%s] in %s",
                           tool,
                           XML_PATH.generic_string());

        const std::string tool_data = get_string_inside_tags(XML, match_tool_entry[0], R"(</tool>)");

        const std::string version_as_string = get_string_inside_tags(tool_data, "<version>", R"(</version>)");
        const std::string exe_relative_path =
            get_string_inside_tags(tool_data, "<exeRelativePath>", R"(</exeRelativePath>)");
        const std::string url = get_string_inside_tags(tool_data, "<url>", R"(</url>)");
        const std::string sha512 = get_string_inside_tags(tool_data, "<sha512>", R"(</sha512>)");
        auto archive_name = extract_string_between_delimiters(tool_data, "<archiveName>", R"(</archiveName>)");

        const Optional<std::array<int, 3>> version = parse_version_string(version_as_string);
        Checks::check_exit(VCPKG_LINE_INFO,
                           version.has_value(),
                           "Could not parse version for tool %s. Version string was: %s",
                           tool,
                           version_as_string);

        const std::string tool_dir_name = Strings::format("%s-%s-%s", tool, version_as_string, OS_STRING);
        const fs::path tool_dir_path = paths.downloads / "tools" / tool_dir_name;
        const fs::path exe_path = tool_dir_path / exe_relative_path;

        return ToolData{*version.get(),
                        exe_path,
                        url,
                        paths.downloads / archive_name.value_or(exe_relative_path),
                        tool_dir_path,
                        sha512};
#endif
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

#if !defined(_WIN32)
    static void extract_archive(const VcpkgPaths& paths, const fs::path& archive, const fs::path& to_path)
    {
        Files::Filesystem& fs = paths.get_filesystem();
        const fs::path to_path_partial = to_path.u8string() + ".partial";

        std::error_code ec;
        fs.remove_all(to_path_partial, ec);
        fs.create_directories(to_path_partial, ec);

        const auto ext = archive.extension();
        if (ext == ".gz" && ext.extension() != ".tar")
        {
            const auto code = System::cmd_execute(
                Strings::format(R"(cd '%s' && tar xzf '%s')", to_path_partial.u8string(), archive.u8string()));
            Checks::check_exit(VCPKG_LINE_INFO, code == 0, "tar failed while extracting %s", archive.u8string());
        }
        else if (ext == ".zip")
        {
            const auto code = System::cmd_execute(
                Strings::format(R"(cd '%s' && unzip -qqo '%s')", to_path_partial.u8string(), archive.u8string()));
            Checks::check_exit(VCPKG_LINE_INFO, code == 0, "unzip failed while extracting %s", archive.u8string());
        }
        else
        {
            Checks::exit_with_message(VCPKG_LINE_INFO, "Unexpected archive extension: %s", ext.u8string());
        }

        fs.rename(to_path_partial, to_path);
    }

    static void verify_hash(const VcpkgPaths& paths,
                            const std::string& url,
                            const fs::path& path,
                            const std::string& sha512)
    {
        const std::string actual_hash = Hash::get_file_hash(paths, path, "SHA512");
        Checks::check_exit(VCPKG_LINE_INFO,
                           sha512 == actual_hash,
                           "File does not have the expected hash:\n"
                           "             url : [ %s ]\n"
                           "       File path : [ %s ]\n"
                           "   Expected hash : [ %s ]\n"
                           "     Actual hash : [ %s ]\n",
                           url,
                           path.u8string(),
                           sha512,
                           actual_hash);
    }

    static void download_file(const VcpkgPaths& paths,
                              const std::string& url,
                              const fs::path& download_path,
                              const std::string& sha512)
    {
        Files::Filesystem& fs = paths.get_filesystem();
        const std::string download_path_part = download_path.u8string() + ".part";
        std::error_code ec;
        fs.remove(download_path_part, ec);
        const auto code = System::cmd_execute(
            Strings::format(R"(curl -L '%s' --create-dirs --output '%s')", url, download_path_part));
        Checks::check_exit(VCPKG_LINE_INFO, code == 0, "Could not download %s", url);

        verify_hash(paths, url, download_path_part, sha512);
        fs.rename(download_path_part, download_path);
    }

#endif
    static fs::path fetch_tool(const VcpkgPaths& paths, const std::string& tool_name, const ToolData& tool_data)
    {
        const std::array<int, 3>& version = tool_data.version;
        const std::string version_as_string = Strings::format("%d.%d.%d", version[0], version[1], version[2]);
        Checks::check_exit(VCPKG_LINE_INFO,
                           !tool_data.url.empty(),
                           "A suitable version of %s was not found (required v%s) and unable to automatically "
                           "download a portable one. Please install a newer version of git.",
                           tool_name,
                           version_as_string);
        System::println("A suitable version of %s was not found (required v%s). Downloading portable %s v%s...",
                        tool_name,
                        version_as_string,
                        tool_name,
                        version_as_string);
#if defined(_WIN32)
        const fs::path script = paths.scripts / "fetchtool.ps1";
        const std::string title = Strings::format(
            "Fetching %s version %s (No sufficient installed version was found)", tool_name, version_as_string);
        const System::PowershellParameter tool_param("tool", tool_name);
        const std::string output = System::powershell_execute_and_capture_output(title, script, {tool_param});

        const std::vector<std::string> tool_path = keep_data_lines(output);
        Checks::check_exit(VCPKG_LINE_INFO, tool_path.size() == 1, "Expected tool path, but got %s", output);

        const fs::path actual_downloaded_path = Strings::trim(std::string{tool_path.at(0)});
        const fs::path& expected_downloaded_path = tool_data.exe_path;
        std::error_code ec;
        const auto eq = fs::stdfs::equivalent(expected_downloaded_path, actual_downloaded_path, ec);
        Checks::check_exit(VCPKG_LINE_INFO,
                           eq && !ec,
                           "Expected tool downloaded path to be %s, but was %s",
                           expected_downloaded_path.u8string(),
                           actual_downloaded_path.u8string());
        return actual_downloaded_path;
#else
        const auto& fs = paths.get_filesystem();
        if (!fs.exists(tool_data.download_path))
        {
            System::println("Downloading %s...", tool_name);
            download_file(paths, tool_data.url, tool_data.download_path, tool_data.sha512);
            System::println("Downloading %s... done.", tool_name);
        }
        else
        {
            verify_hash(paths, tool_data.url, tool_data.download_path, tool_data.sha512);
        }

        System::println("Extracting %s...", tool_name);
        extract_archive(paths, tool_data.download_path, tool_data.tool_dir_path);
        System::println("Extracting %s... done.", tool_name);

        Checks::check_exit(VCPKG_LINE_INFO,
                           fs.exists(tool_data.exe_path),
                           "Expected %s to exist after extracting",
                           tool_data.exe_path);

        return tool_data.exe_path;
#endif
    }

    static fs::path get_cmake_path(const VcpkgPaths& paths)
    {
        std::vector<fs::path> candidate_paths;
#if defined(_WIN32) || defined(__APPLE__) || defined(__linux__)
        static const ToolData TOOL_DATA = parse_tool_data_from_xml(paths, "cmake");
        candidate_paths.push_back(TOOL_DATA.exe_path);
#else
        static const ToolData TOOL_DATA = ToolData{{3, 5, 1}, ""};
#endif
        static const std::string VERSION_CHECK_ARGUMENTS = "--version";

        const std::vector<fs::path> from_path = Files::find_from_PATH("cmake");
        candidate_paths.insert(candidate_paths.end(), from_path.cbegin(), from_path.cend());

        const auto& program_files = System::get_program_files_platform_bitness();
        if (const auto pf = program_files.get()) candidate_paths.push_back(*pf / "CMake" / "bin" / "cmake.exe");
        const auto& program_files_32_bit = System::get_program_files_32_bit();
        if (const auto pf = program_files_32_bit.get()) candidate_paths.push_back(*pf / "CMake" / "bin" / "cmake.exe");

        const Optional<fs::path> path =
            find_if_has_equal_or_greater_version(candidate_paths, VERSION_CHECK_ARGUMENTS, TOOL_DATA.version);
        if (const auto p = path.get())
        {
            return *p;
        }

        return fetch_tool(paths, "cmake", TOOL_DATA);
    }

    static fs::path get_7za_path(const VcpkgPaths& paths)
    {
#if defined(_WIN32)
        static const ToolData TOOL_DATA = parse_tool_data_from_xml(paths, "7zip");
        if (!paths.get_filesystem().exists(TOOL_DATA.exe_path))
        {
            return fetch_tool(paths, "7zip", TOOL_DATA);
        }
        return TOOL_DATA.exe_path;
#else
        Checks::exit_with_message(VCPKG_LINE_INFO, "Cannot download 7zip for non-Windows platforms.");
#endif
    }

    static fs::path get_ninja_path(const VcpkgPaths& paths)
    {
        static const ToolData TOOL_DATA = parse_tool_data_from_xml(paths, "ninja");

        std::vector<fs::path> candidate_paths;
        candidate_paths.push_back(TOOL_DATA.exe_path);
        const std::vector<fs::path> from_path = Files::find_from_PATH("ninja");
        candidate_paths.insert(candidate_paths.end(), from_path.cbegin(), from_path.cend());

        auto path = find_if_has_equal_or_greater_version(candidate_paths, "--version", TOOL_DATA.version);
        if (const auto p = path.get())
        {
            return *p;
        }

        return fetch_tool(paths, "ninja", TOOL_DATA);
    }

    static fs::path get_nuget_path(const VcpkgPaths& paths)
    {
        static const ToolData TOOL_DATA = parse_tool_data_from_xml(paths, "nuget");

        std::vector<fs::path> candidate_paths;
        candidate_paths.push_back(TOOL_DATA.exe_path);
        const std::vector<fs::path> from_path = Files::find_from_PATH("nuget");
        candidate_paths.insert(candidate_paths.end(), from_path.cbegin(), from_path.cend());

        auto path = find_if_has_equal_or_greater_version(candidate_paths, "", TOOL_DATA.version);
        if (const auto p = path.get())
        {
            return *p;
        }

        return fetch_tool(paths, "nuget", TOOL_DATA);
    }

    static fs::path get_git_path(const VcpkgPaths& paths)
    {
        static const ToolData TOOL_DATA = parse_tool_data_from_xml(paths, "git");
        static const std::string VERSION_CHECK_ARGUMENTS = "--version";

        std::vector<fs::path> candidate_paths;
#if defined(_WIN32)
        candidate_paths.push_back(TOOL_DATA.exe_path);
#endif
        const std::vector<fs::path> from_path = Files::find_from_PATH("git");
        candidate_paths.insert(candidate_paths.end(), from_path.cbegin(), from_path.cend());

        const auto& program_files = System::get_program_files_platform_bitness();
        if (const auto pf = program_files.get()) candidate_paths.push_back(*pf / "git" / "cmd" / "git.exe");
        const auto& program_files_32_bit = System::get_program_files_32_bit();
        if (const auto pf = program_files_32_bit.get()) candidate_paths.push_back(*pf / "git" / "cmd" / "git.exe");

        const Optional<fs::path> path =
            find_if_has_equal_or_greater_version(candidate_paths, VERSION_CHECK_ARGUMENTS, TOOL_DATA.version);
        if (const auto p = path.get())
        {
            return *p;
        }

        return fetch_tool(paths, "git", TOOL_DATA);
    }

    static fs::path get_ifw_installerbase_path(const VcpkgPaths& paths)
    {
        static const ToolData TOOL_DATA = parse_tool_data_from_xml(paths, "installerbase");

        static const std::string VERSION_CHECK_ARGUMENTS = "--framework-version";

        std::vector<fs::path> candidate_paths;
        candidate_paths.push_back(TOOL_DATA.exe_path);
        // TODO: Uncomment later
        // const std::vector<fs::path> from_path = Files::find_from_PATH("installerbase");
        // candidate_paths.insert(candidate_paths.end(), from_path.cbegin(), from_path.cend());
        // candidate_paths.push_back(fs::path(System::get_environment_variable("HOMEDRIVE").value_or("C:")) / "Qt" /
        // "Tools" / "QtInstallerFramework" / "3.1" / "bin" / "installerbase.exe");
        // candidate_paths.push_back(fs::path(System::get_environment_variable("HOMEDRIVE").value_or("C:")) / "Qt" /
        // "QtIFW-3.1.0" / "bin" / "installerbase.exe");

        const Optional<fs::path> path =
            find_if_has_equal_or_greater_version(candidate_paths, VERSION_CHECK_ARGUMENTS, TOOL_DATA.version);
        if (const auto p = path.get())
        {
            return *p;
        }

        return fetch_tool(paths, "installerbase", TOOL_DATA);
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

    std::vector<Toolset> find_toolset_instances(const VcpkgPaths& paths)
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

    fs::path get_tool_path(const VcpkgPaths& paths, const std::string& tool)
    {
        // First deal with specially handled tools.
        // For these we may look in locations like Program Files, the PATH etc as well as the auto-downloaded location.
        if (tool == Tools::SEVEN_ZIP) return get_7za_path(paths);
        if (tool == Tools::CMAKE) return get_cmake_path(paths);
        if (tool == Tools::GIT) return get_git_path(paths);
        if (tool == Tools::NINJA) return get_ninja_path(paths);
        if (tool == Tools::NUGET) return get_nuget_path(paths);
        if (tool == Tools::IFW_INSTALLER_BASE) return get_ifw_installerbase_path(paths);
        if (tool == Tools::IFW_BINARYCREATOR)
            return get_ifw_installerbase_path(paths).parent_path() / "binarycreator.exe";
        if (tool == Tools::IFW_REPOGEN) return get_ifw_installerbase_path(paths).parent_path() / "repogen.exe";

        // For other tools, we simply always auto-download them.
        const ToolData tool_data = parse_tool_data_from_xml(paths, tool);
        if (paths.get_filesystem().exists(tool_data.exe_path))
        {
            return tool_data.exe_path;
        }
        return fetch_tool(paths, tool, tool_data);
    }

    const CommandStructure COMMAND_STRUCTURE = {
        Strings::format("The argument should be tool name\n%s", Help::create_example_string("fetch cmake")),
        1,
        1,
        {},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        Util::unused(args.parse_arguments(COMMAND_STRUCTURE));

        const std::string tool = args.command_arguments[0];
        const fs::path tool_path = get_tool_path(paths, tool);
        System::println(tool_path.u8string());
        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
