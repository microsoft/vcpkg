#include "pch.h"

#include <vcpkg/base/downloads.h>
#include <vcpkg/base/hash.h>
#include <vcpkg/base/util.h>

#if defined(_WIN32)
#include <VersionHelpers.h>
#else
#include <vcpkg/base/system.h>
#endif

namespace vcpkg::Downloads
{
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

        auto hSession = WinHttpOpen(L"vcpkg/1.0",
                                    IsWindows8Point1OrGreater() ? WINHTTP_ACCESS_TYPE_AUTOMATIC_PROXY
                                                                : WINHTTP_ACCESS_TYPE_DEFAULT_PROXY,
                                    WINHTTP_NO_PROXY_NAME,
                                    WINHTTP_NO_PROXY_BYPASS,
                                    0);
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

    void verify_downloaded_file_hash(const Files::Filesystem& fs,
                                     const std::string& url,
                                     const fs::path& path,
                                     const std::string& sha512)
    {
        const std::string actual_hash = vcpkg::Hash::get_file_hash(fs, path, "SHA512");
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

    void download_file(vcpkg::Files::Filesystem& fs,
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

        verify_downloaded_file_hash(fs, url, download_path_part, sha512);
        fs.rename(download_path_part, download_path, ec);
        Checks::check_exit(VCPKG_LINE_INFO,
                           !ec,
                           "Failed to do post-download rename-in-place.\n"
                           "fs.rename(%s, %s, %s)",
                           download_path_part,
                           download_path.u8string(),
                           ec.message());
    }
}
