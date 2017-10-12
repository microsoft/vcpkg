#include "pch.h"

#include "Paragraphs.h"
#include "metrics.h"
#include "vcpkg_Commands.h"
#include "vcpkg_System.h"
#include "vcpkglib.h"

namespace vcpkg::Commands::Autocomplete
{
    std::vector<std::string> autocomplete_install(
        const std::vector<std::unique_ptr<SourceControlFile>>& source_paragraphs, const std::string& start_with)
    {
        std::vector<std::string> results;
        const auto& istartswith = Strings::case_insensitive_ascii_starts_with;

        for (const auto& source_control_file : source_paragraphs)
        {
            auto&& sp = *source_control_file->core_paragraph;

            if (istartswith(sp.name, start_with))
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
        const auto& istartswith = Strings::case_insensitive_ascii_starts_with;

        for (const auto& installed_package : installed_packages)
        {
            const auto sp = installed_package->package.displayname();

            if (istartswith(sp, start_with))
            {
                results.push_back(sp);
            }
        }
        return results;
    }

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        Metrics::g_metrics.lock()->set_send_metrics(false);

        if (args.command_arguments.size() != 1)
        {
            Checks::exit_success(VCPKG_LINE_INFO);
        }

        const std::string to_autocomplete = args.command_arguments.at(0);
        const std::vector<std::string> tokens = Strings::split(to_autocomplete, " ");
        if (tokens.size() == 1)
        {
            const std::string requested_command = tokens[0];

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

            if (valid_commands.size() == 1)
            {
                System::println(valid_commands[0] + " ");
            }
            else
            {
                System::println(Strings::join("\n", valid_commands));
            }

            Checks::exit_success(VCPKG_LINE_INFO);
        }

        if (tokens.size() == 2)
        {
            const std::string requested_command = tokens[0];
            const std::string start_with = tokens[1];
            std::vector<std::string> results;
            if (requested_command == "install")
            {
                auto sources_and_errors = Paragraphs::try_load_all_ports(paths.get_filesystem(), paths.ports);
                auto& source_paragraphs = sources_and_errors.paragraphs;

                results = autocomplete_install(source_paragraphs, start_with);
            }
            else if (requested_command == "remove")
            {
                const StatusParagraphs status_db = database_load_check(paths);
                const std::vector<StatusParagraph*> installed_packages = get_installed_ports(status_db);
                results = autocomplete_remove(installed_packages, start_with);
            }

            System::println(Strings::join("\n", results));
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
