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

    struct Constraint
    {
        enum class Type
        {
            None,
            Minimum,
            Exact
        };
    };
}
