#include <vcpkg/base/checks.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/json.h>
#include <vcpkg/base/system.debug.h>

#include <vcpkg/commands.format-manifest.h>
#include <vcpkg/paragraphs.h>
#include <vcpkg/portfileprovider.h>
#include <vcpkg/sourceparagraph.h>
#include <vcpkg/vcpkgcmdarguments.h>
#include <vcpkg/vcpkgpaths.h>

namespace
{
    using namespace vcpkg;

    struct ToWrite
    {
        SourceControlFile scf;
        fs::path file_to_write;
        fs::path original_path;
        std::string original_source;
    };

    Optional<ToWrite> read_manifest(Files::Filesystem& fs, fs::path&& manifest_path)
    {
        auto path_string = fs::u8string(manifest_path);
        Debug::print("Reading ", path_string, "\n");
        auto contents = fs.read_contents(manifest_path, VCPKG_LINE_INFO);
        auto parsed_json_opt = Json::parse(contents, manifest_path);
        if (!parsed_json_opt.has_value())
        {
            System::printf(
                System::Color::error, "Failed to parse %s: %s\n", path_string, parsed_json_opt.error()->format());
            return nullopt;
        }

        const auto& parsed_json = parsed_json_opt.value_or_exit(VCPKG_LINE_INFO).first;
        if (!parsed_json.is_object())
        {
            System::printf(System::Color::error, "The file %s is not an object\n", path_string);
            return nullopt;
        }

        auto parsed_json_obj = parsed_json.object();

        auto scf = SourceControlFile::parse_manifest_file(manifest_path, parsed_json_obj);
        if (!scf.has_value())
        {
            System::printf(System::Color::error, "Failed to parse manifest file: %s\n", path_string);
            print_error_message(scf.error());
            return nullopt;
        }

        return ToWrite{
            std::move(*scf.value_or_exit(VCPKG_LINE_INFO)),
            manifest_path,
            manifest_path,
            std::move(contents),
        };
    }

    Optional<ToWrite> read_control_file(Files::Filesystem& fs, fs::path&& control_path)
    {
        std::error_code ec;
        auto control_path_string = fs::u8string(control_path);
        Debug::print("Reading ", control_path_string, "\n");

        auto manifest_path = control_path.parent_path();
        manifest_path /= fs::u8path("vcpkg.json");

        auto contents = fs.read_contents(control_path, VCPKG_LINE_INFO);
        auto paragraphs = Paragraphs::parse_paragraphs(contents, control_path_string);

        if (!paragraphs)
        {
            System::printf(System::Color::error,
                           "Failed to read paragraphs from %s: %s\n",
                           control_path_string,
                           paragraphs.error());
            return {};
        }
        auto scf_res =
            SourceControlFile::parse_control_file(control_path, std::move(paragraphs).value_or_exit(VCPKG_LINE_INFO));
        if (!scf_res)
        {
            System::printf(System::Color::error, "Failed to parse control file: %s\n", control_path_string);
            print_error_message(scf_res.error());
            return {};
        }

        return ToWrite{
            std::move(*scf_res.value_or_exit(VCPKG_LINE_INFO)),
            manifest_path,
            control_path,
            std::move(contents),
        };
    }

    void write_file(Files::Filesystem& fs, const ToWrite& data)
    {
        auto original_path_string = fs::u8string(data.original_path);
        auto file_to_write_string = fs::u8string(data.file_to_write);
        if (data.file_to_write == data.original_path)
        {
            Debug::print("Formatting ", file_to_write_string, "\n");
        }
        else
        {
            Debug::print("Converting ", file_to_write_string, " -> ", original_path_string, "\n");
        }
        auto res = serialize_manifest(data.scf);

        auto check = SourceControlFile::parse_manifest_file(fs::path{}, res);
        if (!check)
        {
            System::printf(System::Color::error,
                           R"([correctness check] Failed to parse serialized manifest file of %s
Please open an issue at https://github.com/microsoft/vcpkg, with the following output:
Error:)",
                           data.scf.core_paragraph->name);
            print_error_message(check.error());
            Checks::exit_with_message(VCPKG_LINE_INFO,
                                      R"(
=== Serialized manifest file ===
%s
)",
                                      Json::stringify(res, {}));
        }

        auto check_scf = std::move(check).value_or_exit(VCPKG_LINE_INFO);
        if (*check_scf != data.scf)
        {
            Checks::exit_with_message(
                VCPKG_LINE_INFO,
                R"([correctness check] The serialized manifest SCF was different from the original SCF.
Please open an issue at https://github.com/microsoft/vcpkg, with the following output:

=== Original File ===
%s

=== Serialized File ===
%s

=== Original SCF ===
%s

=== Serialized SCF ===
%s
)",
                data.original_source,
                Json::stringify(res, {}),
                Json::stringify(serialize_debug_manifest(data.scf), {}),
                Json::stringify(serialize_debug_manifest(*check_scf), {}));
        }

        // the manifest scf is correct
        std::error_code ec;
        fs.write_contents(data.file_to_write, Json::stringify(res, {}), ec);
        if (ec)
        {
            Checks::exit_with_message(
                VCPKG_LINE_INFO, "Failed to write manifest file %s: %s\n", file_to_write_string, ec.message());
        }
        if (data.original_path != data.file_to_write)
        {
            fs.remove(data.original_path, ec);
            if (ec)
            {
                Checks::exit_with_message(
                    VCPKG_LINE_INFO, "Failed to remove control file %s: %s\n", original_path_string, ec.message());
            }
        }
    }
}

namespace vcpkg::Commands::FormatManifest
{
    static constexpr StringLiteral OPTION_ALL = "all";
    static constexpr StringLiteral OPTION_CONVERT_CONTROL = "convert-control";

    const CommandSwitch FORMAT_SWITCHES[] = {
        {OPTION_ALL, "Format all ports' manifest files."},
        {OPTION_CONVERT_CONTROL, "Convert CONTROL files to manifest files."},
    };

    const CommandStructure COMMAND_STRUCTURE = {
        create_example_string(R"###(format-manifest --all)###"),
        0,
        SIZE_MAX,
        {FORMAT_SWITCHES, {}, {}},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        auto parsed_args = args.parse_arguments(COMMAND_STRUCTURE);

        auto& fs = paths.get_filesystem();
        bool has_error = false;

        const bool format_all = Util::Sets::contains(parsed_args.switches, OPTION_ALL);
        const bool convert_control = Util::Sets::contains(parsed_args.switches, OPTION_CONVERT_CONTROL);

        if (!format_all && convert_control)
        {
            System::print2(System::Color::warning, R"(format-manifest was passed '--convert-control' without '--all'.
    This doesn't do anything:
    we will automatically convert all control files passed explicitly.)");
        }

        if (!format_all && args.command_arguments.empty())
        {
            Checks::exit_with_message(
                VCPKG_LINE_INFO,
                "No files to format; please pass either --all, or the explicit files to format or convert.");
        }

        std::vector<ToWrite> to_write;

        const auto add_file = [&to_write, &has_error](Optional<ToWrite>&& opt) {
            if (auto t = opt.get())
                to_write.push_back(std::move(*t));
            else
                has_error = true;
        };

        for (const auto& arg : args.command_arguments)
        {
            auto path = fs::u8path(arg);
            if (path.is_relative())
            {
                path = paths.original_cwd / path;
            }

            if (path.filename() == fs::u8path("CONTROL"))
            {
                add_file(read_control_file(fs, std::move(path)));
            }
            else
            {
                add_file(read_manifest(fs, std::move(path)));
            }
        }

        if (format_all)
        {
            for (const auto& dir : fs::directory_iterator(paths.ports))
            {
                auto control_path = dir.path() / fs::u8path("CONTROL");
                auto manifest_path = dir.path() / fs::u8path("vcpkg.json");
                auto manifest_exists = fs.exists(manifest_path);
                auto control_exists = fs.exists(control_path);

                Checks::check_exit(VCPKG_LINE_INFO,
                                   !manifest_exists || !control_exists,
                                   "Both a manifest file and a CONTROL file exist in port directory: %s",
                                   fs::u8string(dir.path()));

                if (manifest_exists)
                {
                    add_file(read_manifest(fs, std::move(manifest_path)));
                }
                if (convert_control && control_exists)
                {
                    add_file(read_control_file(fs, std::move(control_path)));
                }
            }
        }

        for (auto const& el : to_write)
        {
            write_file(fs, el);
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

    void FormatManifestCommand::perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const
    {
        FormatManifest::perform_and_exit(args, paths);
    }
}
