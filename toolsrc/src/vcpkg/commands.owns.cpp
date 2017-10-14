#include "pch.h"

#include <vcpkg/base/system.h>
#include <vcpkg/commands.h>
#include <vcpkg/help.h>
#include <vcpkg/vcpkglib.h>

namespace vcpkg::Commands::Owns
{
    static void search_file(const VcpkgPaths& paths, const std::string& file_substr, const StatusParagraphs& status_db)
    {
        const std::vector<StatusParagraphAndAssociatedFiles> installed_files = get_installed_files(paths, status_db);
        for (const StatusParagraphAndAssociatedFiles& pgh_and_file : installed_files)
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

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        static const std::string EXAMPLE = Strings::format("The argument should be a pattern to search for. %s",
                                                           Help::create_example_string("owns zlib.dll"));
        args.check_exact_arg_count(1, EXAMPLE);
        args.check_and_get_optional_command_arguments({});

        StatusParagraphs status_db = database_load_check(paths);
        search_file(paths, args.command_arguments[0], status_db);
        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
