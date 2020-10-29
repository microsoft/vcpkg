#pragma once

#include <vcpkg/base/chrono.h>
#include <vcpkg/base/lineinfo.h>
#include <vcpkg/base/system.print.h>

#include <atomic>

namespace vcpkg::Debug
{
    extern std::atomic<bool> g_debugging;

    template<class... Args>
    void print(System::Color c, const Args&... args)
    {
        if (g_debugging) System::print2(c, "[DEBUG] ", args...);
    }

    template<class... Args>
    void print(const Args&... args)
    {
        if (g_debugging) System::print2("[DEBUG] ", args...);
    }

    template<class F, class R = std::result_of_t<F && ()>, class = std::enable_if_t<!std::is_void<R>::value>>
    R time(LineInfo line, F&& f)
    {
        if (g_debugging)
        {
            auto timer = Chrono::ElapsedTimer::create_started();
            auto&& result = f();
            System::print2("[DEBUG] ", line, " took ", timer, '\n');
            return static_cast<R&&>(result);
        }
        else
            return f();
    }

    template<class F, class R = std::result_of_t<F && ()>, class = std::enable_if_t<std::is_void<R>::value>>
    void time(LineInfo line, F&& f)
    {
        if (g_debugging)
        {
            auto timer = Chrono::ElapsedTimer::create_started();
            f();
            System::print2("[DEBUG] ", line, " took ", timer, '\n');
        }
        else
            f();
    }
}
