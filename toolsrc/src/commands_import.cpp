#include "pch.h"
#include "vcpkg_Commands.h"
#include "Paragraphs.h"
#include "StatusParagraph.h"
#include "vcpkg_Files.h"

namespace vcpkg::Commands::Import
{
    struct Binaries
    {
        std::vector<fs::path> dlls;
        std::vector<fs::path> libs;
    };


    void check_is_directory(const LineInfo& line_info, const fs::path& dirpath)
    {
        Checks::check_exit(line_info, fs::is_directory(dirpath), "The path %s is not a directory", dirpath.string());
    }

    static Binaries find_binaries_in_dir(const fs::path& path)
    {
        check_is_directory(VCPKG_LINE_INFO, path);

        Binaries binaries;
        binaries.dlls = Files::recursive_find_files_with_extension_in_dir(path, ".dll");
        binaries.libs = Files::recursive_find_files_with_extension_in_dir(path, ".lib");
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
        check_is_directory(VCPKG_LINE_INFO, include_directory);
        check_is_directory(VCPKG_LINE_INFO, project_directory);
        check_is_directory(VCPKG_LINE_INFO, destination_path);
        Binaries debug_binaries = find_binaries_in_dir(project_directory / "Debug");
        Binaries release_binaries = find_binaries_in_dir(project_directory / "Release");

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

    void perform_and_exit(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths)
    {
        static const std::string example = Commands::Help::create_example_string(R"(import C:\path\to\CONTROLfile C:\path\to\includedir C:\path\to\projectdir)");
        args.check_exact_arg_count(3, example);
        args.check_and_get_optional_command_arguments({});

        const fs::path control_file_path(args.command_arguments[0]);
        const fs::path include_directory(args.command_arguments[1]);
        const fs::path project_directory(args.command_arguments[2]);

        const expected<std::unordered_map<std::string, std::string>> pghs = Paragraphs::get_single_paragraph(control_file_path);
        Checks::check_exit(VCPKG_LINE_INFO, pghs.get() != nullptr, "Invalid control file %s for package", control_file_path.generic_string());

        StatusParagraph spgh;
        spgh.package = BinaryParagraph(*pghs.get());
        auto& control_file_data = spgh.package;

        do_import(paths, include_directory, project_directory, control_file_data);
        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
