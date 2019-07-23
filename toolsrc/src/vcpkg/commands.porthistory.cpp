#include "pch.h"

#include <vcpkg/commands.h>
#include <vcpkg/help.h>
#include <vcpkg/paragraphs.h>
#include <vcpkg/versiont.h>

#include <vcpkg/base/sortedvector.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/base/util.h>

namespace vcpkg::Commands::PortHistory
{
    struct PortControlVersion
    {
        std::string commit_id;
        std::string version;
        std::string date;
    };

    static std::vector<PortControlVersion> read_versions_from_log(const VcpkgPaths& paths, const std::string& port_name)
    {
        const fs::path& git_exe = paths.get_tool_exe(Tools::GIT);
        const fs::path dot_git_dir = paths.root / ".git";

        const std::string cmd = Strings::format(
            R"("%s" --git-dir="%s" log --cc -w -L "^/Version/",2:ports/%s/CONTROL "--pretty=format:commit %%H%%ndate %%cd" --date=short)",
            git_exe.u8string(),
            dot_git_dir.u8string(),
            port_name);
        auto output = System::cmd_execute_and_capture_output(cmd);

        Checks::check_exit(VCPKG_LINE_INFO,
            output.exit_code == 0, 
            "Failed to fetch git log history for port %s", 
            port_name);

        std::string commit_id;
        std::string date;
        std::vector<PortControlVersion> ret;
        for (auto&& line : Strings::split(output.output, "\n"))
        {
            if (Strings::starts_with(line, "commit "))
            {
                commit_id = line.substr(7);
            }
            else if (Strings::starts_with(line, "date "))
            {
                date = line.substr(5);
            }
            else if (Strings::starts_with(line, "+Version: "))
            {
                std::string new_version = line.substr(10);
                ret.emplace_back(PortControlVersion{ commit_id, new_version, date });
            }
        }

        return ret;
    }

    const CommandStructure COMMAND_STRUCTURE = {
        "The argument should be a port name.\n",
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
        System::print2("             Version          Date     Commit\n");
        for (auto&& version : versions)
        {
            System::printf("%20.20s    %s     %s\n", version.version, version.date, version.commit_id);
        }
        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
