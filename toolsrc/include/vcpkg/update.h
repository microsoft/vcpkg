#pragma once

#include <vcpkg/commands.interface.h>
#include <vcpkg/dependencies.h>
#include <vcpkg/packagespec.h>
#include <vcpkg/statusparagraphs.h>
#include <vcpkg/versiont.h>

namespace vcpkg::Update
{
    struct OutdatedPackage
    {
        static bool compare_by_name(const OutdatedPackage& left, const OutdatedPackage& right);

        PackageSpec spec;
        VersionDiff version_diff;
    };

    std::vector<OutdatedPackage> find_outdated_packages(const PortFileProvider::PortFileProvider& provider,
                                                        const StatusParagraphs& status_db);

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);

    struct UpdateCommand : Commands::PathsCommand
    {
        virtual void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const override;
    };
}
