#include <vcpkg/versiondeserializers.h>

using namespace vcpkg;
using namespace vcpkg::Versions;

namespace vcpkg
{
    ExpectedS<std::map<std::string, VersionSpec>> parse_baseline_file(Files::Filesystem& fs,
                                                                      StringView baseline_name,
                                                                      const fs::path& baseline_file_path)
    {
        if (!fs.exists(baseline_file_path))
        {
            return Strings::format("Couldn't find `%s`", fs::u8string(baseline_file_path));
        }

        auto value = Json::parse_file(VCPKG_LINE_INFO, fs, baseline_file_path);
        if (!value.first.is_object())
        {
            return Strings::format("Error: `%s` does not have a top-level object.", fs::u8string(baseline_file_path));
        }

        const auto& obj = value.first.object();
        auto baseline_value = obj.get(baseline_name);
        if (!baseline_value)
        {
            return Strings::format(
                "Error: `%s` does not contain the baseline \"%s\"", fs::u8string(baseline_file_path), baseline_name);
        }

        Json::Reader r;
        std::map<std::string, VersionT, std::less<>> result;
        r.visit_in_key(*baseline_value, baseline_name, result, BaselineDeserializer::instance);
        if (!r.errors().empty())
        {
            return Strings::format(
                "Error: failed to parse `%s`:\n%s", fs::u8string(baseline_file_path), Strings::join("\n", r.errors()));
        }

        std::map<std::string, VersionSpec> baseline_versions;
        for (auto&& kv_pair : result)
        {
            baseline_versions.emplace(kv_pair.first, VersionSpec(kv_pair.first, kv_pair.second, Scheme::String));
        }
        return baseline_versions;
    }

    ExpectedS<std::vector<VersionDbEntry>> parse_versions_file(Files::Filesystem& fs,
                                                               StringView port_name,
                                                               const fs::path& versions_file_path)
    {
        (void)port_name;
        if (!fs.exists(versions_file_path))
        {
            return Strings::format("Couldn't find the versions database file: %s", fs::u8string(versions_file_path));
        }

        auto versions_json = Json::parse_file(VCPKG_LINE_INFO, fs, versions_file_path);
        if (!versions_json.first.is_object())
        {
            return Strings::format("Error: `%s` does not have a top level object.", fs::u8string(versions_file_path));
        }

        const auto& versions_object = versions_json.first.object();
        auto maybe_versions_array = versions_object.get("versions");
        if (!maybe_versions_array || !maybe_versions_array->is_array())
        {
            return Strings::format("Error: `%s` does not contain a versions array.", fs::u8string(versions_file_path));
        }

        std::vector<VersionDbEntry> db_entries;
        // Avoid warning treated as error.
        if (maybe_versions_array != nullptr)
        {
            Json::Reader r;
            r.visit_in_key(*maybe_versions_array, "versions", db_entries, VersionDbEntryArrayDeserializer::instance);
        }
        return db_entries;
    }
}

VersionTDeserializer VersionTDeserializer::instance;
BaselineDeserializer BaselineDeserializer::instance;
VersionDbEntryDeserializer VersionDbEntryDeserializer::instance;
VersionDbEntryArrayDeserializer VersionDbEntryArrayDeserializer::instance;
Json::StringDeserializer VersionTDeserializer::version_deserializer{"version"};
