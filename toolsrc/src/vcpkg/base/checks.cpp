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

        const auto elapsed_us = GlobalState::timer.lock()->microseconds();

        Debug::println("Exiting after %d us", static_cast<int>(elapsed_us));

        auto metrics = Metrics::g_metrics.lock();
        metrics->track_metric("elapsed_us", elapsed_us);
        GlobalState::debugging = false;
        metrics->flush();

#if defined(_WIN32)
        SetConsoleCP(GlobalState::g_init_console_cp);
        SetConsoleOutputCP(GlobalState::g_init_console_output_cp);
#endif

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
        {
            auto locked_metrics = Metrics::g_metrics.lock();
            locked_metrics->track_property("CtrlHandler", std::to_string(fdw_ctrl_type));
            locked_metrics->track_property("error", "CtrlHandler was fired.");
        }
        cleanup_and_exit(EXIT_FAILURE);
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
