#pragma once

#include <vcpkg/base/files.h>
#include <vcpkg/base/zstringview.h>

#include <string>
#include <unordered_map>
#include <vector>

namespace vcpkg::System
{
    struct CMakeVariable
    {
        CMakeVariable(const StringView varname, const char* varvalue);
        CMakeVariable(const StringView varname, const std::string& varvalue);
        CMakeVariable(const StringView varname, const fs::path& path);

        std::string s;
    };

    std::string make_cmake_cmd(const fs::path& cmake_exe,
                               const fs::path& cmake_script,
                               const std::vector<CMakeVariable>& pass_variables);

    fs::path get_exe_path_of_current_process();

    struct ExitCodeAndOutput
    {
        int exit_code;
        std::string output;
    };

    int cmd_execute_clean(const ZStringView cmd_line,
                          const std::unordered_map<std::string, std::string>& extra_env = {},
                          const std::string& prepend_to_path = {});

    int cmd_execute(const ZStringView cmd_line);

#if defined(_WIN32)
    void cmd_execute_no_wait(const StringView cmd_line);
#endif

    ExitCodeAndOutput cmd_execute_and_capture_output(const ZStringView cmd_line);

    void register_console_ctrl_handler();
}
