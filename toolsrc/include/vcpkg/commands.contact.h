#pragma once

#include <vcpkg/commands.interface.h>

namespace vcpkg::Commands
{
    namespace Contact
    {
        extern const CommandStructure COMMAND_STRUCTURE;
        const std::string& email();
        void perform_and_exit(const VcpkgCmdArguments& args, Files::Filesystem& fs);
    }
}
