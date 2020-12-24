#include <vcpkg/base/jsonreader.h>
#include <vcpkg/base/system.print.h>

#include <vcpkg/configuration.h>
#include <vcpkg/vcpkgcmdarguments.h>

namespace
{
    using namespace vcpkg;

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

        ConfigurationDeserializer(const fs::path& configuration_directory);

    private:
        fs::path configuration_directory;
    };

    constexpr StringLiteral ConfigurationDeserializer::DEFAULT_REGISTRY;
    constexpr StringLiteral ConfigurationDeserializer::REGISTRIES;

    Optional<Configuration> ConfigurationDeserializer::visit_object(Json::Reader& r, const Json::Object& obj)
    {
        RegistrySet registries;

        auto impl_des = get_registry_implementation_deserializer(configuration_directory);

        std::unique_ptr<RegistryImplementation> default_registry;
        if (r.optional_object_field(obj, DEFAULT_REGISTRY, default_registry, *impl_des))
        {
            registries.set_default_registry(std::move(default_registry));
        }

        auto reg_des = get_registry_array_deserializer(configuration_directory);
        std::vector<Registry> regs;
        r.optional_object_field(obj, REGISTRIES, regs, *reg_des);

        for (Registry& reg : regs)
        {
            registries.add_registry(std::move(reg));
        }

        return Configuration{std::move(registries)};
    }

    ConfigurationDeserializer::ConfigurationDeserializer(const fs::path& configuration_directory)
        : configuration_directory(configuration_directory)
    {
    }

}

std::unique_ptr<Json::IDeserializer<Configuration>> vcpkg::make_configuration_deserializer(
    const fs::path& config_directory)
{
    return std::make_unique<ConfigurationDeserializer>(config_directory);
}

namespace vcpkg
{
    void Configuration::validate_feature_flags(const FeatureFlagSettings& flags)
    {
        if (!flags.registries && registry_set.has_modifications())
        {
            System::printf(System::Color::warning,
                           "Warning: configuration specified the \"registries\" or \"default-registries\" field, but "
                           "the %s feature flag was not enabled.\n",
                           VcpkgCmdArguments::REGISTRIES_FEATURE);
            registry_set = RegistrySet();
        }
    }
}
