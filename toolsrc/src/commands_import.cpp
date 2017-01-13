#include "vcpkg_Commands.h"
#include "Paragraphs.h"
#include "StatusParagraph.h"
#include "vcpkg_Files.h"
#include <fstream>

namespace vcpkg::Commands
{
    struct Binaries
    {
        std::vector<fs::path> dlls;
        std::vector<fs::path> libs;
    };

    static Binaries detect_files_in_directory_ending_with(const fs::path& path)
    {
        Files::check_is_directory(path);

        Binaries binaries;

        for (auto it = fs::recursive_directory_iterator(path); it != fs::recursive_directory_iterator(); ++it)
        {
            fs::path file = *it;
            // Skip if directory ?????
            if (file.extension() == ".dll")
            {
                binaries.dlls.push_back(file);
            }
            else if (file.extension() == ".lib")
            {
                binaries.libs.push_back(file);
            }
        }

        return binaries;
    }

    static void copy_files_into_directory(const std::vector<fs::path>& files, const fs::path& destination_folder)
    {
        fs::create_directory(destination_folder);

        for (auto const& src_path : files)
        {
            fs::path dest_path = destination_folder / src_path.filename();
            fs::copy(src_path, dest_path, fs::copy_options::overwrite_existing);
        }
    }

    static void place_library_files_in(const fs::path& include_directory, const fs::path& project_directory, const fs::path& destination_path)
    {
        Files::check_is_directory(include_directory);
        Files::check_is_directory(project_directory);
        Files::check_is_directory(destination_path);
        Binaries debug_binaries = detect_files_in_directory_ending_with(project_directory / "Debug");
        Binaries release_binaries = detect_files_in_directory_ending_with(project_directory / "Release");

        fs::path destination_include_directory = destination_path / "include";
        fs::copy(include_directory, destination_include_directory, fs::copy_options::recursive | fs::copy_options::overwrite_existing);

        copy_files_into_directory(release_binaries.dlls, destination_path / "bin");
        copy_files_into_directory(release_binaries.libs, destination_path / "lib");

        fs::create_directory(destination_path / "debug");
        copy_files_into_directory(debug_binaries.dlls, destination_path / "debug" / "bin");
        copy_files_into_directory(debug_binaries.libs, destination_path / "debug" / "lib");
    }

    static void do_import(const vcpkg_paths& paths, const fs::path& include_directory, const fs::path& project_directory, const BinaryParagraph& control_file_data)
    {
        fs::path library_destination_path = paths.package_dir(control_file_data.spec);
        fs::create_directory(library_destination_path);
        place_library_files_in(include_directory, project_directory, library_destination_path);

        fs::path control_file_path = library_destination_path / "CONTROL";
        std::ofstream(control_file_path) << control_file_data;
    }

    void import_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths)
    {
        static const std::string example = Commands::Helpers::create_example_string(R"(import C:\path\to\CONTROLfile C:\path\to\includedir C:\path\to\projectdir)");
        args.check_exact_arg_count(3, example);

        const fs::path control_file_path(args.command_arguments[0]);
        const fs::path include_directory(args.command_arguments[1]);
        const fs::path project_directory(args.command_arguments[2]);

        auto pghs = Paragraphs::get_paragraphs(control_file_path);
        Checks::check_throw(pghs.size() == 1, "Invalid control file for package");

        StatusParagraph spgh;
        spgh.package = BinaryParagraph(pghs[0]);
        auto& control_file_data = spgh.package;

        do_import(paths, include_directory, project_directory, control_file_data);
        exit(EXIT_SUCCESS);
    }
}
