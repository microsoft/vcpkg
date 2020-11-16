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
    struct RegistryImplDeserializer : Json::IDeserializer<std::unique_ptr<RegistryImpl>>
    {
        constexpr static StringLiteral KIND = "kind";
        constexpr static StringLiteral PATH = "path";

        constexpr static StringLiteral KIND_BUILTIN = "builtin";
        constexpr static StringLiteral KIND_FILESYSTEM = "filesystem";

        virtual StringView type_name() const override;
        virtual View<StringView> valid_fields() const override;

        virtual Optional<std::unique_ptr<RegistryImpl>> visit_null(Json::Reader&) override;
        virtual Optional<std::unique_ptr<RegistryImpl>> visit_object(Json::Reader&, const Json::Object&) override;

        static RegistryImplDeserializer instance;
    };

    struct RegistryDeserializer final : Json::IDeserializer<Registry>
    {
        constexpr static StringLiteral PACKAGES = "packages";

        virtual StringView type_name() const override;
        virtual View<StringView> valid_fields() const override;

        virtual Optional<Registry> visit_object(Json::Reader&, const Json::Object&) override;
    };

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

        ConfigurationDeserializer(const VcpkgCmdArguments& args);

    private:
        bool print_json;

        bool registries_enabled;
    };
}
