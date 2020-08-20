#include "pch.h"

#include <vcpkg/base/downloads.h>
#include <vcpkg/base/hash.h>
#include <vcpkg/base/system.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/base/util.h>

#if defined(_WIN32)
#include <VersionHelpers.h>
#include <winhttp.h>
#endif

namespace vcpkg::Downloads
{
#if defined(_WIN32)
    void winhttp_download_file(Files::Filesystem& fs,
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
}
