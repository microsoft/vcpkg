#include "vcpkg_Commands.h"
#include "vcpkg_System.h"
#include "vcpkg.h"
#include <iostream>

namespace vcpkg
{
    void owns_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths)
    {
        args.check_max_args(1);
        if (args.command_arguments.size() == 0)
        {
            System::println(System::color::error, "Error: owns requires a pattern to search for as the first argument.");
            std::cout <<
                "example:\n"
                "    vcpkg owns .dll\n";
            exit(EXIT_FAILURE);
        }
        StatusParagraphs status_db = database_load_check(paths);
        search_file(paths, args.command_arguments[0], status_db);
        exit(EXIT_SUCCESS);
    }
}
