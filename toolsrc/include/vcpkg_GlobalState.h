#pragma once

#include <vcpkg_Chrono.h>

namespace vcpkg
{
    struct GlobalState
    {
        static ElapsedTime timer;
        static bool debugging;
        static bool feature_packages;
    };
}