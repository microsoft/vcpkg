#include <vcpkg/base/strings.h>
#include <vcpkg/base/system.process.h>

#include <vcpkg/build.h>
#include <vcpkg/cmakevars.h>
#include <vcpkg/commands.env.h>
#include <vcpkg/help.h>
#include <vcpkg/portfileprovider.h>
#include <vcpkg/vcpkgcmdarguments.h>

namespace vcpkg::Commands::Env
{
    static constexpr StringLiteral OPTION_BIN = "bin";
    static constexpr StringLiteral OPTION_INCLUDE = "include";
    static constexpr StringLiteral OPTION_DEBUG_BIN = "debug-bin";
    static constexpr StringLiteral OPTION_TOOLS = "tools";
    static constexpr StringLiteral OPTION_PYTHON = "python";

    static constexpr std::array<CommandSwitch, 5> SWITCHES = {{
        {OPTION_BIN, "Add installed bin/ to PATH"},
        {OPTION_INCLUDE, "Add installed include/ to INCLUDE"},
        {OPTION_DEBUG_BIN, "Add installed debug/bin/ to PATH"},
        {OPTION_TOOLS, "Add installed tools/*/ to PATH"},
        {OPTION_PYTHON, "Add installed python/ to PYTHONPATH"},
    }};

    const CommandStructure COMMAND_STRUCTURE = {
        create_example_string("env <optional command> --triplet x64-windows"),
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

        PortFileProvider::PathsPortFileProvider provider(paths, args.overlay_ports);
        auto var_provider_storage = CMakeVars::make_triplet_cmake_var_provider(paths);
        auto& var_provider = *var_provider_storage;

        var_provider.load_generic_triplet_vars(triplet);

        const Build::PreBuildInfo pre_build_info(
            paths, triplet, var_provider.get_generic_triplet_vars(triplet).value_or_exit(VCPKG_LINE_INFO));
        const Toolset& toolset = paths.get_toolset(pre_build_info);
        auto build_env_cmd = Build::make_build_env_cmd(pre_build_info, toolset, paths.get_all_toolsets());

        std::unordered_map<std::string, std::string> extra_env = {};
        const bool add_bin = Util::Sets::contains(options.switches, OPTION_BIN);
        const bool add_include = Util::Sets::contains(options.switches, OPTION_INCLUDE);
        const bool add_debug_bin = Util::Sets::contains(options.switches, OPTION_DEBUG_BIN);
        const bool add_tools = Util::Sets::contains(options.switches, OPTION_TOOLS);
        const bool add_python = Util::Sets::contains(options.switches, OPTION_PYTHON);

        std::vector<std::string> path_vars;
        if (add_bin) path_vars.push_back(fs::u8string(paths.installed / triplet.to_string() / "bin"));
        if (add_debug_bin) path_vars.push_back(fs::u8string(paths.installed / triplet.to_string() / "debug" / "bin"));
        if (add_include) extra_env.emplace("INCLUDE", fs::u8string(paths.installed / triplet.to_string() / "include"));
        if (add_tools)
        {
            auto tools_dir = paths.installed / triplet.to_string() / "tools";
            auto tool_files = fs.get_files_non_recursive(tools_dir);
            path_vars.push_back(fs::u8string(tools_dir));
            for (auto&& tool_dir : tool_files)
            {
                if (fs.is_directory(tool_dir)) path_vars.push_back(fs::u8string(tool_dir));
            }
        }
        if (add_python)
            extra_env.emplace("PYTHONPATH",
                              fs::u8string(paths.installed / fs::u8path(triplet.to_string()) / fs::u8path("python")));
        if (path_vars.size() > 0) extra_env.emplace("PATH", Strings::join(";", path_vars));
        for (auto&& passthrough : pre_build_info.passthrough_env_vars)
        {
            if (auto e = System::get_environment_variable(passthrough))
            {
                extra_env.emplace(passthrough, e.value_or_exit(VCPKG_LINE_INFO));
            }
        }

        auto env = [&] {
            auto clean_env = System::get_modified_clean_environment(extra_env);
            if (build_env_cmd.empty())
                return clean_env;
            else
            {
#ifdef _WIN32
                return System::cmd_execute_modify_env(build_env_cmd, clean_env);
#else
                Checks::exit_with_message(VCPKG_LINE_INFO,
                                          "Build environment commands are not supported on this platform");
#endif
            }
        }();

        System::Command cmd("cmd");
        if (!args.command_arguments.empty())
        {
            cmd.string_arg("/c").raw_arg(args.command_arguments.at(0));
        }
#ifdef _WIN32
        System::enter_interactive_subprocess();
#endif
        auto rc = System::cmd_execute(cmd, env);
#ifdef _WIN32
        System::exit_interactive_subprocess();
#endif
        Checks::exit_with_code(VCPKG_LINE_INFO, rc);
    }

    void EnvCommand::perform_and_exit(const VcpkgCmdArguments& args,
                                      const VcpkgPaths& paths,
                                      Triplet default_triplet) const
    {
        Env::perform_and_exit(args, paths, default_triplet);
    }
}
