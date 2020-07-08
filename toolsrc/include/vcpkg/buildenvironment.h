#include <string>
#include <vector>

#include <vcpkg/base/system.process.h>
#include <vcpkg/vcpkgpaths.h>

namespace vcpkg
{
    std::string make_cmake_cmd(const VcpkgPaths& paths,
                               const fs::path& cmake_script,
                               std::vector<System::CMakeVariable>&& pass_variables);
}
