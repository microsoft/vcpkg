#pragma once

#include "LineInfo.h"
#include "vcpkg_Strings.h"

namespace vcpkg::Checks
{
    // Indicate that an internal error has occurred and exit the tool. This should be used when invariants have been
    // broken.
    [[noreturn]] void unreachable(const LineInfo& line_info);

    [[noreturn]] void exit_with_code(const LineInfo& line_info, const int exit_code);

    // Exit the tool without an error message.
    [[noreturn]] inline void exit_fail(const LineInfo& line_info) { exit_with_code(line_info, EXIT_FAILURE); }

    // Exit the tool successfully.
    [[noreturn]] inline void exit_success(const LineInfo& line_info) { exit_with_code(line_info, EXIT_SUCCESS); }

    // Display an error message to the user and exit the tool.
    [[noreturn]] void exit_with_message(const LineInfo& line_info, const CStringView errorMessage);

    template<class Arg1, class... Args>
    // Display an error message to the user and exit the tool.
    [[noreturn]] void exit_with_message(const LineInfo& line_info,
                                        const char* errorMessageTemplate,
                                        const Arg1 errorMessageArg1,
                                        const Args&... errorMessageArgs)
    {
        exit_with_message(line_info, Strings::format(errorMessageTemplate, errorMessageArg1, errorMessageArgs...));
    }

    void check_exit(const LineInfo& line_info, bool expression);

    void check_exit(const LineInfo& line_info, bool expression, const CStringView errorMessage);

    template<class Conditional, class Arg1, class... Args>
    void check_exit(const LineInfo& line_info,
                    Conditional&& expression,
                    const char* errorMessageTemplate,
                    const Arg1 errorMessageArg1,
                    const Args&... errorMessageArgs)
    {
        if (!expression)
        {
            // Only create the string if the expression is false
            exit_with_message(line_info, Strings::format(errorMessageTemplate, errorMessageArg1, errorMessageArgs...));
        }
    }
}
