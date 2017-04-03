#pragma once
#include "PackageSpec.h"
#include "vcpkg_paths.h"

namespace vcpkg::PostBuildLint
{
    size_t perform_all_checks(const PackageSpec& spec, const vcpkg_paths& paths);
}
