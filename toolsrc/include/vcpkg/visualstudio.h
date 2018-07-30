#pragma once

#if defined(_WIN32)

#include <vcpkg/vcpkgpaths.h>

namespace vcpkg::VisualStudio
{
    std::vector<Toolset> find_toolset_instances_preferred_first(const VcpkgPaths& paths);
}

#endif
