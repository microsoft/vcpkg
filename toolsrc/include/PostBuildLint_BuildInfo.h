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

        LinkageType::Type crt_linkage;
        LinkageType::Type library_linkage;

        std::map<BuildPolicies::Type, OptBoolT> policies;
    };

    BuildInfo read_build_info(Files::Filesystem& fs, const fs::path& filepath);
}
