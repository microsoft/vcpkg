#include "pch.h"
#include "PostBuildLint_LinkageType.h"
#include "vcpkg_Checks.h"

namespace vcpkg::PostBuildLint
{
    LinkageType linkage_type_value_of(const std::string& as_string)
    {
        if (as_string == "dynamic")
        {
            return LinkageType::DYNAMIC;
        }

        if (as_string == "static")
        {
            return LinkageType::STATIC;
        }

        return LinkageType::UNKNOWN;
    }

    std::string to_string(const LinkageType& build_info)
    {
        switch (build_info)
        {
        case LinkageType::STATIC:
            return "static";
        case LinkageType::DYNAMIC:
            return "dynamic";
        default:
            Checks::unreachable();
        }
    }
}
