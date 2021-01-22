#include <vcpkg/base/json.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/base/util.h>

#include <vcpkg/commands.porthistory.h>
#include <vcpkg/help.h>
#include <vcpkg/paragraphs.h>
#include <vcpkg/tools.h>
#include <vcpkg/vcpkgcmdarguments.h>
#include <vcpkg/vcpkgpaths.h>
#include <vcpkg/versiondeserializers.h>
#include <vcpkg/versions.h>

namespace vcpkg::Commands::PortHistory
{
    namespace
    {
        struct HistoryVersion
        {
            std::string port_name;
            std::string git_tree;
            std::string commit_id;
            std::string commit_date;
            std::string version_string;
            std::string version;
            int port_version;
            Versions::Scheme scheme;
        };

        const System::ExitCodeAndOutput run_git_command_inner(const VcpkgPaths& paths,
                                                              const fs::path& dot_git_directory,
                                                              const fs::path& working_directory,
                                                              const System::Command& cmd)
        {
            const fs::path& git_exe = paths.get_tool_exe(Tools::GIT);

            auto full_cmd = System::Command(git_exe)
                                .string_arg(Strings::concat("--git-dir=", fs::u8string(dot_git_directory)))
                                .string_arg(Strings::concat("--work-tree=", fs::u8string(working_directory)))
                                .raw_arg(cmd.command_line());

            auto output = System::cmd_execute_and_capture_output(full_cmd);
            return output;
        }

        const System::ExitCodeAndOutput run_git_command(const VcpkgPaths& paths, const System::Command& cmd)
        {
            const fs::path& work_dir = paths.root;
            const fs::path dot_git_dir = paths.root / ".git";

            return run_git_command_inner(paths, dot_git_dir, work_dir, cmd);
        }

        vcpkg::Optional<HistoryVersion> get_version_from_text(const std::string& text,
                                                              const std::string& git_tree,
                                                              const std::string& commit_id,
                                                              const std::string& commit_date,
                                                              const std::string& port_name,
                                                              bool is_manifest)
        {
            auto res = Paragraphs::try_load_port_text(text, Strings::concat(commit_id, ":", port_name), is_manifest);
            if (const auto& maybe_scf = res.get())
            {
                if (const auto& scf = maybe_scf->get())
                {
                    auto version = scf->core_paragraph->version;
                    auto port_version = scf->core_paragraph->port_version;
                    auto scheme = scf->core_paragraph->version_scheme;
                    return HistoryVersion{
                        port_name,
                        git_tree,
                        commit_id,
                        commit_date,
                        Strings::concat(version, "#", port_version),
                        version,
                        port_version,
                        scheme,
                    };
                }
            }

            return nullopt;
        }

        vcpkg::Optional<HistoryVersion> get_version_from_commit(const VcpkgPaths& paths,
                                                                const std::string& commit_id,
                                                                const std::string& commit_date,
                                                                const std::string& port_name)
        {
            auto rev_parse_cmd =
                System::Command("rev-parse").string_arg(Strings::concat(commit_id, ":ports/", port_name));
            auto rev_parse_output = run_git_command(paths, rev_parse_cmd);
            if (rev_parse_output.exit_code == 0)
            {
                // Remove newline character
                const auto git_tree = Strings::trim(std::move(rev_parse_output.output));

                // Do we have a manifest file?
                auto manifest_cmd = System::Command("show").string_arg(Strings::concat(git_tree, ":vcpkg.json"));
                auto manifest_output = run_git_command(paths, manifest_cmd);
                if (manifest_output.exit_code == 0)
                {
                    return get_version_from_text(
                        manifest_output.output, git_tree, commit_id, commit_date, port_name, true);
                }

                auto cmd = System::Command("show").string_arg(Strings::concat(git_tree, ":CONTROL"));
                auto control_output = run_git_command(paths, cmd);

                if (control_output.exit_code == 0)
                {
                    return get_version_from_text(
                        control_output.output, git_tree, commit_id, commit_date, port_name, false);
                }
            }

            return nullopt;
        }

        std::vector<HistoryVersion> read_versions_from_log(const VcpkgPaths& paths, const std::string& port_name)
        {
            // log --format="%H %cd" --date=short --left-only -- ports/{port_name}/.
            System::Command builder;
            builder.string_arg("log");
            builder.string_arg("--format=%H %cd");
            builder.string_arg("--date=short");
            builder.string_arg("--left-only");
            builder.string_arg("--"); // Begin pathspec
            builder.string_arg(Strings::format("ports/%s/.", port_name));
            const auto output = run_git_command(paths, builder);

            auto commits = Util::fmap(
                Strings::split(output.output, '\n'), [](const std::string& line) -> auto {
                    auto parts = Strings::split(line, ' ');
                    return std::make_pair(parts[0], parts[1]);
                });

            std::vector<HistoryVersion> ret;
            std::string last_version;
            for (auto&& commit_date_pair : commits)
            {
                auto maybe_version =
                    get_version_from_commit(paths, commit_date_pair.first, commit_date_pair.second, port_name);
                if (maybe_version.has_value())
                {
                    const auto version = maybe_version.value_or_exit(VCPKG_LINE_INFO);

                    // Keep latest port with the current version string
                    if (last_version != version.version_string)
                    {
                        last_version = version.version_string;
                        ret.emplace_back(version);
                    }
                }
            }
            return ret;
        }
    }

    static constexpr StringLiteral OPTION_OUTPUT_FILE = "output";

    static const CommandSetting HISTORY_SETTINGS[] = {
        {OPTION_OUTPUT_FILE, "Write output to a file"},
    };

    const CommandStructure COMMAND_STRUCTURE = {
        create_example_string("history <port>"),
        1,
        1,
        {{}, {HISTORY_SETTINGS}, {}},
        nullptr,
    };

    static Optional<std::string> maybe_lookup(std::unordered_map<std::string, std::string> const& m,
                                              std::string const& key)
    {
        const auto it = m.find(key);
        if (it != m.end()) return it->second;
        return nullopt;
    }

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        const ParsedArguments parsed_args = args.parse_arguments(COMMAND_STRUCTURE);
        auto maybe_output_file = maybe_lookup(parsed_args.settings, OPTION_OUTPUT_FILE);

        std::string port_name = args.command_arguments.at(0);
        std::vector<HistoryVersion> versions = read_versions_from_log(paths, port_name);

        if (args.output_json())
        {
            Json::Array versions_json;
            for (auto&& version : versions)
            {
                Json::Object object;
                object.insert("git-tree", Json::Value::string(version.git_tree));

                serialize_schemed_version(object, version.scheme, version.version, version.port_version, true);
                versions_json.push_back(std::move(object));
            }

            Json::Object root;
            root.insert("versions", versions_json);

            auto json_string = Json::stringify(root, vcpkg::Json::JsonStyle::with_spaces(2));

            if (maybe_output_file.has_value())
            {
                auto output_file_path = fs::u8path(maybe_output_file.value_or_exit(VCPKG_LINE_INFO));
                auto& fs = paths.get_filesystem();
                fs.write_contents(output_file_path, json_string, VCPKG_LINE_INFO);
            }
            else
            {
                System::printf("%s\n", json_string);
            }
        }
        else
        {
            if (maybe_output_file.has_value())
            {
                System::printf(
                    System::Color::warning, "Warning: Option `--$s` requires `--x-json` switch.", OPTION_OUTPUT_FILE);
            }

            System::print2("             version          date    vcpkg commit\n");
            for (auto&& version : versions)
            {
                System::printf("%20.20s    %s    %s\n", version.version_string, version.commit_date, version.commit_id);
            }
        }
        Checks::exit_success(VCPKG_LINE_INFO);
    }

    void PortHistoryCommand::perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const
    {
        PortHistory::perform_and_exit(args, paths);
    }
}
