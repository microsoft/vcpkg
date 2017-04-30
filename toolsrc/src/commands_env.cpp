#include "pch.h"

#include "vcpkg_Build.h"
#include "vcpkg_Commands.h"
#include "vcpkg_System.h"

namespace vcpkg::Commands::Env
{
    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet)
    {
        static const std::string example = Commands::Help::create_example_string(R"(env --Triplet x64-windows)");
        args.check_exact_arg_count(0, example);
        args.check_and_get_optional_command_arguments({});

        System::cmd_execute_clean(Build::make_build_env_cmd(default_triplet, paths.get_toolset()) + L" && cmd");

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
