#pragma once

#include <vcpkg/commands.interface.h>
#include <vcpkg/vcpkgpaths.h>

#include <string>

namespace vcpkg::RemoteInstall
{
    extern const CommandStructure COMMAND_STRUCTURE;

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, Triplet default_triplet);

    struct RemoteInstallCommand : Commands::TripletCommand
    {
        virtual void perform_and_exit(const VcpkgCmdArguments& args,
                                      const VcpkgPaths& paths,
                                      Triplet default_triplet) const override;
    };
}