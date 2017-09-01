#include "pch.h"

#include "Paragraphs.h"
#include "SortedVector.h"
#include "vcpkg_Commands.h"
#include "vcpkg_Maps.h"
#include "vcpkg_System.h"

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
            System::println("%-20s %-16s", name, version);
        }
    }

    static std::map<std::string, VersionT> read_ports_from_commit(const VcpkgPaths& paths,
                                                                  const std::wstring& git_commit_id)
    {
        std::error_code ec;
        auto& fs = paths.get_filesystem();
        const fs::path& git_exe = paths.get_git_exe();
        const fs::path dot_git_dir = paths.root / ".git";
        const std::wstring ports_dir_name_as_string = paths.ports.filename().native();
        const fs::path temp_checkout_path =
            paths.root / Strings::wformat(L"%s-%s", ports_dir_name_as_string, git_commit_id);
        fs.create_directory(temp_checkout_path, ec);
        const std::wstring checkout_this_dir =
            Strings::wformat(LR"(.\%s)", ports_dir_name_as_string); // Must be relative to the root of the repository

        const std::wstring cmd =
            Strings::wformat(LR"("%s" --git-dir="%s" --work-tree="%s" checkout %s -f -q -- %s %s & "%s" reset >NUL)",
                             git_exe.native(),
                             dot_git_dir.native(),
                             temp_checkout_path.native(),
                             git_commit_id,
                             checkout_this_dir,
                             L".vcpkg-root",
                             git_exe.native());
        System::cmd_execute_clean(cmd);
        const std::map<std::string, VersionT> names_and_versions = Paragraphs::load_all_port_names_and_versions(
            paths.get_filesystem(), temp_checkout_path / ports_dir_name_as_string);
        fs.remove_all(temp_checkout_path, ec);
        return names_and_versions;
    }

    static void check_commit_exists(const fs::path& git_exe, const std::wstring& git_commit_id)
    {
        static const std::string VALID_COMMIT_OUTPUT = "commit\n";

        const std::wstring cmd = Strings::wformat(LR"("%s" cat-file -t %s)", git_exe.native(), git_commit_id);
        const System::ExitCodeAndOutput output = System::cmd_execute_and_capture_output(cmd);
        Checks::check_exit(VCPKG_LINE_INFO,
                           output.output == VALID_COMMIT_OUTPUT,
                           "Invalid commit id %s",
                           Strings::to_utf8(git_commit_id));
    }

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        static const std::string EXAMPLE =
            Strings::format("The argument should be a branch/tag/hash to checkout.\n%s",
                            Commands::Help::create_example_string("portsdiff mybranchname"));
        args.check_min_arg_count(1, EXAMPLE);
        args.check_max_arg_count(2, EXAMPLE);
        args.check_and_get_optional_command_arguments({});

        const fs::path& git_exe = paths.get_git_exe();

        const std::wstring git_commit_id_for_previous_snapshot = Strings::to_utf16(args.command_arguments.at(0));
        const std::wstring git_commit_id_for_current_snapshot =
            args.command_arguments.size() < 2 ? L"HEAD" : Strings::to_utf16(args.command_arguments.at(1));

        check_commit_exists(git_exe, git_commit_id_for_current_snapshot);
        check_commit_exists(git_exe, git_commit_id_for_previous_snapshot);

        const std::map<std::string, VersionT> current_names_and_versions =
            read_ports_from_commit(paths, git_commit_id_for_current_snapshot);
        const std::map<std::string, VersionT> previous_names_and_versions =
            read_ports_from_commit(paths, git_commit_id_for_previous_snapshot);

        // Already sorted, so set_difference can work on std::vector too
        const std::vector<std::string> current_ports = Maps::extract_keys(current_names_and_versions);
        const std::vector<std::string> previous_ports = Maps::extract_keys(previous_names_and_versions);

        const SetElementPresence<std::string> setp =
            SetElementPresence<std::string>::create(current_ports, previous_ports);

        const std::vector<std::string>& added_ports = setp.only_left;
        if (!added_ports.empty())
        {
            System::println("\nThe following %d ports were added:\n", added_ports.size());
            do_print_name_and_version(added_ports, current_names_and_versions);
        }

        const std::vector<std::string>& removed_ports = setp.only_right;
        if (!removed_ports.empty())
        {
            System::println("\nThe following %d ports were removed:\n", removed_ports.size());
            do_print_name_and_version(removed_ports, previous_names_and_versions);
        }

        const std::vector<std::string>& common_ports = setp.both;
        const std::vector<UpdatedPort> updated_ports =
            find_updated_ports(common_ports, previous_names_and_versions, current_names_and_versions);

        if (!updated_ports.empty())
        {
            System::println("\nThe following %d ports were updated:\n", updated_ports.size());
            for (const UpdatedPort& p : updated_ports)
            {
                System::println("%-20s %-16s", p.port, p.version_diff.to_string());
            }
        }

        if (added_ports.empty() && removed_ports.empty() && updated_ports.empty())
        {
            System::println("There were no changes in the ports between the two commits.");
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
