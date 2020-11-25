#pragma once

#include <vcpkg/base/fwd/stringview.h>

#include <vcpkg/base/jsonreader.h>
#include <vcpkg/base/stringliteral.h>

#include <vcpkg/versions.h>
#include <vcpkg/versiont.h>

namespace vcpkg
{
    struct VersionDbEntry
    {
        VersionT version;
        Versions::Scheme scheme;
        std::string git_tree;

        VersionDbEntry(const std::string& version_string,
                       int port_version,
                       Versions::Scheme scheme,
                       const std::string& git_tree)
            : version(VersionT(version_string, port_version)), scheme(scheme), git_tree(git_tree)
        {
        }
    };

    Json::IDeserializer<VersionT>& get_versiont_deserializer_instance();

    ExpectedS<std::map<std::string, VersionT, std::less<>>> parse_baseline_file(Files::Filesystem& fs,
                                                                                StringView baseline_name,
                                                                                const fs::path& baseline_file_path);

    ExpectedS<std::vector<VersionDbEntry>> parse_versions_file(Files::Filesystem& fs,
                                                               StringView port_name,
                                                               const fs::path& versions_file_path);
}