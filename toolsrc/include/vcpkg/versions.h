#pragma once

#include <vcpkg/fwd/vcpkgpaths.h>

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
