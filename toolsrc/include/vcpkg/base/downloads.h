#pragma once

#include <vcpkg/base/files.h>

namespace vcpkg::Downloads
{
    void winhttp_download_file(Files::Filesystem& fs,
                               ZStringView target_file_path,
                               StringView hostname,
                               StringView url_path);

    void ftp_download_file(Files::Filesystem& fs,
                           ZStringView target_file_path,
                           StringView hostname,
                           StringView url_path);

    void verify_downloaded_file_hash(const Files::Filesystem& fs,
                                     const std::string& url,
                                     const fs::path& path,
                                     const std::string& sha512);

    void download_file(Files::Filesystem& fs,
                       const std::string& url,
                       const fs::path& download_path,
                       const std::string& sha512);
}
