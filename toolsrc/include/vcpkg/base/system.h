#pragma once

#include <unordered_map>

#include <vcpkg/base/files.h>
#include <vcpkg/base/optional.h>
#include <vcpkg/base/strings.h>

namespace vcpkg::System
{
    fs::path get_exe_path_of_current_process();

    struct CMakeVariable
    {
        CMakeVariable(const CStringView varname, const char* varvalue);
        CMakeVariable(const CStringView varname, const std::string& varvalue);
        CMakeVariable(const CStringView varname, const fs::path& path);

        std::string s;
    };

    std::string make_cmake_cmd(const fs::path& cmake_exe,
                               const fs::path& cmake_script,
                               const std::vector<CMakeVariable>& pass_variables);

    struct ExitCodeAndOutput
    {
        int exit_code;
        std::string output;
    };

    int cmd_execute_clean(const CStringView cmd_line,
                          const std::unordered_map<std::string, std::string>& extra_env = {}) noexcept;

    int cmd_execute(const CStringView cmd_line) noexcept;

#if defined(_WIN32)
    void cmd_execute_no_wait(const CStringView cmd_line) noexcept;
#endif

    ExitCodeAndOutput cmd_execute_and_capture_output(const CStringView cmd_line) noexcept;

    enum class Color
    {
        success = 10,
        error = 12,
        warning = 14,
    };

    void println();
    void print(const CStringView message);
    void println(const CStringView message);
    void print(const Color c, const CStringView message);
    void println(const Color c, const CStringView message);

    template<class Arg1, class... Args>
    void print(const char* message_template, const Arg1& message_arg1, const Args&... message_args)
    {
        return System::print(Strings::format(message_template, message_arg1, message_args...));
    }

    template<class Arg1, class... Args>
    void print(const Color c, const char* message_template, const Arg1& message_arg1, const Args&... message_args)
    {
        return System::print(c, Strings::format(message_template, message_arg1, message_args...));
    }

    template<class Arg1, class... Args>
    void println(const char* message_template, const Arg1& message_arg1, const Args&... message_args)
    {
        return System::println(Strings::format(message_template, message_arg1, message_args...));
    }

    template<class Arg1, class... Args>
    void println(const Color c, const char* message_template, const Arg1& message_arg1, const Args&... message_args)
    {
        return System::println(c, Strings::format(message_template, message_arg1, message_args...));
    }

    Optional<std::string> get_environment_variable(const CStringView varname) noexcept;

    Optional<std::string> get_registry_string(void* base_hkey, const CStringView subkey, const CStringView valuename);

    enum class CPUArchitecture
    {
        X86,
        X64,
        ARM,
        ARM64,
    };

    Optional<CPUArchitecture> to_cpu_architecture(const CStringView& arch);

    CPUArchitecture get_host_processor();

    std::vector<CPUArchitecture> get_supported_host_architectures();

    const Optional<fs::path>& get_program_files_32_bit();

    const Optional<fs::path>& get_program_files_platform_bitness();
}

namespace vcpkg::Debug
{
    void println(const CStringView message);
    void println(const System::Color c, const CStringView message);

    template<class Arg1, class... Args>
    void println(const char* message_template, const Arg1& message_arg1, const Args&... message_args)
    {
        return Debug::println(Strings::format(message_template, message_arg1, message_args...));
    }

    template<class Arg1, class... Args>
    void println(const System::Color c,
                 const char* message_template,
                 const Arg1& message_arg1,
                 const Args&... message_args)
    {
        return Debug::println(c, Strings::format(message_template, message_arg1, message_args...));
    }
}
