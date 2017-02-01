#pragma once
#pragma once
#include <string>

namespace vcpkg::PostBuildLint
{
    enum class ConfigurationType
    {
        DEBUG = 1,
        RELEASE = 2
    };

    std::string to_string(const ConfigurationType& conf);
}
