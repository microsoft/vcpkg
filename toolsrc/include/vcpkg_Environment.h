#pragma once
#include "vcpkg_paths.h"

namespace vcpkg::Environment
{
    void ensure_nuget_on_path(const vcpkg_paths& paths);

    void ensure_git_on_path(const vcpkg_paths& paths);

    void ensure_cmake_on_path(const vcpkg_paths& paths);

    inline void ensure_utilities_on_path(const vcpkg_paths& paths)
    {
        ensure_cmake_on_path(paths);
        ensure_git_on_path(paths);
    }

    const fs::path& get_dumpbin_exe(const vcpkg_paths& paths);

    struct vcvarsall_and_platform_toolset
    {
        fs::path path;
        std::wstring platform_toolset;
    };

    const vcvarsall_and_platform_toolset& get_vcvarsall_bat(const vcpkg_paths& paths);

    const fs::path& get_ProgramFiles_32_bit();

    const fs::path& get_ProgramFiles_platform_bitness();
}
