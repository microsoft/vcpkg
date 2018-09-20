#include "pch.h"

#include <vcpkg/commands.h>
#include <vcpkg/help.h>
#include <vcpkg/visualstudio.h>

namespace vcpkg::Commands::X_VSInstances
{
    const CommandStructure COMMAND_STRUCTURE = {
        Help::create_example_string("x-vsinstances"),
        0,
        0,
        {{}, {}},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
#if defined(_WIN32)
        const ParsedArguments parsed_args = args.parse_arguments(COMMAND_STRUCTURE);

        const auto instances = vcpkg::VisualStudio::get_visual_studio_instances(paths);
        for (const std::string& instance : instances)
        {
            System::println(instance);
        }

        Checks::exit_success(VCPKG_LINE_INFO);
#else
        Checks::exit_with_message(VCPKG_LINE_INFO, "This command is not supported on non-windows platforms.");
#endif
    }
}
