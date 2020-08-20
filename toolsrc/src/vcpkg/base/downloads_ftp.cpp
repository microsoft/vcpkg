#include "pch.h"

#include <vcpkg/base/downloads.h>
#include <vcpkg/base/hash.h>
#include <vcpkg/base/system.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/base/util.h>

#if defined(_WIN32)
#include <VersionHelpers.h>
#include <wininet.h>
#pragma comment(lib, "Wininet")
#endif

namespace vcpkg::Downloads
{
#if defined(_WIN32)
    void ftp_download_file(Files::Filesystem& fs,
                           ZStringView target_file_path,
                           StringView hostname,
                           StringView url_path)
    {
        // Make sure the directories are present, otherwise fopen_s fails
        const auto dir = fs::path(target_file_path.c_str()).parent_path();
        std::error_code ec;
        fs.create_directories(dir, ec);
        Checks::check_exit(VCPKG_LINE_INFO, !ec, "Could not create directories %s", fs::u8string(dir));

        HINTERNET hConnect;
        HINTERNET hFtpSession;
        hConnect = InternetOpen(NULL, INTERNET_OPEN_TYPE_DIRECT, NULL, NULL, 0);
        Checks::check_exit(VCPKG_LINE_INFO, hConnect, "InternetOpen() failed: %d", GetLastError());

        hFtpSession = InternetConnect(
            hConnect, hostname.to_string().c_str(), INTERNET_DEFAULT_FTP_PORT, "", "", INTERNET_SERVICE_FTP, 0, 0);
        Checks::check_exit(VCPKG_LINE_INFO, hFtpSession, "InternetConnect() failed: %d", GetLastError());
        BOOL bSuc = FtpGetFile(hFtpSession,
                               url_path.to_string().c_str(),
                               target_file_path.to_string().c_str(),
                               FALSE,
                               FTP_TRANSFER_TYPE_BINARY,
                               0,
                               0);
        Checks::check_exit(VCPKG_LINE_INFO, bSuc == TRUE, "InternetConnect() failed: %d", GetLastError());
        InternetCloseHandle(hFtpSession);
        InternetCloseHandle(hConnect);
    }
#endif
}
