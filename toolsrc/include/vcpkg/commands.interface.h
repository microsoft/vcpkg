#pragma once

#include <vcpkg/vcpkgcmdarguments.h>
#include <vcpkg/vcpkgpaths.h>

namespace vcpkg::Commands
{
    enum class DryRun : bool
    {
        No,
        Yes,
    };

    struct BasicCommand
    {
        virtual void perform_and_exit(const VcpkgCmdArguments& args, Files::Filesystem& fs) const = 0;
        virtual ~BasicCommand() = default;
    };
}
