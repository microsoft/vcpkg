#include "vcpkg_Commands.h"
#include "vcpkg_System.h"

namespace vcpkg::Commands::Helpers
{
    void print_usage()
    {
        System::println(
            "Commands:\n"
            "  vcpkg search [pat]              Search for packages available to be built\n"
            "  vcpkg install <pkg>             Install a package\n"
            "  vcpkg remove <pkg>              Uninstall a package. \n"
            "  vcpkg remove --purge <pkg>      Uninstall and delete a package. \n"
            "  vcpkg list                      List installed packages\n"
            "  vcpkg update                    Display list of packages for updating\n"
            "  vcpkg hash <file> [alg]         Hash a file by specific algorithm, default SHA512\n"
            "\n"
            "%s" // Integration help
            "\n"
            "  vcpkg edit <pkg>                Open up a port for editing (uses %%EDITOR%%, default 'code')\n"
            "  vcpkg import <pkg>              Import a pre-built library\n"
            "  vcpkg create <pkg> <url>\n"
            "             [archivename]        Create a new package\n"
            "  vcpkg owns <pat>                Search for files in installed packages\n"
            "  vcpkg cache                     List cached compiled packages\n"
            "  vcpkg version                   Display version information\n"
            "  vcpkg contact                   Display contact information to send feedback\n"
            "\n"
            //"internal commands:\n"
            //"  --check-build-deps <controlfile>\n"
            //"  --create-binary-control <controlfile>\n"
            //"\n"
            "Options:\n"
            "  --triplet <t>                   Specify the target architecture triplet.\n"
            "                                  (default: %%VCPKG_DEFAULT_TRIPLET%%, see 'vcpkg help triplet')\n"
            "\n"
            "  --vcpkg-root <path>             Specify the vcpkg root directory\n"
            "                                  (default: %%VCPKG_ROOT%%)\n"
            "\n"
            "For more help (including examples) see the accompanying README.md."
            , INTEGRATE_COMMAND_HELPSTRING);
    }

    std::string create_example_string(const std::string& command_and_arguments)
    {
        std::string cs = Strings::format("Example:\n"
                                         "  vcpkg %s", command_and_arguments);
        return cs;
    }

    void print_example(const std::string& command_and_arguments)
    {
        System::println(create_example_string(command_and_arguments));
    }
}
