#pragma once

#include "CStringView.h"
#include "vcpkg_Checks.h"
#include "vcpkg_optional.h"
#include <array>
#include <string>

namespace vcpkg::PostBuildLint
{
    enum class BuildPolicy
    {
        EMPTY_PACKAGE,
        DLLS_WITHOUT_LIBS,
        ONLY_RELEASE_CRT,
        EMPTY_INCLUDE_FOLDER,
        COUNT,
    };

    inline CStringView to_string(BuildPolicy backing_enum)
    {
        switch (backing_enum)
        {
            case BuildPolicy::EMPTY_PACKAGE: return "PolicyEmptyPackage";
            case BuildPolicy::DLLS_WITHOUT_LIBS: return "PolicyDLLsWithoutLIBs";
            case BuildPolicy::ONLY_RELEASE_CRT: return "PolicyOnlyReleaseCRT";
            case BuildPolicy::EMPTY_INCLUDE_FOLDER: return "PolicyEmptyIncludeFolder";
            default: Checks::unreachable(VCPKG_LINE_INFO);
        }
    }

    Optional<BuildPolicy> to_build_policy(const std::string& s);
    CStringView to_cmake_variable(BuildPolicy s);
}
