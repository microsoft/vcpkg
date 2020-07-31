#include <vcpkg/base/system_headers.h>

#include <catch2/catch.hpp>

#include <vcpkg/base/optional.h>
#include <vcpkg/base/strings.h>
#include <vcpkg/base/stringview.h>
#include <vcpkg/base/system.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/base/zstringview.h>

#include <string>

using vcpkg::nullopt;
using vcpkg::Optional;
using vcpkg::StringView;
using vcpkg::ZStringView;
using vcpkg::Checks::check_exit;
using vcpkg::System::CPUArchitecture;
using vcpkg::System::get_environment_variable;
using vcpkg::System::guess_visual_studio_prompt_target_architecture;
using vcpkg::System::to_cpu_architecture;

namespace
{
    void set_environment_variable(ZStringView varname, Optional<std::string> value)
    {
#if defined(_WIN32)
        const auto w_varname = vcpkg::Strings::to_utf16(varname);
        const auto w_varcstr = w_varname.c_str();
        BOOL exit_code;
        if (value)
        {
            const auto w_value = vcpkg::Strings::to_utf16(value.value_or_exit(VCPKG_LINE_INFO));
            exit_code = SetEnvironmentVariableW(w_varcstr, w_value.c_str());
        }
        else
        {
            exit_code = SetEnvironmentVariableW(w_varcstr, nullptr);
        }

        check_exit(VCPKG_LINE_INFO, exit_code != 0);
#else  // ^^^ defined(_WIN32) / !defined(_WIN32) vvv
        if (auto v = value.get())
        {
            check_exit(VCPKG_LINE_INFO, setenv(varname.c_str(), v->c_str(), 1) == 0);
        }
        else
        {
            check_exit(VCPKG_LINE_INFO, unsetenv(varname.c_str()) == 0);
        }
#endif // defined(_WIN32)
    }

    struct environment_variable_resetter
    {
        explicit environment_variable_resetter(ZStringView varname_)
            : varname(varname_), old_value(get_environment_variable(varname))
        {
        }

        ~environment_variable_resetter() { set_environment_variable(varname, old_value); }

        environment_variable_resetter(const environment_variable_resetter&) = delete;
        environment_variable_resetter& operator=(const environment_variable_resetter&) = delete;

    private:
        ZStringView varname;
        Optional<std::string> old_value;
    };
}

TEST_CASE ("[to_cpu_architecture]", "system")
{
    struct test_case
    {
        Optional<CPUArchitecture> expected;
        StringView input;
    };

    const test_case test_cases[] = {
        {CPUArchitecture::X86, "x86"},
        {CPUArchitecture::X86, "X86"},
        {CPUArchitecture::X64, "x64"},
        {CPUArchitecture::X64, "X64"},
        {CPUArchitecture::X64, "AmD64"},
        {CPUArchitecture::ARM, "ARM"},
        {CPUArchitecture::ARM64, "ARM64"},
        {nullopt, "ARM6"},
        {nullopt, "AR"},
        {nullopt, "Intel"},
    };

    for (auto&& instance : test_cases)
    {
        CHECK(to_cpu_architecture(instance.input) == instance.expected);
    }
}

TEST_CASE ("from_cpu_architecture", "[system]")
{
    struct test_case
    {
        CPUArchitecture input;
        ZStringView expected;
    };

    const test_case test_cases[] = {
        {CPUArchitecture::X86, "x86"},
        {CPUArchitecture::X64, "x64"},
        {CPUArchitecture::ARM, "arm"},
        {CPUArchitecture::ARM64, "arm64"},
    };

    for (auto&& instance : test_cases)
    {
        CHECK(to_zstring_view(instance.input) == instance.expected);
    }
}

TEST_CASE ("guess_visual_studio_prompt", "[system]")
{
    environment_variable_resetter reset_VSCMD_ARG_TGT_ARCH{"VSCMD_ARG_TGT_ARCH"};
    environment_variable_resetter reset_VCINSTALLDIR{"VCINSTALLDIR"};
    environment_variable_resetter reset_Platform{"Platform"};

    set_environment_variable("Platform", "x86"); // ignored if VCINSTALLDIR unset
    set_environment_variable("VCINSTALLDIR", nullopt);
    set_environment_variable("VSCMD_ARG_TGT_ARCH", nullopt);
    CHECK(!guess_visual_studio_prompt_target_architecture().has_value());
    set_environment_variable("VSCMD_ARG_TGT_ARCH", "x86");
    CHECK(guess_visual_studio_prompt_target_architecture().value_or_exit(VCPKG_LINE_INFO) == CPUArchitecture::X86);
    set_environment_variable("VSCMD_ARG_TGT_ARCH", "x64");
    CHECK(guess_visual_studio_prompt_target_architecture().value_or_exit(VCPKG_LINE_INFO) == CPUArchitecture::X64);
    set_environment_variable("VSCMD_ARG_TGT_ARCH", "arm");
    CHECK(guess_visual_studio_prompt_target_architecture().value_or_exit(VCPKG_LINE_INFO) == CPUArchitecture::ARM);
    set_environment_variable("VSCMD_ARG_TGT_ARCH", "arm64");
    CHECK(guess_visual_studio_prompt_target_architecture().value_or_exit(VCPKG_LINE_INFO) == CPUArchitecture::ARM64);

    // check that apparent "nested" prompts defer to "vsdevcmd"
    set_environment_variable("VCINSTALLDIR", "anything");
    CHECK(guess_visual_studio_prompt_target_architecture().value_or_exit(VCPKG_LINE_INFO) == CPUArchitecture::ARM64);
    set_environment_variable("VSCMD_ARG_TGT_ARCH", nullopt);
    set_environment_variable("Platform", nullopt);
    CHECK(guess_visual_studio_prompt_target_architecture().value_or_exit(VCPKG_LINE_INFO) == CPUArchitecture::X86);
    set_environment_variable("Platform", "x86");
    CHECK(guess_visual_studio_prompt_target_architecture().value_or_exit(VCPKG_LINE_INFO) == CPUArchitecture::X86);
    set_environment_variable("Platform", "x64");
    CHECK(guess_visual_studio_prompt_target_architecture().value_or_exit(VCPKG_LINE_INFO) == CPUArchitecture::X64);
}

TEST_CASE ("cmdlinebuilder", "[system]")
{
    using vcpkg::System::CmdLineBuilder;

    CmdLineBuilder cmd;
    cmd.path_arg(fs::u8path("relative/path.exe"));
    cmd.string_arg("abc");
    cmd.string_arg("hello world!");
    cmd.string_arg("|");
    cmd.string_arg(";");
    REQUIRE(cmd.extract() == "relative/path.exe abc \"hello world!\" \"|\" \";\"");

    cmd.path_arg(fs::u8path("trailing\\slash\\"));
    cmd.string_arg("inner\"quotes");
#ifdef _WIN32
    REQUIRE(cmd.extract() == "\"trailing\\slash\\\\\" \"inner\\\"quotes\"");
#else
    REQUIRE(cmd.extract() == "\"trailing\\\\slash\\\\\" \"inner\\\"quotes\"");
#endif
}
