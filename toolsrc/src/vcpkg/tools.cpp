#include "pch.h"

#include <vcpkg/archives.h>
#include <vcpkg/tools.h>
#include <vcpkg/vcpkgpaths.h>

#include <vcpkg/base/checks.h>
#include <vcpkg/base/downloads.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/optional.h>
#include <vcpkg/base/stringrange.h>
#include <vcpkg/base/strings.h>
#include <vcpkg/base/system.h>
#include <vcpkg/base/util.h>

namespace vcpkg
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
            StringRange::find_exactly_one_enclosed(XML, match_tool_entry[0], "</tool>").to_string();
        const std::string version_as_string =
            StringRange::find_exactly_one_enclosed(tool_data, "<version>", "</version>").to_string();
        const std::string exe_relative_path =
            StringRange::find_exactly_one_enclosed(tool_data, "<exeRelativePath>", "</exeRelativePath>").to_string();
        const std::string url = StringRange::find_exactly_one_enclosed(tool_data, "<url>", "</url>").to_string();
        const std::string sha512 =
            StringRange::find_exactly_one_enclosed(tool_data, "<sha512>", "</sha512>").to_string();
        auto archive_name = StringRange::find_at_most_one_enclosed(tool_data, "<archiveName>", "</archiveName>");

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

    struct PathAndVersion
    {
        fs::path path;
        std::string version;
    };

    static Optional<PathAndVersion> find_first_with_sufficient_version(const std::vector<PathAndVersion>& candidates,
                                                                       const std::array<int, 3>& expected_version)
    {
        const auto it = Util::find_if(candidates, [&](const PathAndVersion& candidate) {
            const auto parsed_version = parse_version_string(candidate.version);
            if (!parsed_version.has_value())
            {
                return false;
            }

            const std::array<int, 3> actual_version = *parsed_version.get();
            return actual_version[0] > expected_version[0] ||
                   (actual_version[0] == expected_version[0] && actual_version[1] > expected_version[1]) ||
                   (actual_version[0] == expected_version[0] && actual_version[1] == expected_version[1] &&
                    actual_version[2] >= expected_version[2]);
        });

        if (it == candidates.cend())
        {
            return nullopt;
        }

        return *it;
    }

    struct VersionProvider
    {
        virtual Optional<std::string> get_version(const fs::path& path_to_exe) const = 0;

        std::vector<PathAndVersion> get_versions(const std::vector<fs::path>& candidate_paths) const
        {
            auto&& fs = Files::get_real_filesystem();

            std::vector<PathAndVersion> output;
            for (auto&& p : candidate_paths)
            {
                if (!fs.exists(p)) continue;
                auto maybe_version = this->get_version(p);
                if (const auto version = maybe_version.get())
                {
                    output.emplace_back(PathAndVersion{p, *version});
                    return output;
                }
            }

            return output;
        }
    };

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

    static PathAndVersion fetch_tool(const VcpkgPaths& paths,
                                     const std::string& tool_name,
                                     const ToolData& tool_data,
                                     const VersionProvider& version_provider)
    {
        const auto downloaded_path = fetch_tool(paths, tool_name, tool_data);
        const auto downloaded_version = version_provider.get_version(downloaded_path).value_or_exit(VCPKG_LINE_INFO);
        return {downloaded_path, downloaded_version};
    }

    namespace CMake
    {
        struct CmakeVersionProvider : VersionProvider
        {
            Optional<std::string> get_version(const fs::path& path_to_exe) const override
            {
                const std::string cmd = Strings::format(R"("%s" --version)", path_to_exe.u8string());
                const auto rc = System::cmd_execute_and_capture_output(cmd);
                if (rc.exit_code != 0)
                {
                    return nullopt;
                }

                /* Sample output:
    cmake version 3.10.2

    CMake suite maintained and supported by Kitware (kitware.com/cmake).
                    */
                return StringRange::find_exactly_one_enclosed(rc.output, "cmake version ", "\n").to_string();
            }
        };

        static PathAndVersion get_path(const VcpkgPaths& paths)
        {
            std::vector<fs::path> candidate_paths;
#if defined(_WIN32) || defined(__APPLE__) || defined(__linux__)
            static const ToolData TOOL_DATA = parse_tool_data_from_xml(paths, "cmake");
            candidate_paths.push_back(TOOL_DATA.exe_path);
#else
            static const ToolData TOOL_DATA = ToolData{{3, 5, 1}, ""};
#endif
            const std::vector<fs::path> from_path = paths.get_filesystem().find_from_PATH("cmake");
            candidate_paths.insert(candidate_paths.end(), from_path.cbegin(), from_path.cend());

            const auto& program_files = System::get_program_files_platform_bitness();
            if (const auto pf = program_files.get()) candidate_paths.push_back(*pf / "CMake" / "bin" / "cmake.exe");
            const auto& program_files_32_bit = System::get_program_files_32_bit();
            if (const auto pf = program_files_32_bit.get())
                candidate_paths.push_back(*pf / "CMake" / "bin" / "cmake.exe");

            const CmakeVersionProvider version_provider{};
            const std::vector<PathAndVersion> candidates_with_versions = version_provider.get_versions(candidate_paths);
            const auto maybe_path = find_first_with_sufficient_version(candidates_with_versions, TOOL_DATA.version);
            if (const auto p = maybe_path.get())
            {
                return *p;
            }

            return fetch_tool(paths, Tools::CMAKE, TOOL_DATA, version_provider);
        }
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

    namespace Ninja
    {
        struct NinjaVersionProvider : VersionProvider
        {
            Optional<std::string> get_version(const fs::path& path_to_exe) const override
            {
                const std::string cmd = Strings::format(R"("%s" --version)", path_to_exe.u8string());
                const auto rc = System::cmd_execute_and_capture_output(cmd);
                if (rc.exit_code != 0)
                {
                    return nullopt;
                }

                /* Sample output:
    1.8.2
                    */
                return rc.output;
            }
        };

        static PathAndVersion get_path(const VcpkgPaths& paths)
        {
            static const ToolData TOOL_DATA = parse_tool_data_from_xml(paths, "ninja");

            std::vector<fs::path> candidate_paths;
            candidate_paths.push_back(TOOL_DATA.exe_path);
            const std::vector<fs::path> from_path = paths.get_filesystem().find_from_PATH("ninja");
            candidate_paths.insert(candidate_paths.end(), from_path.cbegin(), from_path.cend());

            const NinjaVersionProvider version_provider{};
            const std::vector<PathAndVersion> candidates_with_versions = version_provider.get_versions(candidate_paths);
            const auto maybe_path = find_first_with_sufficient_version(candidates_with_versions, TOOL_DATA.version);
            if (const auto p = maybe_path.get())
            {
                return *p;
            }

            return fetch_tool(paths, Tools::NINJA, TOOL_DATA, version_provider);
        }
    }

    namespace Nuget
    {
        struct NugetVersionProvider : VersionProvider
        {
            Optional<std::string> get_version(const fs::path& path_to_exe) const override
            {
                const std::string cmd = Strings::format(R"("%s")", path_to_exe.u8string());
                const auto rc = System::cmd_execute_and_capture_output(cmd);
                if (rc.exit_code != 0)
                {
                    return nullopt;
                }

                /* Sample output:
    NuGet Version: 4.6.2.5055
    usage: NuGet <command> [args] [options]
    Type 'NuGet help <command>' for help on a specific command.

    [[[List of available commands follows]]]
                    */
                return StringRange::find_exactly_one_enclosed(rc.output, "NuGet Version: ", "\n").to_string();
            }
        };

        static PathAndVersion get_path(const VcpkgPaths& paths)
        {
            static const ToolData TOOL_DATA = parse_tool_data_from_xml(paths, "nuget");

            std::vector<fs::path> candidate_paths;
            candidate_paths.push_back(TOOL_DATA.exe_path);
            const std::vector<fs::path> from_path = paths.get_filesystem().find_from_PATH("nuget");
            candidate_paths.insert(candidate_paths.end(), from_path.cbegin(), from_path.cend());

            const NugetVersionProvider version_provider{};
            const std::vector<PathAndVersion> candidates_with_versions = version_provider.get_versions(candidate_paths);
            const auto maybe_path = find_first_with_sufficient_version(candidates_with_versions, TOOL_DATA.version);
            if (const auto p = maybe_path.get())
            {
                return *p;
            }

            return fetch_tool(paths, Tools::NUGET, TOOL_DATA, version_provider);
        }
    }

    namespace Git
    {
        struct GitVersionProvider : VersionProvider
        {
            Optional<std::string> get_version(const fs::path& path_to_exe) const override
            {
                const std::string cmd = Strings::format(R"("%s" --version)", path_to_exe.u8string());
                const auto rc = System::cmd_execute_and_capture_output(cmd);
                if (rc.exit_code != 0)
                {
                    return nullopt;
                }

                /* Sample output:
    git version 2.17.1.windows.2
                    */
                const auto idx = rc.output.find("git version ");
                Checks::check_exit(VCPKG_LINE_INFO,
                                   idx != std::string::npos,
                                   "Unexpected format of git version string: %s",
                                   rc.output);
                return rc.output.substr(idx);
            }
        };

        static PathAndVersion get_path(const VcpkgPaths& paths)
        {
            static const ToolData TOOL_DATA = parse_tool_data_from_xml(paths, "git");

            std::vector<fs::path> candidate_paths;
#if defined(_WIN32)
            candidate_paths.push_back(TOOL_DATA.exe_path);
#endif
            const std::vector<fs::path> from_path = paths.get_filesystem().find_from_PATH("git");
            candidate_paths.insert(candidate_paths.end(), from_path.cbegin(), from_path.cend());

            const auto& program_files = System::get_program_files_platform_bitness();
            if (const auto pf = program_files.get()) candidate_paths.push_back(*pf / "git" / "cmd" / "git.exe");
            const auto& program_files_32_bit = System::get_program_files_32_bit();
            if (const auto pf = program_files_32_bit.get()) candidate_paths.push_back(*pf / "git" / "cmd" / "git.exe");

            const GitVersionProvider version_provider{};
            const std::vector<PathAndVersion> candidates_with_versions = version_provider.get_versions(candidate_paths);
            const auto maybe_path = find_first_with_sufficient_version(candidates_with_versions, TOOL_DATA.version);
            if (const auto p = maybe_path.get())
            {
                return *p;
            }

            return fetch_tool(paths, Tools::GIT, TOOL_DATA, version_provider);
        }
    }

    namespace IfwInstallerBase
    {
        struct IfwInstallerBaseVersionProvider : VersionProvider
        {
            Optional<std::string> get_version(const fs::path& path_to_exe) const override
            {
                const std::string cmd = Strings::format(R"("%s" --framework-version)", path_to_exe.u8string());
                const auto rc = System::cmd_execute_and_capture_output(cmd);
                if (rc.exit_code != 0)
                {
                    return nullopt;
                }

                /* Sample output:
    3.1.81
                    */
                return rc.output;
            }
        };

        static PathAndVersion get_path(const VcpkgPaths& paths)
        {
            static const ToolData TOOL_DATA = parse_tool_data_from_xml(paths, "installerbase");

            std::vector<fs::path> candidate_paths;
            candidate_paths.push_back(TOOL_DATA.exe_path);
            // TODO: Uncomment later
            // const std::vector<fs::path> from_path = Files::find_from_PATH("installerbase");
            // candidate_paths.insert(candidate_paths.end(), from_path.cbegin(), from_path.cend());
            // candidate_paths.push_back(fs::path(System::get_environment_variable("HOMEDRIVE").value_or("C:")) / "Qt" /
            // "Tools" / "QtInstallerFramework" / "3.1" / "bin" / "installerbase.exe");
            // candidate_paths.push_back(fs::path(System::get_environment_variable("HOMEDRIVE").value_or("C:")) / "Qt" /
            // "QtIFW-3.1.0" / "bin" / "installerbase.exe");

            const IfwInstallerBaseVersionProvider version_provider{};
            const std::vector<PathAndVersion> candidates_with_versions = version_provider.get_versions(candidate_paths);
            const auto maybe_path = find_first_with_sufficient_version(candidates_with_versions, TOOL_DATA.version);
            if (const auto p = maybe_path.get())
            {
                return *p;
            }

            return fetch_tool(paths, Tools::IFW_INSTALLER_BASE, TOOL_DATA, version_provider);
        }
    }

    struct ToolCacheImpl final : ToolCache
    {
        vcpkg::Cache<std::string, fs::path> path_only_cache;
        vcpkg::Cache<std::string, PathAndVersion> path_version_cache;

        virtual const fs::path& get_tool_path(const VcpkgPaths& paths, const std::string& tool) const override
        {
            return path_only_cache.get_lazy(tool, [&]() {
                // First deal with specially handled tools.
                // For these we may look in locations like Program Files, the PATH etc as well as the auto-downloaded
                // location.
                if (tool == Tools::SEVEN_ZIP) return get_7za_path(paths);
                if (tool == Tools::CMAKE || tool == Tools::GIT || tool == Tools::NINJA || tool == Tools::NUGET ||
                    tool == Tools::IFW_INSTALLER_BASE)
                    return get_tool_pathversion(paths, tool).path;
                if (tool == Tools::IFW_BINARYCREATOR)
                    return IfwInstallerBase::get_path(paths).path.parent_path() / "binarycreator.exe";
                if (tool == Tools::IFW_REPOGEN)
                    return IfwInstallerBase::get_path(paths).path.parent_path() / "repogen.exe";

                // For other tools, we simply always auto-download them.
                const ToolData tool_data = parse_tool_data_from_xml(paths, tool);
                if (paths.get_filesystem().exists(tool_data.exe_path))
                {
                    return tool_data.exe_path;
                }
                return fetch_tool(paths, tool, tool_data);
            });
        }

        const PathAndVersion& get_tool_pathversion(const VcpkgPaths& paths, const std::string& tool) const
        {
            return path_version_cache.get_lazy(tool, [&]() {
                if (tool == Tools::CMAKE) return CMake::get_path(paths);
                if (tool == Tools::GIT) return Git::get_path(paths);
                if (tool == Tools::NINJA) return Ninja::get_path(paths);
                if (tool == Tools::NUGET) return Nuget::get_path(paths);
                if (tool == Tools::IFW_INSTALLER_BASE) return IfwInstallerBase::get_path(paths);

                Checks::exit_with_message(VCPKG_LINE_INFO, "Finding version for %s is not implemented yet.", tool);
            });
        }

        virtual const std::string& get_tool_version(const VcpkgPaths& paths, const std::string& tool) const override
        {
            return get_tool_pathversion(paths, tool).version;
        }
    };

    std::unique_ptr<ToolCache> get_tool_cache() { return std::make_unique<ToolCacheImpl>(); }
}
