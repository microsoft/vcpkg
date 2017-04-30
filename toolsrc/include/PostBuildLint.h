#pragma once
#include "PackageSpec.h"
#include "VcpkgPaths.h"
#include "vcpkg_Build.h"

namespace vcpkg::PostBuildLint
{
    size_t perform_all_checks(const PackageSpec& spec, const VcpkgPaths& paths, const Build::BuildInfo& build_info);
}
