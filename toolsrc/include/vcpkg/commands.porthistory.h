#pragma once

#include <vcpkg/commands.interface.h>

namespace vcpkg::Commands::PortHistory
{
    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);

    struct PortHistoryCommand : PathsCommand
    {
        virtual void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const override;
    };
}
