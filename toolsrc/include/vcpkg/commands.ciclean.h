#pragma once

#include <vcpkg/commands.interface.h>

namespace vcpkg::Commands::CIClean
{
    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);

    struct CICleanCommand : PathsCommand
    {
        virtual void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const override;
    };
}
