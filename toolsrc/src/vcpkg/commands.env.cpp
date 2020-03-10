#include "pch.h"

#include <vcpkg/base/strings.h>
#include <vcpkg/base/system.process.h>

#include <vcpkg/build.h>
#include <vcpkg/cmakevars.h>
#include <vcpkg/commands.h>
#include <vcpkg/help.h>

namespace vcpkg::Commands::Env
{
    static constexpr StringLiteral OPTION_BIN = "--bin";
    static constexpr StringLiteral OPTION_INCLUDE = "--include";
    static constexpr StringLiteral OPTION_DEBUG_BIN = "--debug-bin";
    static constexpr StringLiteral OPTION_TOOLS = "--tools";
    static constexpr StringLiteral OPTION_PYTHON = "--python";

    static constexpr std::array<CommandSwitch, 5> SWITCHES = {{
        {OPTION_BIN, "Add installed bin/ to PATH"},
        {OPTION_INCLUDE, "Add installed include/ to INCLUDE"},
        {OPTION_DEBUG_BIN, "Add installed debug/bin/ to PATH"},
        {OPTION_TOOLS, "Add installed tools/*/ to PATH"},
        {OPTION_PYTHON, "Add installed python/ to PYTHONPATH"},
    }};

    const CommandStructure COMMAND_STRUCTURE = {
        Help::create_example_string("env <optional command> --triplet x64-windows"),
        0,
        1,
        {SWITCHES, {}},
        nullptr,
    };

    // This command should probably optionally take a port
    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, Triplet triplet)
    {
        const auto& fs = paths.get_filesystem();

        const ParsedArguments options = args.parse_arguments(COMMAND_STRUCTURE);

        PortFileProvider::PathsPortFileProvider provider(paths, args.overlay_ports.get());
        auto var_provider_storage = CMakeVars::make_triplet_cmake_var_provider(paths);
        auto& var_provider = *var_provider_storage;

        var_provider.load_generic_triplet_vars(triplet);

        const Build::PreBuildInfo pre_build_info(
            paths, triplet, var_provider.get_generic_triplet_vars(triplet).value_or_exit(VCPKG_LINE_INFO));
        const Toolset& toolset = paths.get_toolset(pre_build_info);
        auto build_env_cmd = Build::make_build_env_cmd(pre_build_info, toolset);

        std::unordered_map<std::string, std::string> extra_env = {};
        const bool add_bin = Util::Sets::contains(options.switches, OPTION_BIN);
        const bool add_include = Util::Sets::contains(options.switches, OPTION_INCLUDE);
        const bool add_debug_bin = Util::Sets::contains(options.switches, OPTION_DEBUG_BIN);
        const bool add_tools = Util::Sets::contains(options.switches, OPTION_TOOLS);
        const bool add_python = Util::Sets::contains(options.switches, OPTION_PYTHON);

        std::vector<std::string> path_vars;
        if (add_bin) path_vars.push_back((paths.installed / triplet.to_string() / "bin").u8string());
        if (add_debug_bin) path_vars.push_back((paths.installed / triplet.to_string() / "debug" / "bin").u8string());
        if (add_include) extra_env.emplace("INCLUDE", (paths.installed / triplet.to_string() / "include").u8string());
        if (add_tools)
        {
            auto tools_dir = paths.installed / triplet.to_string() / "tools";
            auto tool_files = fs.get_files_non_recursive(tools_dir);
            path_vars.push_back(tools_dir.u8string());
            for (auto&& tool_dir : tool_files)
            {
                if (fs.is_directory(tool_dir)) path_vars.push_back(tool_dir.u8string());
            }
        }
        if (add_python) extra_env.emplace("PYTHONPATH", (paths.installed / triplet.to_string() / "python").u8string());
        if (path_vars.size() > 0) extra_env.emplace("PATH", Strings::join(";", path_vars));

        auto env = [&] {
            auto clean_env = System::get_modified_clean_environment(extra_env);
            if (build_env_cmd.empty())
                return clean_env;
            else
                return System::cmd_execute_modify_env(build_env_cmd, clean_env);
        }();

        std::string cmd = args.command_arguments.empty() ? "cmd" : args.command_arguments.at(0);
#ifdef _WIN32
        System::enter_interactive_subprocess();
#endif
        auto rc = System::cmd_execute(cmd, env);
#ifdef _WIN32
        System::exit_interactive_subprocess();
#endif
        Checks::exit_with_code(VCPKG_LINE_INFO, rc);
    }
}
