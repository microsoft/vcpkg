#include "pch.h"

#include "PackageSpec.h"
#include "PostBuildLint_ConfigurationType.h"
#include "vcpkg_Enums.h"

namespace vcpkg::PostBuildLint
{
    static const std::string NULLVALUE_STRING = Enums::nullvalue_to_string(ConfigurationTypeC::ENUM_NAME);

    static const std::string NAME_DEBUG = "Debug";
    static const std::string NAME_RELEASE = "Release";

    const std::string& ConfigurationType::to_string() const
    {
        switch (this->backing_enum)
        {
            case ConfigurationTypeC::DEBUG: return NAME_DEBUG;
            case ConfigurationTypeC::RELEASE: return NAME_RELEASE;
            case ConfigurationTypeC::NULLVALUE: return NULLVALUE_STRING;
            default: Checks::unreachable(VCPKG_LINE_INFO);
        }
    }
}
