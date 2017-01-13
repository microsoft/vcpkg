#include "vcpkg_Commands.h"
#include "vcpkg_System.h"
#include "vcpkg_info.h"

namespace vcpkg::Commands
{
    void contact_command(const vcpkg_cmd_arguments& args)
    {
        args.check_exact_arg_count(0);
        System::println("Send an email to %s with any feedback.", Info::email());
        exit(EXIT_SUCCESS);
    }
}
