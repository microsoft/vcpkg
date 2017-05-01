#include "pch.h"

#include "PostBuildLint_LinkageType.h"
#include "vcpkg_Checks.h"
#include "vcpkg_Enums.h"

namespace vcpkg::PostBuildLint
{
    static const std::string NULLVALUE_STRING = Enums::nullvalue_to_string(LinkageTypeC::ENUM_NAME);

    static const std::string NAME_DYNAMIC = "dynamic";
    static const std::string NAME_STATIC = "static";

    LinkageType LinkageType::value_of(const std::string& as_string)
    {
        if (as_string == NAME_DYNAMIC)
        {
            return LinkageTypeC::DYNAMIC;
        }

        if (as_string == NAME_STATIC)
        {
            return LinkageTypeC::STATIC;
        }

        return LinkageTypeC::NULLVALUE;
    }

    const std::string& LinkageType::to_string() const
    {
        switch (this->backing_enum)
        {
            case LinkageTypeC::DYNAMIC: return NAME_DYNAMIC;
            case LinkageTypeC::STATIC: return NAME_STATIC;
            case LinkageTypeC::NULLVALUE: return NULLVALUE_STRING;
            default: Checks::unreachable(VCPKG_LINE_INFO);
        }
    }
}
