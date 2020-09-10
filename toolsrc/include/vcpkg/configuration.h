#pragma once

#include <vcpkg/fwd/configuration.h>
#include <vcpkg/fwd/vcpkgcmdarguments.h>

#include <vcpkg/base/json.h>

#include <vcpkg/registries.h>

namespace vcpkg
{
    struct Configuration
    {
        // This member is set up via two different configuration options,
        // `registries` and `default_registry`. The fall back logic is
        // taken care of in RegistrySet.
        RegistrySet registry_set;
    };

    struct ConfigurationDeserializer final : Json::IDeserializer<Configuration>
    {
        virtual StringView type_name() const override { return "a configuration object"; }

        constexpr static StringLiteral DEFAULT_REGISTRY = "default-registry";
        constexpr static StringLiteral REGISTRIES = "registries";
        virtual Span<const StringView> valid_fields() const override
        {
            constexpr static StringView t[] = {DEFAULT_REGISTRY, REGISTRIES};
            return t;
        }

        virtual Optional<Configuration> visit_object(Json::Reader& r, const Json::Object& obj) override;

        ConfigurationDeserializer(const VcpkgCmdArguments& args);

    private:
        bool print_json;

        bool registries_enabled;
    };
}
