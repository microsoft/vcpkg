#pragma once

#if !VCPKG_DISABLE_METRICS && defined(_WIN32)
#define VCPKG_ENABLE_X_UPLOAD_METRICS_COMMAND 1
#else
#define VCPKG_ENABLE_X_UPLOAD_METRICS_COMMAND 0
#endif // !VCPKG_DISABLE_METRICS && defined(_WIN32)

#if VCPKG_ENABLE_X_UPLOAD_METRICS_COMMAND

#include <vcpkg/commands.interface.h>

namespace vcpkg::Commands::UploadMetrics
{
    extern const CommandStructure COMMAND_STRUCTURE;
    struct UploadMetricsCommand : BasicCommand
    {
        virtual void perform_and_exit(const VcpkgCmdArguments& args, Files::Filesystem& fs) const override;
    };
}

#endif // VCPKG_ENABLE_X_UPLOAD_METRICS_COMMAND
