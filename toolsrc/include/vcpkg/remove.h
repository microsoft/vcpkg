#pragma once

#include <vcpkg/dependencies.h>
#include <vcpkg/vcpkgcmdarguments.h>
#include <vcpkg/vcpkgpaths.h>

namespace vcpkg::Remove
{
    enum class Purge
    {
        NO = 0,
        YES
    };

    inline Purge to_purge(const bool value) { return value ? Purge::YES : Purge::NO; }

    void perform_remove_plan_action(const VcpkgPaths& paths,
                                    const Dependencies::RemovePlanAction& action,
                                    const Purge purge,
                                    StatusParagraphs* status_db);

    extern const CommandStructure COMMAND_STRUCTURE;

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, Triplet default_triplet);
    void remove_package(const VcpkgPaths& paths, const PackageSpec& spec, StatusParagraphs* status_db);
}
