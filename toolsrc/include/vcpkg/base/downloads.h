#pragma once

#include <vcpkg/base/files.h>
#include <vcpkg/base/optional.h>
#include <vcpkg/base/view.h>

namespace vcpkg::Downloads
{
    namespace details
    {
        struct SplitURIView
        {
            StringView scheme;
            Optional<StringView> authority;
            StringView path_query_fragment;
        };

        // e.g. {"https","//example.org", "/index.html"}
        Optional<SplitURIView> split_uri_view(StringView uri);
    }

    void verify_downloaded_file_hash(const Files::Filesystem& fs,
                                     const std::string& url,
                                     const fs::path& path,
                                     const std::string& sha512);

    // Returns url that was successfully downloaded from
    std::string download_file(Files::Filesystem& fs,
                              View<std::string> urls,
                              const fs::path& download_path,
                              const std::string& sha512);

    void download_file(Files::Filesystem& fs,
                       const std::string& url,
                       const fs::path& download_path,
                       const std::string& sha512);

    std::vector<int> download_files(Files::Filesystem& fs, View<std::pair<std::string, fs::path>> url_pairs);
    int put_file(const Files::Filesystem&, StringView url, const fs::path& file);
    std::vector<int> url_heads(View<std::string> urls);
}
