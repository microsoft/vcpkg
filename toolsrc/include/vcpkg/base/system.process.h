#pragma once

#include <vcpkg/base/files.h>
#include <vcpkg/base/zstringview.h>

#include <functional>
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
        CMakeVariable(std::string var);

        std::string s;
    };

    std::string make_basic_cmake_cmd(const fs::path& cmake_tool_path,
                                     const fs::path& cmake_script,
                                     const std::vector<CMakeVariable>& pass_variables);

    struct CmdLineBuilder
    {
        CmdLineBuilder() = default;
        explicit CmdLineBuilder(const fs::path& p) { path_arg(p); }
        explicit CmdLineBuilder(StringView s) { string_arg(s); }
        explicit CmdLineBuilder(const std::string& s) { string_arg(s); }
        explicit CmdLineBuilder(const char* s) { string_arg({s, ::strlen(s)}); }

        CmdLineBuilder& path_arg(const fs::path& p) & { return string_arg(fs::u8string(p)); }
        CmdLineBuilder& string_arg(StringView s) &;

        CmdLineBuilder&& path_arg(const fs::path& p) && { return std::move(path_arg(p)); }
        CmdLineBuilder&& string_arg(StringView s) && { return std::move(string_arg(s)); };

        CmdLineBuilder& ampersand() &
        {
            buf.push_back('&');
            buf.push_back('&');
            return *this;
        }

        CmdLineBuilder&& ampersand() && { return std::move(ampersand()); }

        std::string&& extract() && { return std::move(buf); }
        operator StringView() noexcept { return buf; }
        StringView command_line() const { return buf; }

        void clear() { buf.clear(); }

    private:
        std::string buf;
    };

    fs::path get_exe_path_of_current_process();

    struct ExitCodeAndOutput
    {
        int exit_code;
        std::string output;
    };

    struct Environment
    {
#if defined(_WIN32)
        std::wstring m_env_data;
#endif
    };

    const Environment& get_clean_environment();
    Environment get_modified_clean_environment(const std::unordered_map<std::string, std::string>& extra_env,
                                               const std::string& prepend_to_path = {});

    struct InWorkingDirectory
    {
        const fs::path& working_directory;
    };

    int cmd_execute(StringView cmd_line, const Environment& env = {});
    int cmd_execute(StringView cmd_line, InWorkingDirectory wd, const Environment& env = {});

    int cmd_execute_clean(StringView cmd_line);
    int cmd_execute_clean(StringView cmd_line, InWorkingDirectory wd);

#if defined(_WIN32)
    Environment cmd_execute_modify_env(StringView cmd_line, const Environment& env = {});

    void cmd_execute_background(const StringView cmd_line);
#endif

    ExitCodeAndOutput cmd_execute_and_capture_output(StringView cmd_line, const Environment& env = {});
    ExitCodeAndOutput cmd_execute_and_capture_output(StringView cmd_line,
                                                     InWorkingDirectory wd,
                                                     const Environment& env = {});

    int cmd_execute_and_stream_lines(StringView cmd_line,
                                     std::function<void(StringView)> per_line_cb,
                                     const Environment& env = {});
    int cmd_execute_and_stream_lines(StringView cmd_line,
                                     InWorkingDirectory wd,
                                     std::function<void(StringView)> per_line_cb,
                                     const Environment& env = {});

    int cmd_execute_and_stream_data(StringView cmd_line,
                                    std::function<void(StringView)> data_cb,
                                    const Environment& env = {});
    int cmd_execute_and_stream_data(StringView cmd_line,
                                    InWorkingDirectory wd,
                                    std::function<void(StringView)> data_cb,
                                    const Environment& env = {});
    void register_console_ctrl_handler();
#if defined(_WIN32)
    void initialize_global_job_object();
    void enter_interactive_subprocess();
    void exit_interactive_subprocess();
#endif
}
