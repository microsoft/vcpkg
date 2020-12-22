#pragma once

#include <vcpkg/fwd/configuration.h>
#include <vcpkg/fwd/vcpkgcmdarguments.h>

#include <vcpkg/base/files.h>
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

        void validate_feature_flags(const FeatureFlagSettings& flags);
    };

    std::unique_ptr<Json::IDeserializer<Configuration>> make_configuration_deserializer(
        const fs::path& config_directory);
}
