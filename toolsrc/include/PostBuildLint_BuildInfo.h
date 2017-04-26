#pragma once

#include "filesystem_fs.h"
#include "vcpkg_Files.h"
#include "PostBuildLint_BuildPolicies.h"
#include "OptBool.h"
#include "PostBuildLint_LinkageType.h"

namespace vcpkg::PostBuildLint
{
    struct BuildInfo
    {
        static BuildInfo create(std::unordered_map<std::string, std::string> pgh);

        LinkageType crt_linkage;
        LinkageType library_linkage;

        std::map<BuildPolicies, OptBool> policies;
    };

    BuildInfo read_build_info(const Files::Filesystem& fs, const fs::path& filepath);
}
