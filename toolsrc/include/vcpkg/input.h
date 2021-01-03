#pragma once

#include <vcpkg/base/cstringview.h>

#include <vcpkg/packagespec.h>
#include <vcpkg/triplet.h>
#include <vcpkg/vcpkgpaths.h>

namespace vcpkg::Input
{
    PackageSpec check_and_get_package_spec(std::string&& spec_string,
                                           Triplet default_triplet,
                                           CStringView example_text);
    FullPackageSpec check_and_get_full_package_spec(std::string&& spec_string,
                                                    Triplet default_triplet,
                                                    CStringView example_text);

    void check_triplet(Triplet t, const VcpkgPaths& paths);
}
