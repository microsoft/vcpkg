#pragma once
#include "vcpkg_paths.h"

namespace vcpkg::Environment
{
    const fs::path& get_dumpbin_exe(const vcpkg_paths& paths);

    struct vcvarsall_and_platform_toolset
    {
        fs::path path;
        std::wstring platform_toolset;
    };

    const vcvarsall_and_platform_toolset& get_vcvarsall_bat(const vcpkg_paths& paths);
}
