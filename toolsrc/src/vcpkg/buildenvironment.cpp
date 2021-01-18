#include <vcpkg/buildenvironment.h>
#include <vcpkg/tools.h>
#include <vcpkg/vcpkgpaths.h>

namespace vcpkg
{
    System::Command make_cmake_cmd(const VcpkgPaths& paths,
                                   const fs::path& cmake_script,
                                   std::vector<System::CMakeVariable>&& pass_variables)
    {
        auto local_variables = std::move(pass_variables);
        local_variables.emplace_back("VCPKG_ROOT_DIR", paths.root);
        local_variables.emplace_back("PACKAGES_DIR", paths.packages);
        local_variables.emplace_back("BUILDTREES_DIR", paths.buildtrees);
        local_variables.emplace_back("_VCPKG_INSTALLED_DIR", paths.installed);
        local_variables.emplace_back("DOWNLOADS", paths.downloads);
        local_variables.emplace_back("VCPKG_MANIFEST_INSTALL", "OFF");
        return System::make_basic_cmake_cmd(paths.get_tool_exe(Tools::CMAKE), cmake_script, local_variables);
    }
}
