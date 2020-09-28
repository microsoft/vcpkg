#include <vcpkg/base/json.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/base/util.h>

#include <vcpkg/commands.porthistory.h>
#include <vcpkg/help.h>
#include <vcpkg/tools.h>
#include <vcpkg/vcpkgcmdarguments.h>
#include <vcpkg/vcpkgpaths.h>
#include <vcpkg/versions.h>

namespace vcpkg::Commands::PortHistory
{
    namespace
    {
        constexpr StringLiteral OPTION_JSON = "json";

        constexpr std::array<CommandSwitch, 1> HISTORY_SWITCHES{
            {{OPTION_JSON, "Outputs version history in JSON format"}}};

        struct HistoryVersion
        {
            std::string port_name;
            std::string commit_id;
            std::string commit_date;
            std::string version_string;
            std::string version;
            std::string port_version;
        };

        static System::ExitCodeAndOutput run_git_command(const VcpkgPaths& paths, const std::string& cmd)
        {
            const fs::path& git_exe = paths.get_tool_exe(Tools::GIT);
            const fs::path dot_git_dir = paths.root / ".git";

            const std::string full_cmd =
                Strings::format(R"("%s" --git-dir="%s" %s)", fs::u8string(git_exe), fs::u8string(dot_git_dir), cmd);

            auto output = System::cmd_execute_and_capture_output(full_cmd);
            return output;
        }

        static Json::Object parse_json_object(StringView sv)
        {
            auto json = Json::parse(sv);
            if (auto r = json.get())
            {
                return std::move(r->first.object());
            }
            else
            {
                Checks::exit_with_message(VCPKG_LINE_INFO, json.error()->format());
            }
        }

        static HistoryVersion parse_version_from_manifest(const std::string& text,
                                                          const std::string& port_name,
                                                          const std::string& commit_id,
                                                          const std::string& commit_date)
        {
            auto object = parse_json_object(text);

            auto maybe_version = object.get("version-string");
            auto maybe_port_version = object.get("port-version");

            auto version = maybe_version ? maybe_version->string().to_string() : "0.0.0";
            auto port_version = maybe_port_version ? maybe_port_version->integer() : 0;

            return HistoryVersion{port_name, commit_id, commit_date, version, version, std::to_string(port_version)};
        }

        static HistoryVersion parse_version_from_control(const std::string& text,
                                                         const std::string& port_name,
                                                         const std::string& commit_id,
                                                         const std::string& commit_date)
        {
            const auto version = Strings::find_at_most_one_enclosed(text, "\nVersion: ", "\n");
            const auto port_version = Strings::find_at_most_one_enclosed(text, "\nPort-Version: ", "\n");
            Checks::check_exit(VCPKG_LINE_INFO, version.has_value(), "CONTROL file does not have a 'Version' field");
            auto version_string = version.get()->to_string();

            // Remove trailing \r that sometimes finds its way into CONTROL files
            if (!version_string.empty() && version_string.at(version_string.size() - 1) == '\r')
            {
                version_string.pop_back();
            }

            if (auto pv = port_version.get())
            {
                // We assume CONTROL files using the port_version field have a clean version_string
                return HistoryVersion{port_name, commit_id, "", version_string, version_string, pv->to_string()};
            }
            else
            {
                std::string clean_version = version_string;
                std::string clean_port_version = "0";

                const auto index = version_string.find_last_of('-');
                if (index != std::string::npos)
                {
                    // Very lazy check to keep date versions untouched
                    if (!vcpkg::Versions::VersionString::is_date(version_string))
                    {
                        clean_port_version = version_string.substr(index + 1);
                        clean_version.resize(index);
                    }
                }

                return HistoryVersion{
                    port_name, commit_id, commit_date, version_string, clean_version, clean_port_version};
            }
        }

        static HistoryVersion get_version_from_commit(const VcpkgPaths& paths,
                                                      const std::string& commit_id,
                                                      const std::string& commit_date,
                                                      const std::string& port_name)
        {
            // Do we have a manifest file?
            const std::string manifest_cmd = Strings::format(R"(show %s:ports/%s/vcpkg.json)", commit_id, port_name);
            auto manifest_output = run_git_command(paths, manifest_cmd);
            if (manifest_output.exit_code == 0)
            {
                return parse_version_from_manifest(manifest_output.output, port_name, commit_id, commit_date);
            }
            else
            {
                const std::string cmd = Strings::format(R"(show %s:ports/%s/CONTROL)", commit_id, port_name);
                auto control_output = run_git_command(paths, cmd);
                Checks::check_exit(VCPKG_LINE_INFO,
                                   control_output.exit_code == 0,
                                   "Failed to find manifest or CONTROL file for port %s at %s",
                                   port_name,
                                   commit_id);
                return parse_version_from_control(control_output.output, port_name, commit_id, commit_date);
            }
        }

        static std::vector<HistoryVersion> read_versions_from_log(const VcpkgPaths& paths, const std::string& port_name)
        {
            const std::string cmd =
                Strings::format(R"(log --format="%%H %%cd" --date=short --left-only -- ports/%s/.)", port_name);
            auto output = run_git_command(paths, cmd);

            auto commits = Util::fmap(
                Strings::split(output.output, '\n'), [](const std::string& line) -> auto {
                    auto parts = Strings::split(line, ' ');
                    return std::make_pair(parts[0], parts[1]);
                });

            std::vector<HistoryVersion> ret;
            std::string last_version;
            for (auto&& commit_date_pair : commits)
            {
                auto&& version =
                    get_version_from_commit(paths, commit_date_pair.first, commit_date_pair.second, port_name);
                if (last_version != version.version_string)
                {
                    last_version = version.version_string;
                    ret.emplace_back(version);
                }
            }
            return ret;
        }
    }

    const CommandStructure COMMAND_STRUCTURE = {
        create_example_string("history <port>"),
        1,
        1,
        {HISTORY_SWITCHES},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        const ParsedArguments options = args.parse_arguments(COMMAND_STRUCTURE);

        std::string port_name = args.command_arguments.at(0);
        std::vector<HistoryVersion> versions = read_versions_from_log(paths, port_name);

        if (Util::Sets::contains(options.switches, OPTION_JSON))
        {
            Json::Array versions_json;
            for (auto&& version : versions)
            {
                Json::Object object;
                object.insert("commit_id", Json::Value::string(version.commit_id));
                object.insert("commit_date", Json::Value::string(version.commit_date));
                object.insert("version_string", Json::Value::string(version.version_string));
                object.insert("version", Json::Value::string(version.version));
                object.insert("port_version", Json::Value::string(version.port_version));
                versions_json.push_back(std::move(object));
            }

            Json::Object root;
            root.insert("port", Json::Value::string(port_name));
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
