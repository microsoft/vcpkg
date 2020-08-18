#pragma once

#include <vcpkg/commands.interface.h>

#include <string>

namespace vcpkg::Help
{
    extern const CommandStructure COMMAND_STRUCTURE;

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);

    void help_topic_valid_triplet(const VcpkgPaths& paths);

    struct HelpCommand : Commands::PathsCommand
    {
        virtual void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const override;
    };
}
