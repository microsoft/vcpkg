#include "pch.h"

#include "PostBuildLint_BuildPolicies.h"
#include "vcpkg_Checks.h"
#include "vcpkg_Enums.h"

namespace vcpkg::PostBuildLint
{
    Optional<BuildPolicy> to_build_policy(const std::string& s)
    {
        for (auto e : Enums::make_enum_range<BuildPolicy>())
        {
            if (s == to_string(e)) return e;
        }
        return nullopt;
    }

    CStringView to_cmake_variable(BuildPolicy s)
    {
        switch (s)
        {
            case BuildPolicy::EMPTY_PACKAGE: return "VCPKG_POLICY_EMPTY_PACKAGE";
            case BuildPolicy::DLLS_WITHOUT_LIBS: return "VCPKG_POLICY_DLLS_WITHOUT_LIBS";
            case BuildPolicy::ONLY_RELEASE_CRT: return "VCPKG_POLICY_ONLY_RELEASE_CRT";
            case BuildPolicy::EMPTY_INCLUDE_FOLDER: return "VCPKG_POLICY_EMPTY_INCLUDE_FOLDER";
            default: Checks::unreachable(VCPKG_LINE_INFO);
        }
    }
}
