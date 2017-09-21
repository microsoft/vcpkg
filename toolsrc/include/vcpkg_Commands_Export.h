#pragma once

#include "StatusParagraphs.h"
#include "VcpkgCmdArguments.h"
#include "VcpkgPaths.h"
#include "VersionT.h"
#include "vcpkg_Build.h"
#include "vcpkg_Dependencies.h"
#include <array>

namespace vcpkg::Commands::Export
{
    void export_integration_files(const fs::path &raw_exported_dir_path, const VcpkgPaths& paths);
}
