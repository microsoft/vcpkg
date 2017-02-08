#pragma once

#include "vcpkg_Strings.h"
#include "filesystem_fs.h"

namespace vcpkg::System
{
    fs::path get_exe_path_of_current_process();

    struct exit_code_and_output
    {
        int exit_code;
        std::string output;
    };

    int cmd_execute(const wchar_t* cmd_line);

    inline int cmd_execute(const std::wstring& cmd_line)
    {
        return cmd_execute(cmd_line.c_str());
    }

    exit_code_and_output cmd_execute_and_capture_output(const wchar_t* cmd_line);

    inline exit_code_and_output cmd_execute_and_capture_output(const std::wstring& cmd_line)
    {
        return cmd_execute_and_capture_output(cmd_line.c_str());
    }

    enum class color
    {
        success = 10,
        error = 12,
        warning = 14,
    };

    void print(const char* message);
    void println(const char* message);
    void print(const color c, const char* message);
    void println(const color c, const char* message);

    inline void print(const std::string& message)
    {
        return print(message.c_str());
    }

    inline void println(const std::string& message)
    {
        return println(message.c_str());
    }

    inline void print(const color c, const std::string& message)
    {
        return print(c, message.c_str());
    }

    inline void println(const color c, const std::string& message)
    {
        return println(c, message.c_str());
    }

    template <class...Args>
    void print(const char* messageTemplate, const Args&... messageArgs)
    {
        return print(Strings::format(messageTemplate, messageArgs...).c_str());
    }

    template <class...Args>
    void print(const color c, const char* messageTemplate, const Args&... messageArgs)
    {
        return print(c, Strings::format(messageTemplate, messageArgs...).c_str());
    }

    template <class...Args>
    void println(const char* messageTemplate, const Args&... messageArgs)
    {
        return println(Strings::format(messageTemplate, messageArgs...).c_str());
    }

    template <class...Args>
    void println(const color c, const char* messageTemplate, const Args&... messageArgs)
    {
        return println(c, Strings::format(messageTemplate, messageArgs...).c_str());
    }

    struct Stopwatch2
    {
        int64_t start_time, end_time, freq;

        void start();
        void stop();
        double microseconds() const;
    };

    std::wstring wdupenv_str(const wchar_t* varname) noexcept;
}
