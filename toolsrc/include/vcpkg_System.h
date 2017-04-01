#pragma once

#include <Windows.h>
#include "vcpkg_Strings.h"
#include "filesystem_fs.h"
#include "vcpkg_optional.h"

namespace vcpkg::System
{
    fs::path get_exe_path_of_current_process();

    struct exit_code_and_output
    {
        int exit_code;
        std::string output;
    };

    int cmd_execute_clean(const cwstring_view cmd_line);

    int cmd_execute(const cwstring_view cmd_line);

    exit_code_and_output cmd_execute_and_capture_output(const cwstring_view cmd_line);

    std::wstring create_powershell_script_cmd(const fs::path& script_path, const cwstring_view args = L"");

    enum class color
    {
        success = 10,
        error = 12,
        warning = 14,
    };

    void print(const cstring_view message);
    void println(const cstring_view message);
    void print(const color c, const cstring_view message);
    void println(const color c, const cstring_view message);

    template <class Arg1, class...Args>
    void print(const char* messageTemplate, const Arg1& messageArg1, const Args&... messageArgs)
    {
        return print(Strings::format(messageTemplate, messageArg1, messageArgs...));
    }

    template <class Arg1, class...Args>
    void print(const color c, const char* messageTemplate, const Arg1& messageArg1,  const Args&... messageArgs)
    {
        return print(c, Strings::format(messageTemplate, messageArg1, messageArgs...));
    }

    template <class Arg1, class...Args>
    void println(const char* messageTemplate, const Arg1& messageArg1, const Args&... messageArgs)
    {
        return println(Strings::format(messageTemplate, messageArg1, messageArgs...));
    }

    template <class Arg1, class...Args>
    void println(const color c, const char* messageTemplate, const Arg1& messageArg1, const Args&... messageArgs)
    {
        return println(c, Strings::format(messageTemplate, messageArg1, messageArgs...));
    }

    optional<std::wstring> get_environmental_variable(const cwstring_view varname) noexcept;

    optional<std::wstring> get_registry_string(HKEY base, const cwstring_view subkey, const cwstring_view valuename);
}
