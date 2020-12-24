#pragma once

#include <vcpkg/commands.interface.h>

namespace vcpkg::Commands::Autocomplete
{
    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);

    struct AutocompleteCommand : PathsCommand
    {
        virtual void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const override;
    };
}
