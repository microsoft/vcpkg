#include "pch.h"

#include "vcpkg_Checks.h"
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
#ifdef _WIN32
        wchar_t buf[VCPKG_MAX_PATH];
        int bytes = GetModuleFileNameW(nullptr, buf, VCPKG_MAX_PATH);
#elif __linux__
        char buf[VCPKG_MAX_PATH];
        int bytes = readlink("/proc/self/exe", buf, VCPKG_MAX_PATH);
#endif
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
#ifdef _WIN32
        auto w6432 = get_environment_variable(L"PROCESSOR_ARCHITEW6432");
        if (auto p = w6432.get()) return to_cpu_architecture(Strings::to_utf8(*p)).value_or_exit(VCPKG_LINE_INFO);

        auto procarch = get_environment_variable(L"PROCESSOR_ARCHITECTURE").value_or_exit(VCPKG_LINE_INFO);
        return to_cpu_architecture(Strings::to_utf8(procarch)).value_or_exit(VCPKG_LINE_INFO);
#endif
#ifdef __linux__
        struct utsname info;

        if (uname(&info) == -1)
        {
            return to_cpu_architecture("").value_or_exit(VCPKG_LINE_INFO);
        }
        // TODO Add linux architecture to `to_cpu_architecture` options
        return to_cpu_architecture(info.machine).value_or_exit()
#endif
    }

#ifdef _WIN32
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

        std::vector<const wchar_t*> env_cstr;
        env_cstr.reserve(env_wstrings.size() + 2);

        for (auto&& env_wstring : env_wstrings)
        {
            const Optional<std::wstring> value = System::get_environment_variable(env_wstring);
            auto v = value.get();
            if (!v || v->empty()) continue;

            env_wstring.push_back(L'=');
            env_wstring.append(*v);
            env_cstr.push_back(env_wstring.c_str());
        }

        env_cstr.push_back(new_PATH.c_str());
        env_cstr.push_back(nullptr);

        // Basically we are wrapping it in quotes
        const std::wstring& actual_cmd_line = Strings::wformat(LR"###("%s")###", cmd_line);
        Debug::println("_wspawnlpe(cmd.exe /c %s)", Strings::to_utf8(actual_cmd_line));
        auto exit_code =
            _wspawnlpe(_P_WAIT, L"cmd.exe", L"cmd.exe", L"/c", actual_cmd_line.c_str(), nullptr, env_cstr.data());
        Debug::println("_wspawnlpe() returned %d", exit_code);
        return static_cast<int>(exit_code);
    }
#endif

#ifdef _WIN32
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
#else
    int cmd_execute(const CStringView cmd_line)
    {
        fflush(nullptr);
        const std::string actual_cmd_line = Strings::format(R"(%s 2>&1)", cmd_line);
        Debug::println("system(%s)", actual_cmd_line);
        int exit_code = system(actual_cmd_line.c_str());
        Debug::println("system() returned %d", exit_code);
        return exit_code;
    }
#endif

#ifdef _WIN32
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
#else
    ExitCodeAndOutput cmd_execute_and_capture_output(const CStringView cmd_line)
    {
        // Flush stdout before launching external process
        fflush(stdout);

        const std::string& actual_cmd_line = Strings::format(R"(%s 2>&1)", cmd_line);
        Debug::println("popen(%s)", actual_cmd_line);

        std::string output;
        char buf[1024];
        auto pipe = popen(actual_cmd_line.c_str(), "r");
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
        auto ec = pclose(pipe);
        Debug::println("popen() returned %d", ec);
        return {ec, output};
    }
#endif

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
#ifdef _WIN32
        HANDLE hConsole = GetStdHandle(STD_OUTPUT_HANDLE);

        CONSOLE_SCREEN_BUFFER_INFO consoleScreenBufferInfo{};
        GetConsoleScreenBufferInfo(hConsole, &consoleScreenBufferInfo);
        auto original_color = consoleScreenBufferInfo.wAttributes;

        SetConsoleTextAttribute(hConsole, static_cast<WORD>(c) | (original_color & 0xF0));
        print(message);
        SetConsoleTextAttribute(hConsole, original_color);
#elif __linux__
        const std::string& colored_message = Strings.format("\033[%dm%s", static_cast<int>(c), message);
        const std::string& original_color = Strings.format("\033[%dm", static_cast<int>(Color::original_color));
        println(colored_message);
        print(original_color);
#endif
    }

    void println(const Color c, const CStringView message)
    {
        print(c, message);
        putchar('\n');
    }

#ifdef _WIN32
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
#endif

#ifdef __linux__
    Optional<std::string> get_environment_variable(const CStringView varname) noexcept
    {
        const char* env = getenv(varname);
        return env == nullptr ? nullopt : std::string(env);
    }
#endif

#ifdef _WIN32
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
#endif
#ifdef __linux__
    const fs::path& get_bin()
    {
        static const fs::path p = "/bin";
        return p;
    }
    const fs::path& get_sbin()
    {
        static const fs::path p = "/sbin";
        return p;
    }
    const fs::path& get_usr_bin()
    {
        static const fs::path p = "/usr/bin";
        return p;
    }
    const fs::path& get_usr_sbin()
    {
        static const fs::path p = "/usr/sbin";
        return p;
    }
#endif
}

namespace vcpkg::Debug
{
    void println(const CStringView message)
    {
        if (g_debugging)
        {
            System::println("[DEBUG] %s", message);
        }
    }

    void println(const System::Color c, const CStringView message)
    {
        if (g_debugging)
        {
            System::println(c, "[DEBUG] %s", message);
        }
    }
}
