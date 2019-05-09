#include "pch.h"

#include <vcpkg/base/system.print.h>
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
                    System::print2(pgh.package.displayname(), ": ", file, '\n');
                }
            }
        }
    }
    const CommandStructure COMMAND_STRUCTURE = {
        Strings::format("The argument should be a pattern to search for. %s",
                        Help::create_example_string("owns zlib.dll")),
        1,
        1,
        {},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        Util::unused(args.parse_arguments(COMMAND_STRUCTURE));

        const StatusParagraphs status_db = database_load_check(paths);
        search_file(paths, args.command_arguments[0], status_db);
        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
