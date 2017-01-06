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
}
