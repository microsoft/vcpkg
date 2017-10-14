#include "pch.h"

#include <vcpkg/base/system.h>
#include <vcpkg/commands.h>
#include <vcpkg/install.h>
#include <vcpkg/metrics.h>
#include <vcpkg/paragraphs.h>
#include <vcpkg/remove.h>
#include <vcpkg/vcpkglib.h>

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

            std::vector<std::string> valid_commands = {
                "install",
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
                "contact",
            };

            Util::unstable_keep_if(valid_commands, [&](const std::string& s) {
                return Strings::case_insensitive_ascii_starts_with(s, requested_command);
            });

            output_sorted_results_and_exit(VCPKG_LINE_INFO, std::move(valid_commands));
        }

        struct CommandEntry
        {
            CStringView regex;
            const CommandStructure& structure;
        };
        static constexpr CommandEntry commands[] = {
            {R"###(^install\s(.*\s|)(\S*)$)###", Install::COMMAND_STRUCTURE},
            {R"###(^edit\s(.*\s|)(\S*)$)###", Edit::COMMAND_STRUCTURE},
            {R"###(^remove\s(.*\s|)(\S*)$)###", Remove::COMMAND_STRUCTURE},
        };

        for (auto&& command : commands)
        {
            if (std::regex_match(to_autocomplete, match, std::regex{command.regex.c_str()}))
            {
                auto prefix = match[2].str();
                std::vector<std::string> v;
                if (Strings::case_insensitive_ascii_starts_with(prefix, "-"))
                {
                    v = Util::fmap(command.structure.switches, [](auto&& s) -> std::string { return s; });
                }
                else
                {
                    v = command.structure.valid_arguments(paths);
                }

                Util::unstable_keep_if(
                    v, [&](const std::string& s) { return Strings::case_insensitive_ascii_starts_with(s, prefix); });

                output_sorted_results_and_exit(VCPKG_LINE_INFO, std::move(v));
            }
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
