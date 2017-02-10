#include "pch.h"
#include "PostBuildLint_BuildPolicies.h"
#include "vcpkg_Enums.h"

namespace vcpkg::PostBuildLint::BuildPolicies
{
    static const std::string NULLVALUE_STRING = Enums::nullvalue_toString(ENUM_NAME);

    static const std::string NAME_EMPTY_PACKAGE = "PolicyEmptyPackage";
    static const std::string NAME_DLLS_WITHOUT_LIBS = "PolicyDLLsWithoutLIBs";

    const std::string& type::toString() const
    {
        switch (this->backing_enum)
        {
            case EMPTY_PACKAGE:
                return NAME_EMPTY_PACKAGE;
            case DLLS_WITHOUT_LIBS:
                return NAME_DLLS_WITHOUT_LIBS;
            case NULLVALUE:
                return NULLVALUE_STRING;
            default:
                Enums::unreachable(ENUM_NAME);
        }
    }

    const std::string& type::cmake_variable() const
    {
        static const std::string CMAKE_VARIABLE_EMPTY_PACKAGE = "VCPKG_POLICY_EMPTY_PACKAGE";
        static const std::string CMAKE_VARIABLE_DLLS_WITHOUT_LIBS = "VCPKG_POLICY_DLLS_WITHOUT_LIBS";

        switch (this->backing_enum)
        {
            case EMPTY_PACKAGE:
                return CMAKE_VARIABLE_EMPTY_PACKAGE;
            case DLLS_WITHOUT_LIBS:
                return CMAKE_VARIABLE_DLLS_WITHOUT_LIBS;
            case NULLVALUE:
                Enums::nullvalue_used(ENUM_NAME);
            default:
                Enums::unreachable(ENUM_NAME);
        }
    }

    type parse(const std::string& s)
    {
        if (s == NAME_EMPTY_PACKAGE)
        {
            return BuildPolicies::EMPTY_PACKAGE;
        }

        if (s == NAME_DLLS_WITHOUT_LIBS)
        {
            return BuildPolicies::DLLS_WITHOUT_LIBS;
        }

        return BuildPolicies::NULLVALUE;
    }
}
