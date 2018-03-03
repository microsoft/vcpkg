#pragma once

#include <vcpkg/dependencies.h>
#include <vcpkg/vcpkgpaths.h>

#include <vcpkg/base/files.h>

#include <string>
#include <vector>

namespace vcpkg::Import::Ext
{
    struct Options
    {
        Optional<std::string> maybe_project_directory;
        Optional<std::string> maybe_include_directory;
        Optional<std::string> maybe_control_file_path;
    };

    void do_import(const VcpkgPaths& paths, const Options& opts);
}