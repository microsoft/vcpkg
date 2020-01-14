#include "pch.h"

#include <vcpkg/base/checks.h>
#include <vcpkg/base/chrono.h>
#include <vcpkg/base/system.debug.h>
#include <vcpkg/base/system.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/base/util.h>

#include <ctime>

#if defined(__APPLE__)
#include <mach-o/dyld.h>
#endif

#if defined(__FreeBSD__)
#include <sys/sysctl.h>
#endif

#if defined(_WIN32)
#pragma comment(lib, "Advapi32")
#endif

using namespace vcpkg::System;

namespace vcpkg
{
#if defined(_WIN32)
    namespace
    {
        struct CtrlCStateMachine
        {
            CtrlCStateMachine() : m_state(CtrlCState::normal) {}

            void transition_to_spawn_process() noexcept
            {
                auto expected = CtrlCState::normal;
                auto transitioned = m_state.compare_exchange_strong(expected, CtrlCState::blocked_on_child);
                if (!transitioned)
                {
                    // Ctrl-C was hit and is asynchronously executing on another thread
                    Checks::exit_fail(VCPKG_LINE_INFO);
                }
            }
            void transition_from_spawn_process() noexcept
            {
                auto expected = CtrlCState::blocked_on_child;
                auto transitioned = m_state.compare_exchange_strong(expected, CtrlCState::normal);
                if (!transitioned)
                {
                    // Ctrl-C was hit while blocked on the child process, so exit immediately
                    Checks::exit_fail(VCPKG_LINE_INFO);
                }
            }
            void transition_handle_ctrl_c() noexcept
            {
                auto prev_state = m_state.exchange(CtrlCState::exit_requested);

                if (prev_state == CtrlCState::normal)
                {
                    // Not currently blocked on a child process and Ctrl-C has not been hit.
                    Checks::exit_fail(VCPKG_LINE_INFO);
                }
                else if (prev_state == CtrlCState::exit_requested)
                {
                    // Ctrl-C was hit previously?
                }
                else
                {
                    // We are currently blocked on a child process. Upon return, transition_from_spawn_process() will be
                    // called and exit.
                }
            }

        private:
            enum class CtrlCState
            {
                normal,
                blocked_on_child,
                exit_requested,
            };

            std::atomic<CtrlCState> m_state;
        };

        static CtrlCStateMachine g_ctrl_c_state;
    }
#endif

    fs::path System::get_exe_path_of_current_process()
    {
#if defined(_WIN32)
        wchar_t buf[_MAX_PATH];
        const int bytes = GetModuleFileNameW(nullptr, buf, _MAX_PATH);
        if (bytes == 0) std::abort();
        return fs::path(buf, buf + bytes);
#elif defined(__APPLE__)
        static constexpr const uint32_t buff_size = 1024 * 32;
        uint32_t size = buff_size;
        char buf[buff_size] = {};
        int result = _NSGetExecutablePath(buf, &size);
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

    Optional<CPUArchitecture> System::to_cpu_architecture(StringView arch)
    {
        if (Strings::case_insensitive_ascii_equals(arch, "x86")) return CPUArchitecture::X86;
        if (Strings::case_insensitive_ascii_equals(arch, "x64")) return CPUArchitecture::X64;
        if (Strings::case_insensitive_ascii_equals(arch, "amd64")) return CPUArchitecture::X64;
        if (Strings::case_insensitive_ascii_equals(arch, "arm")) return CPUArchitecture::ARM;
        if (Strings::case_insensitive_ascii_equals(arch, "arm64")) return CPUArchitecture::ARM64;
        return nullopt;
    }

    CPUArchitecture System::get_host_processor()
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
#elif defined(__arm__) || defined(_M_ARM)
        return CPUArchitecture::ARM;
#elif defined(__aarch64__) || defined(_M_ARM64)
        return CPUArchitecture::ARM64;
#else
#error "Unknown host architecture"
#endif
#endif
    }

    std::vector<CPUArchitecture> System::get_supported_host_architectures()
    {
        std::vector<CPUArchitecture> supported_architectures;
        supported_architectures.push_back(get_host_processor());

        // AMD64 machines support running x86 applications and ARM64 machines support running ARM applications
        if (supported_architectures.back() == CPUArchitecture::X64)
        {
            supported_architectures.push_back(CPUArchitecture::X86);
        }
        else if (supported_architectures.back() == CPUArchitecture::ARM64)
        {
            supported_architectures.push_back(CPUArchitecture::ARM);
        }

#if defined(_WIN32)
        // On ARM32/64 Windows we can rely on x86 emulation
        if (supported_architectures.front() == CPUArchitecture::ARM ||
            supported_architectures.front() == CPUArchitecture::ARM64)
        {
            supported_architectures.push_back(CPUArchitecture::X86);
        }
#endif

        return supported_architectures;
    }

    System::CMakeVariable::CMakeVariable(const StringView varname, const char* varvalue)
        : s(Strings::format(R"("-D%s=%s")", varname, varvalue))
    {
    }
    System::CMakeVariable::CMakeVariable(const StringView varname, const std::string& varvalue)
        : CMakeVariable(varname, varvalue.c_str())
    {
    }
    System::CMakeVariable::CMakeVariable(const StringView varname, const fs::path& path)
        : CMakeVariable(varname, path.generic_u8string())
    {
    }

    std::string System::make_cmake_cmd(const fs::path& cmake_exe,
                                       const fs::path& cmake_script,
                                       const std::vector<CMakeVariable>& pass_variables)
    {
        const std::string cmd_cmake_pass_variables = Strings::join(" ", pass_variables, [](auto&& v) { return v.s; });
        return Strings::format(
            R"("%s" %s -P "%s")", cmake_exe.u8string(), cmd_cmake_pass_variables, cmake_script.generic_u8string());
    }

#if defined(_WIN32)
    static std::wstring compute_clean_environment(const std::unordered_map<std::string, std::string>& extra_env,
                                                  const std::string& prepend_to_path)
    {
        static const std::string SYSTEM_ROOT = get_environment_variable("SystemRoot").value_or_exit(VCPKG_LINE_INFO);
        static const std::string SYSTEM_32 = SYSTEM_ROOT + R"(\system32)";
        std::string new_path = Strings::format(R"(Path=%s%s;%s;%s\Wbem;%s\WindowsPowerShell\v1.0\)",
                                               prepend_to_path,
                                               SYSTEM_32,
                                               SYSTEM_ROOT,
                                               SYSTEM_32,
                                               SYSTEM_32);

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
            // Enables find_package(CUDA) and enable_language(CUDA) in CMake
            L"CUDA_PATH",
            L"CUDA_PATH_V9_0",
            L"CUDA_PATH_V9_1",
            L"CUDA_PATH_V10_0",
            L"CUDA_PATH_V10_1",
            L"CUDA_TOOLKIT_ROOT_DIR",
            // Environmental variable generated automatically by CUDA after installation
            L"NVCUDASAMPLES_ROOT",
            // Enables find_package(Vulkan) in CMake. Environmental variable generated by Vulkan SDK installer
            L"VULKAN_SDK",
            // Enable targeted Android NDK
            L"ANDROID_NDK_HOME",
        };

        const Optional<std::string> keep_vars = System::get_environment_variable("VCPKG_KEEP_ENV_VARS");
        const auto k = keep_vars.get();

        if (k && !k->empty())
        {
            auto vars = Strings::split(*k, ";");

            for (auto&& var : vars)
            {
                env_wstrings.push_back(Strings::to_utf16(var));
            }
        }

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

        return env_cstr;
    }
#endif

#if defined(_WIN32)
    /// <param name="maybe_environment">If non-null, an environment block to use for the new process. If null, the new
    /// process will inherit the current environment.</param>
    static void windows_create_process(const StringView cmd_line,
                                       const wchar_t* environment_block,
                                       PROCESS_INFORMATION& process_info,
                                       DWORD dwCreationFlags) noexcept
    {
        STARTUPINFOW startup_info;
        memset(&startup_info, 0, sizeof(STARTUPINFOW));
        startup_info.cb = sizeof(STARTUPINFOW);

        // Flush stdout before launching external process
        fflush(nullptr);

        // Wrapping the command in a single set of quotes causes cmd.exe to correctly execute
        const std::string actual_cmd_line = Strings::format(R"###(cmd.exe /c "%s")###", cmd_line);
        Debug::print("CreateProcessW(", actual_cmd_line, ")\n");
        bool succeeded = TRUE == CreateProcessW(nullptr,
                                                Strings::to_utf16(actual_cmd_line).data(),
                                                nullptr,
                                                nullptr,
                                                FALSE,
                                                IDLE_PRIORITY_CLASS | CREATE_UNICODE_ENVIRONMENT | dwCreationFlags,
                                                (void*)environment_block,
                                                nullptr,
                                                &startup_info,
                                                &process_info);

        Checks::check_exit(VCPKG_LINE_INFO, succeeded, "Process creation failed with error code: %lu", GetLastError());
    }
#endif

#if defined(_WIN32)
    void System::cmd_execute_no_wait(StringView cmd_line)
    {
        auto timer = Chrono::ElapsedTimer::create_started();

        PROCESS_INFORMATION process_info;
        memset(&process_info, 0, sizeof(PROCESS_INFORMATION));

        windows_create_process(cmd_line, nullptr, process_info, DETACHED_PROCESS);

        CloseHandle(process_info.hThread);
        CloseHandle(process_info.hProcess);

        Debug::print("CreateProcessW() took ", static_cast<int>(timer.microseconds()), " us\n");
    }
#endif

    int System::cmd_execute_clean(const ZStringView cmd_line,
                                  const std::unordered_map<std::string, std::string>& extra_env,
                                  const std::string& prepend_to_path)
    {
        auto timer = Chrono::ElapsedTimer::create_started();
#if defined(_WIN32)

        PROCESS_INFORMATION process_info;
        memset(&process_info, 0, sizeof(PROCESS_INFORMATION));

        g_ctrl_c_state.transition_to_spawn_process();
        auto clean_env = compute_clean_environment(extra_env, prepend_to_path);
        windows_create_process(cmd_line, clean_env.data(), process_info, NULL);

        CloseHandle(process_info.hThread);

        const DWORD result = WaitForSingleObject(process_info.hProcess, INFINITE);
        g_ctrl_c_state.transition_from_spawn_process();
        Checks::check_exit(VCPKG_LINE_INFO, result != WAIT_FAILED, "WaitForSingleObject failed");

        DWORD exit_code = 0;
        GetExitCodeProcess(process_info.hProcess, &exit_code);

        CloseHandle(process_info.hProcess);

        Debug::print(
            "CreateProcessW() returned ", exit_code, " after ", static_cast<int>(timer.microseconds()), " us\n");
        return static_cast<int>(exit_code);
#else
        // TODO: this should create a clean environment on Linux/macOS
        Util::unused(extra_env, prepend_to_path);
        Debug::print("system(", cmd_line, ")\n");
        fflush(nullptr);
        int rc = system(cmd_line.c_str());
        Debug::print("system() returned ", rc, " after ", static_cast<int>(timer.microseconds()), " us\n");
        return rc;
#endif
    }

    int System::cmd_execute(const ZStringView cmd_line)
    {
        // Flush stdout before launching external process
        fflush(nullptr);

        auto timer = Chrono::ElapsedTimer::create_started();
#if defined(_WIN32)
        // We are wrap the command line in quotes to cause cmd.exe to correctly process it
        auto actual_cmd_line = Strings::concat('"', cmd_line, '"');
        Debug::print("_wsystem(", actual_cmd_line, ")\n");
        g_ctrl_c_state.transition_to_spawn_process();
        const int exit_code = _wsystem(Strings::to_utf16(actual_cmd_line).c_str());
        g_ctrl_c_state.transition_from_spawn_process();
        Debug::print("_wsystem() returned ",
                     exit_code,
                     " after ",
                     Strings::format("%8d", static_cast<int>(timer.microseconds())),
                     " us\n");
#else
        Debug::print("_system(", cmd_line, ")\n");
        const int exit_code = system(cmd_line.c_str());
        Debug::print("_system() returned ",
                     exit_code,
                     " after ",
                     Strings::format("%8d", static_cast<int>(timer.microseconds())),
                     " us\n");
#endif
        return exit_code;
    }

    ExitCodeAndOutput System::cmd_execute_and_capture_output(const ZStringView cmd_line)
    {
        auto timer = Chrono::ElapsedTimer::create_started();

#if defined(_WIN32)
        const auto actual_cmd_line = Strings::format(R"###("%s 2>&1")###", cmd_line);

        Debug::print("_wpopen(", actual_cmd_line, ")\n");
        std::wstring output;
        wchar_t buf[1024];
        g_ctrl_c_state.transition_to_spawn_process();
        // Flush stdout before launching external process
        fflush(stdout);
        const auto pipe = _wpopen(Strings::to_utf16(actual_cmd_line).c_str(), L"r");
        if (pipe == nullptr)
        {
            g_ctrl_c_state.transition_from_spawn_process();
            return {1, Strings::to_utf8(output.c_str())};
        }
        while (fgetws(buf, 1024, pipe))
        {
            output.append(buf);
        }
        if (!feof(pipe))
        {
            g_ctrl_c_state.transition_from_spawn_process();
            return {1, Strings::to_utf8(output.c_str())};
        }

        const auto ec = _pclose(pipe);
        g_ctrl_c_state.transition_from_spawn_process();

        // On Win7, output from powershell calls contain a utf-8 byte order mark in the utf-16 stream, so we strip it
        // out if it is present. 0xEF,0xBB,0xBF is the UTF-8 byte-order mark
        const wchar_t* a = output.c_str();
        while (output.size() >= 3 && a[0] == 0xEF && a[1] == 0xBB && a[2] == 0xBF)
        {
            output.erase(0, 3);
        }

        Debug::print("_pclose() returned ",
                     ec,
                     " after ",
                     Strings::format("%8d", static_cast<int>(timer.microseconds())),
                     " us\n");
        return {ec, Strings::to_utf8(output.c_str())};
#else
        const auto actual_cmd_line = Strings::format(R"###(%s 2>&1)###", cmd_line);

        Debug::print("popen(", actual_cmd_line, ")\n");
        std::string output;
        char buf[1024];
        // Flush stdout before launching external process
        fflush(stdout);
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

        Debug::print("_pclose() returned ", ec, " after ", Strings::format("%8d", (int)timer.microseconds()), " us\n");

        return {ec, output};
#endif
    }

    Optional<std::string> System::get_environment_variable(ZStringView varname) noexcept
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

    Optional<std::string> System::get_registry_string(void* base_hkey, StringView sub_key, StringView valuename)
    {
        HKEY k = nullptr;
        const LSTATUS ec =
            RegOpenKeyExW(reinterpret_cast<HKEY>(base_hkey), Strings::to_utf16(sub_key).c_str(), NULL, KEY_READ, &k);
        if (ec != ERROR_SUCCESS) return nullopt;

        auto w_valuename = Strings::to_utf16(valuename);

        DWORD dw_buffer_size = 0;
        DWORD dw_type = 0;
        auto rc = RegQueryValueExW(k, w_valuename.c_str(), nullptr, &dw_type, nullptr, &dw_buffer_size);
        if (rc != ERROR_SUCCESS || !is_string_keytype(dw_type) || dw_buffer_size == 0 ||
            dw_buffer_size % sizeof(wchar_t) != 0)
            return nullopt;
        std::wstring ret;
        ret.resize(dw_buffer_size / sizeof(wchar_t));

        rc = RegQueryValueExW(
            k, w_valuename.c_str(), nullptr, &dw_type, reinterpret_cast<LPBYTE>(ret.data()), &dw_buffer_size);
        if (rc != ERROR_SUCCESS || !is_string_keytype(dw_type) || dw_buffer_size != sizeof(wchar_t) * ret.size())
            return nullopt;

        ret.pop_back(); // remove extra trailing null byte
        return Strings::to_utf8(ret);
    }
#else
    Optional<std::string> System::get_registry_string(void*, StringView, StringView) { return nullopt; }
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

    const Optional<fs::path>& System::get_program_files_32_bit()
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

    const Optional<fs::path>& System::get_program_files_platform_bitness()
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

#if defined(_WIN32)
    static BOOL ctrl_handler(DWORD fdw_ctrl_type)
    {
        switch (fdw_ctrl_type)
        {
            case CTRL_C_EVENT: g_ctrl_c_state.transition_handle_ctrl_c(); return TRUE;
            default: return FALSE;
        }
    }

    void System::register_console_ctrl_handler()
    {
        SetConsoleCtrlHandler(reinterpret_cast<PHANDLER_ROUTINE>(ctrl_handler), TRUE);
    }
#else
    void System::register_console_ctrl_handler() {}
#endif

    int System::get_num_logical_cores() { return std::thread::hardware_concurrency(); }
}

namespace vcpkg::Debug
{
    std::atomic<bool> g_debugging(false);
}
