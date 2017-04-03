#include "pch.h"
#include "PostBuildLint_ConfigurationType.h"
#include "vcpkg_Enums.h"
#include "PackageSpec.h"

namespace vcpkg::PostBuildLint::ConfigurationType
{
    static const std::string NULLVALUE_STRING = Enums::nullvalue_toString(ENUM_NAME);

    static const std::string NAME_DEBUG = "Debug";
    static const std::string NAME_RELEASE = "Release";

    const std::string& Type::toString() const
    {
        switch (this->backing_enum)
        {
        case ConfigurationType::DEBUG:
            return NAME_DEBUG;
        case ConfigurationType::RELEASE:
            return NAME_RELEASE;
        case ConfigurationType::NULLVALUE:
            return NULLVALUE_STRING;
        default:
            Checks::unreachable(VCPKG_LINE_INFO);
        }
    }
}
