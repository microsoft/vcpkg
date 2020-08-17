#pragma once

#include <vcpkg/base/system.process.h>

#include <vcpkg/fwd/vcpkgpaths.h>

#include <string>
#include <vector>

namespace vcpkg
{
    std::string make_cmake_cmd(const VcpkgPaths& paths,
                               const fs::path& cmake_script,
                               std::vector<System::CMakeVariable>&& pass_variables);
}
