#pragma once

#include <vcpkg/commands.interface.h>

namespace vcpkg::Commands::Upgrade
{
    extern const CommandStructure COMMAND_STRUCTURE;
    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, Triplet default_triplet);

    struct UpgradeCommand : TripletCommand
    {
        virtual void perform_and_exit(const VcpkgCmdArguments& args,
                                      const VcpkgPaths& paths,
                                      Triplet default_triplet) const override;
    };
}
