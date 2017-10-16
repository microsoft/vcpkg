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
            constexpr CommandEntry(const CStringView& regex, const CommandStructure& structure)
                : regex(regex), structure(structure)
            {
            }

            CStringView regex;
            const CommandStructure& structure;
        };
        static constexpr CommandEntry COMMANDS[] = {
            CommandEntry{R"###(^install\s(.*\s|)(\S*)$)###", Install::COMMAND_STRUCTURE},
            CommandEntry{R"###(^edit\s(.*\s|)(\S*)$)###", Edit::COMMAND_STRUCTURE},
            CommandEntry{R"###(^remove\s(.*\s|)(\S*)$)###", Remove::COMMAND_STRUCTURE},
        };

        for (auto&& command : COMMANDS)
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
