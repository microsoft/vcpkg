#pragma once

#include <vcpkg/commands.interface.h>

namespace vcpkg::Commands
{
    namespace Create
    {
        extern const CommandStructure COMMAND_STRUCTURE;
        int perform(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
    }
}
