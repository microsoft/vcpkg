#include "pch.h"
#include "PostBuildLint_ConfigurationType.h"
#include "vcpkg_Checks.h"

namespace vcpkg::PostBuildLint
{
    std::string to_string(const ConfigurationType& conf)
    {
        switch (conf)
        {
            case ConfigurationType::DEBUG:
                return "Debug";
            case ConfigurationType::RELEASE:
                return "Release";
            default:
                Checks::unreachable();
        }
    }
}
