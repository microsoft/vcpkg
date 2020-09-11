#include <vcpkg/base/checks.h>
#include <vcpkg/base/downloads.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/optional.h>
#include <vcpkg/base/strings.h>
#include <vcpkg/base/stringview.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/base/util.h>

#include <vcpkg/archives.h>
#include <vcpkg/tools.h>
#include <vcpkg/vcpkgpaths.h>

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

    static ExpectedT<ToolData, std::string> parse_tool_data_from_xml(const VcpkgPaths& paths, const std::string& tool)
    {
#if defined(_WIN32)
        static constexpr StringLiteral OS_STRING = "windows";
#elif defined(__APPLE__)
        static constexpr StringLiteral OS_STRING = "osx";
#elif defined(__linux__)
        static constexpr StringLiteral OS_STRING = "linux";
#elif defined(__FreeBSD__)
        static constexpr StringLiteral OS_STRING = "freebsd";
#else
        return std::string("operating system is unknown");
#endif

#if defined(_WIN32) || defined(__APPLE__) || defined(__linux__) || defined(__FreeBSD__)
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
                           fs::u8string(XML_PATH));
        Checks::check_exit(VCPKG_LINE_INFO,
                           XML_VERSION == match_xml_version[1],
                           "Expected %s version: [%s], but was [%s]. Please re-run bootstrap-vcpkg.",
                           fs::u8string(XML_PATH),
                           XML_VERSION,
                           match_xml_version[1]);

        const std::regex tool_regex{Strings::format(R"###(<tool[\s]+name="%s"[\s]+os="%s">)###", tool, OS_STRING)};
        std::smatch match_tool_entry;
        const bool has_tool_entry = std::regex_search(XML.cbegin(), XML.cend(), match_tool_entry, tool_regex);
        if (!has_tool_entry)
        {
            return Strings::format("Could not automatically acquire %s because there is no entry in %s for os=%s. You "
                                   "may be able to install %s via your system package manager.",
                                   tool,
                                   fs::u8string(XML_PATH),
                                   OS_STRING,
                                   tool);
        }

        const std::string tool_data =
            StringView::find_exactly_one_enclosed(XML, match_tool_entry[0], "</tool>").to_string();
        const std::string version_as_string =
            StringView::find_exactly_one_enclosed(tool_data, "<version>", "</version>").to_string();
        const std::string exe_relative_path =
            StringView::find_exactly_one_enclosed(tool_data, "<exeRelativePath>", "</exeRelativePath>").to_string();
        const std::string url = StringView::find_exactly_one_enclosed(tool_data, "<url>", "</url>").to_string();
        const std::string sha512 =
            StringView::find_exactly_one_enclosed(tool_data, "<sha512>", "</sha512>").to_string();
        auto archive_name = StringView::find_at_most_one_enclosed(tool_data, "<archiveName>", "</archiveName>");

        const Optional<std::array<int, 3>> version = parse_version_string(version_as_string);
        Checks::check_exit(VCPKG_LINE_INFO,
                           version.has_value(),
                           "Could not parse version for tool %s. Version string was: %s",
                           tool,
                           version_as_string);

        const std::string tool_dir_name = Strings::format("%s-%s-%s", tool, version_as_string, OS_STRING);
        const fs::path tool_dir_path = paths.tools / tool_dir_name;
        const fs::path exe_path = tool_dir_path / exe_relative_path;
        fs::path download_path;
        if (auto a = archive_name.get())
        {
            download_path = paths.downloads / fs::u8path(a->to_string());
        }
        else
        {
            download_path = paths.downloads / fs::u8path(Strings::concat(sha512.substr(0, 8), '-', exe_relative_path));
        }

        return ToolData{*version.get(), exe_path, url, download_path, archive_name.has_value(), tool_dir_path, sha512};
#endif
    }

    struct PathAndVersion
    {
        fs::path path;
        std::string version;
    };

    struct ToolProvider
    {
        virtual const std::string& tool_data_name() const = 0;
        virtual const std::string& exe_stem() const = 0;
        virtual std::array<int, 3> default_min_version() const = 0;

        virtual void add_special_paths(std::vector<fs::path>& out_candidate_paths) const { (void)out_candidate_paths; }
        virtual Optional<std::string> get_version(const VcpkgPaths& paths, const fs::path& path_to_exe) const = 0;
    };

    static Optional<PathAndVersion> find_first_with_sufficient_version(const VcpkgPaths& paths,
                                                                       const ToolProvider& tool_provider,
                                                                       const std::vector<fs::path>& candidates,
                                                                       const std::array<int, 3>& expected_version)
    {
        const auto& fs = paths.get_filesystem();
        for (auto&& candidate : candidates)
        {
            if (!fs.exists(candidate)) continue;
            auto maybe_version = tool_provider.get_version(paths, candidate);
            const auto version = maybe_version.get();
            if (!version) continue;
            const auto parsed_version = parse_version_string(*version);
            if (!parsed_version) continue;
            auto& actual_version = *parsed_version.get();
            const auto version_acceptable =
                actual_version[0] > expected_version[0] ||
                (actual_version[0] == expected_version[0] && actual_version[1] > expected_version[1]) ||
                (actual_version[0] == expected_version[0] && actual_version[1] == expected_version[1] &&
                 actual_version[2] >= expected_version[2]);
            if (!version_acceptable) continue;

            return PathAndVersion{candidate, *version};
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
        System::printf("A suitable version of %s was not found (required v%s). Downloading portable %s v%s...\n",
                       tool_name,
                       version_as_string,
                       tool_name,
                       version_as_string);
        auto& fs = paths.get_filesystem();
        if (!fs.exists(tool_data.download_path))
        {
            System::print2("Downloading ", tool_name, "...\n");
            System::print2("  ", tool_data.url, " -> ", fs::u8string(tool_data.download_path), "\n");
            Downloads::download_file(fs, tool_data.url, tool_data.download_path, tool_data.sha512);
        }
        else
        {
            Downloads::verify_downloaded_file_hash(fs, tool_data.url, tool_data.download_path, tool_data.sha512);
        }

        if (tool_data.is_archive)
        {
            System::print2("Extracting ", tool_name, "...\n");
            Archives::extract_archive(paths, tool_data.download_path, tool_data.tool_dir_path);
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
                           fs::u8string(tool_data.exe_path));

        return tool_data.exe_path;
    }

    static PathAndVersion fetch_tool(const VcpkgPaths& paths,
                                     const ToolProvider& tool_provider,
                                     const ToolData& tool_data)
    {
        const auto downloaded_path = fetch_tool(paths, tool_provider.tool_data_name(), tool_data);
        const auto downloaded_version =
            tool_provider.get_version(paths, downloaded_path).value_or_exit(VCPKG_LINE_INFO);
        return {downloaded_path, downloaded_version};
    }

    static PathAndVersion get_path(const VcpkgPaths& paths, const ToolProvider& tool)
    {
        auto& fs = paths.get_filesystem();

        std::array<int, 3> min_version = tool.default_min_version();

        std::vector<fs::path> candidate_paths;
        auto maybe_tool_data = parse_tool_data_from_xml(paths, tool.tool_data_name());
        if (auto tool_data = maybe_tool_data.get())
        {
            candidate_paths.push_back(tool_data->exe_path);
            min_version = tool_data->version;
        }

        auto& exe_stem = tool.exe_stem();
        if (!exe_stem.empty())
        {
            auto paths_from_path = fs.find_from_PATH(exe_stem);
            candidate_paths.insert(candidate_paths.end(), paths_from_path.cbegin(), paths_from_path.cend());
        }

        tool.add_special_paths(candidate_paths);

        const auto maybe_path = find_first_with_sufficient_version(paths, tool, candidate_paths, min_version);
        if (const auto p = maybe_path.get())
        {
            return *p;
        }
        if (auto tool_data = maybe_tool_data.get())
        {
            return fetch_tool(paths, tool, *tool_data);
        }

        Checks::exit_with_message(VCPKG_LINE_INFO, maybe_tool_data.error());
    }

    struct CMakeProvider : ToolProvider
    {
        std::string m_exe = "cmake";

        virtual const std::string& tool_data_name() const override { return m_exe; }
        virtual const std::string& exe_stem() const override { return m_exe; }
        virtual std::array<int, 3> default_min_version() const override { return {3, 17, 1}; }

        virtual void add_special_paths(std::vector<fs::path>& out_candidate_paths) const override
        {
#if defined(_WIN32)
            const auto& program_files = System::get_program_files_platform_bitness();
            if (const auto pf = program_files.get()) out_candidate_paths.push_back(*pf / "CMake" / "bin" / "cmake.exe");
            const auto& program_files_32_bit = System::get_program_files_32_bit();
            if (const auto pf = program_files_32_bit.get())
                out_candidate_paths.push_back(*pf / "CMake" / "bin" / "cmake.exe");
#else
            // TODO: figure out if this should do anything on non-Windows
            (void)out_candidate_paths;
#endif
        }
        virtual Optional<std::string> get_version(const VcpkgPaths&, const fs::path& path_to_exe) const override
        {
            const std::string cmd = Strings::format(R"("%s" --version)", fs::u8string(path_to_exe));
            const auto rc = System::cmd_execute_and_capture_output(cmd);
            if (rc.exit_code != 0)
            {
                return nullopt;
            }

            /* Sample output:
cmake version 3.10.2

CMake suite maintained and supported by Kitware (kitware.com/cmake).
                */
            return StringView::find_exactly_one_enclosed(rc.output, "cmake version ", "\n").to_string();
        }
    };

    struct NinjaProvider : ToolProvider
    {
        std::string m_exe = "ninja";

        virtual const std::string& tool_data_name() const override { return m_exe; }
        virtual const std::string& exe_stem() const override { return m_exe; }
        virtual std::array<int, 3> default_min_version() const override { return {3, 5, 1}; }

        virtual Optional<std::string> get_version(const VcpkgPaths&, const fs::path& path_to_exe) const override
        {
            const std::string cmd = Strings::format(R"("%s" --version)", fs::u8string(path_to_exe));
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

    struct NuGetProvider : ToolProvider
    {
        std::string m_exe = "nuget";

        virtual const std::string& tool_data_name() const override { return m_exe; }
        virtual const std::string& exe_stem() const override { return m_exe; }
        virtual std::array<int, 3> default_min_version() const override { return {4, 6, 2}; }

        virtual Optional<std::string> get_version(const VcpkgPaths& paths, const fs::path& path_to_exe) const override
        {
            System::CmdLineBuilder cmd;
#ifndef _WIN32
            cmd.path_arg(paths.get_tool_exe(Tools::MONO));
#else
            (void)paths;
#endif
            cmd.path_arg(path_to_exe);
            const auto rc = System::cmd_execute_and_capture_output(cmd.extract());
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
            return StringView::find_exactly_one_enclosed(rc.output, "NuGet Version: ", "\n").to_string();
        }
    };

    struct GitProvider : ToolProvider
    {
        std::string m_exe = "git";

        virtual const std::string& tool_data_name() const override { return m_exe; }
        virtual const std::string& exe_stem() const override { return m_exe; }
        virtual std::array<int, 3> default_min_version() const override { return {2, 7, 4}; }

        virtual void add_special_paths(std::vector<fs::path>& out_candidate_paths) const override
        {
#if defined(_WIN32)
            const auto& program_files = System::get_program_files_platform_bitness();
            if (const auto pf = program_files.get()) out_candidate_paths.push_back(*pf / "git" / "cmd" / "git.exe");
            const auto& program_files_32_bit = System::get_program_files_32_bit();
            if (const auto pf = program_files_32_bit.get())
                out_candidate_paths.push_back(*pf / "git" / "cmd" / "git.exe");
#else
            // TODO: figure out if this should do anything on non-windows
            (void)out_candidate_paths;
#endif
        }

        virtual Optional<std::string> get_version(const VcpkgPaths&, const fs::path& path_to_exe) const override
        {
            const std::string cmd = Strings::format(R"("%s" --version)", fs::u8string(path_to_exe));
            const auto rc = System::cmd_execute_and_capture_output(cmd);
            if (rc.exit_code != 0)
            {
                return nullopt;
            }

            /* Sample output:
git version 2.17.1.windows.2
                */
            const auto idx = rc.output.find("git version ");
            Checks::check_exit(
                VCPKG_LINE_INFO, idx != std::string::npos, "Unexpected format of git version string: %s", rc.output);
            return rc.output.substr(idx);
        }
    };

    struct MonoProvider : ToolProvider
    {
        std::string m_exe = "mono";

        virtual const std::string& tool_data_name() const override { return m_exe; }
        virtual const std::string& exe_stem() const override { return m_exe; }
        virtual std::array<int, 3> default_min_version() const override { return {0, 0, 0}; }

        virtual Optional<std::string> get_version(const VcpkgPaths&, const fs::path& path_to_exe) const override
        {
            const auto rc = System::cmd_execute_and_capture_output(
                System::CmdLineBuilder().path_arg(path_to_exe).string_arg("--version").extract());
            if (rc.exit_code != 0)
            {
                return nullopt;
            }

            /* Sample output:
Mono JIT compiler version 6.8.0.105 (Debian 6.8.0.105+dfsg-2 Wed Feb 26 23:23:50 UTC 2020)
                */
            const auto idx = rc.output.find("Mono JIT compiler version ");
            Checks::check_exit(
                VCPKG_LINE_INFO, idx != std::string::npos, "Unexpected format of mono version string: %s", rc.output);
            return rc.output.substr(idx);
        }
    };

    struct IfwInstallerBaseProvider : ToolProvider
    {
        std::string m_exe;
        std::string m_toolname = "installerbase";

        virtual const std::string& tool_data_name() const override { return m_toolname; }
        virtual const std::string& exe_stem() const override { return m_exe; }
        virtual std::array<int, 3> default_min_version() const override { return {0, 0, 0}; }

        virtual void add_special_paths(std::vector<fs::path>& out_candidate_paths) const override
        {
            (void)out_candidate_paths;
            // TODO: Uncomment later
            // const std::vector<fs::path> from_path = Files::find_from_PATH("installerbase");
            // candidate_paths.insert(candidate_paths.end(), from_path.cbegin(), from_path.cend());
            // candidate_paths.push_back(fs::path(System::get_environment_variable("HOMEDRIVE").value_or("C:")) /
            // "Qt" / "Tools" / "QtInstallerFramework" / "3.1" / "bin" / "installerbase.exe");
            // candidate_paths.push_back(fs::path(System::get_environment_variable("HOMEDRIVE").value_or("C:")) /
            // "Qt" / "QtIFW-3.1.0" / "bin" / "installerbase.exe");
        }

        virtual Optional<std::string> get_version(const VcpkgPaths&, const fs::path& path_to_exe) const override
        {
            const std::string cmd = Strings::format(R"("%s" --framework-version)", fs::u8string(path_to_exe));
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

    struct ToolCacheImpl final : ToolCache
    {
        vcpkg::Cache<std::string, fs::path> path_only_cache;
        vcpkg::Cache<std::string, PathAndVersion> path_version_cache;

        virtual const fs::path& get_tool_path(const VcpkgPaths& paths, const std::string& tool) const override
        {
            return path_only_cache.get_lazy(tool, [&]() {
                if (tool == Tools::IFW_BINARYCREATOR)
                    return get_tool_path(paths, Tools::IFW_INSTALLER_BASE).parent_path() / "binarycreator.exe";
                if (tool == Tools::IFW_REPOGEN)
                    return get_tool_path(paths, Tools::IFW_INSTALLER_BASE).parent_path() / "repogen.exe";

                return get_tool_pathversion(paths, tool).path;
            });
        }

        const PathAndVersion& get_tool_pathversion(const VcpkgPaths& paths, const std::string& tool) const
        {
            return path_version_cache.get_lazy(tool, [&]() -> PathAndVersion {
                // First deal with specially handled tools.
                // For these we may look in locations like Program Files, the PATH etc as well as the auto-downloaded
                // location.
                if (tool == Tools::CMAKE)
                {
                    if (System::get_environment_variable("VCPKG_FORCE_SYSTEM_BINARIES").has_value())
                    {
                        return {"cmake", "0"};
                    }
                    return get_path(paths, CMakeProvider());
                }
                if (tool == Tools::GIT)
                {
                    if (System::get_environment_variable("VCPKG_FORCE_SYSTEM_BINARIES").has_value())
                    {
                        return {"git", "0"};
                    }
                    return get_path(paths, GitProvider());
                }
                if (tool == Tools::NINJA)
                {
                    if (System::get_environment_variable("VCPKG_FORCE_SYSTEM_BINARIES").has_value())
                    {
                        return {"ninja", "0"};
                    }
                    return get_path(paths, NinjaProvider());
                }
                if (tool == Tools::NUGET) return get_path(paths, NuGetProvider());
                if (tool == Tools::IFW_INSTALLER_BASE) return get_path(paths, IfwInstallerBaseProvider());
                if (tool == Tools::MONO) return get_path(paths, MonoProvider());

                // For other tools, we simply always auto-download them.
                auto maybe_tool_data = parse_tool_data_from_xml(paths, tool);
                if (auto p_tool_data = maybe_tool_data.get())
                {
                    if (paths.get_filesystem().exists(p_tool_data->exe_path))
                    {
                        return {p_tool_data->exe_path, p_tool_data->sha512};
                    }
                    return {fetch_tool(paths, tool, *p_tool_data), p_tool_data->sha512};
                }

                Checks::exit_with_message(VCPKG_LINE_INFO, "Unknown or unavailable tool: %s", tool);
            });
        }

        virtual const std::string& get_tool_version(const VcpkgPaths& paths, const std::string& tool) const override
        {
            return get_tool_pathversion(paths, tool).version;
        }
    };

    std::unique_ptr<ToolCache> get_tool_cache() { return std::make_unique<ToolCacheImpl>(); }
}
