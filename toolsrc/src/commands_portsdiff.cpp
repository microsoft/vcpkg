#include "pch.h"
#include "vcpkg_Commands.h"
#include "vcpkg_System.h"
#include "vcpkg_Maps.h"
#include "SourceParagraph.h"
#include "vcpkg_Environment.h"
#include "Paragraphs.h"

namespace vcpkg::Commands::PortsDiff
{
    static void do_print_name_and_version(const std::vector<std::string>& ports_to_print, const std::map<std::string, std::string>& names_and_versions)
    {
        for (const std::string& name : ports_to_print)
        {
            const std::string& version = names_and_versions.at(name);
            System::println("%-20s %-16s", name, version);
        }
    }

    static void do_print_name_and_previous_version_and_current_version(const std::vector<std::string>& ports_to_print,
                                                                       const std::map<std::string, std::string>& previous_names_and_versions,
                                                                       const std::map<std::string, std::string>& current_names_and_versions)
    {
        for (const std::string& name : ports_to_print)
        {
            const std::string& previous_version = previous_names_and_versions.at(name);
            const std::string& current_version = current_names_and_versions.at(name);
            System::println("%-20s %-16s -> %s", name, previous_version, current_version);
        }
    }

    static std::map<std::string, std::string> read_ports_from_commit(const vcpkg_paths& paths, const std::wstring& git_commit_id)
    {
        const fs::path& git_exe = paths.get_git_exe();
        const fs::path dot_git_dir = paths.root / ".git";
        const std::wstring ports_dir_name_as_string = paths.ports.filename().native();
        const fs::path temp_checkout_path = paths.root / Strings::wformat(L"%s-%s", ports_dir_name_as_string, git_commit_id);
        fs::create_directory(temp_checkout_path);
        const std::wstring checkout_this_dir = Strings::wformat(LR"(.\%s)", ports_dir_name_as_string); // Must be relative to the root of the repository

        const std::wstring cmd = Strings::wformat(LR"("%s" --git-dir="%s" --work-tree="%s" checkout %s -f -q -- %s %s & "%s" reset >NUL)",
                                                  git_exe.native(),
                                                  dot_git_dir.native(),
                                                  temp_checkout_path.native(),
                                                  git_commit_id,
                                                  checkout_this_dir,
                                                  L".vcpkg-root",
                                                  git_exe.native());
        System::cmd_execute_clean(cmd);
        const std::vector<SourceParagraph> source_paragraphs = Paragraphs::load_all_ports(temp_checkout_path / ports_dir_name_as_string);
        const std::map<std::string, std::string> names_and_versions = Paragraphs::extract_port_names_and_versions(source_paragraphs);
        fs::remove_all(temp_checkout_path);
        return names_and_versions;
    }

    static void check_commit_exists(const fs::path& git_exe, const std::wstring& git_commit_id)
    {
        static const std::string VALID_COMMIT_OUTPUT = "commit\n";

        const std::wstring cmd = Strings::wformat(LR"("%s" cat-file -t %s 2>NUL)", git_exe.native(), git_commit_id);
        const System::exit_code_and_output output = System::cmd_execute_and_capture_output(cmd);
        Checks::check_exit(output.output == VALID_COMMIT_OUTPUT, "Invalid commit id %s", Strings::utf16_to_utf8(git_commit_id));
    }

    void perform_and_exit(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths)
    {
        static const std::string example = Strings::format("The argument should be a branch/tag/hash to checkout.\n%s", Commands::Help::create_example_string("portsdiff mybranchname"));
        args.check_min_arg_count(1, example);
        args.check_max_arg_count(2, example);
        args.check_and_get_optional_command_arguments({});

        const fs::path& git_exe = paths.get_git_exe();

        const std::wstring git_commit_id_for_previous_snapshot = Strings::utf8_to_utf16(args.command_arguments.at(0));
        const std::wstring git_commit_id_for_current_snapshot = args.command_arguments.size() < 2 ? L"HEAD" : Strings::utf8_to_utf16(args.command_arguments.at(1));

        check_commit_exists(git_exe, git_commit_id_for_current_snapshot);
        check_commit_exists(git_exe, git_commit_id_for_previous_snapshot);

        const std::map<std::string, std::string> current_names_and_versions = read_ports_from_commit(paths, git_commit_id_for_current_snapshot);
        const std::map<std::string, std::string> previous_names_and_versions = read_ports_from_commit(paths, git_commit_id_for_previous_snapshot);

        // Already sorted, so set_difference can work on std::vector too
        std::vector<std::string> current_ports = Maps::extract_keys(current_names_and_versions);
        std::vector<std::string> previous_ports = Maps::extract_keys(previous_names_and_versions);

        std::vector<std::string> added_ports;
        std::set_difference(
            current_ports.cbegin(), current_ports.cend(),
            previous_ports.cbegin(), previous_ports.cend(),
            std::back_inserter(added_ports));

        if (!added_ports.empty())
        {
            System::println("\nThe following %d ports were added:\n", added_ports.size());
            do_print_name_and_version(added_ports, current_names_and_versions);
        }

        std::vector<std::string> removed_ports;
        std::set_difference(
            previous_ports.cbegin(), previous_ports.cend(),
            current_ports.cbegin(), current_ports.cend(),
            std::back_inserter(removed_ports));

        if (!removed_ports.empty())
        {
            System::println("\nThe following %d ports were removed:\n", removed_ports.size());
            do_print_name_and_version(removed_ports, previous_names_and_versions);
        }

        std::vector<std::string> potentially_updated_ports;
        std::set_intersection(
            current_ports.cbegin(), current_ports.cend(),
            previous_ports.cbegin(), previous_ports.cend(),
            std::back_inserter(potentially_updated_ports));

        std::vector<std::string> updated_ports;
        std::copy_if(potentially_updated_ports.cbegin(), potentially_updated_ports.cend(), std::back_inserter(updated_ports),
                     [&](const std::string& port) -> bool
                     {
                         return current_names_and_versions.at(port) != previous_names_and_versions.at(port);
                     }
        );

        if (!updated_ports.empty())
        {
            System::println("\nThe following %d ports were updated:\n", updated_ports.size());
            do_print_name_and_previous_version_and_current_version(updated_ports, previous_names_and_versions, current_names_and_versions);
        }

        if (added_ports.empty() && removed_ports.empty() && updated_ports.empty())
        {
            System::println("There were no changes in the ports between the two commits.");
        }

        exit(EXIT_SUCCESS);
    }
}
