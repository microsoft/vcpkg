#include "pch.h"

#include "vcpkg_Build.h"
#include "vcpkg_Checks.h"
#include "vcpkg_Enums.h"

namespace vcpkg::Build
{
    static const std::string NAME_EMPTY_PACKAGE = "PolicyEmptyPackage";
    static const std::string NAME_DLLS_WITHOUT_LIBS = "PolicyDLLsWithoutLIBs";
    static const std::string NAME_ONLY_RELEASE_CRT = "PolicyOnlyReleaseCRT";
    static const std::string NAME_EMPTY_INCLUDE_FOLDER = "PolicyEmptyIncludeFolder";
    static const std::string NAME_ALLOW_OBSOLETE_MSVCRT = "PolicyAllowObsoleteMsvcrt";

    const std::string& to_string(BuildPolicy policy)
    {
        switch (policy)
        {
            case BuildPolicy::EMPTY_PACKAGE: return NAME_EMPTY_PACKAGE;
            case BuildPolicy::DLLS_WITHOUT_LIBS: return NAME_DLLS_WITHOUT_LIBS;
            case BuildPolicy::ONLY_RELEASE_CRT: return NAME_ONLY_RELEASE_CRT;
            case BuildPolicy::EMPTY_INCLUDE_FOLDER: return NAME_EMPTY_INCLUDE_FOLDER;
            case BuildPolicy::ALLOW_OBSOLETE_MSVCRT: return NAME_ALLOW_OBSOLETE_MSVCRT;
            default: Checks::unreachable(VCPKG_LINE_INFO);
        }
    }

    CStringView to_cmake_variable(BuildPolicy policy)
    {
        switch (policy)
        {
            case BuildPolicy::EMPTY_PACKAGE: return "VCPKG_POLICY_EMPTY_PACKAGE";
            case BuildPolicy::DLLS_WITHOUT_LIBS: return "VCPKG_POLICY_DLLS_WITHOUT_LIBS";
            case BuildPolicy::ONLY_RELEASE_CRT: return "VCPKG_POLICY_ONLY_RELEASE_CRT";
            case BuildPolicy::EMPTY_INCLUDE_FOLDER: return "VCPKG_POLICY_EMPTY_INCLUDE_FOLDER";
            case BuildPolicy::ALLOW_OBSOLETE_MSVCRT: return "VCPKG_POLICY_ALLOW_OBSOLETE_MSVCRT";
            default: Checks::unreachable(VCPKG_LINE_INFO);
        }
    }
}
