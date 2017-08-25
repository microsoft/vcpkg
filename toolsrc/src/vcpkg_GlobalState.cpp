#include "pch.h"

#include "vcpkg_GlobalState.h"

namespace vcpkg
{
    Util::LockGuarded<ElapsedTime> GlobalState::timer;
    std::atomic<bool> GlobalState::debugging = false;
    std::atomic<bool> GlobalState::feature_packages = false;
}
