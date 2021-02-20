#include <vcpkg/base/system.print.h>

#include <vcpkg/commands.autocomplete.h>
#include <vcpkg/commands.edit.h>
#include <vcpkg/commands.integrate.h>
#include <vcpkg/commands.upgrade.h>
#include <vcpkg/install.h>
#include <vcpkg/metrics.h>
#include <vcpkg/paragraphs.h>
#include <vcpkg/remove.h>
#include <vcpkg/vcpkgcmdarguments.h>
#include <vcpkg/vcpkglib.h>

namespace vcpkg::Commands::Autocomplete
{
    [[noreturn]] static void output_sorted_results_and_exit(const LineInfo& line_info,
                                                            std::vector<std::string>&& results)
    {
        const SortedVector<std::string> sorted_results(results);
        System::print2(Strings::join("\n", sorted_results), '\n');

        Checks::exit_success(line_info);
    }

    static std::vector<std::string> combine_port_with_triplets(const std::string& port,
                                                               const std::vector<std::string>& triplets)
    {
        return Util::fmap(triplets,
                          [&](const std::string& triplet) { return Strings::format("%s:%s", port, triplet); });
    }

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        Metrics::g_metrics.lock()->set_send_metrics(false);
        const std::string to_autocomplete = Strings::join(" ", args.command_arguments);
        const std::vector<std::string> tokens = Strings::split(to_autocomplete, ' ');

        std::smatch match;

        // Handles vcpkg <command>
        if (std::regex_match(to_autocomplete, match, std::regex{R"###(^(\S*)$)###"}))
        {
            const std::string requested_command = match[1].str();

            // First try public commands
            std::vector<std::string> public_commands = {"install",
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
                                                        "upgrade"};

            Util::erase_remove_if(public_commands, [&](const std::string& s) {
                return !Strings::case_insensitive_ascii_starts_with(s, requested_command);
            });

            if (!public_commands.empty())
            {
                output_sorted_results_and_exit(VCPKG_LINE_INFO, std::move(public_commands));
            }

            // If no public commands match, try private commands
            std::vector<std::string> private_commands = {
                "build",
                "buildexternal",
                "ci",
                "depend-info",
                "env",
                "import",
                "portsdiff",
            };

            Util::erase_remove_if(private_commands, [&](const std::string& s) {
                return !Strings::case_insensitive_ascii_starts_with(s, requested_command);
            });

            output_sorted_results_and_exit(VCPKG_LINE_INFO, std::move(private_commands));
        }

        // Handles vcpkg install package:<triplet>
        if (std::regex_match(to_autocomplete, match, std::regex{R"###(^install(.*|)\s([^:]+):(\S*)$)###"}))
        {
            const auto port_name = match[2].str();
            const auto triplet_prefix = match[3].str();

            // TODO: Support autocomplete for ports in --overlay-ports
            auto maybe_port =
                Paragraphs::try_load_port(paths.get_filesystem(), paths.builtin_ports_directory() / port_name);
            if (maybe_port.error())
            {
                Checks::exit_success(VCPKG_LINE_INFO);
            }

            std::vector<std::string> triplets = paths.get_available_triplets_names();
            Util::erase_remove_if(triplets, [&](const std::string& s) {
                return !Strings::case_insensitive_ascii_starts_with(s, triplet_prefix);
            });

            auto result = combine_port_with_triplets(port_name, triplets);

            output_sorted_results_and_exit(VCPKG_LINE_INFO, std::move(result));
        }

        struct CommandEntry
        {
            constexpr CommandEntry(const CStringView& name, const CStringView& regex, const CommandStructure& structure)
                : name(name), regex(regex), structure(structure)
            {
            }

            CStringView name;
            CStringView regex;
            const CommandStructure& structure;
        };

        static constexpr CommandEntry COMMANDS[] = {
            CommandEntry{"install", R"###(^install\s(.*\s|)(\S*)$)###", Install::COMMAND_STRUCTURE},
            CommandEntry{"edit", R"###(^edit\s(.*\s|)(\S*)$)###", Edit::COMMAND_STRUCTURE},
            CommandEntry{"remove", R"###(^remove\s(.*\s|)(\S*)$)###", Remove::COMMAND_STRUCTURE},
            CommandEntry{"integrate", R"###(^integrate(\s+)(\S*)$)###", Integrate::COMMAND_STRUCTURE},
            CommandEntry{"upgrade", R"###(^upgrade(\s+)(\S*)$)###", Upgrade::COMMAND_STRUCTURE},
        };

        for (auto&& command : COMMANDS)
        {
            if (std::regex_match(to_autocomplete, match, std::regex{command.regex.c_str()}))
            {
                const auto prefix = match[2].str();
                std::vector<std::string> results;

                const bool is_option = Strings::case_insensitive_ascii_starts_with(prefix, "-");
                if (is_option)
                {
                    results = Util::fmap(command.structure.options.switches, [](const CommandSwitch& s) -> std::string {
                        return Strings::format("--%s", s.name.to_string());
                    });

                    auto settings = Util::fmap(command.structure.options.settings,
                                               [](auto&& s) { return Strings::format("--%s", s.name); });
                    results.insert(results.end(), settings.begin(), settings.end());

                    auto multisettings = Util::fmap(command.structure.options.multisettings,
                                                    [](auto&& s) { return Strings::format("--%s", s.name); });
                    results.insert(results.end(), multisettings.begin(), multisettings.end());
                }
                else
                {
                    if (command.structure.valid_arguments != nullptr)
                    {
                        results = command.structure.valid_arguments(paths);
                    }
                }

                Util::erase_remove_if(results, [&](const std::string& s) {
                    return !Strings::case_insensitive_ascii_starts_with(s, prefix);
                });

                if (command.name == "install" && results.size() == 1 && !is_option)
                {
                    const auto port_at_each_triplet =
                        combine_port_with_triplets(results[0], paths.get_available_triplets_names());
                    Util::Vectors::append(&results, port_at_each_triplet);
                }

                output_sorted_results_and_exit(VCPKG_LINE_INFO, std::move(results));
            }
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }

    void AutocompleteCommand::perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const
    {
        Autocomplete::perform_and_exit(args, paths);
    }
}
