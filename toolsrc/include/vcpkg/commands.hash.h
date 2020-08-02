#pragma once

#include <vcpkg/commands.interface.h>

namespace vcpkg::Commands::Hash
{
    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);

    struct HashCommand : PathsCommand
    {
        virtual void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const override;
    };
}
