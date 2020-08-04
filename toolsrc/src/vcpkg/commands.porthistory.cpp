#include "pch.h"

#include <vcpkg/base/system.print.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/base/util.h>

#include <vcpkg/commands.porthistory.h>
#include <vcpkg/help.h>

namespace vcpkg::Commands::PortHistory
{
    struct PortControlVersion
    {
        std::string commit_id;
        std::string version;
        std::string date;
    };

    static System::ExitCodeAndOutput run_git_command(const VcpkgPaths& paths, const std::string& cmd)
    {
        const fs::path& git_exe = paths.get_tool_exe(Tools::GIT);
        const fs::path dot_git_dir = paths.root / ".git";

        const std::string full_cmd =
            Strings::format(R"("%s" --git-dir="%s" %s)", git_exe.u8string(), dot_git_dir.u8string(), cmd);

        auto output = System::cmd_execute_and_capture_output(full_cmd);
        Checks::check_exit(VCPKG_LINE_INFO, output.exit_code == 0, "Failed to run command: %s", full_cmd);
        return output;
    }

    static std::string get_version_from_commit(const VcpkgPaths& paths,
                                               const std::string& commit_id,
                                               const std::string& port_name)
    {
        const std::string cmd = Strings::format(R"(show %s:ports/%s/CONTROL)", commit_id, port_name);
        auto output = run_git_command(paths, cmd);

        const auto version = Strings::find_at_most_one_enclosed(output.output, "\nVersion: ", "\n");
        const auto port_version = Strings::find_at_most_one_enclosed(output.output, "\nPort-Version: ", "\n");
        Checks::check_exit(VCPKG_LINE_INFO, version.has_value(), "CONTROL file does not have a 'Version' field");
        if (auto pv = port_version.get())
        {
            return Strings::format("%s#%s", version.get()->to_string(), pv->to_string());
        }

        return version.get()->to_string();
    }

    static std::vector<PortControlVersion> read_versions_from_log(const VcpkgPaths& paths, const std::string& port_name)
    {
        const std::string cmd =
            Strings::format(R"(log --format="%%H %%cd" --date=short --left-only -- ports/%s/.)", port_name);
        auto output = run_git_command(paths, cmd);

        auto commits = Util::fmap(
            Strings::split(output.output, '\n'), [](const std::string& line) -> auto {
                auto parts = Strings::split(line, ' ');
                return std::make_pair(parts[0], parts[1]);
            });

        std::vector<PortControlVersion> ret;
        std::string last_version;
        for (auto&& commit_date_pair : commits)
        {
            const std::string version = get_version_from_commit(paths, commit_date_pair.first, port_name);
            if (last_version != version)
            {
                ret.emplace_back(PortControlVersion{commit_date_pair.first, version, commit_date_pair.second});
                last_version = version;
            }
        }
        return ret;
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
        Util::unused(args.parse_arguments(COMMAND_STRUCTURE));

        std::string port_name = args.command_arguments.at(0);
        std::vector<PortControlVersion> versions = read_versions_from_log(paths, port_name);
        System::print2("             version          date    vcpkg commit\n");
        for (auto&& version : versions)
        {
            System::printf("%20.20s    %s    %s\n", version.version, version.date, version.commit_id);
        }
        Checks::exit_success(VCPKG_LINE_INFO);
    }

    void PortHistoryCommand::perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const
    {
        PortHistory::perform_and_exit(args, paths);
    }
}
