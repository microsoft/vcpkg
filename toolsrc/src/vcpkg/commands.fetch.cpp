#include <vcpkg/base/system.print.h>

#include <vcpkg/commands.fetch.h>
#include <vcpkg/vcpkgcmdarguments.h>
#include <vcpkg/vcpkgpaths.h>

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
        (void)args.parse_arguments(COMMAND_STRUCTURE);
        const std::string tool = args.command_arguments[0];
        const fs::path tool_path = paths.get_tool_exe(tool);
        System::print2(fs::u8string(tool_path), '\n');
        Checks::exit_success(VCPKG_LINE_INFO);
    }

    void FetchCommand::perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const
    {
        Fetch::perform_and_exit(args, paths);
    }
}
