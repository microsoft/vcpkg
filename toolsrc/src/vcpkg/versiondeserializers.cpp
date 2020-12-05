#include <vcpkg/base/util.h>

#include <vcpkg/versiondeserializers.h>

using namespace vcpkg;
using namespace vcpkg::Versions;

namespace
{
    constexpr StringLiteral VERSION_RELAXED = "version";
    constexpr StringLiteral VERSION_SEMVER = "version-semver";
    constexpr StringLiteral VERSION_STRING = "version-string";
    constexpr StringLiteral VERSION_DATE = "version-date";
    constexpr StringLiteral PORT_VERSION = "port-version";
    constexpr StringLiteral GIT_TREE = "git-tree";

    struct VersionDeserializer final : Json::IDeserializer<std::string>
    {
        VersionDeserializer(StringLiteral type) : m_type(type) { }
        StringView type_name() const override { return m_type; }

        Optional<std::string> visit_string(Json::Reader& r, StringView sv) override
        {
            StringView pv(std::find(sv.begin(), sv.end(), '#'), sv.end());
            if (pv.size() == 1)
            {
                r.add_generic_error(type_name(), "invalid character '#' in version text");
            }
            else if (pv.size() > 1)
            {
                r.add_generic_error(type_name(),
                                    "invalid character '#' in version text. Did you mean \"port-version\": ",
                                    pv.substr(1),
                                    "?");
            }
            return sv.to_string();
        }
        StringLiteral m_type;
    };
}

namespace vcpkg
{
    std::unique_ptr<Json::IDeserializer<std::string>> make_version_deserializer(StringLiteral type_name)
    {
        return std::make_unique<VersionDeserializer>(type_name);
    }

    SchemedVersion visit_required_schemed_deserializer(StringView parent_type, Json::Reader& r, const Json::Object& obj)
    {
        auto maybe_schemed_version = visit_optional_schemed_deserializer(parent_type, r, obj);
        if (auto p = maybe_schemed_version.get())
        {
            return std::move(*p);
        }
        else
        {
            r.add_generic_error(parent_type, "expected a versioning field (example: ", VERSION_STRING, ")");
            return {};
        }
    }
    Optional<SchemedVersion> visit_optional_schemed_deserializer(StringView parent_type,
                                                                 Json::Reader& r,
                                                                 const Json::Object& obj)
    {
        Versions::Scheme version_scheme = Versions::Scheme::String;
        std::string version;
        int port_version = 0;

        static VersionDeserializer version_exact_deserializer{"an exact version string"};
        static VersionDeserializer version_relaxed_deserializer{"a relaxed version string"};
        static VersionDeserializer version_semver_deserializer{"a semantic version string"};
        static VersionDeserializer version_date_deserializer{"a date version string"};

        bool has_exact = r.optional_object_field(obj, VERSION_STRING, version, version_exact_deserializer);
        bool has_relax = r.optional_object_field(obj, VERSION_RELAXED, version, version_relaxed_deserializer);
        bool has_semver = r.optional_object_field(obj, VERSION_SEMVER, version, version_semver_deserializer);
        bool has_date = r.optional_object_field(obj, VERSION_DATE, version, version_date_deserializer);
        int num_versions = (int)has_exact + (int)has_relax + (int)has_semver + (int)has_date;
        bool has_port_version =
            r.optional_object_field(obj, PORT_VERSION, port_version, Json::NaturalNumberDeserializer::instance);

        if (num_versions == 0)
        {
            if (!has_port_version)
            {
                return nullopt;
            }
            else
            {
                r.add_generic_error(parent_type, "unexpected \"port_version\" without a versioning field");
            }
        }
        else if (num_versions > 1)
        {
            r.add_generic_error(parent_type, "expected only one versioning field");
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

        return SchemedVersion{version_scheme, {version, port_version}};
    }

    View<StringView> schemed_deserializer_fields()
    {
        static const StringView t[] = {VERSION_RELAXED, VERSION_SEMVER, VERSION_STRING, VERSION_DATE, PORT_VERSION};
        return t;
    }

    void serialize_schemed_version(Json::Object& out_obj,
                                   Versions::Scheme scheme,
                                   const std::string& version,
                                   int port_version,
                                   bool always_emit_port_version)
    {
        auto version_field = [](Versions::Scheme version_scheme) {
            switch (version_scheme)
            {
                case Versions::Scheme::String: return VERSION_STRING;
                case Versions::Scheme::Semver: return VERSION_SEMVER;
                case Versions::Scheme::Relaxed: return VERSION_RELAXED;
                case Versions::Scheme::Date: return VERSION_DATE;
                default: Checks::unreachable(VCPKG_LINE_INFO);
            }
        };

        out_obj.insert(version_field(scheme), Json::Value::string(version));

        if (port_version != 0 || always_emit_port_version)
        {
            out_obj.insert(PORT_VERSION, Json::Value::integer(port_version));
        }
    }

}

namespace
{
    struct VersionDbEntryDeserializer final : Json::IDeserializer<VersionDbEntry>
    {
        static constexpr StringLiteral GIT_TREE = "git-tree";

        StringView type_name() const override { return "a version database entry"; }
        View<StringView> valid_fields() const override
        {
            static const StringView u[] = {GIT_TREE};
            static const auto t = vcpkg::Util::Vectors::concat<StringView>(schemed_deserializer_fields(), u);
            return t;
        }

        Optional<VersionDbEntry> visit_object(Json::Reader& r, const Json::Object& obj) override
        {
            VersionDbEntry ret;

            auto schemed_version = visit_required_schemed_deserializer(type_name(), r, obj);
            ret.scheme = schemed_version.scheme;
            ret.version = std::move(schemed_version.versiont);

            static Json::StringDeserializer git_tree_deserializer("a git object SHA");

            r.required_object_field(type_name(), obj, GIT_TREE, ret.git_tree, git_tree_deserializer);

            return std::move(ret);
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
            static const StringView t[] = {VERSION_STRING, PORT_VERSION};
            return t;
        }

        Optional<VersionT> visit_object(Json::Reader& r, const Json::Object& obj) override
        {
            std::string version;
            int port_version = 0;

            static VersionDeserializer version_deserializer{"version"};

            r.required_object_field(type_name(), obj, VERSION_STRING, version, version_deserializer);
            r.optional_object_field(obj, PORT_VERSION, port_version, Json::NaturalNumberDeserializer::instance);

            return VersionT{std::move(version), port_version};
        }
        static VersionTDeserializer instance;
    };

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
