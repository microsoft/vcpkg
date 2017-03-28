#pragma once

#include "vcpkg_Strings.h"
#include "LineInfo.h"

namespace vcpkg::Checks
{
    __declspec(noreturn) void unreachable(const LineInfo& line_info);

    _declspec(noreturn) void exit_with_code(const LineInfo& line_info, const int exit_code);

    _declspec(noreturn) inline void exit_fail(const LineInfo& line_info)
    {
        exit_with_code(line_info, EXIT_FAILURE);
    }

    _declspec(noreturn) inline void exit_success(const LineInfo& line_info)
    {
        exit_with_code(line_info, EXIT_SUCCESS);
    }

    // Part of the reason these exist is to not include extra headers in this one to avoid circular #includes. 
    _declspec(noreturn) void exit_with_message(const LineInfo& line_info, const cstring_view errorMessage);

    template <class Arg1, class...Args>
    _declspec(noreturn) void exit_with_message(const LineInfo& line_info, const char* errorMessageTemplate, const Arg1 errorMessageArg1, const Args&... errorMessageArgs)
    {
        exit_with_message(line_info, Strings::format(errorMessageTemplate, errorMessageArg1, errorMessageArgs...).c_str());
    }

    _declspec(noreturn) void throw_with_message(const LineInfo& line_info, const cstring_view errorMessage);

    template <class Arg1, class...Args>
    _declspec(noreturn) void throw_with_message(const LineInfo& line_info, const char* errorMessageTemplate, const Arg1 errorMessageArg1, const Args&... errorMessageArgs)
    {
        throw_with_message(line_info, Strings::format(errorMessageTemplate, errorMessageArg1, errorMessageArgs...).c_str());
    }

    void check_throw(const LineInfo& line_info, bool expression, const cstring_view errorMessage);

    template <class Arg1, class...Args>
    void check_throw(const LineInfo& line_info, bool expression, const char* errorMessageTemplate, const Arg1 errorMessageArg1, const Args&... errorMessageArgs)
    {
        if (!expression)
        {
            // Only create the string if the expression is false
            throw_with_message(line_info, Strings::format(errorMessageTemplate, errorMessageArg1, errorMessageArgs...).c_str());
        }
    }

    void check_exit(const LineInfo& line_info, bool expression);

    void check_exit(const LineInfo& line_info, bool expression, const cstring_view errorMessage);

    template <class Arg1, class...Args>
    void check_exit(const LineInfo& line_info, bool expression, const char* errorMessageTemplate, const Arg1 errorMessageArg1, const Args&... errorMessageArgs)
    {
        if (!expression)
        {
            // Only create the string if the expression is false
            exit_with_message(line_info, Strings::format(errorMessageTemplate, errorMessageArg1, errorMessageArgs...).c_str());
        }
    }
}
