#pragma once

#include <vcpkg/commands.interface.h>

namespace vcpkg::Commands
{
    namespace PortHistory
    {
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
    }
}
