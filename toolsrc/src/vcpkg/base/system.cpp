#include "pch.h"

#include <vcpkg/base/checks.h>
#include <vcpkg/base/system.h>
#include <vcpkg/globalstate.h>
#include <vcpkg/metrics.h>

#include <ctime>

#if defined(__APPLE__)
#include <mach-o/dyld.h>
#endif

#if defined(__FreeBSD__)
#include <sys/sysctl.h>
#endif

#pragma comment(lib, "Advapi32")

namespace vcpkg::System
{
    tm get_current_date_time()
    {
        using std::chrono::system_clock;
        std::time_t now_time = system_clock::to_time_t(system_clock::now());
        tm parts{};
#if defined(_WIN32)
        localtime_s(&parts, &now_time);
#else
        parts = *localtime(&now_time);
#endif
        return parts;
    }

    fs::path get_exe_path_of_current_process()
    {
#if defined(_WIN32)
        wchar_t buf[_MAX_PATH];
        const int bytes = GetModuleFileNameW(nullptr, buf, _MAX_PATH);
        if (bytes == 0) std::abort();
        return fs::path(buf, buf + bytes);
#elif defined(__APPLE__)
        uint32_t size = 1024 * 32;
        char buf[size] = {};
        bool result = _NSGetExecutablePath(buf, &size);
        Checks::check_exit(VCPKG_LINE_INFO, result != -1, "Could not determine current executable path.");
        std::unique_ptr<char> canonicalPath(realpath(buf, NULL));
        Checks::check_exit(VCPKG_LINE_INFO, result != -1, "Could not determine current executable path.");
        return fs::path(std::string(canonicalPath.get()));
#elif defined(__FreeBSD__)
        int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_PATHNAME, -1};
        char exePath[2048];
        size_t len = sizeof(exePath);
        auto rcode = sysctl(mib, 4, exePath, &len, NULL, 0);
        Checks::check_exit(VCPKG_LINE_INFO, rcode == 0, "Could not determine current executable path.");
        Checks::check_exit(VCPKG_LINE_INFO, len > 0, "Could not determine current executable path.");
        return fs::path(exePath, exePath + len - 1);
#else /* LINUX */
        std::array<char, 1024 * 4> buf;
        auto written = readlink("/proc/self/exe", buf.data(), buf.size());
        Checks::check_exit(VCPKG_LINE_INFO, written != -1, "Could not determine current executable path.");
        return fs::path(buf.data(), buf.data() + written);
#endif
    }

    Optional<CPUArchitecture> to_cpu_architecture(const CStringView& arch)
    {
        if (Strings::case_insensitive_ascii_equals(arch, "x86")) return CPUArchitecture::X86;
        if (Strings::case_insensitive_ascii_equals(arch, "x64")) return CPUArchitecture::X64;
        if (Strings::case_insensitive_ascii_equals(arch, "amd64")) return CPUArchitecture::X64;
        if (Strings::case_insensitive_ascii_equals(arch, "arm")) return CPUArchitecture::ARM;
        if (Strings::case_insensitive_ascii_equals(arch, "arm64")) return CPUArchitecture::ARM64;
        return nullopt;
    }

    CPUArchitecture get_host_processor()
    {
#if defined(_WIN32)
        auto w6432 = get_environment_variable("PROCESSOR_ARCHITEW6432");
        if (const auto p = w6432.get()) return to_cpu_architecture(*p).value_or_exit(VCPKG_LINE_INFO);

        const auto procarch = get_environment_variable("PROCESSOR_ARCHITECTURE").value_or_exit(VCPKG_LINE_INFO);
        return to_cpu_architecture(procarch).value_or_exit(VCPKG_LINE_INFO);
#else
#if defined(__x86_64__) || defined(_M_X64)
        return CPUArchitecture::X64;
#elif defined(__x86__) || defined(_M_X86)
        return CPUArchitecture::X86;
#else
#error "Unknown host architecture"
#endif
#endif
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

    CMakeVariable::CMakeVariable(const CStringView varname, const char* varvalue)
        : s(Strings::format(R"("-D%s=%s")", varname, varvalue))
    {
    }
    CMakeVariable::CMakeVariable(const CStringView varname, const std::string& varvalue)
        : CMakeVariable(varname, varvalue.c_str())
    {
    }
    CMakeVariable::CMakeVariable(const CStringView varname, const fs::path& path)
        : CMakeVariable(varname, path.generic_u8string())
    {
    }

    std::string make_cmake_cmd(const fs::path& cmake_exe,
                               const fs::path& cmake_script,
                               const std::vector<CMakeVariable>& pass_variables)
    {
        const std::string cmd_cmake_pass_variables = Strings::join(" ", pass_variables, [](auto&& v) { return v.s; });
        return Strings::format(
            R"("%s" %s -P "%s")", cmake_exe.u8string(), cmd_cmake_pass_variables, cmake_script.generic_u8string());
    }

    PowershellParameter::PowershellParameter(const CStringView varname, const char* varvalue)
        : s(Strings::format(R"(-%s '%s')", varname, varvalue))
    {
    }

    PowershellParameter::PowershellParameter(const CStringView varname, const std::string& varvalue)
        : PowershellParameter(varname, varvalue.c_str())
    {
    }

    PowershellParameter::PowershellParameter(const CStringView varname, const fs::path& path)
        : PowershellParameter(varname, path.generic_u8string())
    {
    }

    static std::string make_powershell_cmd(const fs::path& script_path,
                                           const std::vector<PowershellParameter>& parameters)
    {
        const std::string args = Strings::join(" ", parameters, [](auto&& v) { return v.s; });

        // TODO: switch out ExecutionPolicy Bypass with "Remove Mark Of The Web" code and restore RemoteSigned
        return Strings::format(
            R"(powershell -NoProfile -ExecutionPolicy Bypass -Command "& {& '%s' %s}")", script_path.u8string(), args);
    }

    int cmd_execute_clean(const CStringView cmd_line, const std::unordered_map<std::string, std::string>& extra_env)
    {
#if defined(_WIN32)
        static const std::string SYSTEM_ROOT = get_environment_variable("SystemRoot").value_or_exit(VCPKG_LINE_INFO);
        static const std::string SYSTEM_32 = SYSTEM_ROOT + R"(\system32)";
        std::string new_path = Strings::format(
            R"(Path=%s;%s;%s\Wbem;%s\WindowsPowerShell\v1.0\)", SYSTEM_32, SYSTEM_ROOT, SYSTEM_32, SYSTEM_32);

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
            L"http_proxy",
            L"https_proxy",
            // Enables find_package(CUDA) in CMake
            L"CUDA_PATH",
            // Environmental variable generated automatically by CUDA after installation
            L"NVCUDASAMPLES_ROOT",
        };

        // Flush stdout before launching external process
        fflush(nullptr);

        std::wstring env_cstr;

        for (auto&& env_wstring : env_wstrings)
        {
            const Optional<std::string> value = System::get_environment_variable(Strings::to_utf8(env_wstring.c_str()));
            const auto v = value.get();
            if (!v || v->empty()) continue;

            env_cstr.append(env_wstring);
            env_cstr.push_back(L'=');
            env_cstr.append(Strings::to_utf16(*v));
            env_cstr.push_back(L'\0');
        }

        if (extra_env.find("PATH") != extra_env.end())
            new_path += Strings::format(";%s", extra_env.find("PATH")->second);
        env_cstr.append(Strings::to_utf16(new_path));
        env_cstr.push_back(L'\0');
        env_cstr.append(L"VSLANG=1033");
        env_cstr.push_back(L'\0');

        for (const auto& item : extra_env)
        {
            if (item.first == "PATH") continue;
            env_cstr.append(Strings::to_utf16(item.first));
            env_cstr.push_back(L'=');
            env_cstr.append(Strings::to_utf16(item.second));
            env_cstr.push_back(L'\0');
        }

        STARTUPINFOW startup_info;
        memset(&startup_info, 0, sizeof(STARTUPINFOW));
        startup_info.cb = sizeof(STARTUPINFOW);

        PROCESS_INFORMATION process_info;
        memset(&process_info, 0, sizeof(PROCESS_INFORMATION));

        // Basically we are wrapping it in quotes
        const std::string actual_cmd_line = Strings::format(R"###(cmd.exe /c "%s")###", cmd_line);
        Debug::println("CreateProcessW(%s)", actual_cmd_line);
        bool succeeded = TRUE == CreateProcessW(nullptr,
                                                Strings::to_utf16(actual_cmd_line).data(),
                                                nullptr,
                                                nullptr,
                                                FALSE,
                                                IDLE_PRIORITY_CLASS | CREATE_UNICODE_ENVIRONMENT,
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
#else
        Debug::println("system(%s)", cmd_line.c_str());
        fflush(nullptr);
        int rc = system(cmd_line.c_str());
        Debug::println("system() returned %d", rc);
        return rc;
#endif
    }

    int cmd_execute(const CStringView cmd_line)
    {
        // Flush stdout before launching external process
        fflush(nullptr);

        // Basically we are wrapping it in quotes
#if defined(_WIN32)
        const std::string& actual_cmd_line = Strings::format(R"###("%s")###", cmd_line);
        Debug::println("_wsystem(%s)", actual_cmd_line);
        const int exit_code = _wsystem(Strings::to_utf16(actual_cmd_line).c_str());
        Debug::println("_wsystem() returned %d", exit_code);
#else
        Debug::println("_system(%s)", cmd_line);
        const int exit_code = system(cmd_line.c_str());
        Debug::println("_system() returned %d", exit_code);
#endif
        return exit_code;
    }

    ExitCodeAndOutput cmd_execute_and_capture_output(const CStringView cmd_line)
    {
        // Flush stdout before launching external process
        fflush(stdout);

        auto timer = Chrono::ElapsedTimer::create_started();

#if defined(_WIN32)
        const auto actual_cmd_line = Strings::format(R"###("%s 2>&1")###", cmd_line);

        Debug::println("_wpopen(%s)", actual_cmd_line);
        std::wstring output;
        wchar_t buf[1024];
        const auto pipe = _wpopen(Strings::to_utf16(actual_cmd_line).c_str(), L"r");
        if (pipe == nullptr)
        {
            return {1, Strings::to_utf8(output.c_str())};
        }
        while (fgetws(buf, 1024, pipe))
        {
            output.append(buf);
        }
        if (!feof(pipe))
        {
            return {1, Strings::to_utf8(output.c_str())};
        }

        const auto ec = _pclose(pipe);

        // On Win7, output from powershell calls contain a utf-8 byte order mark in the utf-16 stream, so we strip it
        // out if it is present. 0xEF,0xBB,0xBF is the UTF-8 byte-order mark
        const wchar_t* a = output.c_str();
        while (output.size() >= 3 && a[0] == 0xEF && a[1] == 0xBB && a[2] == 0xBF)
        {
            output.erase(0, 3);
        }

        Debug::println("_pclose() returned %d after %8d us", ec, static_cast<int>(timer.microseconds()));

        return {ec, Strings::to_utf8(output.c_str())};
#else
        const auto actual_cmd_line = Strings::format(R"###(%s 2>&1)###", cmd_line);

        Debug::println("popen(%s)", actual_cmd_line);
        std::string output;
        char buf[1024];
        const auto pipe = popen(actual_cmd_line.c_str(), "r");
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

        const auto ec = pclose(pipe);

        Debug::println("_pclose() returned %d after %8d us", ec, (int)timer.microseconds());

        return {ec, output};
#endif
    }

    void powershell_execute(const std::string& title,
                            const fs::path& script_path,
                            const std::vector<PowershellParameter>& parameters)
    {
        const std::string cmd = make_powershell_cmd(script_path, parameters);
        const int rc = System::cmd_execute(cmd);

        if (rc)
        {
            System::println(Color::error,
                            "%s\n"
                            "Could not run:\n"
                            "    '%s'",
                            title,
                            script_path.generic_string());

            {
                auto locked_metrics = Metrics::g_metrics.lock();
                locked_metrics->track_property("error", "powershell script failed");
                locked_metrics->track_property("title", title);
            }

            Checks::exit_with_code(VCPKG_LINE_INFO, rc);
        }
    }

    std::string powershell_execute_and_capture_output(const std::string& title,
                                                      const fs::path& script_path,
                                                      const std::vector<PowershellParameter>& parameters)
    {
        const std::string cmd = make_powershell_cmd(script_path, parameters);
        auto rc = System::cmd_execute_and_capture_output(cmd);

        if (rc.exit_code)
        {
            System::println(Color::error,
                            "%s\n"
                            "Could not run:\n"
                            "    '%s'\n"
                            "Error message was:\n"
                            "    %s",
                            title,
                            script_path.generic_string(),
                            rc.output);

            {
                auto locked_metrics = Metrics::g_metrics.lock();
                locked_metrics->track_property("error", "powershell script failed");
                locked_metrics->track_property("title", title);
            }

            Checks::exit_with_code(VCPKG_LINE_INFO, rc.exit_code);
        }

        // Remove newline from all output.
        // Powershell returns newlines when it hits the column count of the console.
        // For example, this is 80 in cmd on Windows 7. If the expected output is longer than 80 lines, we get
        // newlines in-between the data.
        // To solve this, we design our interaction with powershell to not depend on newlines,
        // and then strip all newlines here.
        rc.output = Strings::replace_all(std::move(rc.output), "\n", "");

        return rc.output;
    }

    void println() { putchar('\n'); }

    void print(const CStringView message) { fputs(message.c_str(), stdout); }

    void println(const CStringView message)
    {
        print(message);
        println();
    }

    void print(const Color c, const CStringView message)
    {
#if defined(_WIN32)
        const HANDLE console_handle = GetStdHandle(STD_OUTPUT_HANDLE);

        CONSOLE_SCREEN_BUFFER_INFO console_screen_buffer_info{};
        GetConsoleScreenBufferInfo(console_handle, &console_screen_buffer_info);
        const auto original_color = console_screen_buffer_info.wAttributes;

        SetConsoleTextAttribute(console_handle, static_cast<WORD>(c) | (original_color & 0xF0));
        print(message);
        SetConsoleTextAttribute(console_handle, original_color);
#else
        print(message);
#endif
    }

    void println(const Color c, const CStringView message)
    {
        print(c, message);
        println();
    }

    Optional<std::string> get_environment_variable(const CStringView varname) noexcept
    {
#if defined(_WIN32)
        const auto w_varname = Strings::to_utf16(varname);
        const auto sz = GetEnvironmentVariableW(w_varname.c_str(), nullptr, 0);
        if (sz == 0) return nullopt;

        std::wstring ret(sz, L'\0');

        Checks::check_exit(VCPKG_LINE_INFO, MAXDWORD >= ret.size());
        const auto sz2 = GetEnvironmentVariableW(w_varname.c_str(), ret.data(), static_cast<DWORD>(ret.size()));
        Checks::check_exit(VCPKG_LINE_INFO, sz2 + 1 == sz);
        ret.pop_back();
        return Strings::to_utf8(ret.c_str());
#else
        auto v = getenv(varname.c_str());
        if (!v) return nullopt;
        return std::string(v);
#endif
    }

#if defined(_WIN32)
    static bool is_string_keytype(const DWORD hkey_type)
    {
        return hkey_type == REG_SZ || hkey_type == REG_MULTI_SZ || hkey_type == REG_EXPAND_SZ;
    }

    Optional<std::string> get_registry_string(void* base_hkey, const CStringView sub_key, const CStringView valuename)
    {
        HKEY k = nullptr;
        const LSTATUS ec =
            RegOpenKeyExW(reinterpret_cast<HKEY>(base_hkey), Strings::to_utf16(sub_key).c_str(), NULL, KEY_READ, &k);
        if (ec != ERROR_SUCCESS) return nullopt;

        DWORD dw_buffer_size = 0;
        DWORD dw_type = 0;
        auto rc =
            RegQueryValueExW(k, Strings::to_utf16(valuename).c_str(), nullptr, &dw_type, nullptr, &dw_buffer_size);
        if (rc != ERROR_SUCCESS || !is_string_keytype(dw_type) || dw_buffer_size == 0 ||
            dw_buffer_size % sizeof(wchar_t) != 0)
            return nullopt;
        std::wstring ret;
        ret.resize(dw_buffer_size / sizeof(wchar_t));

        rc = RegQueryValueExW(k,
                              Strings::to_utf16(valuename).c_str(),
                              nullptr,
                              &dw_type,
                              reinterpret_cast<LPBYTE>(ret.data()),
                              &dw_buffer_size);
        if (rc != ERROR_SUCCESS || !is_string_keytype(dw_type) || dw_buffer_size != sizeof(wchar_t) * ret.size())
            return nullopt;

        ret.pop_back(); // remove extra trailing null byte
        return Strings::to_utf8(ret.c_str());
    }
#else
    Optional<std::string> get_registry_string(void* base_hkey, const CStringView sub_key, const CStringView valuename)
    {
        return nullopt;
    }
#endif

    static const Optional<fs::path>& get_program_files()
    {
        static const auto PATH = []() -> Optional<fs::path> {
            auto value = System::get_environment_variable("PROGRAMFILES");
            if (auto v = value.get())
            {
                return *v;
            }

            return nullopt;
        }();

        return PATH;
    }

    const Optional<fs::path>& get_program_files_32_bit()
    {
        static const auto PATH = []() -> Optional<fs::path> {
            auto value = System::get_environment_variable("ProgramFiles(x86)");
            if (auto v = value.get())
            {
                return *v;
            }
            return get_program_files();
        }();
        return PATH;
    }

    const Optional<fs::path>& get_program_files_platform_bitness()
    {
        static const auto PATH = []() -> Optional<fs::path> {
            auto value = System::get_environment_variable("ProgramW6432");
            if (auto v = value.get())
            {
                return *v;
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
