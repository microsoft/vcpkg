#pragma once

#include <vcpkg/base/chrono.h>

#include <vcpkg/binaryparagraph.h>
#include <vcpkg/build.h>
#include <vcpkg/dependencies.h>
#include <vcpkg/vcpkgcmdarguments.h>
#include <vcpkg/vcpkgpaths.h>

#include <vector>

namespace vcpkg::Commands::Mirror
{
    extern const CommandStructure COMMAND_STRUCTURE;

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, Triplet default_triplet);

    struct MirrorCommand : Commands::TripletCommand
    {
        virtual void perform_and_exit(const VcpkgCmdArguments& inArgs,
                                      const VcpkgPaths& paths,
                                      Triplet default_triplet) const override;
    };
}
