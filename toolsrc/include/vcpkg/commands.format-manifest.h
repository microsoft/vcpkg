#pragma once

#include <vcpkg/commands.interface.h>

namespace vcpkg::Commands::FormatManifest
{
    extern const CommandStructure COMMAND_STRUCTURE;
    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);

    struct FormatManifestCommand : PathsCommand
    {
        virtual void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const override;
    };
}
