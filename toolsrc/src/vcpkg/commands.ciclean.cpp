#include <vcpkg/base/checks.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/system.print.h>

#include <vcpkg/commands.ciclean.h>
#include <vcpkg/vcpkgcmdarguments.h>
#include <vcpkg/vcpkgpaths.h>

using namespace vcpkg;

namespace
{
    void clear_directory(Files::Filesystem& fs, const fs::path& target)
    {
        using vcpkg::System::print2;
        if (fs.is_directory(target))
        {
            print2("Clearing contents of ", fs::u8string(target), "\n");
            fs.remove_all_inside(target, VCPKG_LINE_INFO);
        }
        else
        {
            print2("Skipping clearing contents of ", fs::u8string(target), " because it was not a directory\n");
        }
    }
}

namespace vcpkg::Commands::CIClean
{
    void perform_and_exit(const VcpkgCmdArguments&, const VcpkgPaths& paths)
    {
        using vcpkg::System::print2;
        auto& fs = paths.get_filesystem();
        print2("Starting vcpkg CI clean\n");
        clear_directory(fs, paths.buildtrees);
        clear_directory(fs, paths.installed);
        clear_directory(fs, paths.packages);
        print2("Completed vcpkg CI clean\n");
        Checks::exit_success(VCPKG_LINE_INFO);
    }

    void CICleanCommand::perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const
    {
        CIClean::perform_and_exit(args, paths);
    }
}
