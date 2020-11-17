#pragma once

#include <vcpkg/base/fwd/stringview.h>

#include <vcpkg/base/jsonreader.h>
#include <vcpkg/base/stringliteral.h>

#include <vcpkg/versiont.h>

namespace vcpkg
{
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

    struct BaselineDeserializer final : Json::IDeserializer<std::map<std::string, VersionT, std::less<>>>
    {
        StringView type_name() const override { return "a baseline object"; }

        Optional<type> visit_object(Json::Reader& r, const Json::Object& obj) override
        {
            std::map<std::string, VersionT, std::less<>> result;

            for (auto pr : obj)
            {
                const auto& version_value = pr.second;
                VersionT version;
                r.visit_in_key(version_value, pr.first, version, VersionTDeserializer::instance);

                result.emplace(pr.first.to_string(), std::move(version));
            }

            return std::move(result);
        }

        static BaselineDeserializer instance;
    };
}