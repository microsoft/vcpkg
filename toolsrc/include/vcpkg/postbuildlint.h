#pragma once

#include <vcpkg/fwd/build.h>
#include <vcpkg/fwd/vcpkgpaths.h>

#include <vcpkg/base/files.h>

namespace vcpkg
{
    struct PackageSpec;
}

namespace vcpkg::PostBuildLint
{
    size_t perform_all_checks(const PackageSpec& spec,
                              const VcpkgPaths& paths,
                              const Build::PreBuildInfo& pre_build_info,
                              const Build::BuildInfo& build_info,
                              const fs::path& port_dir);
}
