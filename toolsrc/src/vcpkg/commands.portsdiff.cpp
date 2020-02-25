#include "pch.h"

#include <vcpkg/commands.h>
#include <vcpkg/help.h>
#include <vcpkg/paragraphs.h>
#include <vcpkg/versiont.h>

#include <vcpkg/base/sortedvector.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/base/util.h>

namespace vcpkg::Commands::PortsDiff
{
    struct UpdatedPort
    {
        static bool compare_by_name(const UpdatedPort& left, const UpdatedPort& right)
        {
            return left.port < right.port;
        }

        std::string port;
        VersionDiff version_diff;
    };

    template<class T>
    struct SetElementPresence
    {
        static SetElementPresence create(std::vector<T> left, std::vector<T> right)
        {
            // TODO: This can be done with one pass instead of three passes
            SetElementPresence output;
            std::set_difference(
                left.cbegin(), left.cend(), right.cbegin(), right.cend(), std::back_inserter(output.only_left));
            std::set_intersection(
                left.cbegin(), left.cend(), right.cbegin(), right.cend(), std::back_inserter(output.both));
            std::set_difference(
                right.cbegin(), right.cend(), left.cbegin(), left.cend(), std::back_inserter(output.only_right));

            return output;
        }

        std::vector<T> only_left;
        std::vector<T> both;
        std::vector<T> only_right;
    };

    static std::vector<UpdatedPort> find_updated_ports(
        const std::vector<std::string>& ports,
        const std::map<std::string, VersionT>& previous_names_and_versions,
        const std::map<std::string, VersionT>& current_names_and_versions)
    {
        std::vector<UpdatedPort> output;
        for (const std::string& name : ports)
        {
            const VersionT& previous_version = previous_names_and_versions.at(name);
            const VersionT& current_version = current_names_and_versions.at(name);
            if (previous_version == current_version)
            {
                continue;
            }

            output.push_back({name, VersionDiff(previous_version, current_version)});
        }

        return output;
    }

    static void do_print_name_and_version(const std::vector<std::string>& ports_to_print,
                                          const std::map<std::string, VersionT>& names_and_versions)
    {
        for (const std::string& name : ports_to_print)
        {
            const VersionT& version = names_and_versions.at(name);
            System::printf("    - %-14s %-16s\n", name, version);
        }
    }

    static std::map<std::string, VersionT> read_ports_from_commit(const VcpkgPaths& paths,
                                                                  const std::string& git_commit_id)
    {
        std::error_code ec;
        auto& fs = paths.get_filesystem();
        const fs::path& git_exe = paths.get_tool_exe(Tools::GIT);
        const fs::path dot_git_dir = paths.root / ".git";
        const std::string ports_dir_name_as_string = paths.ports.filename().u8string();
        const fs::path temp_checkout_path =
            paths.root / Strings::format("%s-%s", ports_dir_name_as_string, git_commit_id);
        fs.create_directory(temp_checkout_path, ec);
        const auto checkout_this_dir =
            Strings::format(R"(.\%s)", ports_dir_name_as_string); // Must be relative to the root of the repository

        const std::string cmd = Strings::format(R"("%s" --git-dir="%s" --work-tree="%s" checkout %s -f -q -- %s %s)",
                                                git_exe.u8string(),
                                                dot_git_dir.u8string(),
                                                temp_checkout_path.u8string(),
                                                git_commit_id,
                                                checkout_this_dir,
                                                ".vcpkg-root");
        System::cmd_execute_and_capture_output(cmd, System::get_clean_environment());
        System::cmd_execute_and_capture_output(Strings::format(R"("%s" reset)", git_exe.u8string()),
                                               System::get_clean_environment());
        const auto all_ports =
            Paragraphs::load_all_ports(paths.get_filesystem(), temp_checkout_path / ports_dir_name_as_string);
        std::map<std::string, VersionT> names_and_versions;
        for (auto&& port : all_ports)
            names_and_versions.emplace(port->core_paragraph->name, port->core_paragraph->version);
        fs.remove_all(temp_checkout_path, VCPKG_LINE_INFO);
        return names_and_versions;
    }

    static void check_commit_exists(const fs::path& git_exe, const std::string& git_commit_id)
    {
        static const std::string VALID_COMMIT_OUTPUT = "commit\n";

        const auto cmd = Strings::format(R"("%s" cat-file -t %s)", git_exe.u8string(), git_commit_id);
        const System::ExitCodeAndOutput output = System::cmd_execute_and_capture_output(cmd);
        Checks::check_exit(
            VCPKG_LINE_INFO, output.output == VALID_COMMIT_OUTPUT, "Invalid commit id %s", git_commit_id);
    }

    const CommandStructure COMMAND_STRUCTURE = {
        Strings::format("The argument should be a branch/tag/hash to checkout.\n%s",
                        Help::create_example_string("portsdiff mybranchname")),
        1,
        2,
        {},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        Util::unused(args.parse_arguments(COMMAND_STRUCTURE));

        const fs::path& git_exe = paths.get_tool_exe(Tools::GIT);

        const std::string git_commit_id_for_previous_snapshot = args.command_arguments.at(0);
        const std::string git_commit_id_for_current_snapshot =
            args.command_arguments.size() < 2 ? "HEAD" : args.command_arguments.at(1);

        check_commit_exists(git_exe, git_commit_id_for_current_snapshot);
        check_commit_exists(git_exe, git_commit_id_for_previous_snapshot);

        const std::map<std::string, VersionT> current_names_and_versions =
            read_ports_from_commit(paths, git_commit_id_for_current_snapshot);
        const std::map<std::string, VersionT> previous_names_and_versions =
            read_ports_from_commit(paths, git_commit_id_for_previous_snapshot);

        // Already sorted, so set_difference can work on std::vector too
        const std::vector<std::string> current_ports = Util::extract_keys(current_names_and_versions);
        const std::vector<std::string> previous_ports = Util::extract_keys(previous_names_and_versions);

        const SetElementPresence<std::string> setp =
            SetElementPresence<std::string>::create(current_ports, previous_ports);

        const std::vector<std::string>& added_ports = setp.only_left;
        if (!added_ports.empty())
        {
            System::printf("\nThe following %zd ports were added:\n", added_ports.size());
            do_print_name_and_version(added_ports, current_names_and_versions);
        }

        const std::vector<std::string>& removed_ports = setp.only_right;
        if (!removed_ports.empty())
        {
            System::printf("\nThe following %zd ports were removed:\n", removed_ports.size());
            do_print_name_and_version(removed_ports, previous_names_and_versions);
        }

        const std::vector<std::string>& common_ports = setp.both;
        const std::vector<UpdatedPort> updated_ports =
            find_updated_ports(common_ports, previous_names_and_versions, current_names_and_versions);

        if (!updated_ports.empty())
        {
            System::printf("\nThe following %zd ports were updated:\n", updated_ports.size());
            for (const UpdatedPort& p : updated_ports)
            {
                System::printf("    - %-14s %-16s\n", p.port, p.version_diff.to_string());
            }
        }

        if (added_ports.empty() && removed_ports.empty() && updated_ports.empty())
        {
            System::print2("There were no changes in the ports between the two commits.\n");
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
