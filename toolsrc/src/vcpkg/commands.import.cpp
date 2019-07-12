#include "pch.h"

#include <vcpkg/base/files.h>
#include <vcpkg/commands.h>
#include <vcpkg/help.h>
#include <vcpkg/paragraphs.h>
#include <vcpkg/statusparagraph.h>

namespace vcpkg::Commands::Import
{
    struct Binaries
    {
        std::vector<fs::path> dlls;
        std::vector<fs::path> libs;
    };

    static void check_is_directory(const LineInfo& line_info, const Files::Filesystem& fs, const fs::path& dirpath)
    {
        Checks::check_exit(line_info, fs.is_directory(dirpath), "The path %s is not a directory", dirpath.string());
    }

    static Binaries find_binaries_in_dir(const Files::Filesystem& fs, const fs::path& path)
    {
        auto files = fs.get_files_recursive(path);

        check_is_directory(VCPKG_LINE_INFO, fs, path);

        Binaries binaries;
        for (auto&& file : files)
        {
            if (fs.is_directory(file)) continue;
            const auto ext = file.extension();
            if (ext == ".dll")
                binaries.dlls.push_back(std::move(file));
            else if (ext == ".lib")
                binaries.libs.push_back(std::move(file));
        }
        return binaries;
    }

    static void copy_files_into_directory(Files::Filesystem& fs,
                                          const std::vector<fs::path>& files,
                                          const fs::path& destination_folder)
    {
        std::error_code ec;
        fs.create_directory(destination_folder, ec);

        for (auto const& src_path : files)
        {
            const fs::path dest_path = destination_folder / src_path.filename();
            fs.copy(src_path, dest_path, fs::copy_options::overwrite_existing);
        }
    }

    static void place_library_files_in(Files::Filesystem& fs,
                                       const fs::path& include_directory,
                                       const fs::path& project_directory,
                                       const fs::path& destination_path)
    {
        check_is_directory(VCPKG_LINE_INFO, fs, include_directory);
        check_is_directory(VCPKG_LINE_INFO, fs, project_directory);
        check_is_directory(VCPKG_LINE_INFO, fs, destination_path);
        const Binaries debug_binaries = find_binaries_in_dir(fs, project_directory / "Debug");
        const Binaries release_binaries = find_binaries_in_dir(fs, project_directory / "Release");

        const fs::path destination_include_directory = destination_path / "include";
        fs.copy(include_directory,
                destination_include_directory,
                fs::copy_options::recursive | fs::copy_options::overwrite_existing);

        copy_files_into_directory(fs, release_binaries.dlls, destination_path / "bin");
        copy_files_into_directory(fs, release_binaries.libs, destination_path / "lib");

        std::error_code ec;
        fs.create_directory(destination_path / "debug", ec);
        copy_files_into_directory(fs, debug_binaries.dlls, destination_path / "debug" / "bin");
        copy_files_into_directory(fs, debug_binaries.libs, destination_path / "debug" / "lib");
    }

    static void do_import(const VcpkgPaths& paths,
                          const fs::path& include_directory,
                          const fs::path& project_directory,
                          const BinaryParagraph& control_file_data)
    {
        auto& fs = paths.get_filesystem();
        const fs::path library_destination_path = paths.package_dir(control_file_data.spec);
        std::error_code ec;
        fs.create_directory(library_destination_path, ec);
        place_library_files_in(paths.get_filesystem(), include_directory, project_directory, library_destination_path);

        const fs::path control_file_path = library_destination_path / "CONTROL";
        fs.write_contents(control_file_path, Strings::serialize(control_file_data), VCPKG_LINE_INFO);
    }

    const CommandStructure COMMAND_STRUCTURE = {
        Help::create_example_string(R"(import C:\path\to\CONTROLfile C:\path\to\includedir C:\path\to\projectdir)"),
        3,
        3,
        {},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        Util::unused(args.parse_arguments(COMMAND_STRUCTURE));

        const fs::path control_file_path(args.command_arguments[0]);
        const fs::path include_directory(args.command_arguments[1]);
        const fs::path project_directory(args.command_arguments[2]);

        const Expected<std::unordered_map<std::string, std::string>> pghs =
            Paragraphs::get_single_paragraph(paths.get_filesystem(), control_file_path);
        Checks::check_exit(VCPKG_LINE_INFO,
                           pghs.get() != nullptr,
                           "Invalid control file %s for package",
                           control_file_path.generic_u8string());

        StatusParagraph spgh;
        spgh.package = BinaryParagraph(*pghs.get());
        auto& control_file_data = spgh.package;

        do_import(paths, include_directory, project_directory, control_file_data);
        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
