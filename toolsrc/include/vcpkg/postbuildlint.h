#pragma once

#include <vcpkg/build.h>
#include <vcpkg/packagespec.h>
#include <vcpkg/vcpkgpaths.h>

namespace vcpkg::PostBuildLint
{
    size_t perform_all_checks(const PackageSpec& spec,
                              const VcpkgPaths& paths,
                              const Build::PreBuildInfo& pre_build_info,
                              const Build::BuildInfo& build_info,
                              const fs::path& port_dir);
}
