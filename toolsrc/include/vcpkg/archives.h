#pragma once

#include <vcpkg/base/files.h>
#include <vcpkg/vcpkgpaths.h>

namespace vcpkg::Archives
{
    void extract_archive(const VcpkgPaths& paths, const fs::path& archive, const fs::path& to_path);
}
