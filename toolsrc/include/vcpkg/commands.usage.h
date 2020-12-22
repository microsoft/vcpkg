#pragma once

#include <vcpkg/commands.interface.h>

namespace vcpkg::Commands::Usage
{
    struct UsageCommand : TripletCommand
    {
        virtual void perform_and_exit(const VcpkgCmdArguments& args,
                                      const VcpkgPaths& paths,
                                      Triplet default_triplet) const override;
    };
}
