#include "pch.h"

#include <vcpkg/base/system.h>
#include <vcpkg/build.h>
#include <vcpkg/commands.h>
#include <vcpkg/help.h>

namespace vcpkg::Commands::Env
{
    const CommandStructure COMMAND_STRUCTURE = {
        Help::create_example_string("env --triplet x64-windows"),
        0,
        0,
        {},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet)
    {
        args.parse_arguments(COMMAND_STRUCTURE);

        const auto pre_build_info = Build::PreBuildInfo::from_triplet_file(paths, default_triplet);
        const Toolset& toolset = paths.get_toolset(pre_build_info);
        auto env_cmd = Build::make_build_env_cmd(pre_build_info, toolset);
        if (env_cmd.empty())
            System::cmd_execute_clean("cmd");
        else
            System::cmd_execute_clean(env_cmd + " && cmd");

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
