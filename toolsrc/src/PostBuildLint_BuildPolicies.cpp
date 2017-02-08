#include "pch.h"
#include "PostBuildLint_BuildPolicies.h"
#include "vcpkg_Checks.h"

namespace vcpkg::PostBuildLint::BuildPolicies
{
    static const std::string NAME_UNKNOWN = "PolicyUnknown";
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
            case UNKNOWN:
                return NAME_UNKNOWN;
            default:
                Checks::unreachable();
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
            case UNKNOWN:
                Checks::exit_with_message("No CMake command corresponds to UNKNOWN");
            default:
                Checks::unreachable();
        }
    }

    type::type(): backing_enum(backing_enum_t::UNKNOWN) {}

    const std::vector<type>& values()
    {
        static const std::vector<type>& v = {UNKNOWN, EMPTY_PACKAGE, DLLS_WITHOUT_LIBS};
        return v;
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

        return BuildPolicies::UNKNOWN;
    }
}
