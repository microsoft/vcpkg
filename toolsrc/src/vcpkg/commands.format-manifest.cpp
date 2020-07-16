#include "pch.h"

#include <vcpkg/base/checks.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/json.h>
#include <vcpkg/base/system.debug.h>

#include <vcpkg/commands.h>
#include <vcpkg/paragraphs.h>
#include <vcpkg/portfileprovider.h>
#include <vcpkg/sourceparagraph.h>

namespace vcpkg::Commands::FormatManifest
{
    static constexpr StringLiteral OPTION_ALL = "all";
    static constexpr StringLiteral OPTION_CONVERT_CONTROL = "convert-control";

    const CommandSwitch FORMAT_SWITCHES[] = {
        {OPTION_ALL, "Format all ports' manifest files."},
        {OPTION_CONVERT_CONTROL, "Convert CONTROL files to manifest files."},
    };

    const CommandStructure COMMAND_STRUCTURE = {
        create_example_string(R"###(x-format-manifest --all)###"),
        0,
        SIZE_MAX,
        {FORMAT_SWITCHES, {}, {}},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        struct ReadControlFile
        {
            fs::path control_file;
            fs::path manifest_file;
        };
        struct WriteFile
        {
            SourceControlFile scf;
            fs::path file_to_write;
            std::string original;
        };

        auto parsed_args = args.parse_arguments(COMMAND_STRUCTURE);

        std::vector<fs::path> manifests_to_read;
        std::vector<ReadControlFile> control_files_to_read;
        std::vector<WriteFile> files_to_write;

        auto& fs = paths.get_filesystem();
        bool has_error = false;

        const bool convert_control = Util::Sets::contains(parsed_args.switches, OPTION_CONVERT_CONTROL);

        if (Util::Sets::contains(parsed_args.switches, OPTION_ALL))
        {
            for (const auto& dir : fs::directory_iterator(paths.ports))
            {
                auto control_path = dir.path() / fs::u8path("CONTROL");
                auto manifest_path = dir.path() / fs::u8path("vcpkg.json");
                if (fs.exists(manifest_path))
                {
                    manifests_to_read.push_back(std::move(manifest_path));
                }
                else if (convert_control && fs.exists(control_path))
                {
                    control_files_to_read.push_back({std::move(control_path), std::move(manifest_path)});
                }
            }
        }

        for (const auto& arg : args.command_arguments)
        {
            auto path = fs::u8path(arg);
            if (path.is_relative())
            {
                path = paths.original_cwd / path;
            }

            if (path.filename() == fs::u8path("CONTROL"))
            {
                auto manifest_path = path.parent_path() / fs::u8path("vcpkg.json");
                control_files_to_read.push_back({std::move(path), std::move(manifest_path)});
            }
            else
            {
                manifests_to_read.push_back(std::move(path));
            }
        }

        for (const auto& path : manifests_to_read)
        {
            Debug::print("Reading ", path.u8string(), "\n");
            auto contents = fs.read_contents(path, VCPKG_LINE_INFO);
            auto parsed_json_opt = Json::parse(contents, path);
            if (!parsed_json_opt.has_value())
            {
                System::printf(System::Color::error,
                               "Failed to parse %s: %s\n",
                               path.u8string(),
                               parsed_json_opt.error()->format());
                has_error = true;
                continue;
            }

            const auto& parsed_json = parsed_json_opt.value_or_exit(VCPKG_LINE_INFO).first;
            if (!parsed_json.is_object())
            {
                System::printf(System::Color::error, "The file %s is not an object\n", path.u8string());
                has_error = true;
                continue;
            }

            auto scf = SourceControlFile::parse_manifest_file(path, parsed_json.object());
            if (!scf.has_value())
            {
                System::printf(System::Color::error, "Failed to parse manifest file: %s\n", path.u8string());
                print_error_message(scf.error());
                has_error = true;
                continue;
            }

            files_to_write.push_back({std::move(*scf.value_or_exit(VCPKG_LINE_INFO)), path, std::move(contents)});
        }

        for (const auto& el : control_files_to_read)
        {
            std::error_code ec;
            Debug::print("Reading ", el.control_file.u8string(), "\n");

            auto contents = fs.read_contents(el.control_file, VCPKG_LINE_INFO);
            auto paragraphs = Paragraphs::parse_paragraphs(contents, el.control_file.u8string());

            if (!paragraphs)
            {
                System::printf(System::Color::error,
                               "Failed to read paragraphs from %s: %s\n",
                               el.control_file.u8string(),
                               paragraphs.error());
                has_error = true;
                continue;
            }
            auto scf_res = SourceControlFile::parse_control_file(el.control_file,
                                                                 std::move(paragraphs).value_or_exit(VCPKG_LINE_INFO));
            if (!scf_res)
            {
                System::printf(System::Color::error, "Failed to parse control file: %s\n", el.control_file.u8string());
                print_error_message(scf_res.error());
                has_error = true;
                continue;
            }

            files_to_write.push_back({std::move(*scf_res.value_or_exit(VCPKG_LINE_INFO)), el.manifest_file, contents});
        }

        for (auto const& el : files_to_write)
        {
            Debug::print("Writing ", el.file_to_write.u8string(), "\n");
            auto res = serialize_manifest(el.scf);

            auto check_scf_json = Json::parse(res);
            if (!check_scf_json)
            {
                Checks::exit_with_message(VCPKG_LINE_INFO,
                                          R"([correctness check] Failed to parse serialized JSON file of %s
Please open an issue at https://github.com/microsoft/vcpkg, with the following output:
    Error: %s

=== Serialized manifest file ===
%s
)",
                                          el.scf.core_paragraph->name,
                                          check_scf_json.error()->format(),
                                          res);
            }
            auto check_scf_json_value = std::move(check_scf_json).value_or_exit(VCPKG_LINE_INFO).first;

            auto check_scf = SourceControlFile::parse_manifest_file(fs::path{}, check_scf_json_value.object());
            if (!check_scf)
            {
                System::printf(System::Color::error,
                               R"([correctness check] Failed to parse serialized manifest file of %s
Please open an issue at https://github.com/microsoft/vcpkg, with the following output:
    Error:)",
                               el.scf.core_paragraph->name);
                print_error_message(check_scf.error());
                Checks::exit_with_message(VCPKG_LINE_INFO,
                                          R"(
=== Serialized manifest file ===
%s
)",
                                          res);
            }

            auto check = std::move(check_scf).value_or_exit(VCPKG_LINE_INFO);
            if (*check != el.scf)
            {
                Checks::exit_with_message(
                    VCPKG_LINE_INFO,
                    R"([correctness check] The serialized manifest SCF was different from the original SCF.
Please open an issue at https://github.com/microsoft/vcpkg, with the following output:

=== Original File ===
%s

=== Serialized File ===
%s
)",
                    el.original,
                    res);
            }

            // the manifest scf is correct
            std::error_code ec;
            fs.write_contents(el.file_to_write, res, ec);
            if (ec)
            {
                Checks::exit_with_message(VCPKG_LINE_INFO,
                                          "Failed to write manifest file %s: %s\n",
                                          el.file_to_write.u8string(),
                                          ec.message());
            }
        }

        if (has_error)
        {
            Checks::exit_fail(VCPKG_LINE_INFO);
        }
        else
        {
            System::print2("Succeeded in formatting the manifest files.\n");
            Checks::exit_success(VCPKG_LINE_INFO);
        }
    }
}
