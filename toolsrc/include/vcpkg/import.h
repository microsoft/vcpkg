#pragma once

#include <vcpkg/vcpkgpaths.h>

namespace vcpkg::Import
{
    extern const CommandStructure COMMAND_STRUCTURE;

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet);
}
