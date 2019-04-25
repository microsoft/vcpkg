#pragma once

#include <vcpkg/packagespec.h>

namespace vcpkg::Input
{
    PackageSpec check_and_get_package_spec(std::string&& spec_string,
                                           const Triplet& default_triplet,
                                           CStringView example_text);
    FullPackageSpec check_and_get_full_package_spec(std::string&& spec_string,
                                                    const Triplet& default_triplet,
                                                    CStringView example_text);

    void check_triplet(const Triplet& t, const VcpkgPaths& paths);
}
