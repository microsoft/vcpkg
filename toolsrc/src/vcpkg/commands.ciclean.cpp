#include "pch.h"

#include <vcpkg/base/checks.h>
#include <vcpkg/base/files.h>
#include <vcpkg/commands.h>
#include <vcpkg/vcpkgcmdarguments.h>

using namespace vcpkg;

namespace vcpkg::Commands::CIClean
{
    void perform_and_exit(const VcpkgCmdArguments&, const VcpkgPaths& paths)
    {
        auto& fs = paths.get_filesystem();
        if (fs.is_directory(paths.buildtrees))
        {
            fs.remove_all_inside(paths.buildtrees, VCPKG_LINE_INFO);
        }

        if (fs.is_directory(paths.installed))
        {
            fs.remove_all_inside(paths.installed, VCPKG_LINE_INFO);
        }

        if (fs.is_directory(paths.packages))
        {
            fs.remove_all_inside(paths.packages, VCPKG_LINE_INFO);
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
