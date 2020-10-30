#pragma once

#include <vcpkg/commands.interface.h>
#include <vcpkg/vcpkgcmdarguments.h>

namespace vcpkg::Commands::Owns
{
    extern const CommandStructure COMMAND_STRUCTURE;
    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);

    struct OwnsCommand : PathsCommand
    {
        virtual void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const override;
    };
}
