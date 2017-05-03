#pragma once
#include "PackageSpec.h"

namespace vcpkg::Input
{
    PackageSpec check_and_get_package_spec(const std::string& package_spec_as_string,
                                           const Triplet& default_triplet,
                                           CStringView example_text);

    void check_triplet(const Triplet& t, const VcpkgPaths& paths);
}
