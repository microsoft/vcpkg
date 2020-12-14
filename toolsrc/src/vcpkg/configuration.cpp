#include <vcpkg/base/jsonreader.h>
#include <vcpkg/base/system.print.h>

#include <vcpkg/configuration.h>
#include <vcpkg/configurationdeserializer.h>
#include <vcpkg/vcpkgcmdarguments.h>

namespace vcpkg
{
    Optional<Configuration> ConfigurationDeserializer::visit_object(Json::Reader& r, const Json::Object& obj)
    {
        RegistrySet registries;

        bool registries_feature_flags_warning = false;

        auto impl_des = get_registry_implementation_deserializer(configuration_directory);

        {
            std::unique_ptr<RegistryImplementation> default_registry;
            if (r.optional_object_field(obj, DEFAULT_REGISTRY, default_registry, *impl_des))
            {
                if (!registries_enabled)
                {
                    registries_feature_flags_warning = true;
                }
                else
                {
                    registries.set_default_registry(std::move(default_registry));
                }
            }
        }

        auto reg_des = get_registry_array_deserializer(configuration_directory);
        std::vector<Registry> regs;
        r.optional_object_field(obj, REGISTRIES, regs, *reg_des);

        if (!regs.empty() && !registries_enabled)
        {
            registries_feature_flags_warning = true;
            regs.clear();
        }

        if (!r.errors().empty())
        {
            return nullopt;
        }

        for (Registry& reg : regs)
        {
            registries.add_registry(std::move(reg));
        }

        if (registries_feature_flags_warning && !print_json)
        {
            System::printf(System::Color::warning,
                           "Warning: configuration specified the \"registries\" or \"default-registries\" field, but "
                           "the %s feature flag was not enabled.\n",
                           VcpkgCmdArguments::REGISTRIES_FEATURE);
        }

        return Configuration{std::move(registries)};
    }

    constexpr StringLiteral ConfigurationDeserializer::DEFAULT_REGISTRY;
    constexpr StringLiteral ConfigurationDeserializer::REGISTRIES;

    ConfigurationDeserializer::ConfigurationDeserializer(const VcpkgCmdArguments& args,
                                                         const fs::path& configuration_directory)
        : configuration_directory(configuration_directory)
    {
        registries_enabled = args.registries_enabled();
        print_json = args.output_json();
    }

}
