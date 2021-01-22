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

#include <algorithm>

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

    Optional<ToWrite> read_manifest(Files::Filesystem& fs, const fs::path& manifest_path)
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

    Optional<ToWrite> read_control_file(Files::Filesystem& fs, const fs::path& control_path)
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
        auto scf_res = SourceControlFile::parse_control_file(fs::u8string(control_path),
                                                             std::move(paragraphs).value_or_exit(VCPKG_LINE_INFO));
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
            Checks::exit_maybe_upgrade(VCPKG_LINE_INFO,
                                       R"(
=== Serialized manifest file ===
%s
)",
                                       Json::stringify(res, {}));
        }

        auto check_scf = std::move(check).value_or_exit(VCPKG_LINE_INFO);
        if (*check_scf != data.scf)
        {
            Checks::exit_maybe_upgrade(
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

    static const auto CONTROL_name = fs::u8path("CONTROL");
    static const auto vcpkg_json_name = fs::u8path("vcpkg.json");

    Optional<ToWrite> read_input_file(Files::Filesystem& fs, const fs::path& resolved_path)
    {
        if (resolved_path.filename() == CONTROL_name)
        {
            return read_control_file(fs, resolved_path);
        }

        return read_manifest(fs, resolved_path);
    }

    void add_write(std::vector<std::string>& errors,
                   std::vector<ToWrite>& to_write,
                   Optional<ToWrite>&& this_manifest,
                   const fs::path& resolved_path)
    {
        if (this_manifest.get())
        {
            to_write.push_back(std::move(this_manifest).value_or_exit(VCPKG_LINE_INFO));
        }
        else
        {
            errors.push_back(Strings::concat("Failed to parse ", fs::u8string(resolved_path)));
        }
    }

    std::string format_both_manifest_and_control_error(StringView port_name)
    {
        return Strings::concat("Both a manifest file and a CONTROL file exist in port ", port_name, ".");
    }
}

namespace vcpkg::Commands::FormatManifest
{
    ExpectedS<fs::path> resolve_format_manifest_input(StringView input,
                                                      const fs::path& original_cwd,
                                                      const fs::path& ports_base,
                                                      const Files::ITestFileExists& filesystem)
    {
        auto p = fs::u8path(input);
        if (p.is_absolute())
        {
            if (filesystem.exists(p, ignore_errors))
            {
                return std::move(p);
            }

            return {Strings::concat(input, " not found.")};
        }

        {
            auto as_absolute = Files::combine(original_cwd, p);
            if (filesystem.exists(as_absolute, ignore_errors))
            {
                return std::move(as_absolute);
            }
        } // destroy as_absolute

        if (std::none_of(input.begin(), input.end(), fs::is_slash))
        {
            // nonexistent single element relative path, try to interpret as port name
            const auto port_path = Files::combine(ports_base, p);
            auto control_path = Files::combine(port_path, CONTROL_name);
            auto vcpkg_json_path = Files::combine(port_path, vcpkg_json_name);
            const bool control_exists = filesystem.exists(control_path, ignore_errors);
            const bool vcpkg_json_exists = filesystem.exists(vcpkg_json_path, ignore_errors);
            if (control_exists)
            {
                if (vcpkg_json_exists)
                {
                    return {format_both_manifest_and_control_error(input)};
                }

                return {std::move(control_path)};
            }
            else if (vcpkg_json_exists)
            {
                return {std::move(vcpkg_json_path)};
            }
        }

        return {Strings::concat(input, " could not be interpreted as a port name, CONTROL path, or manifest path.")};
    }

    static constexpr StringLiteral OPTION_ALL = "all";
    static constexpr StringLiteral OPTION_CONVERT_CONTROL = "convert-control";

    const CommandSwitch FORMAT_SWITCHES[] = {
        {OPTION_ALL, "Format all ports' manifest files."},
        {OPTION_CONVERT_CONTROL, "Convert CONTROL files to manifest files; requires --all."},
    };

    const CommandStructure COMMAND_STRUCTURE = {
        create_example_string(R"###(format-manifest name-of-port path/to/vcpkg.json path/to/CONTROL)###"),
        0,
        SIZE_MAX,
        {FORMAT_SWITCHES, {}, {}},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        auto parsed_args = args.parse_arguments(COMMAND_STRUCTURE);

        auto& fs = paths.get_filesystem();

        const bool format_all = Util::Sets::contains(parsed_args.switches, OPTION_ALL);
        const bool convert_control = Util::Sets::contains(parsed_args.switches, OPTION_CONVERT_CONTROL);

        if (!format_all && convert_control)
        {
            System::print2(System::Color::warning, R"(Warning: '--convert-control' has no effect without '--all'.
    Explicit paths to CONTROL files, or names of ports using CONTROL files
    are always converted.)");
        }

        if (!format_all && args.command_arguments.empty())
        {
            Checks::exit_with_message(VCPKG_LINE_INFO, R"(Error: No targets to format. Please pass --all,
    or a list of port names, CONTROL files, and/or manifests to format or convert.)");
        }

        std::vector<std::string> errors;
        std::vector<ToWrite> to_write;
        for (const auto& arg : args.command_arguments)
        {
            auto maybe_resolved =
                resolve_format_manifest_input(arg, paths.original_cwd, paths.builtin_ports_directory(), fs);
            if (!maybe_resolved)
            {
                errors.push_back(std::move(maybe_resolved).error());
                continue;
            }

            const auto& resolved = maybe_resolved.value_or_exit(VCPKG_LINE_INFO);
            add_write(errors, to_write, read_input_file(fs, resolved), resolved);
        }

        if (format_all)
        {
            for (const auto& dir : fs::directory_iterator(paths.builtin_ports_directory()))
            {
                const auto& port_path = dir.path();
                auto control_path = port_path / CONTROL_name;
                auto manifest_path = port_path / vcpkg_json_name;
                auto manifest_exists = fs.exists(manifest_path, ignore_errors);
                auto control_exists = fs.exists(control_path, ignore_errors);
                if (control_exists)
                {
                    if (manifest_exists)
                    {
                        errors.push_back(format_both_manifest_and_control_error(fs::u8string(port_path.filename())));
                    }
                    else if (convert_control)
                    {
                        add_write(errors, to_write, read_control_file(fs, control_path), control_path);
                    }
                }
                else if (manifest_exists)
                {
                    add_write(errors, to_write, read_manifest(fs, manifest_path), manifest_path);
                }
            }
        }

        for (auto const& el : to_write)
        {
            write_file(fs, el);
        }

        if (errors.empty())
        {
            System::print2("Succeeded in formatting all manifests.\n");
            Checks::exit_success(VCPKG_LINE_INFO);
        }

        for (const std::string& error : errors)
        {
            System::print2(System::Color::error, error, "\n");
        }

        Checks::exit_fail(VCPKG_LINE_INFO);
    }

    void FormatManifestCommand::perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const
    {
        FormatManifest::perform_and_exit(args, paths);
    }
}
