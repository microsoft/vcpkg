#include "vcpkg_Commands.h"
#include "vcpkg_System.h"
#include "vcpkg.h"

namespace vcpkg
{
    static void search_file(const vcpkg_paths& paths, const std::string& file_substr, const StatusParagraphs& status_db)
    {
        const std::vector<StatusParagraph_and_associated_files> installed_files = get_installed_files(paths, status_db);
        for (const StatusParagraph_and_associated_files& pgh_and_file : installed_files)
        {
            const StatusParagraph& pgh = pgh_and_file.pgh;

            for (const std::string& file : pgh_and_file.files)
            {
                if (file.find(file_substr) != std::string::npos)
                {
                    System::println("%s: %s", pgh.package.displayname(), file);
                }
            }
        }
    }

    void owns_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths)
    {
        static const std::string example = Strings::format("The argument should be a pattern to search for. %s", create_example_string("owns zlib.dll"));
        args.check_exact_arg_count(1, example);

        StatusParagraphs status_db = database_load_check(paths);
        search_file(paths, args.command_arguments[0], status_db);
        exit(EXIT_SUCCESS);
    }
}
