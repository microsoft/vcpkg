#pragma once

#include <vcpkg/base/cstringview.h>
#include <vcpkg/base/strings.h>

namespace vcpkg::Checks
{
    void register_global_shutdown_handler(void (*func)());

    // Note: for internal use
    [[noreturn]] void final_cleanup_and_exit(const int exit_code);

    // Indicate that an internal error has occurred and exit the tool. This should be used when invariants have been
    // broken.
    [[noreturn]] void unreachable(const LineInfo& line_info);

    [[noreturn]] void exit_with_code(const LineInfo& line_info, const int exit_code);

    // Exit the tool without an error message.
    [[noreturn]] inline void exit_fail(const LineInfo& line_info) { exit_with_code(line_info, EXIT_FAILURE); }

    // Exit the tool successfully.
    [[noreturn]] inline void exit_success(const LineInfo& line_info) { exit_with_code(line_info, EXIT_SUCCESS); }

    // Display an error message to the user and exit the tool.
    [[noreturn]] void exit_with_message(const LineInfo& line_info, StringView error_message);

    template<class Arg1, class... Args>
    // Display an error message to the user and exit the tool.
    [[noreturn]] void exit_with_message(const LineInfo& line_info,
                                        const char* error_message_template,
                                        const Arg1& error_message_arg1,
                                        const Args&... error_message_args)
    {
        exit_with_message(line_info,
                          Strings::format(error_message_template, error_message_arg1, error_message_args...));
    }

    void check_exit(const LineInfo& line_info, bool expression);

    void check_exit(const LineInfo& line_info, bool expression, StringView error_message);

    template<class Conditional, class Arg1, class... Args>
    void check_exit(const LineInfo& line_info,
                    Conditional&& expression,
                    const char* error_message_template,
                    const Arg1& error_message_arg1,
                    const Args&... error_message_args)
    {
        if (!expression)
        {
            // Only create the string if the expression is false
            exit_with_message(line_info,
                              Strings::format(error_message_template, error_message_arg1, error_message_args...));
        }
    }
}
