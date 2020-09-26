#include <vcpkg/base/cache.h>
#include <vcpkg/base/downloads.h>
#include <vcpkg/base/hash.h>
#include <vcpkg/base/lockguarded.h>
#include <vcpkg/base/system.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/base/util.h>

#if defined(_WIN32)
#include <VersionHelpers.h>
#endif

namespace vcpkg::Downloads
{
#if defined(_WIN32)
    struct WinHttpCloseHandleWrapper
    {
        void operator()(HINTERNET h) { WinHttpCloseHandle(h); }
    };

    struct WinHttpRequest
    {
        WinHttpRequest(HINTERNET hConnect, StringView url_path, const wchar_t* method = L"GET")
        {
            // Create an HTTP request handle.
            auto h = WinHttpOpenRequest(hConnect,
                                        method,
                                        Strings::to_utf16(url_path).c_str(),
                                        nullptr,
                                        WINHTTP_NO_REFERER,
                                        WINHTTP_DEFAULT_ACCEPT_TYPES,
                                        WINHTTP_FLAG_SECURE);
            Checks::check_exit(VCPKG_LINE_INFO, h, "WinHttpOpenRequest() failed: %d", GetLastError());
            m_hRequest.reset(h);

            // Send a request.
            auto bResults = WinHttpSendRequest(
                m_hRequest.get(), WINHTTP_NO_ADDITIONAL_HEADERS, 0, WINHTTP_NO_REQUEST_DATA, 0, 0, 0);

            Checks::check_exit(VCPKG_LINE_INFO, bResults, "WinHttpSendRequest() failed: %d", GetLastError());

            // End the request.
            bResults = WinHttpReceiveResponse(m_hRequest.get(), NULL);
            Checks::check_exit(VCPKG_LINE_INFO, bResults, "WinHttpReceiveResponse() failed: %d", GetLastError());
        }

        template<class F>
        void forall_data(F f)
        {
            std::vector<char> buf;

            size_t total_downloaded_size = 0;
            DWORD dwSize = 0;
            do
            {
                DWORD downloaded_size = 0;
                auto bResults = WinHttpQueryDataAvailable(m_hRequest.get(), &dwSize);
                Checks::check_exit(VCPKG_LINE_INFO, bResults, "WinHttpQueryDataAvailable() failed: %d", GetLastError());

                if (buf.size() < dwSize) buf.resize(static_cast<size_t>(dwSize) * 2);

                bResults = WinHttpReadData(m_hRequest.get(), (LPVOID)buf.data(), dwSize, &downloaded_size);
                Checks::check_exit(VCPKG_LINE_INFO, bResults, "WinHttpReadData() failed: %d", GetLastError());
                f(Span<char>(buf.data(), downloaded_size));

                total_downloaded_size += downloaded_size;
            } while (dwSize > 0);
        }

        std::unique_ptr<void, WinHttpCloseHandleWrapper> m_hRequest;
    };

    struct WinHttpSession
    {
        WinHttpSession()
        {
            auto h = WinHttpOpen(L"vcpkg/1.0",
                                 IsWindows8Point1OrGreater() ? WINHTTP_ACCESS_TYPE_AUTOMATIC_PROXY
                                                             : WINHTTP_ACCESS_TYPE_DEFAULT_PROXY,
                                 WINHTTP_NO_PROXY_NAME,
                                 WINHTTP_NO_PROXY_BYPASS,
                                 0);
            Checks::check_exit(VCPKG_LINE_INFO, h, "WinHttpOpen() failed: %d", GetLastError());
            m_hSession.reset(h);

            // If the environment variable HTTPS_PROXY is set
            // use that variable as proxy. This situation might exist when user is in a company network
            // with restricted network/proxy settings
            auto maybe_https_proxy_env = System::get_environment_variable("HTTPS_PROXY");
            if (auto p_https_proxy = maybe_https_proxy_env.get())
            {
                std::wstring env_proxy_settings = Strings::to_utf16(*p_https_proxy);
                WINHTTP_PROXY_INFO proxy;
                proxy.dwAccessType = WINHTTP_ACCESS_TYPE_NAMED_PROXY;
                proxy.lpszProxy = env_proxy_settings.data();
                proxy.lpszProxyBypass = nullptr;

                WinHttpSetOption(m_hSession.get(), WINHTTP_OPTION_PROXY, &proxy, sizeof(proxy));
            }
            // Win7 IE Proxy fallback
            else if (IsWindows7OrGreater() && !IsWindows8Point1OrGreater())
            {
                // First check if any proxy has been found automatically
                WINHTTP_PROXY_INFO proxyInfo;
                DWORD proxyInfoSize = sizeof(WINHTTP_PROXY_INFO);
                auto noProxyFound =
                    !WinHttpQueryOption(m_hSession.get(), WINHTTP_OPTION_PROXY, &proxyInfo, &proxyInfoSize) ||
                    proxyInfo.dwAccessType == WINHTTP_ACCESS_TYPE_NO_PROXY;

                // If no proxy was found automatically, use IE's proxy settings, if any
                if (noProxyFound)
                {
                    WINHTTP_CURRENT_USER_IE_PROXY_CONFIG ieProxy;
                    if (WinHttpGetIEProxyConfigForCurrentUser(&ieProxy) && ieProxy.lpszProxy != nullptr)
                    {
                        WINHTTP_PROXY_INFO proxy;
                        proxy.dwAccessType = WINHTTP_ACCESS_TYPE_NAMED_PROXY;
                        proxy.lpszProxy = ieProxy.lpszProxy;
                        proxy.lpszProxyBypass = ieProxy.lpszProxyBypass;
                        WinHttpSetOption(m_hSession.get(), WINHTTP_OPTION_PROXY, &proxy, sizeof(proxy));
                        GlobalFree(ieProxy.lpszProxy);
                        GlobalFree(ieProxy.lpszProxyBypass);
                        GlobalFree(ieProxy.lpszAutoConfigUrl);
                    }
                }
            }

            // Use Windows 10 defaults on Windows 7
            DWORD secure_protocols(WINHTTP_FLAG_SECURE_PROTOCOL_TLS1 | WINHTTP_FLAG_SECURE_PROTOCOL_TLS1_1 |
                                   WINHTTP_FLAG_SECURE_PROTOCOL_TLS1_2);
            WinHttpSetOption(
                m_hSession.get(), WINHTTP_OPTION_SECURE_PROTOCOLS, &secure_protocols, sizeof(secure_protocols));
        }

        std::unique_ptr<void, WinHttpCloseHandleWrapper> m_hSession;
    };

    struct WinHttpConnection
    {
        WinHttpConnection(HINTERNET hSession, StringView hostname)
        {
            // Specify an HTTP server.
            auto h = WinHttpConnect(hSession, Strings::to_utf16(hostname).c_str(), INTERNET_DEFAULT_HTTPS_PORT, 0);
            Checks::check_exit(VCPKG_LINE_INFO, h, "WinHttpConnect() failed: %d", GetLastError());
            m_hConnect.reset(h);
        }

        std::unique_ptr<void, WinHttpCloseHandleWrapper> m_hConnect;
    };

    static void winhttp_download_file(Files::Filesystem& fs,
                                      ZStringView target_file_path,
                                      StringView hostname,
                                      StringView url_path)
    {
        // Make sure the directories are present, otherwise fopen_s fails
        const auto dir = fs::path(target_file_path.c_str()).parent_path();
        std::error_code ec;
        fs.create_directories(dir, ec);
        Checks::check_exit(VCPKG_LINE_INFO, !ec, "Could not create directories %s", fs::u8string(dir));

        FILE* f = nullptr;
        const errno_t err = fopen_s(&f, target_file_path.c_str(), "wb");
        Checks::check_exit(VCPKG_LINE_INFO,
                           !err,
                           "Could not download https://%s%s. Failed to open file %s. Error code was %s",
                           hostname,
                           url_path,
                           target_file_path,
                           std::to_string(err));
        ASSUME(f != nullptr);

        WinHttpSession s;
        WinHttpConnection conn(s.m_hSession.get(), hostname);
        WinHttpRequest req(conn.m_hConnect.get(), url_path);
        req.forall_data([&](Span<char> span) { fwrite(span.data(), 1, span.size(), f); });
        fflush(f);
        fclose(f);
    }
#endif

    void verify_downloaded_file_hash(const Files::Filesystem& fs,
                                     const std::string& url,
                                     const fs::path& path,
                                     const std::string& sha512)
    {
        std::string actual_hash = vcpkg::Hash::get_file_hash(VCPKG_LINE_INFO, fs, path, Hash::Algorithm::Sha512);

        // <HACK to handle NuGet.org changing nupkg hashes.>
        // This is the NEW hash for 7zip
        if (actual_hash == "a9dfaaafd15d98a2ac83682867ec5766720acf6e99d40d1a00d480692752603bf3f3742623f0ea85647a92374df"
                           "405f331afd6021c5cf36af43ee8db198129c0")
            // This is the OLD hash for 7zip
            actual_hash = "8c75314102e68d2b2347d592f8e3eb05812e1ebb525decbac472231633753f1d4ca31c8e6881a36144a8da26b257"
                          "1305b3ae3f4e2b85fc4a290aeda63d1a13b8";
        // </HACK>

        Checks::check_exit(VCPKG_LINE_INFO,
                           sha512 == actual_hash,
                           "File does not have the expected hash:\n"
                           "             url : [ %s ]\n"
                           "       File path : [ %s ]\n"
                           "   Expected hash : [ %s ]\n"
                           "     Actual hash : [ %s ]\n",
                           url,
                           fs::u8string(path),
                           sha512,
                           actual_hash);
    }

    static void url_heads_inner(View<std::string> urls, std::vector<int>* out)
    {
        static constexpr StringLiteral guid_marker = "8a1db05f-a65d-419b-aa72-037fb4d0672e";

        System::CmdLineBuilder cmd;
        cmd.string_arg("curl")
            .string_arg("--head")
            .string_arg("--location")
            .string_arg("-w")
            .string_arg(Strings::concat(guid_marker, " %{http_code}\\n"));
        for (auto&& url : urls)
        {
            cmd.string_arg(url);
        }
        auto res = System::cmd_execute_and_stream_lines(cmd, [out](const std::string& line) {
            if (Strings::starts_with(line, guid_marker))
            {
                out->push_back(std::strtol(line.data() + guid_marker.size(), nullptr, 10));
            }
        });
        Checks::check_exit(VCPKG_LINE_INFO, res == 0, "curl failed to execute with exit code: %d", res);
    }
    std::vector<int> url_heads(View<std::string> urls)
    {
        static constexpr size_t batch_size = 100;

        std::vector<int> ret;

        size_t i = 0;
        for (; i + batch_size <= urls.size(); i += batch_size)
        {
            url_heads_inner({urls.data() + i, batch_size}, &ret);
        }
        if (i != urls.size()) url_heads_inner({urls.begin() + i, urls.end()}, &ret);

        return ret;
    }

    static void download_files_inner(Files::Filesystem&,
                                     View<std::pair<std::string, fs::path>> url_pairs,
                                     std::vector<int>* out)
    {
        static constexpr StringLiteral guid_marker = "8a1db05f-a65d-419b-aa72-037fb4d0672e";

        System::CmdLineBuilder cmd;
        cmd.string_arg("curl")
            .string_arg("--location")
            .string_arg("-w")
            .string_arg(Strings::concat(guid_marker, " %{http_code}\\n"));
        for (auto&& url : url_pairs)
        {
            cmd.string_arg(url.first).string_arg("-o").path_arg(url.second);
        }
        auto res = System::cmd_execute_and_stream_lines(cmd, [out](const std::string& line) {
            if (Strings::starts_with(line, guid_marker))
            {
                out->push_back(std::strtol(line.data() + guid_marker.size(), nullptr, 10));
            }
        });
        Checks::check_exit(VCPKG_LINE_INFO, res == 0, "curl failed to execute with exit code: %d", res);
    }
    std::vector<int> download_files(Files::Filesystem& fs, View<std::pair<std::string, fs::path>> url_pairs)
    {
        static constexpr size_t batch_size = 50;

        std::vector<int> ret;

        size_t i = 0;
        for (; i + batch_size <= url_pairs.size(); i += batch_size)
        {
            download_files_inner(fs, {url_pairs.data() + i, batch_size}, &ret);
        }
        if (i != url_pairs.size()) download_files_inner(fs, {url_pairs.begin() + i, url_pairs.end()}, &ret);

        Checks::check_exit(VCPKG_LINE_INFO, ret.size() == url_pairs.size());
        return ret;
    }

    int put_file(const Files::Filesystem&, StringView url, const fs::path& file)
    {
        static constexpr StringLiteral guid_marker = "9a1db05f-a65d-419b-aa72-037fb4d0672e";

        System::CmdLineBuilder cmd;
        cmd.string_arg("curl").string_arg("-X").string_arg("PUT");
        cmd.string_arg("-w").string_arg(Strings::concat("\\n", guid_marker, "%{http_code}"));
        cmd.string_arg(url);
        cmd.string_arg("-T").path_arg(file);
        cmd.string_arg("-H").string_arg("x-ms-blob-type: BlockBlob");
        int code = 0;
        auto res = System::cmd_execute_and_stream_lines(cmd, [&code](const std::string& line) {
            if (Strings::starts_with(line, guid_marker))
            {
                code = std::strtol(line.data() + guid_marker.size(), nullptr, 10);
            }
        });
        if (res != 0)
        {
            System::print2(System::Color::warning, "curl failed to execute with exit code: ", res, '\n');
        }
        return code;
    }

    void download_file(vcpkg::Files::Filesystem& fs,
                       const std::string& url,
                       const fs::path& download_path,
                       const std::string& sha512)
    {
        const std::string download_path_part = fs::u8string(download_path) + ".part";
        auto download_path_part_path = fs::u8path(download_path_part);
        std::error_code ec;
        fs.remove(download_path, ec);
        fs.remove(download_path_part_path, ec);
#if defined(_WIN32)
        Checks::check_exit(VCPKG_LINE_INFO, Strings::starts_with(url, "https://"));
        auto url_no_proto = url.substr(8); // drop https://
        auto path_begin = Util::find(url_no_proto, '/');
        std::string hostname(url_no_proto.begin(), path_begin);
        std::string path(path_begin, url_no_proto.end());

        winhttp_download_file(fs, download_path_part, hostname, path);
#else
        const auto code = System::cmd_execute(
            Strings::format(R"(curl -L '%s' --create-dirs --output '%s')", url, download_path_part));
        Checks::check_exit(VCPKG_LINE_INFO, code == 0, "Could not download %s", url);
#endif

        verify_downloaded_file_hash(fs, url, download_path_part_path, sha512);
        fs.rename(download_path_part_path, download_path, VCPKG_LINE_INFO);
    }
}
