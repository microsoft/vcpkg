#include <vcpkg/base/downloads.h>
#include <vcpkg/base/hash.h>
#include <vcpkg/base/system.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/base/util.h>

#if defined(_WIN32)
#include <VersionHelpers.h>
#endif

namespace vcpkg::Downloads
{
#if defined(_WIN32)
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

        auto hSession = WinHttpOpen(L"vcpkg/1.0",
                                    IsWindows8Point1OrGreater() ? WINHTTP_ACCESS_TYPE_AUTOMATIC_PROXY
                                                                : WINHTTP_ACCESS_TYPE_DEFAULT_PROXY,
                                    WINHTTP_NO_PROXY_NAME,
                                    WINHTTP_NO_PROXY_BYPASS,
                                    0);
        Checks::check_exit(VCPKG_LINE_INFO, hSession, "WinHttpOpen() failed: %d", GetLastError());

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

            WinHttpSetOption(hSession, WINHTTP_OPTION_PROXY, &proxy, sizeof(proxy));
        }
        // Win7 IE Proxy fallback
        else if (IsWindows7OrGreater() && !IsWindows8Point1OrGreater())
        {
            // First check if any proxy has been found automatically
            WINHTTP_PROXY_INFO proxyInfo;
            DWORD proxyInfoSize = sizeof(WINHTTP_PROXY_INFO);
            auto noProxyFound = !WinHttpQueryOption(hSession, WINHTTP_OPTION_PROXY, &proxyInfo, &proxyInfoSize) ||
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
                    WinHttpSetOption(hSession, WINHTTP_OPTION_PROXY, &proxy, sizeof(proxy));
                    GlobalFree(ieProxy.lpszProxy);
                    GlobalFree(ieProxy.lpszProxyBypass);
                    GlobalFree(ieProxy.lpszAutoConfigUrl);
                }
            }
        }

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

            if (buf.size() < dwSize) buf.resize(static_cast<size_t>(dwSize) * 2);

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
