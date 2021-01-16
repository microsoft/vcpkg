#pragma once

#include <vcpkg/base/lineinfo.h>
#include <vcpkg/base/stringview.h>

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
    [[noreturn]] void exit_fail(const LineInfo& line_info);

    // Exit the tool successfully.
    [[noreturn]] void exit_success(const LineInfo& line_info);

    // Display an error message to the user and exit the tool.
    [[noreturn]] void exit_with_message(const LineInfo& line_info, StringView error_message);

    void check_exit(const LineInfo& line_info, bool expression);

    void check_exit(const LineInfo& line_info, bool expression, StringView error_message);
}
