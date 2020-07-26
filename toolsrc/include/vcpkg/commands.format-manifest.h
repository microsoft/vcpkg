#pragma once

#include <vcpkg/commands.interface.h>

namespace vcpkg::Commands
{
    namespace FormatManifest
    {
        extern const CommandStructure COMMAND_STRUCTURE;
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
    }
}
