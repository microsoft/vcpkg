#pragma once

#include <vcpkg/base/expected.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/stringview.h>

#include <vcpkg/commands.interface.h>

namespace vcpkg::Commands::FormatManifest
{
    ExpectedS<fs::path> resolve_format_manifest_input(StringView input,
                                                      const fs::path& original_cwd,
                                                      const fs::path& ports_base,
                                                      const Files::ITestFileExists& filesystem);

    extern const CommandStructure COMMAND_STRUCTURE;
    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths);

    struct FormatManifestCommand : PathsCommand
    {
        virtual void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const override;
    };
}
