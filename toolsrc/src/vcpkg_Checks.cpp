#include "pch.h"
#include "vcpkg_Checks.h"
#include "vcpkg_System.h"
#include "vcpkglib.h"

namespace vcpkg::Checks
{
    static void print_line_info_if_debug(const LineInfo& line_info)
    {
        if (g_debugging)
        {
            System::println(System::color::error, line_info.toString());
        }
    }

    __declspec(noreturn) void unreachable(const LineInfo& line_info)
    {
        System::println(System::color::error, "Error: Unreachable code was reached");
        System::println(System::color::error, line_info.toString()); // Always print line_info here
#ifndef NDEBUG
        std::abort();
#else
        ::exit(EXIT_FAILURE);
#endif
    }

    void exit_with_code(const LineInfo& line_info, const int exit_code)
    {
        print_line_info_if_debug(line_info);
        ::exit(exit_code);
    }

    __declspec(noreturn) void exit_with_message(const LineInfo& line_info, const cstring_view errorMessage)
    {
        System::println(System::color::error, errorMessage);
        exit_fail(line_info);
    }

    void check_exit(const LineInfo& line_info, bool expression)
    {
        if (!expression)
        {
            exit_with_message(line_info, "");
        }
    }

    void check_exit(const LineInfo& line_info, bool expression, const cstring_view errorMessage)
    {
        if (!expression)
        {
            exit_with_message(line_info, errorMessage);
        }
    }
}
