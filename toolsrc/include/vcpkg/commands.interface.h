#pragma once

#include <vcpkg/vcpkgcmdarguments.h>
#include <vcpkg/vcpkgpaths.h>

namespace vcpkg::Commands
{
    enum class DryRun : bool
    {
        No,
        Yes,
    };

    struct BasicCommand
    {
        virtual void perform_and_exit(const VcpkgCmdArguments& args, Files::Filesystem& fs) const = 0;
        virtual ~BasicCommand() = default;
    };

    struct PathsCommand
    {
        virtual void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const = 0;
        virtual ~PathsCommand() = default;
    };

    struct TripletCommand
    {
        virtual void perform_and_exit(const VcpkgCmdArguments& args,
                                      const VcpkgPaths& paths,
                                      Triplet default_triplet) const = 0;
        virtual ~TripletCommand() = default;
    };
}
