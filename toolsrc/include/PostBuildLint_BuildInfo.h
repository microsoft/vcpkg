#pragma once

#include <unordered_map>
#include "Paragraphs.h"
#include "PostBuildLint_BuildPolicies.h"
#include "opt_bool.h"

namespace vcpkg::PostBuildLint
{
    struct BuildInfo
    {
        static BuildInfo create(std::unordered_map<std::string, std::string> pgh);

        std::string crt_linkage;
        std::string library_linkage;

        std::map<BuildPolicies::type, opt_bool_t> policies;
    };

    BuildInfo read_build_info(const fs::path& filepath);
}
