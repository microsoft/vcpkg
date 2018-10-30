#pragma once

#if defined(_WIN32)

#include <vcpkg/vcpkgpaths.h>

namespace vcpkg::VisualStudio
{
    const std::array<CStringView, 4>& get_preferred_toolset_names() noexcept;

    std::vector<std::string> get_visual_studio_instances(const VcpkgPaths& paths);

    std::vector<Toolset> find_toolset_instances_preferred_first(const VcpkgPaths& paths);
}

#endif
