#pragma once

#include <vcpkg/commands.interface.h>

namespace vcpkg::Commands::Integrate
{
    extern const CommandStructure COMMAND_STRUCTURE;

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);
    void append_helpstring(HelpTableFormatter& table);
    std::string get_helpstring();

    struct IntegrateCommand : PathsCommand
    {
        virtual void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const override;
    };
}
