#include "pch.h"

#include "vcpkg_GlobalState.h"

namespace vcpkg
{
    ElapsedTime GlobalState::timer;
    bool GlobalState::debugging = false;
    bool GlobalState::feature_packages = false;
}
