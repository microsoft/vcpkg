#include "vcpkg_Commands.h"
#include "vcpkg.h"
#include "Paragraphs.h"

namespace vcpkg
{
    void import_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths)
    {
        static const std::string example = create_example_string(R"(import C:\path\to\CONTROLfile C:\path\to\includedir C:\path\to\projectdir)");
        args.check_exact_arg_count(3, example.c_str());

        const fs::path control_file_path(args.command_arguments[0]);
        const fs::path include_directory(args.command_arguments[1]);
        const fs::path project_directory(args.command_arguments[2]);

        auto pghs = Paragraphs::get_paragraphs(control_file_path);
        Checks::check_throw(pghs.size() == 1, "Invalid control file for package");

        StatusParagraph spgh;
        spgh.package = BinaryParagraph(pghs[0]);
        auto& control_file_data = spgh.package;

        vcpkg::binary_import(paths, include_directory, project_directory, control_file_data);
        exit(EXIT_SUCCESS);
    }
}
