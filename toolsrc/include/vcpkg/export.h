#pragma once

#include <vcpkg/commands.interface.h>

namespace vcpkg::Export
{
    extern const CommandStructure COMMAND_STRUCTURE;

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, Triplet default_triplet);

    void export_integration_files(const fs::path& raw_exported_dir_path, const VcpkgPaths& paths);

    struct ExportCommand : Commands::TripletCommand
    {
        virtual void perform_and_exit(const VcpkgCmdArguments& args,
                                      const VcpkgPaths& paths,
                                      Triplet default_triplet) const override;
    };
}
