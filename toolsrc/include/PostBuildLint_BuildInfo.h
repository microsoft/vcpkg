#pragma once

#include "PostBuildLint_BuildPolicies.h"
#include "filesystem_fs.h"
#include "vcpkg_Files.h"

namespace vcpkg::PostBuildLint
{
    enum class LinkageType : char
    {
        DYNAMIC,
        STATIC,
    };

    Optional<LinkageType> to_linkagetype(const std::string& str);

    struct BuildInfo
    {
        static BuildInfo create(std::unordered_map<std::string, std::string> pgh);

        LinkageType crt_linkage;
        LinkageType library_linkage;

        std::map<BuildPolicy, bool> policies;
    };

    BuildInfo read_build_info(const Files::Filesystem& fs, const fs::path& filepath);
}
