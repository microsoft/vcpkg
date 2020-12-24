#pragma once

#include <vcpkg/commands.interface.h>

namespace vcpkg::Commands::PortsDiff
{
    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);

    struct PortsDiffCommand : PathsCommand
    {
        virtual void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const override;
    };
}
