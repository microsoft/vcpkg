#pragma once

#include <vcpkg/fwd/configuration.h>

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
}
