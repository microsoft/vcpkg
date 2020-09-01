#pragma once

#include <vcpkg/build.h>

namespace vcpkg::Commands::Mirror
{
    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, Triplet default_triplet);

    struct MirrorCommand : Commands::TripletCommand
    {
        virtual void perform_and_exit(const VcpkgCmdArguments& inArgs,
                                      const VcpkgPaths& paths,
                                      Triplet default_triplet) const override;
    };
}
