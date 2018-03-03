#pragma once

#include <vcpkg/dependencies.h>
#include <vcpkg/vcpkgpaths.h>
#include <vcpkg/base/files.h>

#include <string>
#include <vector>

namespace vcpkg::Import::Pkg
{
    struct Options
    {
        Optional<std::string> maybe_vcexport_file_path;
    };

    void do_import(const VcpkgPaths& paths, const Options& opts);
}