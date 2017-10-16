#include "pch.h"

#include <vcpkg/base/system.h>
#include <vcpkg/build.h>
#include <vcpkg/commands.h>
#include <vcpkg/help.h>

namespace vcpkg::Commands::Env
{
    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet)
    {
        static const std::string EXAMPLE = Help::create_example_string(R"(env --triplet x64-windows)");
        args.check_exact_arg_count(0, EXAMPLE);
        args.check_and_get_optional_command_arguments({});

        const auto pre_build_info = Build::PreBuildInfo::from_triplet_file(paths, default_triplet);
        const Toolset& toolset = paths.get_toolset(pre_build_info.platform_toolset, pre_build_info.visual_studio_path);
        System::cmd_execute_clean(Build::make_build_env_cmd(pre_build_info, toolset) + " && cmd");

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
