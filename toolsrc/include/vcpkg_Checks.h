#pragma once

#include "vcpkg_Strings.h"
#include "LineInfo.h"

namespace vcpkg::Checks
{
    [[noreturn]]
    void unreachable(const LineInfo& line_info);

    [[noreturn]]
    void exit_with_code(const LineInfo& line_info, const int exit_code);

    [[noreturn]]
    inline void exit_fail(const LineInfo& line_info)
    {
        exit_with_code(line_info, EXIT_FAILURE);
    }

    [[noreturn]]
    inline void exit_success(const LineInfo& line_info)
    {
        exit_with_code(line_info, EXIT_SUCCESS);
    }

    // Part of the reason these exist is to not include extra headers in this one to avoid circular #includes. 
    [[noreturn]]
    void exit_with_message(const LineInfo& line_info, const CStringView errorMessage);

    template <class Arg1, class...Args>
    [[noreturn]]
    void exit_with_message(const LineInfo& line_info, const char* errorMessageTemplate, const Arg1 errorMessageArg1, const Args&... errorMessageArgs)
    {
        exit_with_message(line_info, Strings::format(errorMessageTemplate, errorMessageArg1, errorMessageArgs...));
    }

    void check_exit(const LineInfo& line_info, bool expression);

    void check_exit(const LineInfo& line_info, bool expression, const CStringView errorMessage);

    template <class Arg1, class...Args>
    void check_exit(const LineInfo& line_info, bool expression, const char* errorMessageTemplate, const Arg1 errorMessageArg1, const Args&... errorMessageArgs)
    {
        if (!expression)
        {
            // Only create the string if the expression is false
            exit_with_message(line_info, Strings::format(errorMessageTemplate, errorMessageArg1, errorMessageArgs...));
        }
    }
}
