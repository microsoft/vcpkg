#pragma once

#include <vcpkg/commands.interface.h>

namespace vcpkg::Commands::Info
{
    extern const CommandStructure COMMAND_STRUCTURE;

    struct InfoCommand : PathsCommand
    {
        virtual void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const override;
    };
}
