#include "vcpkg_Commands.h"
#include "vcpkg_System.h"
#include "vcpkg.h"

namespace vcpkg
{
    void owns_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths)
    {
        static const std::string example = Strings::format("The argument should be a pattern to search for. %s", create_example_string("owns zlib.dll"));
        args.check_exact_arg_count(1, example.c_str());

        StatusParagraphs status_db = database_load_check(paths);
        search_file(paths, args.command_arguments[0], status_db);
        exit(EXIT_SUCCESS);
    }
}
