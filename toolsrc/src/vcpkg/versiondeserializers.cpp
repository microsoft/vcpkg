#include <vcpkg/versiondeserializers.h>

using namespace vcpkg;
using namespace vcpkg::Versions;

namespace
{
    struct VersionDbEntryDeserializer final : Json::IDeserializer<VersionDbEntry>
    {
        static constexpr StringLiteral VERSION_RELAXED = "version";
        static constexpr StringLiteral VERSION_SEMVER = "version-semver";
        static constexpr StringLiteral VERSION_STRING = "version-string";
        static constexpr StringLiteral VERSION_DATE = "version-date";
        static constexpr StringLiteral PORT_VERSION = "port-version";
        static constexpr StringLiteral GIT_TREE = "git-tree";

        StringView type_name() const override { return "a version database entry"; }
        View<StringView> valid_fields() const override
        {
            static const StringView t[] = {
                VERSION_RELAXED, VERSION_SEMVER, VERSION_STRING, VERSION_DATE, PORT_VERSION, GIT_TREE};
            return t;
        }

        Optional<VersionDbEntry> visit_object(Json::Reader& r, const Json::Object& obj) override
        {
            std::string version;
            int port_version = 0;
            std::string git_tree;
            Versions::Scheme version_scheme = Versions::Scheme::String;

            // Code copy-and-paste'd from sourceparagraph.cpp
            static Json::StringDeserializer version_exact_deserializer{"an exact version string"};
            static Json::StringDeserializer version_relaxed_deserializer{"a relaxed version string"};
            static Json::StringDeserializer version_semver_deserializer{"a semantic version string"};
            static Json::StringDeserializer version_date_deserializer{"a date version string"};
            static Json::StringDeserializer git_tree_deserializer("a git object SHA");

            bool has_exact = r.optional_object_field(obj, VERSION_STRING, version, version_exact_deserializer);
            bool has_relax = r.optional_object_field(obj, VERSION_RELAXED, version, version_relaxed_deserializer);
            bool has_semver = r.optional_object_field(obj, VERSION_SEMVER, version, version_semver_deserializer);
            bool has_date = r.optional_object_field(obj, VERSION_DATE, version, version_date_deserializer);
            int num_versions = (int)has_exact + (int)has_relax + (int)has_semver + (int)has_date;
            if (num_versions == 0)
            {
                r.add_generic_error(type_name(), "expected a versioning field (example: ", VERSION_STRING, ")");
            }
            else if (num_versions > 1)
            {
                r.add_generic_error(type_name(), "expected only one versioning field");
            }
            else
            {
                if (has_exact)
                    version_scheme = Versions::Scheme::String;
                else if (has_relax)
                    version_scheme = Versions::Scheme::Relaxed;
                else if (has_semver)
                    version_scheme = Versions::Scheme::Semver;
                else if (has_date)
                    version_scheme = Versions::Scheme::Date;
                else
                    Checks::unreachable(VCPKG_LINE_INFO);
            }
            r.optional_object_field(obj, PORT_VERSION, port_version, Json::NaturalNumberDeserializer::instance);
            r.required_object_field(type_name(), obj, GIT_TREE, git_tree, git_tree_deserializer);

            return VersionDbEntry(version, port_version, version_scheme, git_tree);
        }

        static VersionDbEntryDeserializer instance;
    };

    struct VersionDbEntryArrayDeserializer final : Json::IDeserializer<std::vector<VersionDbEntry>>
    {
        virtual StringView type_name() const override { return "an array of versions"; }

        virtual Optional<std::vector<VersionDbEntry>> visit_array(Json::Reader& r, const Json::Array& arr) override
        {
            return r.array_elements(arr, VersionDbEntryDeserializer::instance);
        }

        static VersionDbEntryArrayDeserializer instance;
    };

    VersionDbEntryDeserializer VersionDbEntryDeserializer::instance;
    VersionDbEntryArrayDeserializer VersionDbEntryArrayDeserializer::instance;

    struct BaselineDeserializer final : Json::IDeserializer<std::map<std::string, VersionT, std::less<>>>
    {
        StringView type_name() const override { return "a baseline object"; }

        Optional<type> visit_object(Json::Reader& r, const Json::Object& obj) override
        {
            std::map<std::string, VersionT, std::less<>> result;

            for (auto&& pr : obj)
            {
                const auto& version_value = pr.second;
                VersionT version;
                r.visit_in_key(version_value, pr.first, version, get_versiont_deserializer_instance());

                result.emplace(pr.first.to_string(), std::move(version));
            }

            return std::move(result);
        }

        static BaselineDeserializer instance;
    };
    BaselineDeserializer BaselineDeserializer::instance;

    struct VersionTDeserializer final : Json::IDeserializer<VersionT>
    {
        StringView type_name() const override { return "a version object"; }
        View<StringView> valid_fields() const override
        {
            static const StringView t[] = {"version-string", "port-version"};
            return t;
        }

        Optional<VersionT> visit_object(Json::Reader& r, const Json::Object& obj) override
        {
            std::string version;
            int port_version = 0;

            r.required_object_field(type_name(), obj, "version-string", version, version_deserializer);
            r.optional_object_field(obj, "port-version", port_version, Json::NaturalNumberDeserializer::instance);

            return VersionT{std::move(version), port_version};
        }

        static Json::StringDeserializer version_deserializer;
        static VersionTDeserializer instance;
    };
    Json::StringDeserializer VersionTDeserializer::version_deserializer{"version"};
    VersionTDeserializer VersionTDeserializer::instance;
}

namespace vcpkg
{
    Json::IDeserializer<VersionT>& get_versiont_deserializer_instance() { return VersionTDeserializer::instance; }

    ExpectedS<std::map<std::string, VersionT, std::less<>>> parse_baseline_file(Files::Filesystem& fs,
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
        return result;
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
