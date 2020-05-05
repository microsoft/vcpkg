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
            CtrlCStateMachine() : m_number_of_external_processes(0), m_global_job(NULL), m_in_interactive(0) {}

            void transition_to_spawn_process() noexcept
            {
                int cur = 0;
                while (!m_number_of_external_processes.compare_exchange_strong(cur, cur + 1))
                {
                    if (cur < 0)
                    {
                        // Ctrl-C was hit and is asynchronously executing on another thread.
                        // Some other processes are outstanding.
                        // Sleep forever -- the other process will complete and exit the program
                        while (true)
                        {
                            std::this_thread::sleep_for(std::chrono::seconds(10));
                            System::print2("Waiting for child processes to exit...\n");
                        }
                    }
                }
            }
            void transition_from_spawn_process() noexcept
            {
                auto previous = m_number_of_external_processes.fetch_add(-1);
                if (previous == INT_MIN + 1)
                {
                    // Ctrl-C was hit while blocked on the child process
                    // This is the last external process to complete
                    // Therefore, exit
                    Checks::final_cleanup_and_exit(1);
                }
                else if (previous < 0)
                {
                    // Ctrl-C was hit while blocked on the child process
                    // Some other processes are outstanding.
                    // Sleep forever -- the other process will complete and exit the program
                    while (true)
                    {
                        std::this_thread::sleep_for(std::chrono::seconds(10));
                        System::print2("Waiting for child processes to exit...\n");
                    }
                }
            }
            void transition_handle_ctrl_c() noexcept
            {
                int old_value = 0;
                while (!m_number_of_external_processes.compare_exchange_strong(old_value, old_value + INT_MIN))
                {
                    if (old_value < 0)
                    {
                        // Repeat calls to Ctrl-C -- a previous one succeeded.
                        return;
                    }
                }

                if (old_value == 0)
                {
                    // Not currently blocked on a child process
                    Checks::final_cleanup_and_exit(1);
                }
                else
                {
                    // We are currently blocked on a child process.
                    // If none of the child processes are interactive, use the Job Object to terminate the tree.
                    if (m_in_interactive.load() == 0)
                    {
                        auto job = m_global_job.exchange(NULL);
                        if (job != NULL)
                        {
                            ::CloseHandle(job);
                        }
                    }
                }
            }

            void initialize_job()
            {
                m_global_job = CreateJobObjectW(NULL, NULL);
                if (m_global_job != NULL)
                {
                    JOBOBJECT_EXTENDED_LIMIT_INFORMATION info = {};
                    info.BasicLimitInformation.LimitFlags =
                        JOB_OBJECT_LIMIT_BREAKAWAY_OK | JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE;
                    ::SetInformationJobObject(m_global_job, JobObjectExtendedLimitInformation, &info, sizeof(info));
                    ::AssignProcessToJobObject(m_global_job, ::GetCurrentProcess());
                }
            }

            void enter_interactive() { ++m_in_interactive; }
            void exit_interactive() { --m_in_interactive; }

        private:
            std::atomic<int> m_number_of_external_processes;
            std::atomic<HANDLE> m_global_job;
            std::atomic<int> m_in_interactive;
        };

        static CtrlCStateMachine g_ctrl_c_state;
    }

    void System::initialize_global_job_object() { g_ctrl_c_state.initialize_job(); }
    void System::enter_interactive_subprocess() { g_ctrl_c_state.enter_interactive(); }
    void System::exit_interactive_subprocess() { g_ctrl_c_state.exit_interactive(); }
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
    Environment System::get_modified_clean_environment(const std::unordered_map<std::string, std::string>& extra_env,
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
            // Environment variables to tell git to use custom SSH executable or command
            L"GIT_SSH",
            L"GIT_SSH_COMMAND",
            // Environment variables needed for ssh-agent based authentication
            L"SSH_AUTH_SOCK",
            L"SSH_AGENT_PID",
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

        return {env_cstr};
    }
#else
    Environment System::get_modified_clean_environment(const std::unordered_map<std::string, std::string>&,
                                                       const std::string&)
    {
        return {};
    }
#endif
    const Environment& System::get_clean_environment()
    {
        static const Environment clean_env = get_modified_clean_environment({});
        return clean_env;
    }

    int System::cmd_execute_clean(const ZStringView cmd_line) { return cmd_execute(cmd_line, get_clean_environment()); }

#if defined(_WIN32)
    struct ProcessInfo
    {
        constexpr ProcessInfo() : proc_info{} {}

        unsigned int wait_and_close_handles()
        {
            CloseHandle(proc_info.hThread);

            const DWORD result = WaitForSingleObject(proc_info.hProcess, INFINITE);
            Checks::check_exit(VCPKG_LINE_INFO, result != WAIT_FAILED, "WaitForSingleObject failed");

            DWORD exit_code = 0;
            GetExitCodeProcess(proc_info.hProcess, &exit_code);

            CloseHandle(proc_info.hProcess);

            return exit_code;
        }

        void close_handles()
        {
            CloseHandle(proc_info.hThread);
            CloseHandle(proc_info.hProcess);
        }

        PROCESS_INFORMATION proc_info;
    };

    /// <param name="maybe_environment">If non-null, an environment block to use for the new process. If null, the
    /// new process will inherit the current environment.</param>
    static ExpectedT<ProcessInfo, unsigned long> windows_create_process(const StringView cmd_line,
                                                                        const Environment& env,
                                                                        DWORD dwCreationFlags,
                                                                        STARTUPINFOW& startup_info) noexcept
    {
        ProcessInfo process_info;
        Debug::print("CreateProcessW(", cmd_line, ")\n");

        // Flush stdout before launching external process
        fflush(nullptr);
        bool succeeded = TRUE == CreateProcessW(nullptr,
                                                Strings::to_utf16(cmd_line).data(),
                                                nullptr,
                                                nullptr,
                                                TRUE,
                                                IDLE_PRIORITY_CLASS | CREATE_UNICODE_ENVIRONMENT | dwCreationFlags,
                                                (void*)(env.m_env_data.empty() ? nullptr : env.m_env_data.data()),
                                                nullptr,
                                                &startup_info,
                                                &process_info.proc_info);
        if (succeeded)
            return process_info;
        else
            return GetLastError();
    }

    static ExpectedT<ProcessInfo, unsigned long> windows_create_process(const StringView cmd_line,
                                                                        const Environment& env,
                                                                        DWORD dwCreationFlags) noexcept
    {
        STARTUPINFOW startup_info;
        memset(&startup_info, 0, sizeof(STARTUPINFOW));
        startup_info.cb = sizeof(STARTUPINFOW);

        return windows_create_process(cmd_line, env, dwCreationFlags, startup_info);
    }

    struct ProcessInfoAndPipes
    {
        ProcessInfo proc_info;
        HANDLE child_stdin = 0;
        HANDLE child_stdout = 0;

        template<class Function>
        int wait_and_stream_output(Function&& f)
        {
            CloseHandle(child_stdin);

            unsigned long bytes_read = 0;
            static constexpr int buffer_size = 1024 * 32;
            auto buf = std::make_unique<char[]>(buffer_size);
            while (ReadFile(child_stdout, (void*)buf.get(), buffer_size, &bytes_read, nullptr) && bytes_read > 0)
            {
                f(StringView{buf.get(), static_cast<size_t>(bytes_read)});
            }

            CloseHandle(child_stdout);

            return proc_info.wait_and_close_handles();
        }
    };

    static ExpectedT<ProcessInfoAndPipes, unsigned long> windows_create_process_redirect(const StringView cmd_line,
                                                                                         const Environment& env,
                                                                                         DWORD dwCreationFlags) noexcept
    {
        ProcessInfoAndPipes ret;

        STARTUPINFOW startup_info;
        memset(&startup_info, 0, sizeof(STARTUPINFOW));
        startup_info.cb = sizeof(STARTUPINFOW);
        startup_info.dwFlags |= STARTF_USESTDHANDLES;

        SECURITY_ATTRIBUTES saAttr;
        memset(&saAttr, 0, sizeof(SECURITY_ATTRIBUTES));
        saAttr.nLength = sizeof(SECURITY_ATTRIBUTES);
        saAttr.bInheritHandle = TRUE;
        saAttr.lpSecurityDescriptor = NULL;

        // Create a pipe for the child process's STDOUT.
        if (!CreatePipe(&ret.child_stdout, &startup_info.hStdOutput, &saAttr, 0)) Checks::exit_fail(VCPKG_LINE_INFO);
        // Ensure the read handle to the pipe for STDOUT is not inherited.
        if (!SetHandleInformation(ret.child_stdout, HANDLE_FLAG_INHERIT, 0)) Checks::exit_fail(VCPKG_LINE_INFO);
        // Create a pipe for the child process's STDIN.
        if (!CreatePipe(&startup_info.hStdInput, &ret.child_stdin, &saAttr, 0)) Checks::exit_fail(VCPKG_LINE_INFO);
        // Ensure the write handle to the pipe for STDIN is not inherited.
        if (!SetHandleInformation(ret.child_stdin, HANDLE_FLAG_INHERIT, 0)) Checks::exit_fail(VCPKG_LINE_INFO);
        startup_info.hStdError = startup_info.hStdOutput;

        auto maybe_proc_info = windows_create_process(cmd_line, env, dwCreationFlags, startup_info);

        CloseHandle(startup_info.hStdInput);
        CloseHandle(startup_info.hStdOutput);

        if (auto proc_info = maybe_proc_info.get())
        {
            ret.proc_info = std::move(*proc_info);
            return std::move(ret);
        }
        else
        {
            return maybe_proc_info.error();
        }
    }
#endif

#if defined(_WIN32)
    void System::cmd_execute_no_wait(StringView cmd_line)
    {
        auto timer = Chrono::ElapsedTimer::create_started();

        auto process_info = windows_create_process(cmd_line, {}, DETACHED_PROCESS | CREATE_BREAKAWAY_FROM_JOB);
        if (auto p = process_info.get())
        {
            p->close_handles();
        }
        else
        {
            Debug::print("cmd_execute_no_wait() failed with error code ", process_info.error(), "\n");
        }

        Debug::print("cmd_execute_no_wait() took ", static_cast<int>(timer.microseconds()), " us\n");
    }

    Environment System::cmd_execute_modify_env(const ZStringView cmd_line, const Environment& env)
    {
        static StringLiteral magic_string = "cdARN4xjKueKScMy9C6H";

        auto actual_cmd_line = Strings::concat(cmd_line, " & echo ", magic_string, "& set");

        auto rc_output = cmd_execute_and_capture_output(actual_cmd_line, env);
        Checks::check_exit(VCPKG_LINE_INFO, rc_output.exit_code == 0);
        auto it = Strings::search(rc_output.output, Strings::concat(magic_string, "\r\n"));
        const auto e = static_cast<const char*>(rc_output.output.data()) + rc_output.output.size();
        Checks::check_exit(VCPKG_LINE_INFO, it != e);
        it += magic_string.size() + 2;

        std::wstring out_env;

        for (;;)
        {
            auto eq = std::find(it, e, '=');
            if (eq == e) break;
            StringView varname(it, eq);
            auto nl = std::find(eq + 1, e, '\r');
            if (nl == e) break;
            StringView value(eq + 1, nl);

            out_env.append(Strings::to_utf16(Strings::concat(varname, '=', value)));
            out_env.push_back(L'\0');

            it = nl + 1;
            if (it != e && *it == '\n') ++it;
        }

        return {std::move(out_env)};
    }
#endif

    int System::cmd_execute(const ZStringView cmd_line, const Environment& env)
    {
        auto timer = Chrono::ElapsedTimer::create_started();
#if defined(_WIN32)
        using vcpkg::g_ctrl_c_state;
        g_ctrl_c_state.transition_to_spawn_process();
        auto proc_info = windows_create_process(cmd_line, env, NULL);
        auto long_exit_code = [&]() -> unsigned long {
            if (auto p = proc_info.get())
                return p->wait_and_close_handles();
            else
                return proc_info.error();
        }();
        if (long_exit_code > INT_MAX) long_exit_code = INT_MAX;
        int exit_code = static_cast<int>(long_exit_code);
        g_ctrl_c_state.transition_from_spawn_process();

        Debug::print(
            "cmd_execute() returned ", exit_code, " after ", static_cast<unsigned int>(timer.microseconds()), " us\n");
#else
        (void)env;
        Debug::print("system(", cmd_line, ")\n");
        fflush(nullptr);
        int exit_code = system(cmd_line.c_str());
        Debug::print(
            "system() returned ", exit_code, " after ", static_cast<unsigned int>(timer.microseconds()), " us\n");
#endif
        return exit_code;
    }

    int System::cmd_execute_and_stream_lines(const ZStringView cmd_line,
                                             std::function<void(const std::string&)> per_line_cb,
                                             const Environment& env)
    {
        std::string buf;

        auto rc = cmd_execute_and_stream_data(
            cmd_line,
            [&](StringView sv) {
                auto prev_size = buf.size();
                Strings::append(buf, sv);

                auto it = std::find(buf.begin() + prev_size, buf.end(), '\n');
                while (it != buf.end())
                {
                    std::string s(buf.begin(), it);
                    per_line_cb(s);
                    buf.erase(buf.begin(), it + 1);
                    it = std::find(buf.begin(), buf.end(), '\n');
                }
            },
            env);

        per_line_cb(buf);
        return rc;
    }

    int System::cmd_execute_and_stream_data(const ZStringView cmd_line,
                                            std::function<void(StringView)> data_cb,
                                            const Environment& env)
    {
        auto timer = Chrono::ElapsedTimer::create_started();

#if defined(_WIN32)
        using vcpkg::g_ctrl_c_state;

        g_ctrl_c_state.transition_to_spawn_process();
        auto maybe_proc_info = windows_create_process_redirect(cmd_line, env, NULL);
        auto exit_code = [&]() -> unsigned long {
            if (auto p = maybe_proc_info.get())
                return p->wait_and_stream_output(data_cb);
            else
                return maybe_proc_info.error();
        }();
        g_ctrl_c_state.transition_from_spawn_process();
#else
        (void)env;
        const auto actual_cmd_line = Strings::format(R"###(%s 2>&1)###", cmd_line);

        Debug::print("popen(", actual_cmd_line, ")\n");
        // Flush stdout before launching external process
        fflush(stdout);
        const auto pipe = popen(actual_cmd_line.c_str(), "r");
        if (pipe == nullptr)
        {
            return 1;
        }
        char buf[1024];
        while (fgets(buf, 1024, pipe))
        {
            data_cb(StringView{buf, strlen(buf)});
        }

        if (!feof(pipe))
        {
            return 1;
        }

        const auto exit_code = pclose(pipe);
#endif
        Debug::print("cmd_execute_and_stream_data() returned ",
                     exit_code,
                     " after ",
                     Strings::format("%8d", static_cast<int>(timer.microseconds())),
                     " us\n");

        return exit_code;
    }

    ExitCodeAndOutput System::cmd_execute_and_capture_output(const ZStringView cmd_line, const Environment& env)
    {
        std::string output;
        auto rc = cmd_execute_and_stream_data(
            cmd_line, [&](StringView sv) { Strings::append(output, sv); }, env);
        return {rc, std::move(output)};
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
}
