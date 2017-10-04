#pragma once

#include "VcpkgPaths.h"

namespace vcpkg::Commands::Export
{
    void export_integration_files(const fs::path& raw_exported_dir_path, const VcpkgPaths& paths);
}
