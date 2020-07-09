#pragma once

#include <string>
#include <utility>

#include <vcpkg/base/files.h>

namespace vcpkg
{
    struct VcpkgPaths;

    struct ToolCache
    {
        virtual ~ToolCache() { }

        virtual const fs::path& get_tool_path(const VcpkgPaths& paths, const std::string& tool) const = 0;
        virtual const std::string& get_tool_version(const VcpkgPaths& paths, const std::string& tool) const = 0;
    };

    std::unique_ptr<ToolCache> get_tool_cache();
}
