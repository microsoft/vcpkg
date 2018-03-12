#include "pch.h"

#include <vcpkg/base/system.h>
#include <vcpkg/base/strings.h>
#include <vcpkg/build.h>
#include <vcpkg/commands.h>
#include <vcpkg/help.h>

namespace vcpkg::Commands::Env
{
    static constexpr StringLiteral OPTION_BIN = "--bin";
    static constexpr StringLiteral OPTION_INCLUDE = "--include";
    static constexpr StringLiteral OPTION_DEBUG_BIN = "--debug-bin";
    static constexpr StringLiteral OPTION_TOOL = "--tool";
    static constexpr StringLiteral OPTION_PYTHON = "--python";

    static constexpr std::array<CommandSwitch, 5> SWITCHES = {{
        {OPTION_BIN, "Add <vcpkg-root>/install/<triplet>/bin to PATH"},
        {OPTION_INCLUDE, "Add <vcpkg-root>/install/<triplet>/include to INCLUDE"},
        {OPTION_DEBUG_BIN, "Add <vcpkg-root>/install/<triplet>/debug/bin to PATH"},
        {OPTION_TOOL, "Add <vcpkg-root>/install/<triplet>/tool to PATH"},
        {OPTION_PYTHON, "Add <vcpkg-root>/install/<triplet>/python to PYTHONPATH"},
    }};

    const CommandStructure COMMAND_STRUCTURE = {
        Help::create_example_string("env --triplet x64-windows"),
        0,
        SIZE_MAX,
        {SWITCHES, {}},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet)
    {
        const ParsedArguments options = args.parse_arguments(COMMAND_STRUCTURE);

        const auto pre_build_info = Build::PreBuildInfo::from_triplet_file(paths, default_triplet);
        const Toolset& toolset = paths.get_toolset(pre_build_info);
        auto env_cmd = Build::make_build_env_cmd(pre_build_info, toolset);

        std::unordered_map<std::string, std::string> extra_env = {};
        const bool add_bin = Util::Sets::contains(options.switches, (OPTION_BIN));
        const bool add_include = Util::Sets::contains(options.switches, (OPTION_INCLUDE));
        const bool add_debug_bin = Util::Sets::contains(options.switches, (OPTION_DEBUG_BIN));
        const bool add_tool = Util::Sets::contains(options.switches, (OPTION_TOOL));
        const bool add_python = Util::Sets::contains(options.switches, (OPTION_PYTHON));

        std::vector<std::string> path_vars;
        if (add_bin)
            path_vars.push_back((paths.installed / default_triplet.to_string() / "bin").u8string());
        if (add_debug_bin)
            path_vars.push_back((paths.installed / default_triplet.to_string() / "debug" / "bin").u8string());
        if (add_include)
            extra_env.emplace("INCLUDE", (paths.installed / default_triplet.to_string() / "include").u8string());
        if (add_tool)
            path_vars.push_back((paths.installed / default_triplet.to_string() / "include").u8string());
        if (add_python)
            extra_env.emplace("PYTHONPATH", (paths.installed / default_triplet.to_string() / "python").u8string());
        if (path_vars.size() > 0)
            extra_env.emplace("PATH", Strings::join(";", path_vars));

        if (env_cmd.empty())
            System::cmd_execute_clean("cmd", extra_env);
        else
            System::cmd_execute_clean(env_cmd + " && cmd", extra_env);

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
