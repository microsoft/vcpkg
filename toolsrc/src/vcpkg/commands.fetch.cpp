#include "pch.h"

#include <vcpkg/commands.fetch.h>

namespace vcpkg::Commands::Fetch
{
    const CommandStructure COMMAND_STRUCTURE = {
        Strings::format("The argument should be tool name\n%s", create_example_string("fetch cmake")),
        1,
        1,
        {},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        Util::unused(args.parse_arguments(COMMAND_STRUCTURE));

        const std::string tool = args.command_arguments[0];
        const fs::path tool_path = paths.get_tool_exe(tool);
        System::print2(tool_path.u8string(), '\n');
        Checks::exit_success(VCPKG_LINE_INFO);
    }

    void FetchCommand::perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const
    {
        Fetch::perform_and_exit(args, paths);
    }
}
