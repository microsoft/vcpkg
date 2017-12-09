#pragma once

#include <vcpkg/base/chrono.h>
#include <vcpkg/base/util.h>

#include <atomic>

namespace vcpkg
{
    struct GlobalState
    {
        static Util::LockGuarded<Chrono::ElapsedTimer> timer;
        static Util::LockGuarded<std::string> g_surveydate;

        static std::atomic<bool> debugging;
        static std::atomic<bool> feature_packages;

        static std::atomic<int> g_init_console_cp;
        static std::atomic<int> g_init_console_output_cp;
    };
}
