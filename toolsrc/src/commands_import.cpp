#include "vcpkg_Commands.h"
#include "vcpkg.h"
#include "vcpkg_System.h"

namespace vcpkg
{
    void import_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths)
    {
        if (args.command_arguments.size() != 3)
        {
            System::println(System::color::error, "Error: %s requires 3 parameters", args.command);
            print_example(Strings::format(R"(%s C:\path\to\CONTROLfile C:\path\to\includedir C:\path\to\projectdir)", args.command).c_str());
            exit(EXIT_FAILURE);
        }

        const fs::path control_file_path(args.command_arguments[0]);
        const fs::path include_directory(args.command_arguments[1]);
        const fs::path project_directory(args.command_arguments[2]);

        auto pghs = get_paragraphs(control_file_path);
        Checks::check_throw(pghs.size() == 1, "Invalid control file for package");

        StatusParagraph spgh;
        spgh.package = BinaryParagraph(pghs[0]);
        auto& control_file_data = spgh.package;

        vcpkg::binary_import(paths, include_directory, project_directory, control_file_data);
        exit(EXIT_SUCCESS);
    }
}
