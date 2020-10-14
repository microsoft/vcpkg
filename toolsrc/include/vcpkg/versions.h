#pragma once

#include <vcpkg/fwd/vcpkgpaths.h>

#include <set>
#include <string>
#include <tuple>
#include <vector>

namespace vcpkg::Versions
{
    enum class Scheme
    {
        String,
        Relaxed,
        Semver,
        Date
    };
}
