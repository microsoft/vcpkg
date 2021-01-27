#pragma once

#include <vcpkg/commands.interface.h>

namespace vcpkg::Commands::Version
{
    const char* base_version() noexcept;
    const char* version() noexcept;
    void perform_and_exit(const VcpkgCmdArguments& args, Files::Filesystem& fs);

    struct VersionCommand : BasicCommand
    {
        virtual void perform_and_exit(const VcpkgCmdArguments& args, Files::Filesystem& fs) const override;
    };
}
