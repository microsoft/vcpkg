#pragma once

#include <vcpkg/commands.interface.h>

namespace vcpkg::Commands::Search
{
    extern const CommandStructure COMMAND_STRUCTURE;
    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);

    struct SearchCommand : PathsCommand
    {
        virtual void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const override;
    };
}
