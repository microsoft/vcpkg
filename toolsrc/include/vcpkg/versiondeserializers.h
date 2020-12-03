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
        Versions::Scheme scheme = Versions::Scheme::String;
        std::string git_tree;
    };

    Json::IDeserializer<VersionT>& get_versiont_deserializer_instance();
    std::unique_ptr<Json::IDeserializer<std::string>> make_version_deserializer(StringLiteral type_name);

    struct SchemedVersion
    {
        Versions::Scheme scheme = Versions::Scheme::String;
        VersionT versiont;
    };

    Optional<SchemedVersion> visit_optional_schemed_deserializer(StringView parent_type,
                                                                 Json::Reader& r,
                                                                 const Json::Object& obj);
    SchemedVersion visit_required_schemed_deserializer(StringView parent_type,
                                                       Json::Reader& r,
                                                       const Json::Object& obj);
    View<StringView> schemed_deserializer_fields();

    void serialize_schemed_version(Json::Object& out_obj,
                                   Versions::Scheme scheme,
                                   const std::string& version,
                                   int port_version,
                                   bool always_emit_port_version = false);

    ExpectedS<std::map<std::string, VersionT, std::less<>>> parse_baseline_file(Files::Filesystem& fs,
                                                                                StringView baseline_name,
                                                                                const fs::path& baseline_file_path);

    ExpectedS<std::vector<VersionDbEntry>> parse_versions_file(Files::Filesystem& fs,
                                                               StringView port_name,
                                                               const fs::path& versions_file_path);
}