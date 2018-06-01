#include "pch.h"

#include <vcpkg/base/checks.h>
#include <vcpkg/base/sortedvector.h>
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

    struct VcpkgStringRange
    {
        VcpkgStringRange() = default;

        // Implicit by design
        VcpkgStringRange(const std::string& s) : begin(s.cbegin()), end(s.cend()) {}

        VcpkgStringRange(const std::string::const_iterator begin, const std::string::const_iterator end)
            : begin(begin), end(end)
        {
        }

        std::string::const_iterator begin;
        std::string::const_iterator end;

        std::string to_string() const { return std::string(this->begin, this->end); }
    };

    static std::vector<VcpkgStringRange> find_all_enclosed(const VcpkgStringRange& input,
                                                           const std::string& left_delim,
                                                           const std::string& right_delim)
    {
        std::string::const_iterator it_left = input.begin;
        std::string::const_iterator it_right = input.begin;

        std::vector<VcpkgStringRange> output;

        while (true)
        {
            it_left = std::search(it_right, input.end, left_delim.cbegin(), left_delim.cend());
            if (it_left == input.end) break;

            it_left += left_delim.length();

            it_right = std::search(it_left, input.end, right_delim.cbegin(), right_delim.cend());
            if (it_right == input.end) break;

            output.emplace_back(it_left, it_right);

            ++it_right;
        }

        return output;
    }

    static VcpkgStringRange find_exactly_one_enclosed(const VcpkgStringRange& input,
                                                      const std::string& left_tag,
                                                      const std::string& right_tag)
    {
        std::vector<VcpkgStringRange> result = find_all_enclosed(input, left_tag, right_tag);
        Checks::check_exit(VCPKG_LINE_INFO,
                           result.size() == 1,
                           "Found %d sets of %s.*%s but expected exactly 1, in block:\n%s",
                           result.size(),
                           left_tag,
                           right_tag,
                           input);
        return std::move(result.front());
    }

    static Optional<VcpkgStringRange> find_at_most_one_enclosed(const VcpkgStringRange& input,
                                                                const std::string& left_tag,
                                                                const std::string& right_tag)
    {
        std::vector<VcpkgStringRange> result = find_all_enclosed(input, left_tag, right_tag);
        Checks::check_exit(VCPKG_LINE_INFO,
                           result.size() <= 1,
                           "Found %d sets of %s.*%s but expected at most 1, in block:\n%s",
                           result.size(),
                           left_tag,
                           right_tag,
                           input);

        if (result.empty())
        {
            return nullopt;
        }

        return result.front();
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

        const std::string tool_data = find_exactly_one_enclosed(XML, match_tool_entry[0], "</tool>").to_string();
        const std::string version_as_string =
            find_exactly_one_enclosed(tool_data, "<version>", "</version>").to_string();
        const std::string exe_relative_path =
            find_exactly_one_enclosed(tool_data, "<exeRelativePath>", "</exeRelativePath>").to_string();
        const std::string url = find_exactly_one_enclosed(tool_data, "<url>", "</url>").to_string();
        const std::string sha512 = find_exactly_one_enclosed(tool_data, "<sha512>", "</sha512>").to_string();
        auto archive_name = find_at_most_one_enclosed(tool_data, "<archiveName>", "</archiveName>");

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

    static void extract_archive(const VcpkgPaths& paths, const fs::path& archive, const fs::path& to_path)
    {
        Files::Filesystem& fs = paths.get_filesystem();
        const fs::path to_path_partial = to_path.u8string() + ".partial";

        std::error_code ec;
        fs.remove_all(to_path, ec);
        fs.remove_all(to_path_partial, ec);
        fs.create_directories(to_path_partial, ec);
        const auto ext = archive.extension();
#if defined(_WIN32)
        if (ext == ".nupkg")
        {
            static bool recursion_limiter_sevenzip_old = false;
            Checks::check_exit(VCPKG_LINE_INFO, !recursion_limiter_sevenzip_old);
            recursion_limiter_sevenzip_old = true;
            const auto nuget_exe = get_tool_path(paths, Tools::NUGET);

            const std::string stem = archive.stem().u8string();
            // assuming format of [name].[version in the form d.d.d]
            // This assumption may not always hold
            std::smatch match;
            const bool has_match = std::regex_match(stem, match, std::regex{R"###(^(.+)\.(\d+\.\d+\.\d+)$)###"});
            Checks::check_exit(VCPKG_LINE_INFO,
                               has_match,
                               "Could not deduce nuget id and version from filename: %s",
                               archive.u8string());

            const std::string nugetid = match[1];
            const std::string version = match[2];

            const auto code_and_output = System::cmd_execute_and_capture_output(Strings::format(
                R"("%s" install %s -Version %s -OutputDirectory "%s" -Source "%s" -nocache -DirectDownload -NonInteractive -ForceEnglishOutput -PackageSaveMode nuspec)",
                nuget_exe.u8string(),
                nugetid,
                version,
                to_path_partial.u8string(),
                paths.downloads.u8string()));

            Checks::check_exit(VCPKG_LINE_INFO,
                               code_and_output.exit_code == 0,
                               "Failed to extract '%s' with message:\n%s",
                               archive.u8string(),
                               code_and_output.output);
            recursion_limiter_sevenzip_old = false;
        }
        else
        {
            static bool recursion_limiter_sevenzip = false;
            Checks::check_exit(VCPKG_LINE_INFO, !recursion_limiter_sevenzip);
            recursion_limiter_sevenzip = true;
            const auto seven_zip = get_tool_path(paths, Tools::SEVEN_ZIP);
            const auto code_and_output = System::cmd_execute_and_capture_output(Strings::format(
                R"("%s" x "%s" -o"%s" -y)", seven_zip.u8string(), archive.u8string(), to_path_partial.u8string()));
            Checks::check_exit(VCPKG_LINE_INFO,
                               code_and_output.exit_code == 0,
                               "7zip failed while extracting '%s' with message:\n%s",
                               archive.u8string(),
                               code_and_output.output);
            recursion_limiter_sevenzip = false;
        }
#else
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
#endif

        fs.rename(to_path_partial, to_path, ec);
        Checks::check_exit(VCPKG_LINE_INFO,
                           !ec,
                           "Failed to do post-extract rename-in-place.\nfs.rename(%s, %s, %s)",
                           to_path_partial.u8string(),
                           to_path.u8string(),
                           ec.message());
    }

    static void verify_hash(const Files::Filesystem& fs,
                            const std::string& url,
                            const fs::path& path,
                            const std::string& sha512)
    {
        const std::string actual_hash = Hash::get_file_hash(fs, path, "SHA512");
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

#if defined(_WIN32)
    static void winhttp_download_file(Files::Filesystem& fs,
                                      CStringView target_file_path,
                                      CStringView hostname,
                                      CStringView url_path)
    {
        // Make sure the directories are present, otherwise fopen_s fails
        const auto dir = fs::path(target_file_path.c_str()).parent_path();
        std::error_code ec;
        fs.create_directories(dir, ec);
        Checks::check_exit(VCPKG_LINE_INFO, !ec, "Could not create directories %s", dir.u8string());

        FILE* f = nullptr;
        const errno_t err = fopen_s(&f, target_file_path.c_str(), "wb");
        Checks::check_exit(VCPKG_LINE_INFO,
                           !err,
                           "Could not download https://%s%s. Failed to open file %s. Error code was %s",
                           hostname,
                           url_path,
                           target_file_path,
                           std::to_string(err));

        auto hSession = WinHttpOpen(
            L"vcpkg/1.0", WINHTTP_ACCESS_TYPE_DEFAULT_PROXY, WINHTTP_NO_PROXY_NAME, WINHTTP_NO_PROXY_BYPASS, 0);
        Checks::check_exit(VCPKG_LINE_INFO, hSession, "WinHttpOpen() failed: %d", GetLastError());

        // Use Windows 10 defaults on Windows 7
        DWORD secure_protocols(WINHTTP_FLAG_SECURE_PROTOCOL_SSL3 | WINHTTP_FLAG_SECURE_PROTOCOL_TLS1 |
                               WINHTTP_FLAG_SECURE_PROTOCOL_TLS1_1 | WINHTTP_FLAG_SECURE_PROTOCOL_TLS1_2);
        WinHttpSetOption(hSession, WINHTTP_OPTION_SECURE_PROTOCOLS, &secure_protocols, sizeof(secure_protocols));

        // Specify an HTTP server.
        auto hConnect = WinHttpConnect(hSession, Strings::to_utf16(hostname).c_str(), INTERNET_DEFAULT_HTTPS_PORT, 0);
        Checks::check_exit(VCPKG_LINE_INFO, hConnect, "WinHttpConnect() failed: %d", GetLastError());

        // Create an HTTP request handle.
        auto hRequest = WinHttpOpenRequest(hConnect,
                                           L"GET",
                                           Strings::to_utf16(url_path).c_str(),
                                           nullptr,
                                           WINHTTP_NO_REFERER,
                                           WINHTTP_DEFAULT_ACCEPT_TYPES,
                                           WINHTTP_FLAG_SECURE);
        Checks::check_exit(VCPKG_LINE_INFO, hRequest, "WinHttpOpenRequest() failed: %d", GetLastError());

        // Send a request.
        auto bResults =
            WinHttpSendRequest(hRequest, WINHTTP_NO_ADDITIONAL_HEADERS, 0, WINHTTP_NO_REQUEST_DATA, 0, 0, 0);
        Checks::check_exit(VCPKG_LINE_INFO, bResults, "WinHttpSendRequest() failed: %d", GetLastError());

        // End the request.
        bResults = WinHttpReceiveResponse(hRequest, NULL);
        Checks::check_exit(VCPKG_LINE_INFO, bResults, "WinHttpReceiveResponse() failed: %d", GetLastError());

        std::vector<char> buf;

        size_t total_downloaded_size = 0;
        DWORD dwSize = 0;
        do
        {
            DWORD downloaded_size = 0;
            bResults = WinHttpQueryDataAvailable(hRequest, &dwSize);
            Checks::check_exit(VCPKG_LINE_INFO, bResults, "WinHttpQueryDataAvailable() failed: %d", GetLastError());

            if (buf.size() < dwSize) buf.resize(dwSize * 2);

            bResults = WinHttpReadData(hRequest, (LPVOID)buf.data(), dwSize, &downloaded_size);
            Checks::check_exit(VCPKG_LINE_INFO, bResults, "WinHttpReadData() failed: %d", GetLastError());
            fwrite(buf.data(), 1, downloaded_size, f);

            total_downloaded_size += downloaded_size;
        } while (dwSize > 0);

        WinHttpCloseHandle(hSession);
        WinHttpCloseHandle(hConnect);
        WinHttpCloseHandle(hRequest);
        fflush(f);
        fclose(f);
    }
#endif

    static void download_file(Files::Filesystem& fs,
                              const std::string& url,
                              const fs::path& download_path,
                              const std::string& sha512)
    {
        const std::string download_path_part = download_path.u8string() + ".part";
        std::error_code ec;
        fs.remove(download_path, ec);
        fs.remove(download_path_part, ec);
#if defined(_WIN32)
        auto url_no_proto = url.substr(8); // drop https://
        auto path_begin = Util::find(url_no_proto, '/');
        std::string hostname(url_no_proto.begin(), path_begin);
        std::string path(path_begin, url_no_proto.end());

        winhttp_download_file(fs, download_path_part.c_str(), hostname, path);
#else
        const auto code = System::cmd_execute(
            Strings::format(R"(curl -L '%s' --create-dirs --output '%s')", url, download_path_part));
        Checks::check_exit(VCPKG_LINE_INFO, code == 0, "Could not download %s", url);
#endif

        verify_hash(fs, url, download_path_part, sha512);
        fs.rename(download_path_part, download_path, ec);
        Checks::check_exit(VCPKG_LINE_INFO,
                           !ec,
                           "Failed to do post-download rename-in-place.\nfs.rename(%s, %s, %s)",
                           download_path_part,
                           download_path.u8string(),
                           ec.message());
    }

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
        auto& fs = paths.get_filesystem();
        if (!fs.exists(tool_data.download_path))
        {
            System::println("Downloading %s...", tool_name);
            download_file(fs, tool_data.url, tool_data.download_path, tool_data.sha512);
            System::println("Downloading %s... done.", tool_name);
        }
        else
        {
            verify_hash(fs, tool_data.url, tool_data.download_path, tool_data.sha512);
        }

        if (tool_data.is_archive)
        {
            System::println("Extracting %s...", tool_name);
            extract_archive(paths, tool_data.download_path, tool_data.tool_dir_path);
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

    struct VisualStudioInstance
    {
        enum class ReleaseType
        {
            STABLE,
            PRERELEASE,
            LEGACY
        };

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

        std::string major_version() const { return version.substr(0, 2); }
    };

#if defined(WIN32)
    static std::vector<VisualStudioInstance> get_visual_studio_instances(const VcpkgPaths& paths)
    {
        const auto& fs = paths.get_filesystem();
        std::vector<VisualStudioInstance> instances;

        const auto& program_files_32_bit = System::get_program_files_32_bit().value_or_exit(VCPKG_LINE_INFO);

        // Instances from vswhere
        const fs::path vswhere_exe = program_files_32_bit / "Microsoft Visual Studio" / "Installer" / "vswhere.exe";
        if (fs.exists(vswhere_exe))
        {
            const auto code_and_output = System::cmd_execute_and_capture_output(
                Strings::format(R"("%s" -prerelease -legacy -products * -format xml)", vswhere_exe.u8string()));
            Checks::check_exit(VCPKG_LINE_INFO,
                               code_and_output.exit_code == 0,
                               "Running vswhere.exe failed with message:\n%s",
                               code_and_output.output);

            const auto instance_entries = find_all_enclosed(code_and_output.output, "<instance>", "</instance>");
            for (const VcpkgStringRange& instance : instance_entries)
            {
                auto maybe_is_prerelease = find_at_most_one_enclosed(instance, "<isPrerelease>", "</isPrerelease>");

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
                    find_exactly_one_enclosed(instance, "<installationPath>", "</installationPath>").to_string(),
                    find_exactly_one_enclosed(instance, "<installationVersion>", "</installationVersion>").to_string(),
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
#endif

#if defined(_WIN32)
    std::vector<Toolset> find_toolset_instances_preferred_first(const VcpkgPaths& paths)
    {
        using CPU = System::CPUArchitecture;

        const auto& fs = paths.get_filesystem();

        // Note: this will contain a mix of vcvarsall.bat locations and dumpbin.exe locations.
        std::vector<fs::path> paths_examined;

        std::vector<Toolset> found_toolsets;
        std::vector<Toolset> excluded_toolsets;

        const SortedVector<VisualStudioInstance> sorted{get_visual_studio_instances(paths),
                                                        VisualStudioInstance::preferred_first_comparator};

        const bool v140_is_available = Util::find_if(sorted, [&](const VisualStudioInstance& vs_instance) {
                                           return vs_instance.major_version() == "14";
                                       }) != sorted.end();

        for (const VisualStudioInstance& vs_instance : sorted)
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
                        const Toolset v141toolset{
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
                            const Toolset v140toolset{vs_instance.root_path,
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
#endif

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
