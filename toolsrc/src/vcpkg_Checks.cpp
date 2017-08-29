#include "pch.h"

#include "metrics.h"
#include "vcpkg_Checks.h"
#include "vcpkg_GlobalState.h"
#include "vcpkg_System.h"
#include "vcpkglib.h"

namespace vcpkg::Checks
{
    [[noreturn]] static void cleanup_and_exit(const int exit_code)
    {
        auto elapsed_us = GlobalState::timer.lock()->microseconds();

        auto metrics = Metrics::g_metrics.lock();
        metrics->track_metric("elapsed_us", elapsed_us);
        GlobalState::debugging = false;
        metrics->flush();

        SetConsoleCP(GlobalState::g_init_console_cp);
        SetConsoleOutputCP(GlobalState::g_init_console_output_cp);

        ::exit(exit_code);
    }

    static BOOL CtrlHandler(DWORD fdwCtrlType)
    {
        {
            auto locked_metrics = Metrics::g_metrics.lock();
            locked_metrics->track_property("CtrlHandler", std::to_string(fdwCtrlType));
            locked_metrics->track_property("error", "CtrlHandler was fired.");
        }
        cleanup_and_exit(EXIT_FAILURE);
    }

    void register_console_ctrl_handler() { SetConsoleCtrlHandler((PHANDLER_ROUTINE)CtrlHandler, TRUE); }

    [[noreturn]] void unreachable(const LineInfo& line_info)
    {
        System::println(System::Color::error, "Error: Unreachable code was reached");
        System::println(System::Color::error, line_info.to_string()); // Always print line_info here
#ifndef NDEBUG
        std::abort();
#else
        cleanup_and_exit(EXIT_FAILURE);
#endif
    }

    [[noreturn]] void exit_with_code(const LineInfo& line_info, const int exit_code)
    {
        Debug::println(System::Color::error, line_info.to_string());
        cleanup_and_exit(exit_code);
    }

    [[noreturn]] void exit_with_message(const LineInfo& line_info, const CStringView errorMessage)
    {
        System::println(System::Color::error, errorMessage);
        exit_fail(line_info);
    }

    void check_exit(const LineInfo& line_info, bool expression)
    {
        if (!expression)
        {
            exit_with_message(line_info, Strings::EMPTY);
        }
    }

    void check_exit(const LineInfo& line_info, bool expression, const CStringView errorMessage)
    {
        if (!expression)
        {
            exit_with_message(line_info, errorMessage);
        }
    }
}
