#include "pch.h"

#include "PostBuildLint_BuildPolicies.h"
#include "vcpkg_Checks.h"
#include "vcpkg_Enums.h"

namespace vcpkg::PostBuildLint
{
    static const std::string NULLVALUE_STRING = Enums::nullvalue_to_string(BuildPoliciesC::ENUM_NAME);

    static const std::string NAME_EMPTY_PACKAGE = "PolicyEmptyPackage";
    static const std::string NAME_DLLS_WITHOUT_LIBS = "PolicyDLLsWithoutLIBs";
    static const std::string NAME_ONLY_RELEASE_CRT = "PolicyOnlyReleaseCRT";
    static const std::string NAME_EMPTY_INCLUDE_FOLDER = "PolicyEmptyIncludeFolder";

    BuildPolicies BuildPolicies::parse(const std::string& s)
    {
        if (s == NAME_EMPTY_PACKAGE)
        {
            return BuildPoliciesC::EMPTY_PACKAGE;
        }

        if (s == NAME_DLLS_WITHOUT_LIBS)
        {
            return BuildPoliciesC::DLLS_WITHOUT_LIBS;
        }

        if (s == NAME_ONLY_RELEASE_CRT)
        {
            return BuildPoliciesC::ONLY_RELEASE_CRT;
        }

        if (s == NAME_EMPTY_INCLUDE_FOLDER)
        {
            return BuildPoliciesC::EMPTY_INCLUDE_FOLDER;
        }

        return BuildPoliciesC::NULLVALUE;
    }

    const std::string& BuildPolicies::to_string() const
    {
        switch (this->backing_enum)
        {
            case BuildPoliciesC::EMPTY_PACKAGE: return NAME_EMPTY_PACKAGE;
            case BuildPoliciesC::DLLS_WITHOUT_LIBS: return NAME_DLLS_WITHOUT_LIBS;
            case BuildPoliciesC::ONLY_RELEASE_CRT: return NAME_ONLY_RELEASE_CRT;
            case BuildPoliciesC::EMPTY_INCLUDE_FOLDER: return NAME_EMPTY_INCLUDE_FOLDER;
            case BuildPoliciesC::NULLVALUE: return NULLVALUE_STRING;
            default: Checks::unreachable(VCPKG_LINE_INFO);
        }
    }

    const std::string& BuildPolicies::cmake_variable() const
    {
        static const std::string CMAKE_VARIABLE_EMPTY_PACKAGE = "VCPKG_POLICY_EMPTY_PACKAGE";
        static const std::string CMAKE_VARIABLE_DLLS_WITHOUT_LIBS = "VCPKG_POLICY_DLLS_WITHOUT_LIBS";
        static const std::string CMAKE_VARIABLE_ONLY_RELEASE_CRT = "VCPKG_POLICY_ONLY_RELEASE_CRT";
        static const std::string CMAKE_VARIABLE_EMPTY_INCLUDE_FOLDER = "VCPKG_POLICY_EMPTY_INCLUDE_FOLDER";

        switch (this->backing_enum)
        {
            case BuildPoliciesC::EMPTY_PACKAGE: return CMAKE_VARIABLE_EMPTY_PACKAGE;
            case BuildPoliciesC::DLLS_WITHOUT_LIBS: return CMAKE_VARIABLE_DLLS_WITHOUT_LIBS;
            case BuildPoliciesC::ONLY_RELEASE_CRT: return CMAKE_VARIABLE_ONLY_RELEASE_CRT;
            case BuildPoliciesC::EMPTY_INCLUDE_FOLDER: return CMAKE_VARIABLE_EMPTY_INCLUDE_FOLDER;
            case BuildPoliciesC::NULLVALUE: Enums::nullvalue_used(VCPKG_LINE_INFO, BuildPoliciesC::ENUM_NAME);
            default: Checks::unreachable(VCPKG_LINE_INFO);
        }
    }
}
