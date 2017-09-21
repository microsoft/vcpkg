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
        const int bytes = GetModuleFileNameW(nullptr, buf, _MAX_PATH);
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
        if (const auto p = w6432.get()) return to_cpu_architecture(Strings::to_utf8(*p)).value_or_exit(VCPKG_LINE_INFO);

        const auto procarch = get_environment_variable(L"PROCESSOR_ARCHITECTURE").value_or_exit(VCPKG_LINE_INFO);
        return to_cpu_architecture(Strings::to_utf8(procarch)).value_or_exit(VCPKG_LINE_INFO);
    }

    std::vector<CPUArchitecture> get_supported_host_architectures()
    {
        std::vector<CPUArchitecture> supported_architectures;
        supported_architectures.push_back(get_host_processor());

        // AMD64 machines support to run x86 applications
        if (supported_architectures.back() == CPUArchitecture::X64)
        {
            supported_architectures.push_back(CPUArchitecture::X86);
        }

        return supported_architectures;
    }

    int cmd_execute_clean(const CWStringView cmd_line)
    {
        static const std::wstring SYSTEM_ROOT = get_environment_variable(L"SystemRoot").value_or_exit(VCPKG_LINE_INFO);
        static const std::wstring SYSTEM_32 = SYSTEM_ROOT + LR"(\system32)";
        static const std::wstring NEW_PATH = Strings::wformat(
            LR"(Path=%s;%s;%s\Wbem;%s\WindowsPowerShell\v1.0\)", SYSTEM_32, SYSTEM_ROOT, SYSTEM_32, SYSTEM_32);

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
            const auto v = value.get();
            if (!v || v->empty()) continue;

            env_cstr.append(env_wstring);
            env_cstr.push_back(L'=');
            env_cstr.append(*v);
            env_cstr.push_back(L'\0');
        }

        env_cstr.append(NEW_PATH);
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

        const DWORD result = WaitForSingleObject(process_info.hProcess, INFINITE);
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
        const int exit_code = _wsystem(actual_cmd_line.c_str());
        Debug::println("_wsystem() returned %d", exit_code);
        return exit_code;
    }

    // On Win7, output from powershell calls contain a byte order mark, so we strip it out if it is present
    static void remove_byte_order_mark(std::wstring* s)
    {
        const wchar_t* a = s->c_str();
        // This is the UTF-8 byte-order mark
        if (a[0] == 0xEF && a[1] == 0xBB && a[2] == 0xBF)
        {
            s->erase(0, 3);
        }
    }

    ExitCodeAndOutput cmd_execute_and_capture_output(const CWStringView cmd_line)
    {
        // Flush stdout before launching external process
        fflush(stdout);

        const std::wstring& actual_cmd_line = Strings::wformat(LR"###("%s 2>&1")###", cmd_line);

        Debug::println("_wpopen(%s)", Strings::to_utf8(actual_cmd_line));
        std::wstring output;
        wchar_t buf[1024];
        const auto pipe = _wpopen(actual_cmd_line.c_str(), L"r");
        if (pipe == nullptr)
        {
            return {1, Strings::to_utf8(output)};
        }
        while (fgetws(buf, 1024, pipe))
        {
            output.append(buf);
        }
        if (!feof(pipe))
        {
            return {1, Strings::to_utf8(output)};
        }

        const auto ec = _pclose(pipe);
        Debug::println("_pclose() returned %d", ec);
        remove_byte_order_mark(&output);
        return {ec, Strings::to_utf8(output)};
    }

    std::wstring create_powershell_script_cmd(const fs::path& script_path, const CWStringView args)
    {
        // TODO: switch out ExecutionPolicy Bypass with "Remove Mark Of The Web" code and restore RemoteSigned
        return Strings::wformat(
            LR"(powershell -NoProfile -ExecutionPolicy Bypass -Command "& {& '%s' %s}")", script_path.native(), args);
    }

    void println() { println(Strings::EMPTY); }

    void print(const CStringView message) { fputs(message, stdout); }

    void println(const CStringView message)
    {
        print(message);
        putchar('\n');
    }

    void print(const Color c, const CStringView message)
    {
        const HANDLE console_handle = GetStdHandle(STD_OUTPUT_HANDLE);

        CONSOLE_SCREEN_BUFFER_INFO console_screen_buffer_info{};
        GetConsoleScreenBufferInfo(console_handle, &console_screen_buffer_info);
        const auto original_color = console_screen_buffer_info.wAttributes;

        SetConsoleTextAttribute(console_handle, static_cast<WORD>(c) | (original_color & 0xF0));
        print(message);
        SetConsoleTextAttribute(console_handle, original_color);
    }

    void println(const Color c, const CStringView message)
    {
        print(c, message);
        putchar('\n');
    }

    Optional<std::wstring> get_environment_variable(const CWStringView varname) noexcept
    {
        const auto sz = GetEnvironmentVariableW(varname, nullptr, 0);
        if (sz == 0) return nullopt;

        std::wstring ret(sz, L'\0');

        Checks::check_exit(VCPKG_LINE_INFO, MAXDWORD >= ret.size());
        const auto sz2 = GetEnvironmentVariableW(varname, ret.data(), static_cast<DWORD>(ret.size()));
        Checks::check_exit(VCPKG_LINE_INFO, sz2 + 1 == sz);
        ret.pop_back();
        return ret;
    }

    static bool is_string_keytype(DWORD hkey_type)
    {
        return hkey_type == REG_SZ || hkey_type == REG_MULTI_SZ || hkey_type == REG_EXPAND_SZ;
    }

    Optional<std::wstring> get_registry_string(HKEY base, const CWStringView sub_key, const CWStringView valuename)
    {
        HKEY k = nullptr;
        const LSTATUS ec = RegOpenKeyExW(base, sub_key, NULL, KEY_READ, &k);
        if (ec != ERROR_SUCCESS) return nullopt;

        DWORD dw_buffer_size = 0;
        DWORD dw_type = 0;
        auto rc = RegQueryValueExW(k, valuename, nullptr, &dw_type, nullptr, &dw_buffer_size);
        if (rc != ERROR_SUCCESS || !is_string_keytype(dw_type) || dw_buffer_size == 0 ||
            dw_buffer_size % sizeof(wchar_t) != 0)
            return nullopt;
        std::wstring ret;
        ret.resize(dw_buffer_size / sizeof(wchar_t));

        rc = RegQueryValueExW(k, valuename, nullptr, &dw_type, reinterpret_cast<LPBYTE>(ret.data()), &dw_buffer_size);
        if (rc != ERROR_SUCCESS || !is_string_keytype(dw_type) || dw_buffer_size != sizeof(wchar_t) * ret.size())
            return nullopt;

        ret.pop_back(); // remove extra trailing null byte
        return ret;
    }

    static const fs::path& get_program_files()
    {
        static const fs::path PATH = System::get_environment_variable(L"PROGRAMFILES").value_or_exit(VCPKG_LINE_INFO);
        return PATH;
    }

    const fs::path& get_program_files_32_bit()
    {
        static const fs::path PATH = []() -> fs::path {
            auto value = System::get_environment_variable(L"ProgramFiles(x86)");
            if (auto v = value.get())
            {
                return std::move(*v);
            }
            return get_program_files();
        }();
        return PATH;
    }

    const fs::path& get_program_files_platform_bitness()
    {
        static const fs::path PATH = []() -> fs::path {
            auto value = System::get_environment_variable(L"ProgramW6432");
            if (auto v = value.get())
            {
                return std::move(*v);
            }
            return get_program_files();
        }();
        return PATH;
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
