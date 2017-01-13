#include "vcpkg_Commands.h"
#include "vcpkg_System.h"
#include "vcpkg_info.h"

namespace vcpkg::Commands
{
    void version_command(const vcpkg_cmd_arguments& args)
    {
        args.check_exact_arg_count(0);
        System::println("Vcpkg package management program version %s\n"
                        "\n"
                        "See LICENSE.txt for license information.", Info::version()
        );
        exit(EXIT_SUCCESS);
    }
}
