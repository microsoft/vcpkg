#pragma once

#include "vcpkg_Strings.h"

#include <filesystem>

namespace vcpkg {namespace System
{
    std::tr2::sys::path get_exe_path_of_current_process();

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
    void print(color c, const char* message);
    void println(color c, const char* message);

    template <class...Args>
    void print(const char* messageTemplate, const Args&... messageArgs)
    {
        return print(Strings::format(messageTemplate, messageArgs...).c_str());
    }

    template <class...Args>
    void print(color c, const char* messageTemplate, const Args&... messageArgs)
    {
        return print(c, Strings::format(messageTemplate, messageArgs...).c_str());
    }

    template <class...Args>
    void println(const char* messageTemplate, const Args&... messageArgs)
    {
        return println(Strings::format(messageTemplate, messageArgs...).c_str());
    }

    template <class...Args>
    void println(color c, const char* messageTemplate, const Args&... messageArgs)
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
}}
