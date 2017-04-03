#pragma once
#include "PackageSpec.h"
#include "VcpkgPaths.h"

namespace vcpkg::PostBuildLint
{
    size_t perform_all_checks(const PackageSpec& spec, const VcpkgPaths& paths);
}
