#include "pch.h"

#include <vcpkg/globalstate.h>

namespace vcpkg
{
    Util::LockGuarded<Chrono::ElapsedTime> GlobalState::timer;
    std::atomic<bool> GlobalState::debugging(false);
    std::atomic<bool> GlobalState::feature_packages(false);

    std::atomic<int> GlobalState::g_init_console_cp(0);
    std::atomic<int> GlobalState::g_init_console_output_cp(0);
}
