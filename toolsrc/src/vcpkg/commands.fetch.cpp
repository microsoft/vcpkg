#include "pch.h"

#include <vcpkg/base/archives.h>
#include <vcpkg/base/checks.h>
#include <vcpkg/base/downloads.h>
#include <vcpkg/base/stringrange.h>
#include <vcpkg/base/strings.h>
#include <vcpkg/base/system.h>
#include <vcpkg/base/util.h>
#include <vcpkg/commands.h>
#include <vcpkg/help.h>
#

namespace vcpkg::Commands::Fetch
{
    struct ToolData
    {
        std::array<int, 3> version;
        fs::path exe_path;
        std::string url;
        fs::path download_path;
        bool is_archive;
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

        const std::string tool_data =
            VcpkgStringRange::find_exactly_one_enclosed(XML, match_tool_entry[0], "</tool>").to_string();
        const std::string version_as_string =
            VcpkgStringRange::find_exactly_one_enclosed(tool_data, "<version>", "</version>").to_string();
        const std::string exe_relative_path =
            VcpkgStringRange::find_exactly_one_enclosed(tool_data, "<exeRelativePath>", "</exeRelativePath>")
                .to_string();
        const std::string url = VcpkgStringRange::find_exactly_one_enclosed(tool_data, "<url>", "</url>").to_string();
        const std::string sha512 =
            VcpkgStringRange::find_exactly_one_enclosed(tool_data, "<sha512>", "</sha512>").to_string();
        auto archive_name = VcpkgStringRange::find_at_most_one_enclosed(tool_data, "<archiveName>", "</archiveName>");

        const Optional<std::array<int, 3>> version = parse_version_string(version_as_string);
        Checks::check_exit(VCPKG_LINE_INFO,
                           version.has_value(),
                           "Could not parse version for tool %s. Version string was: %s",
                           tool,
                           version_as_string);

        const std::string tool_dir_name = Strings::format("%s-%s-%s", tool, version_as_string, OS_STRING);
        const fs::path tool_dir_path = paths.tools / tool_dir_name;
        const fs::path exe_path = tool_dir_path / exe_relative_path;

        return ToolData{*version.get(),
                        exe_path,
                        url,
                        paths.downloads / archive_name.value_or(exe_relative_path).to_string(),
                        archive_name.has_value(),
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

    static Optional<fs::path> find_if_has_equal_or_greater_version(Files::Filesystem& fs,
                                                                   const std::vector<fs::path>& candidate_paths,
                                                                   const std::string& version_check_arguments,
                                                                   const std::array<int, 3>& expected_version)
    {
        const auto it = Util::find_if(candidate_paths, [&](const fs::path& p) {
            if (!fs.exists(p)) return false;
            const std::string cmd = Strings::format(R"("%s" %s)", p.u8string(), version_check_arguments);
            return exists_and_has_equal_or_greater_version(cmd, expected_version);
        });

        if (it != candidate_paths.cend())
        {
            return *it;
        }

        return nullopt;
    }
    static fs::path fetch_tool(const VcpkgPaths& paths, const std::string& tool_name, const ToolData& tool_data)
    {
        const std::array<int, 3>& version = tool_data.version;
        const std::string version_as_string = Strings::format("%d.%d.%d", version[0], version[1], version[2]);
        Checks::check_exit(VCPKG_LINE_INFO,
                           !tool_data.url.empty(),
                           "A suitable version of %s was not found (required v%s) and unable to automatically "
                           "download a portable one. Please install a newer version of %s.",
                           tool_name,
                           version_as_string,
                           tool_name);
        System::println("A suitable version of %s was not found (required v%s). Downloading portable %s v%s...",
                        tool_name,
                        version_as_string,
                        tool_name,
                        version_as_string);
        auto& fs = paths.get_filesystem();
        if (!fs.exists(tool_data.download_path))
        {
            System::println("Downloading %s...", tool_name);
            Downloads::download_file(fs, tool_data.url, tool_data.download_path, tool_data.sha512);
            System::println("Downloading %s... done.", tool_name);
        }
        else
        {
            Downloads::verify_downloaded_file_hash(fs, tool_data.url, tool_data.download_path, tool_data.sha512);
        }

        if (tool_data.is_archive)
        {
            System::println("Extracting %s...", tool_name);
            Archives::extract_archive(paths, tool_data.download_path, tool_data.tool_dir_path);
            System::println("Extracting %s... done.", tool_name);
        }
        else
        {
            std::error_code ec;
            fs.create_directories(tool_data.exe_path.parent_path(), ec);
            fs.rename(tool_data.download_path, tool_data.exe_path, ec);
        }

        Checks::check_exit(VCPKG_LINE_INFO,
                           fs.exists(tool_data.exe_path),
                           "Expected %s to exist after fetching",
                           tool_data.exe_path.u8string());

        return tool_data.exe_path;
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

        const Optional<fs::path> path = find_if_has_equal_or_greater_version(
            paths.get_filesystem(), candidate_paths, VERSION_CHECK_ARGUMENTS, TOOL_DATA.version);
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

        auto path = find_if_has_equal_or_greater_version(
            paths.get_filesystem(), candidate_paths, "--version", TOOL_DATA.version);
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

        auto path =
            find_if_has_equal_or_greater_version(paths.get_filesystem(), candidate_paths, "", TOOL_DATA.version);
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

        const Optional<fs::path> path = find_if_has_equal_or_greater_version(
            paths.get_filesystem(), candidate_paths, VERSION_CHECK_ARGUMENTS, TOOL_DATA.version);
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

        const Optional<fs::path> path = find_if_has_equal_or_greater_version(
            paths.get_filesystem(), candidate_paths, VERSION_CHECK_ARGUMENTS, TOOL_DATA.version);
        if (const auto p = path.get())
        {
            return *p;
        }

        return fetch_tool(paths, "installerbase", TOOL_DATA);
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
