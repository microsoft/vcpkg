#include "pch.h"

#include "vcpkg_Checks.h"
#include "vcpkg_GlobalState.h"
#include "vcpkg_System.h"
#include "vcpkglib.h"

namespace vcpkg::System
{
    tm get_current_date_time()
    {
        using std::chrono::system_clock;
        std::time_t now_time = system_clock::to_time_t(system_clock::now());
        tm parts;
        localtime_s(&parts, &now_time);
        return parts;
    }

    fs::path get_exe_path_of_current_process()
    {
        wchar_t buf[_MAX_PATH];
        int bytes = GetModuleFileNameW(nullptr, buf, _MAX_PATH);
        if (bytes == 0) std::abort();
        return fs::path(buf, buf + bytes);
    }

    Optional<CPUArchitecture> to_cpu_architecture(CStringView arch)
    {
        if (Strings::case_insensitive_ascii_compare(arch, "x86") == 0) return CPUArchitecture::X86;
        if (Strings::case_insensitive_ascii_compare(arch, "x64") == 0) return CPUArchitecture::X64;
        if (Strings::case_insensitive_ascii_compare(arch, "amd64") == 0) return CPUArchitecture::X64;
        if (Strings::case_insensitive_ascii_compare(arch, "arm") == 0) return CPUArchitecture::ARM;
        if (Strings::case_insensitive_ascii_compare(arch, "arm64") == 0) return CPUArchitecture::ARM64;
        return nullopt;
    }

    CPUArchitecture get_host_processor()
    {
        auto w6432 = get_environment_variable(L"PROCESSOR_ARCHITEW6432");
        if (auto p = w6432.get()) return to_cpu_architecture(Strings::to_utf8(*p)).value_or_exit(VCPKG_LINE_INFO);

        auto procarch = get_environment_variable(L"PROCESSOR_ARCHITECTURE").value_or_exit(VCPKG_LINE_INFO);
        return to_cpu_architecture(Strings::to_utf8(procarch)).value_or_exit(VCPKG_LINE_INFO);
    }

    int cmd_execute_clean(const CWStringView cmd_line)
    {
        static const std::wstring system_root = get_environment_variable(L"SystemRoot").value_or_exit(VCPKG_LINE_INFO);
        static const std::wstring system_32 = system_root + LR"(\system32)";
        static const std::wstring new_PATH = Strings::wformat(
            LR"(Path=%s;%s;%s\Wbem;%s\WindowsPowerShell\v1.0\)", system_32, system_root, system_32, system_32);

        std::vector<std::wstring> env_wstrings = {
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
            L"PROCESSOR_ARCHITEW6432",
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
            // Enables find_package(CUDA) in CMake
            L"CUDA_PATH",
        };

        // Flush stdout before launching external process
        fflush(nullptr);

        std::wstring env_cstr;

        for (auto&& env_wstring : env_wstrings)
        {
            const Optional<std::wstring> value = System::get_environment_variable(env_wstring);
            auto v = value.get();
            if (!v || v->empty()) continue;

            env_cstr.append(env_wstring);
            env_cstr.push_back(L'=');
            env_cstr.append(*v);
            env_cstr.push_back(L'\0');
        }

        env_cstr.append(new_PATH);
        env_cstr.push_back(L'\0');

        STARTUPINFOW startup_info;
        memset(&startup_info, 0, sizeof(STARTUPINFOW));
        startup_info.cb = sizeof(STARTUPINFOW);

        PROCESS_INFORMATION process_info;
        memset(&process_info, 0, sizeof(PROCESS_INFORMATION));

        // Basically we are wrapping it in quotes
        std::wstring actual_cmd_line = Strings::wformat(LR"###(cmd.exe /c "%s")###", cmd_line);
        Debug::println("CreateProcessW(%s)", Strings::to_utf8(actual_cmd_line));
        bool succeeded = TRUE == CreateProcessW(nullptr,
                                                actual_cmd_line.data(),
                                                nullptr,
                                                nullptr,
                                                FALSE,
                                                BELOW_NORMAL_PRIORITY_CLASS | CREATE_UNICODE_ENVIRONMENT,
                                                env_cstr.data(),
                                                nullptr,
                                                &startup_info,
                                                &process_info);

        Checks::check_exit(VCPKG_LINE_INFO, succeeded, "Process creation failed with error code: %lu", GetLastError());

        CloseHandle(process_info.hThread);

        DWORD result = WaitForSingleObject(process_info.hProcess, INFINITE);
        Checks::check_exit(VCPKG_LINE_INFO, result != WAIT_FAILED, "WaitForSingleObject failed");

        DWORD exit_code = 0;
        GetExitCodeProcess(process_info.hProcess, &exit_code);

        Debug::println("CreateProcessW() returned %lu", exit_code);
        return static_cast<int>(exit_code);
    }

    int cmd_execute(const CWStringView cmd_line)
    {
        // Flush stdout before launching external process
        fflush(nullptr);

        // Basically we are wrapping it in quotes
        const std::wstring& actual_cmd_line = Strings::wformat(LR"###("%s")###", cmd_line);
        Debug::println("_wsystem(%s)", Strings::to_utf8(actual_cmd_line));
        int exit_code = _wsystem(actual_cmd_line.c_str());
        Debug::println("_wsystem() returned %d", exit_code);
        return exit_code;
    }

    ExitCodeAndOutput cmd_execute_and_capture_output(const CWStringView cmd_line)
    {
        // Flush stdout before launching external process
        fflush(stdout);

        const std::wstring& actual_cmd_line = Strings::wformat(LR"###("%s 2>&1")###", cmd_line);

        Debug::println("_wpopen(%s)", Strings::to_utf8(actual_cmd_line));
        std::string output;
        char buf[1024];
        auto pipe = _wpopen(actual_cmd_line.c_str(), L"r");
        if (pipe == nullptr)
        {
            return {1, output};
        }
        while (fgets(buf, 1024, pipe))
        {
            output.append(buf);
        }
        if (!feof(pipe))
        {
            return {1, output};
        }
        auto ec = _pclose(pipe);
        Debug::println("_wpopen() returned %d", ec);
        return {ec, output};
    }

    std::wstring create_powershell_script_cmd(const fs::path& script_path, const CWStringView args)
    {
        // TODO: switch out ExecutionPolicy Bypass with "Remove Mark Of The Web" code and restore RemoteSigned
        return Strings::wformat(
            LR"(powershell -NoProfile -ExecutionPolicy Bypass -Command "& {& '%s' %s}")", script_path.native(), args);
    }

    void print(const CStringView message) { fputs(message, stdout); }

    void println(const CStringView message)
    {
        print(message);
        putchar('\n');
    }

    void print(const Color c, const CStringView message)
    {
        HANDLE hConsole = GetStdHandle(STD_OUTPUT_HANDLE);

        CONSOLE_SCREEN_BUFFER_INFO consoleScreenBufferInfo{};
        GetConsoleScreenBufferInfo(hConsole, &consoleScreenBufferInfo);
        auto original_color = consoleScreenBufferInfo.wAttributes;

        SetConsoleTextAttribute(hConsole, static_cast<WORD>(c) | (original_color & 0xF0));
        print(message);
        SetConsoleTextAttribute(hConsole, original_color);
    }

    void println(const Color c, const CStringView message)
    {
        print(c, message);
        putchar('\n');
    }

    Optional<std::wstring> get_environment_variable(const CWStringView varname) noexcept
    {
        auto sz = GetEnvironmentVariableW(varname, nullptr, 0);
        if (sz == 0) return nullopt;

        std::wstring ret(sz, L'\0');

        Checks::check_exit(VCPKG_LINE_INFO, MAXDWORD >= ret.size());
        auto sz2 = GetEnvironmentVariableW(varname, ret.data(), static_cast<DWORD>(ret.size()));
        Checks::check_exit(VCPKG_LINE_INFO, sz2 + 1 == sz);
        ret.pop_back();
        return ret;
    }

    static bool is_string_keytype(DWORD hkey_type)
    {
        return hkey_type == REG_SZ || hkey_type == REG_MULTI_SZ || hkey_type == REG_EXPAND_SZ;
    }

    Optional<std::wstring> get_registry_string(HKEY base, const CWStringView subKey, const CWStringView valuename)
    {
        HKEY k = nullptr;
        LSTATUS ec = RegOpenKeyExW(base, subKey, NULL, KEY_READ, &k);
        if (ec != ERROR_SUCCESS) return nullopt;

        DWORD dwBufferSize = 0;
        DWORD dwType = 0;
        auto rc = RegQueryValueExW(k, valuename, nullptr, &dwType, nullptr, &dwBufferSize);
        if (rc != ERROR_SUCCESS || !is_string_keytype(dwType) || dwBufferSize == 0 ||
            dwBufferSize % sizeof(wchar_t) != 0)
            return nullopt;
        std::wstring ret;
        ret.resize(dwBufferSize / sizeof(wchar_t));

        rc = RegQueryValueExW(k, valuename, nullptr, &dwType, reinterpret_cast<LPBYTE>(ret.data()), &dwBufferSize);
        if (rc != ERROR_SUCCESS || !is_string_keytype(dwType) || dwBufferSize != sizeof(wchar_t) * ret.size())
            return nullopt;

        ret.pop_back(); // remove extra trailing null byte
        return ret;
    }

    static const fs::path& get_ProgramFiles()
    {
        static const fs::path p = System::get_environment_variable(L"PROGRAMFILES").value_or_exit(VCPKG_LINE_INFO);
        return p;
    }

    const fs::path& get_ProgramFiles_32_bit()
    {
        static const fs::path p = []() -> fs::path {
            auto value = System::get_environment_variable(L"ProgramFiles(x86)");
            if (auto v = value.get())
            {
                return std::move(*v);
            }
            return get_ProgramFiles();
        }();
        return p;
    }

    const fs::path& get_ProgramFiles_platform_bitness()
    {
        static const fs::path p = []() -> fs::path {
            auto value = System::get_environment_variable(L"ProgramW6432");
            if (auto v = value.get())
            {
                return std::move(*v);
            }
            return get_ProgramFiles();
        }();
        return p;
    }
}

namespace vcpkg::Debug
{
    void println(const CStringView message)
    {
        if (GlobalState::debugging)
        {
            System::println("[DEBUG] %s", message);
        }
    }

    void println(const System::Color c, const CStringView message)
    {
        if (GlobalState::debugging)
        {
            System::println(c, "[DEBUG] %s", message);
        }
    }
}
