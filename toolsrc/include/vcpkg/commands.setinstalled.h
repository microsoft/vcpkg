#pragma once

#include <vcpkg/commands.interface.h>

namespace vcpkg::Commands
{
    namespace SetInstalled
    {
        extern const CommandStructure COMMAND_STRUCTURE;
        void perform_and_exit_ex(const VcpkgCmdArguments& args,
                                 const VcpkgPaths& paths,
                                 const PortFileProvider::PathsPortFileProvider& provider,
                                 IBinaryProvider& binary_provider,
                                 const CMakeVars::CMakeVarProvider& cmake_vars,
                                 const std::vector<FullPackageSpec>& specs,
                                 const Build::BuildPackageOptions& install_plan_options,
                                 DryRun dry_run,
                                 const Optional<fs::path>& pkgsconfig_path);
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, Triplet default_triplet);
    }
}
