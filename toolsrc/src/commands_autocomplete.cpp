#include "pch.h"

#include "Paragraphs.h"
#include "metrics.h"
#include "vcpkg_Commands.h"
#include "vcpkg_System.h"
#include "vcpkglib.h"
#include <regex>

namespace vcpkg::Commands::Autocomplete
{
    std::vector<std::string> autocomplete_install(
        const std::vector<std::unique_ptr<SourceControlFile>>& source_paragraphs, const std::string& start_with)
    {
        std::vector<std::string> results;

        for (const auto& source_control_file : source_paragraphs)
        {
            auto&& sp = *source_control_file->core_paragraph;

            if (Strings::case_insensitive_ascii_starts_with(sp.name, start_with))
            {
                results.push_back(sp.name);
            }
        }
        return results;
    }

    std::vector<std::string> autocomplete_remove(std::vector<StatusParagraph*> installed_packages,
                                                 const std::string& start_with)
    {
        std::vector<std::string> results;

        for (const auto& installed_package : installed_packages)
        {
            const auto sp = installed_package->package.displayname();

            if (Strings::case_insensitive_ascii_starts_with(sp, start_with))
            {
                results.push_back(sp);
            }
        }
        return results;
    }

    [[noreturn]] static void output_sorted_results_and_exit(const LineInfo& line_info,
                                                            std::vector<std::string>&& results)
    {
        const SortedVector<std::string> sorted_results(results);
        System::println(Strings::join("\n", sorted_results));
        Checks::exit_success(line_info);
    }

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        Metrics::g_metrics.lock()->set_send_metrics(false);
        const std::string to_autocomplete = Strings::join(" ", args.command_arguments);
        const std::vector<std::string> tokens = Strings::split(to_autocomplete, " ");

        std::smatch match;

        // Handles vcpkg <command>
        if (std::regex_match(to_autocomplete, match, std::regex{R"###(^(\S*)$)###"}))
        {
            const std::string requested_command = match[1].str();

            std::vector<std::string> valid_commands = {"install",
                                                       "search",
                                                       "remove",
                                                       "list",
                                                       "update",
                                                       "hash",
                                                       "help",
                                                       "integrate",
                                                       "export",
                                                       "edit",
                                                       "create",
                                                       "owns",
                                                       "cache",
                                                       "version",
                                                       "contact"};

            Util::unstable_keep_if(valid_commands, [&](const std::string& s) {
                return Strings::case_insensitive_ascii_starts_with(s, requested_command);
            });

            output_sorted_results_and_exit(VCPKG_LINE_INFO, std::move(valid_commands));
        }

        // Handles vcpkg install <package>
        if (std::regex_match(to_autocomplete, match, std::regex{R"###(^install.* (\S*)$)###"}))
        {
            const std::string start_with = match[1].str();
            auto sources_and_errors = Paragraphs::try_load_all_ports(paths.get_filesystem(), paths.ports);
            auto& source_paragraphs = sources_and_errors.paragraphs;
            output_sorted_results_and_exit(VCPKG_LINE_INFO, autocomplete_install(source_paragraphs, start_with));
        }

        // Handles vcpkg remove <package>
        if (std::regex_match(to_autocomplete, match, std::regex{R"###(^remove.* (\S*)$)###"}))
        {
            const std::string start_with = match[1].str();
            const StatusParagraphs status_db = database_load_check(paths);
            const std::vector<StatusParagraph*> installed_packages = get_installed_ports(status_db);
            output_sorted_results_and_exit(VCPKG_LINE_INFO, autocomplete_remove(installed_packages, start_with));
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
