#pragma once

#include <vcpkg/base/fwd/json.h>

#include <vcpkg/fwd/vcpkgcmdarguments.h>

#include <vcpkg/base/json.h>
#include <vcpkg/base/optional.h>
#include <vcpkg/base/stringliteral.h>
#include <vcpkg/base/stringview.h>
#include <vcpkg/base/view.h>

#include <vcpkg/configuration.h>
#include <vcpkg/registries.h>

namespace vcpkg
{
    std::unique_ptr<Json::IDeserializer<std::unique_ptr<RegistryImplementation>>>
    get_registry_implementation_deserializer(const fs::path& configuration_directory);

    std::unique_ptr<Json::IDeserializer<std::vector<Registry>>> get_registry_array_deserializer(
        const fs::path& configuration_directory);

    struct ConfigurationDeserializer final : Json::IDeserializer<Configuration>
    {
        virtual StringView type_name() const override { return "a configuration object"; }

        constexpr static StringLiteral DEFAULT_REGISTRY = "default-registry";
        constexpr static StringLiteral REGISTRIES = "registries";
        virtual View<StringView> valid_fields() const override
        {
            constexpr static StringView t[] = {DEFAULT_REGISTRY, REGISTRIES};
            return t;
        }

        virtual Optional<Configuration> visit_object(Json::Reader& r, const Json::Object& obj) override;

        ConfigurationDeserializer(const VcpkgCmdArguments& args, const fs::path& configuration_directory);

    private:
        bool print_json;

        bool registries_enabled;

        fs::path configuration_directory;
    };
}
