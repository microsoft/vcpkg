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
        };

        const System::ExitCodeAndOutput run_git_command_inner(const VcpkgPaths& paths,
                                                              const fs::path& dot_git_directory,
                                                              const fs::path& working_directory,
                                                              const std::string& cmd)
        {
            const fs::path& git_exe = paths.get_tool_exe(Tools::GIT);

            System::CmdLineBuilder builder;
            builder.path_arg(git_exe)
                .string_arg(Strings::concat("--git-dir=", fs::u8string(dot_git_directory)))
                .string_arg(Strings::concat("--work-tree=", fs::u8string(working_directory)));
            const std::string full_cmd = Strings::concat(builder.extract(), " ", cmd);

            const auto output = System::cmd_execute_and_capture_output(full_cmd);
            return output;
        }

        const System::ExitCodeAndOutput run_git_command(const VcpkgPaths& paths, const std::string& cmd)
        {
            const fs::path& work_dir = paths.root;
            const fs::path dot_git_dir = paths.root / ".git";

            return run_git_command_inner(paths, dot_git_dir, work_dir, cmd);
        }

        bool is_date(const std::string& version_string)
        {
            std::regex re("^([0-9]{4,}[-][0-9]{2}[-][0-9]{2})$");
            return std::regex_match(version_string, re);
        }

        std::pair<std::string, int> clean_version_string(const std::string& version_string,
                                                         int port_version,
                                                         bool from_manifest)
        {
            // Manifest files and ports that use the `Port-Version` field are assumed to have a clean version string
            // already.
            if (from_manifest || port_version > 0)
            {
                return std::make_pair(version_string, port_version);
            }

            std::string clean_version = version_string;
            int clean_port_version = 0;

            const auto index = version_string.find_last_of('-');
            if (index != std::string::npos)
            {
                // Very lazy check to keep date versions untouched
                if (!is_date(version_string))
                {
                    auto maybe_port_version = version_string.substr(index + 1);
                    clean_version.resize(index);

                    try
                    {
                        clean_port_version = std::stoi(maybe_port_version);
                    }
                    catch (std::exception&)
                    {
                        // If not convertible to int consider last fragment as part of version string
                        clean_version = version_string;
                    }
                }
            }

            return std::make_pair(clean_version, clean_port_version);
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
                    // TODO: Get clean version name and port version
                    const auto version_string = scf->core_paragraph->version;
                    const auto clean_version =
                        clean_version_string(version_string, scf->core_paragraph->port_version, is_manifest);

                    // SCF to HistoryVersion
                    return HistoryVersion{
                        port_name,
                        git_tree,
                        commit_id,
                        commit_date,
                        Strings::concat(clean_version.first, "#", std::to_string(clean_version.second)),
                        clean_version.first,
                        clean_version.second};
                }
            }

            return nullopt;
        }

        vcpkg::Optional<HistoryVersion> get_version_from_commit(const VcpkgPaths& paths,
                                                                const std::string& commit_id,
                                                                const std::string& commit_date,
                                                                const std::string& port_name)
        {
            const std::string rev_parse_cmd = Strings::format("rev-parse %s:ports/%s", commit_id, port_name);
            auto rev_parse_output = run_git_command(paths, rev_parse_cmd);
            if (rev_parse_output.exit_code == 0)
            {
                // Remove newline character
                const auto git_tree = Strings::trim(std::move(rev_parse_output.output));

                // Do we have a manifest file?
                const std::string manifest_cmd = Strings::format(R"(show %s:vcpkg.json)", git_tree, port_name);
                auto manifest_output = run_git_command(paths, manifest_cmd);
                if (manifest_output.exit_code == 0)
                {
                    return get_version_from_text(
                        manifest_output.output, git_tree, commit_id, commit_date, port_name, true);
                }

                const std::string cmd = Strings::format(R"(show %s:CONTROL)", git_tree, commit_id, port_name);
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
            System::CmdLineBuilder builder;
            builder.string_arg("log");
            builder.string_arg("--format=%H %cd");
            builder.string_arg("--date=short");
            builder.string_arg("--left-only");
            builder.string_arg("--"); // Begin pathspec
            builder.string_arg(Strings::format("ports/%s/.", port_name));
            const auto output = run_git_command(paths, builder.extract());

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
                // NOTE: Uncomment this code if you're looking for edge cases to patch in the generation.
                //       Otherwise, x-history simply skips "bad" versions, which is OK behavior.
                // else
                //{
                //    Checks::exit_with_message(VCPKG_LINE_INFO, "Failed to get version from %s:%s",
                //    commit_date_pair.first, port_name);
                //}
            }
            return ret;
        }
    }

    const CommandStructure COMMAND_STRUCTURE = {
        create_example_string("history <port>"),
        1,
        1,
        {},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        const ParsedArguments options = args.parse_arguments(COMMAND_STRUCTURE);

        std::string port_name = args.command_arguments.at(0);
        std::vector<HistoryVersion> versions = read_versions_from_log(paths, port_name);

        if (args.output_json())
        {
            Json::Array versions_json;
            for (auto&& version : versions)
            {
                Json::Object object;
                object.insert("git-tree", Json::Value::string(version.git_tree));
                object.insert("version-string", Json::Value::string(version.version));
                object.insert("port-version", Json::Value::integer(version.port_version));
                versions_json.push_back(std::move(object));
            }

            Json::Object root;
            root.insert("versions", versions_json);

            auto json_string = Json::stringify(root, vcpkg::Json::JsonStyle::with_spaces(2));
            System::printf("%s\n", json_string);
        }
        else
        {
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
