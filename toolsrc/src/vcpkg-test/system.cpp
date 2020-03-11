#include <catch2/catch.hpp>

#include <Windows.h>
#include <string>
#include <vcpkg/base/optional.h>
#include <vcpkg/base/stringview.h>
#include <vcpkg/base/zstringview.h>
#include <vcpkg/base/strings.h>
#include <vcpkg/base/system.h>

using vcpkg::Optional;
using vcpkg::StringView;
using vcpkg::ZStringView;
using vcpkg::Checks::check_exit;
using vcpkg::System::get_environment_variable;
using vcpkg::System::to_cpu_architecture;
using vcpkg::System::guess_visual_studio_prompt_target_architecture;
using vcpkg::nullopt;
using vcpkg::System::CPUArchitecture;

namespace
{
    void set_environment_variable(StringView varname, Optional<std::string> value)
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
        std::string tmp;
        tmp.reserve(varname.size() + value.size() + 1);
        tmp.append(varname.data(), varname.size());
        tmp.push_back('=');
        if (value)
        {
            const auto& unpacked = value.value_or_exit(VCPKG_LINE_INFO);
            tmp.append(unpacked);
        }

        const int exit_code = putenv(tmp.c_str());
        check_exit(VCPKG_LINE_INFO, exit_code == 0);
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

TEST_CASE ("[from_cpu_architecture]", "system")
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

TEST_CASE ("[guess_visual_studio_prompt]", "system")
{
    environment_variable_resetter reset_VSCMD_ARG_TGT_ARCH{"VSCMD_ARG_TGT_ARCH"};
    set_environment_variable("VSCMD_ARG_TGT_ARCH", nullopt);
    CHECK(!guess_visual_studio_prompt_target_architecture().has_value());
    set_environment_variable("VSCMD_ARG_TGT_ARCH", "x86");
    CHECK(guess_visual_studio_prompt_target_architecture()
        .value_or_exit(VCPKG_LINE_INFO) == CPUArchitecture::X86);
    set_environment_variable("VSCMD_ARG_TGT_ARCH", "x64");
    CHECK(guess_visual_studio_prompt_target_architecture()
        .value_or_exit(VCPKG_LINE_INFO) == CPUArchitecture::X64);
    set_environment_variable("VSCMD_ARG_TGT_ARCH", "arm");
    CHECK(guess_visual_studio_prompt_target_architecture()
        .value_or_exit(VCPKG_LINE_INFO) == CPUArchitecture::ARM);
    set_environment_variable("VSCMD_ARG_TGT_ARCH", "arm64");
    CHECK(guess_visual_studio_prompt_target_architecture().value_or_exit(VCPKG_LINE_INFO)
        == CPUArchitecture::ARM64);
}
