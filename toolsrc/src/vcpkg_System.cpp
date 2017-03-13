#include "pch.h"
#include "vcpkg_System.h"
#include "vcpkg_Checks.h"

namespace vcpkg::System
{
    fs::path get_exe_path_of_current_process()
    {
        wchar_t buf[_MAX_PATH];
        int bytes = GetModuleFileNameW(nullptr, buf, _MAX_PATH);
        if (bytes == 0)
            std::abort();
        return fs::path(buf, buf + bytes);
    }

    int cmd_execute_clean(const wchar_t* cmd_line)
    {
        static const std::wstring system_root = *get_environmental_variable(L"SystemRoot");
        static const std::wstring system_32 = system_root + LR"(\system32)";
        static const std::wstring new_PATH = Strings::wformat(LR"(Path=%s;%s;%s\WindowsPowerShell\v1.0\)", system_32, system_root, system_32);

        std::vector<std::wstring> env_wstrings =
        {
            L"ALLUSERSPROFILE",
            L"APPDATA",
            L"CommonProgramFiles",
            L"CommonProgramFiles(x86)",
            L"CommonProgramW6432",
            L"COMPUTERNAME",
            L"ComSpec",
            L"HOMEDRIVE",
            L"HOMEPATH",
            L"LOCALAPPDATA",
            L"LOGONSERVER",
            L"NUMBER_OF_PROCESSORS",
            L"OS",
            L"PATHEXT",
            L"PROCESSOR_ARCHITECTURE",
            L"PROCESSOR_IDENTIFIER",
            L"PROCESSOR_LEVEL",
            L"PROCESSOR_REVISION",
            L"ProgramData",
            L"ProgramFiles",
            L"ProgramFiles(x86)",
            L"ProgramW6432",
            L"PROMPT",
            L"PSModulePath",
            L"PUBLIC",
            L"SystemDrive",
            L"SystemRoot",
            L"TEMP",
            L"TMP",
            L"USERDNSDOMAIN",
            L"USERDOMAIN",
            L"USERDOMAIN_ROAMINGPROFILE",
            L"USERNAME",
            L"USERPROFILE",
            L"windir",
            // Enables proxy information to be passed to Curl, the underlying download library in cmake.exe
            L"HTTP_PROXY",
            L"HTTPS_PROXY",
        };

        // Flush stdout before launching external process
        _flushall();

        std::vector<const wchar_t*> env_cstr;
        env_cstr.reserve(env_wstrings.size() + 2);

        for (auto&& env_wstring : env_wstrings)
        {
            auto v = System::get_environmental_variable(env_wstring.c_str());
            if (v == nullptr || v->empty())
                continue;

            env_wstring.push_back(L'=');
            env_wstring.append(*v);
            env_cstr.push_back(env_wstring.c_str());
        }

        env_cstr.push_back(new_PATH.c_str());
        env_cstr.push_back(nullptr);

        // Basically we are wrapping it in quotes
        const std::wstring& actual_cmd_line = Strings::wformat(LR"###("%s")###", cmd_line);
        auto exit_code = _wspawnlpe(_P_WAIT, L"cmd.exe", L"cmd.exe", L"/c", actual_cmd_line.c_str(), nullptr, env_cstr.data());
        return static_cast<int>(exit_code);
    }

    int cmd_execute(const wchar_t* cmd_line)
    {
        // Flush stdout before launching external process
        _flushall();

        // Basically we are wrapping it in quotes
        const std::wstring& actual_cmd_line = Strings::wformat(LR"###("%s")###", cmd_line);
        int exit_code = _wsystem(actual_cmd_line.c_str());
        return exit_code;
    }

    exit_code_and_output cmd_execute_and_capture_output(const wchar_t* cmd_line)
    {
        // Flush stdout before launching external process
        fflush(stdout);

        const std::wstring& actual_cmd_line = Strings::wformat(LR"###("%s")###", cmd_line);

        std::string output;
        char buf[1024];
        auto pipe = _wpopen(actual_cmd_line.c_str(), L"r");
        if (pipe == nullptr)
        {
            return { 1, output };
        }
        while (fgets(buf, 1024, pipe))
        {
            output.append(buf);
        }
        if (!feof(pipe))
        {
            return { 1, output };
        }
        auto ec = _pclose(pipe);
        return { ec, output };
    }

    std::wstring create_powershell_script_cmd(const fs::path& script_path)
    {
        return create_powershell_script_cmd(script_path, L"");
    }

    std::wstring create_powershell_script_cmd(const fs::path& script_path, const std::wstring& args)
    {
        // TODO: switch out ExecutionPolicy Bypass with "Remove Mark Of The Web" code and restore RemoteSigned
        return Strings::wformat(LR"(powershell -ExecutionPolicy Bypass -Command "& {& '%s' %s}")", script_path.native(), args);
    }

    void print(const char* message)
    {
        fputs(message, stdout);
    }

    void println(const char* message)
    {
        print(message);
        putchar('\n');
    }

    void print(const color c, const char* message)
    {
        HANDLE hConsole = GetStdHandle(STD_OUTPUT_HANDLE);

        CONSOLE_SCREEN_BUFFER_INFO consoleScreenBufferInfo{};
        GetConsoleScreenBufferInfo(hConsole, &consoleScreenBufferInfo);
        auto original_color = consoleScreenBufferInfo.wAttributes;

        SetConsoleTextAttribute(hConsole, static_cast<WORD>(c) | (original_color & 0xF0));
        print(message);
        SetConsoleTextAttribute(hConsole, original_color);
    }

    void println(const color c, const char* message)
    {
        print(c, message);
        putchar('\n');
    }

    optional<std::wstring> get_environmental_variable(const wchar_t* varname) noexcept
    {
        auto sz = GetEnvironmentVariableW(varname, nullptr, 0);
        if (sz == 0)
            return nullptr;

        auto ret = std::make_unique<std::wstring>(sz, L'\0');
        Checks::check_exit(MAXDWORD >= ret->size());
        auto sz2 = GetEnvironmentVariableW(varname, ret->data(), static_cast<DWORD>(ret->size()));
        Checks::check_exit(sz2 + 1 == sz);
        ret->pop_back();
        return ret;
    }

    void set_environmental_variable(const wchar_t* varname, const wchar_t* varvalue) noexcept
    {
        _wputenv_s(varname, varvalue);
    }

    static bool is_string_keytype(DWORD hkey_type)
    {
        return hkey_type == REG_SZ || hkey_type == REG_MULTI_SZ || hkey_type == REG_EXPAND_SZ;
    }

    optional<std::wstring> get_registry_string(HKEY base, const wchar_t* subKey, const wchar_t* valuename)
    {
        HKEY k = nullptr;
        LSTATUS ec = RegOpenKeyExW(base, subKey, NULL, KEY_READ, &k);
        if (ec != ERROR_SUCCESS)
            return nullptr;

        DWORD dwBufferSize = 0;
        DWORD dwType = 0;
        auto rc = RegQueryValueExW(k, valuename, nullptr, &dwType, nullptr, &dwBufferSize);
        if (rc != ERROR_SUCCESS || !is_string_keytype(dwType) || dwBufferSize == 0 || dwBufferSize % sizeof(wchar_t) != 0)
            return nullptr;
        std::wstring ret;
        ret.resize(dwBufferSize / sizeof(wchar_t));

        rc = RegQueryValueExW(k, valuename, nullptr, &dwType, reinterpret_cast<LPBYTE>(ret.data()), &dwBufferSize);
        if (rc != ERROR_SUCCESS || !is_string_keytype(dwType) || dwBufferSize != sizeof(wchar_t) * ret.size())
            return nullptr;

        ret.pop_back(); // remove extra trailing null byte
        return std::make_unique<std::wstring>(std::move(ret));
    }
}
