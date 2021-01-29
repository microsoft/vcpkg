#pragma once

#include <vcpkg/fwd/vcpkgpaths.h>

#include <vcpkg/base/system.process.h>

#include <string>
#include <vector>

namespace vcpkg
{
    System::Command make_cmake_cmd(const VcpkgPaths& paths,
                                   const fs::path& cmake_script,
                                   std::vector<System::CMakeVariable>&& pass_variables);
}
