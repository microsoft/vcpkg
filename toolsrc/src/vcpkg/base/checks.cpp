#include "pch.h"

#include <vcpkg/globalstate.h>
#include <vcpkg/metrics.h>

#include <vcpkg/base/checks.h>
#include <vcpkg/base/system.h>

namespace vcpkg::Checks
{
    [[noreturn]] static void cleanup_and_exit(const int exit_code)
    {
        static std::atomic<bool> have_entered{false};
        if (have_entered) std::terminate();
        have_entered = true;

        const auto elapsed_us_inner = GlobalState::timer.lock()->microseconds();

        bool debugging = GlobalState::debugging;

        auto metrics = Metrics::g_metrics.lock();
        metrics->track_metric("elapsed_us", elapsed_us_inner);
        GlobalState::debugging = false;
        metrics->flush();

#if defined(_WIN32)
        if (GlobalState::g_init_console_initialized)
        {
            SetConsoleCP(GlobalState::g_init_console_cp);
            SetConsoleOutputCP(GlobalState::g_init_console_output_cp);
        }
#endif

        auto elapsed_us = GlobalState::timer.lock()->microseconds();
        if (debugging)
            System::println("[DEBUG] Exiting after %d us (%d us)",
                            static_cast<int>(elapsed_us),
                            static_cast<int>(elapsed_us_inner));

        fflush(nullptr);

#if defined(_WIN32)
        ::TerminateProcess(::GetCurrentProcess(), exit_code);
#else
        std::exit(exit_code);
#endif
    }

#if defined(_WIN32)
    static BOOL ctrl_handler(DWORD fdw_ctrl_type)
    {
        switch (fdw_ctrl_type)
        {
            case CTRL_C_EVENT: GlobalState::g_ctrl_c_state.transition_handle_ctrl_c(); return TRUE;
            default: return FALSE;
        }
    }

    void register_console_ctrl_handler()
    {
        SetConsoleCtrlHandler(reinterpret_cast<PHANDLER_ROUTINE>(ctrl_handler), TRUE);
    }
#else
    void register_console_ctrl_handler() {}
#endif
    void unreachable(const LineInfo& line_info)
    {
        System::println(System::Color::error, "Error: Unreachable code was reached");
        System::println(System::Color::error, line_info.to_string()); // Always print line_info here
#ifndef NDEBUG
        std::abort();
#else
        cleanup_and_exit(EXIT_FAILURE);
#endif
    }

    void exit_with_code(const LineInfo& line_info, const int exit_code)
    {
        Debug::println(System::Color::error, line_info.to_string());
        cleanup_and_exit(exit_code);
    }

    void exit_with_message(const LineInfo& line_info, const CStringView error_message)
    {
        System::println(System::Color::error, error_message);
        exit_fail(line_info);
    }

    void check_exit(const LineInfo& line_info, bool expression)
    {
        if (!expression)
        {
            exit_fail(line_info);
        }
    }

    void check_exit(const LineInfo& line_info, bool expression, const CStringView error_message)
    {
        if (!expression)
        {
            exit_with_message(line_info, error_message);
        }
    }
}
