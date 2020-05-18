#include "pch.h"

#include <vcpkg/base/checks.h>
#include <vcpkg/base/stringview.h>
#include <vcpkg/base/system.debug.h>

namespace vcpkg
{
    static void (*g_shutdown_handler)() = nullptr;
    void Checks::register_global_shutdown_handler(void (*func)())
    {
        if (g_shutdown_handler)
            // Setting the handler twice is a program error. Terminate.
            std::abort();
        g_shutdown_handler = func;
    }

    [[noreturn]] void Checks::final_cleanup_and_exit(const int exit_code)
    {
        static std::atomic<bool> have_entered{false};
        if (have_entered.exchange(true))
        {
#if defined(_WIN32)
            ::TerminateProcess(::GetCurrentProcess(), exit_code);
#else
            std::terminate();
#endif
        }

        if (g_shutdown_handler) g_shutdown_handler();

        fflush(nullptr);

#if defined(_WIN32)
        ::TerminateProcess(::GetCurrentProcess(), exit_code);
#endif
        std::exit(exit_code);
    }

    [[noreturn]] void Checks::unreachable(const LineInfo& line_info)
    {
        System::print2(System::Color::error, "Error: Unreachable code was reached\n");
        System::print2(System::Color::error, line_info, '\n'); // Always print line_info here
#ifndef NDEBUG
        std::abort();
#else
        final_cleanup_and_exit(EXIT_FAILURE);
#endif
    }

    [[noreturn]] void Checks::exit_with_code(const LineInfo& line_info, const int exit_code)
    {
        Debug::print(System::Color::error, line_info, '\n');
        final_cleanup_and_exit(exit_code);
    }

    [[noreturn]] void Checks::exit_with_message(const LineInfo& line_info, StringView error_message)
    {
        System::print2(System::Color::error, error_message, '\n');
        exit_fail(line_info);
    }

    void Checks::check_exit(const LineInfo& line_info, bool expression)
    {
        if (!expression)
        {
            exit_fail(line_info);
        }
    }

    void Checks::check_exit(const LineInfo& line_info, bool expression, StringView error_message)
    {
        if (!expression)
        {
            exit_with_message(line_info, error_message);
        }
    }

    std::string LineInfo::to_string() const
    {
        std::string ret;
        this->to_string(ret);
        return ret;
    }
    void LineInfo::to_string(std::string& out) const
    {
        out += m_file_name;
        Strings::append(out, '(', m_line_number, ')');
    }
    namespace details
    {
        void exit_if_null(bool b, const LineInfo& line_info) { Checks::check_exit(line_info, b, "Value was null"); }
    }
}
