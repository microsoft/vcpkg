#include "pch.h"

#include <vcpkg/base/system.print.h>
#include <vcpkg/commands.h>
#include <vcpkg/globalstate.h>
#include <vcpkg/help.h>
#include <vcpkg/metrics.h>
#include <vcpkg/vcpkgcmdarguments.h>

namespace vcpkg
{
    static void parse_value(const std::string* arg_begin,
                            const std::string* arg_end,
                            const std::string& option_name,
                            std::unique_ptr<std::string>& option_field)
    {
        if (arg_begin == arg_end)
        {
            System::print2(System::Color::error, "Error: expected value after ", option_name, '\n');
            Metrics::g_metrics.lock()->track_property("error", "error option name");
            Help::print_usage();
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        if (option_field != nullptr)
        {
            System::print2(System::Color::error, "Error: ", option_name, " specified multiple times\n");
            Metrics::g_metrics.lock()->track_property("error", "error option specified multiple times");
            Help::print_usage();
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        option_field = std::make_unique<std::string>(*arg_begin);
    }

    static void parse_cojoined_value(std::string new_value,
                                     const std::string& option_name,
                                     std::unique_ptr<std::string>& option_field)
    {
        if (nullptr != option_field)
        {
            System::printf(System::Color::error, "Error: %s specified multiple times\n", option_name);
            Metrics::g_metrics.lock()->track_property("error", "error option specified multiple times");
            Help::print_usage();
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        option_field = std::make_unique<std::string>(std::move(new_value));
    }

    static void parse_switch(bool new_setting, const std::string& option_name, Optional<bool>& option_field)
    {
        if (option_field && option_field != new_setting)
        {
            System::print2(System::Color::error, "Error: conflicting values specified for --", option_name, '\n');
            Metrics::g_metrics.lock()->track_property("error", "error conflicting switches");
            Help::print_usage();
            Checks::exit_fail(VCPKG_LINE_INFO);
        }
        option_field = new_setting;
    }

    static void parse_cojoined_multivalue(std::string new_value,
                                          const std::string& option_name,
                                          std::unique_ptr<std::vector<std::string>>& option_field)
    {
        if (new_value.empty())
        {
            System::print2(System::Color::error, "Error: expected value after ", option_name, '\n');
            Metrics::g_metrics.lock()->track_property("error", "error option name");
            Help::print_usage();
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        if (!option_field)
        {
            option_field = std::make_unique<std::vector<std::string>>();
        }
        option_field->emplace_back(std::move(new_value));
    }

    static void parse_cojoined_multivalue(std::string new_value,
                                          const std::string& option_name,
                                          std::vector<std::string>& option_field)
    {
        if (new_value.empty())
        {
            System::print2(System::Color::error, "Error: expected value after ", option_name, '\n');
            Metrics::g_metrics.lock()->track_property("error", "error option name");
            Help::print_usage();
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        option_field.emplace_back(std::move(new_value));
    }

    VcpkgCmdArguments VcpkgCmdArguments::create_from_command_line(const int argc,
                                                                  const CommandLineCharType* const* const argv)
    {
        std::vector<std::string> v;
        for (int i = 1; i < argc; ++i)
        {
            std::string arg;
#if defined(_WIN32)
            arg = Strings::to_utf8(argv[i]);
#else
            arg = argv[i];
#endif
            // Response file?
            if (arg.size() > 0 && arg[0] == '@')
            {
                arg.erase(arg.begin());
                const auto& fs = Files::get_real_filesystem();
                auto lines = fs.read_lines(fs::u8path(arg));
                if (!lines.has_value())
                {
                    System::print2(System::Color::error, "Error: Could not open response file ", arg, '\n');
                    Checks::exit_fail(VCPKG_LINE_INFO);
                }
                std::copy(lines.get()->begin(), lines.get()->end(), std::back_inserter(v));
            }
            else
            {
                v.emplace_back(std::move(arg));
            }
        }

        return VcpkgCmdArguments::create_from_arg_sequence(v.data(), v.data() + v.size());
    }

    VcpkgCmdArguments VcpkgCmdArguments::create_from_arg_sequence(const std::string* arg_begin,
                                                                  const std::string* arg_end)
    {
        VcpkgCmdArguments args;

        for (; arg_begin != arg_end; ++arg_begin)
        {
            std::string arg = *arg_begin;

            if (arg.empty())
            {
                continue;
            }

            if (arg[0] == '-' && arg[1] != '-')
            {
                Metrics::g_metrics.lock()->track_property("error", "error short options are not supported");
                Checks::exit_with_message(VCPKG_LINE_INFO, "Error: short options are not supported: %s", arg);
            }

            if (arg[0] == '-' && arg[1] == '-')
            {
                // make argument case insensitive before the first =
                auto& f = std::use_facet<std::ctype<char>>(std::locale());
                auto first_eq = std::find(std::begin(arg), std::end(arg), '=');
                f.tolower(&arg[0], &arg[0] + (first_eq - std::begin(arg)));
                // command switch
                if (arg == "--vcpkg-root")
                {
                    ++arg_begin;
                    parse_value(arg_begin, arg_end, "--vcpkg-root", args.vcpkg_root_dir);
                    continue;
                }
                if (Strings::starts_with(arg, "--x-scripts-root="))
                {
                    parse_cojoined_value(
                        arg.substr(sizeof("--x-scripts-root=") - 1), "--x-scripts-root", args.scripts_root_dir);
                    continue;
                }
                if (arg == "--triplet")
                {
                    ++arg_begin;
                    parse_value(arg_begin, arg_end, "--triplet", args.triplet);
                    continue;
                }
                if (Strings::starts_with(arg, "--overlay-ports="))
                {
                    parse_cojoined_multivalue(
                        arg.substr(sizeof("--overlay-ports=") - 1), "--overlay-ports", args.overlay_ports);
                    continue;
                }
                if (Strings::starts_with(arg, "--overlay-triplets="))
                {
                    parse_cojoined_multivalue(
                        arg.substr(sizeof("--overlay-triplets=") - 1), "--overlay-triplets", args.overlay_triplets);
                    continue;
                }
                if (Strings::starts_with(arg, "--x-binarysource="))
                {
                    parse_cojoined_multivalue(
                        arg.substr(sizeof("--x-binarysource=") - 1), "--x-binarysource", args.binarysources);
                    continue;
                }
                if (arg == "--debug")
                {
                    parse_switch(true, "debug", args.debug);
                    continue;
                }
                if (arg == "--sendmetrics")
                {
                    parse_switch(true, "sendmetrics", args.sendmetrics);
                    continue;
                }
                if (arg == "--printmetrics")
                {
                    parse_switch(true, "printmetrics", args.printmetrics);
                    continue;
                }
                if (arg == "--no-sendmetrics")
                {
                    parse_switch(false, "sendmetrics", args.sendmetrics);
                    continue;
                }
                if (arg == "--no-printmetrics")
                {
                    parse_switch(false, "printmetrics", args.printmetrics);
                    continue;
                }
                if (arg == "--featurepackages")
                {
                    parse_switch(true, "featurepackages", args.featurepackages);
                    continue;
                }
                if (arg == "--no-featurepackages")
                {
                    parse_switch(false, "featurepackages", args.featurepackages);
                    continue;
                }
                if (arg == "--binarycaching")
                {
                    parse_switch(true, "binarycaching", args.binarycaching);
                    continue;
                }
                if (arg == "--no-binarycaching")
                {
                    parse_switch(false, "binarycaching", args.binarycaching);
                    continue;
                }

                const auto eq_pos = arg.find('=');
                if (eq_pos != std::string::npos)
                {
                    const auto& key = arg.substr(0, eq_pos);
                    const auto& value = arg.substr(eq_pos + 1);

                    auto it = args.optional_command_arguments.find(key);
                    if (args.optional_command_arguments.end() == it)
                    {
                        args.optional_command_arguments.emplace(key, std::vector<std::string>{value});
                    }
                    else
                    {
                        if (auto* maybe_values = it->second.get())
                        {
                            maybe_values->emplace_back(value);
                        }
                    }
                }
                else
                {
                    args.optional_command_arguments.emplace(arg, nullopt);
                }
                continue;
            }

            if (args.command.empty())
            {
                args.command = arg;
            }
            else
            {
                args.command_arguments.push_back(arg);
            }
        }

        return args;
    }

    ParsedArguments VcpkgCmdArguments::parse_arguments(const CommandStructure& command_structure) const
    {
        bool failed = false;
        ParsedArguments output;

        const size_t actual_arg_count = command_arguments.size();

        if (command_structure.minimum_arity == command_structure.maximum_arity)
        {
            if (actual_arg_count != command_structure.minimum_arity)
            {
                System::printf(System::Color::error,
                               "Error: '%s' requires %u arguments, but %u were provided.\n",
                               this->command,
                               command_structure.minimum_arity,
                               actual_arg_count);
                failed = true;
            }
        }
        else
        {
            if (actual_arg_count < command_structure.minimum_arity)
            {
                System::printf(System::Color::error,
                               "Error: '%s' requires at least %u arguments, but %u were provided\n",
                               this->command,
                               command_structure.minimum_arity,
                               actual_arg_count);
                failed = true;
            }
            if (actual_arg_count > command_structure.maximum_arity)
            {
                System::printf(System::Color::error,
                               "Error: '%s' requires at most %u arguments, but %u were provided\n",
                               this->command,
                               command_structure.maximum_arity,
                               actual_arg_count);
                failed = true;
            }
        }

        auto options_copy = this->optional_command_arguments;
        for (auto&& option : command_structure.options.switches)
        {
            const auto it = options_copy.find(option.name);
            if (it != options_copy.end())
            {
                if (it->second.has_value())
                {
                    // Having a string value indicates it was passed like '--a=xyz'
                    System::printf(
                        System::Color::error, "Error: The option '%s' does not accept an argument.\n", option.name);
                    failed = true;
                }
                else
                {
                    output.switches.insert(option.name);
                    options_copy.erase(it);
                }
            }
        }

        for (auto&& option : command_structure.options.settings)
        {
            const auto it = options_copy.find(option.name);
            if (it != options_copy.end())
            {
                if (!it->second.has_value())
                {
                    // Not having a string value indicates it was passed like '--a'
                    System::printf(
                        System::Color::error, "Error: The option '%s' must be passed an argument.\n", option.name);
                    failed = true;
                }
                else
                {
                    const auto& value = it->second.value_or_exit(VCPKG_LINE_INFO);
                    if (value.front().empty())
                    {
                        // Fail when not given a value, e.g.: "vcpkg install sqlite3 --additional-ports="
                        System::printf(
                            System::Color::error, "Error: The option '%s' must be passed an argument.\n", option.name);
                        failed = true;
                    }
                    else
                    {
                        output.settings.emplace(option.name, value.front());
                        options_copy.erase(it);
                    }
                }
            }
        }

        for (auto&& option : command_structure.options.multisettings)
        {
            const auto it = options_copy.find(option.name);
            if (it != options_copy.end())
            {
                if (!it->second.has_value())
                {
                    // Not having a string value indicates it was passed like '--a'
                    System::printf(
                        System::Color::error, "Error: The option '%s' must be passed an argument.\n", option.name);
                    failed = true;
                }
                else
                {
                    const auto& value = it->second.value_or_exit(VCPKG_LINE_INFO);
                    for (auto&& v : value)
                    {
                        if (v.empty())
                        {
                            System::printf(System::Color::error,
                                           "Error: The option '%s' must be passed an argument.\n",
                                           option.name);
                            failed = true;
                        }
                        else
                        {
                            output.multisettings[option.name].emplace_back(v);
                        }
                    }
                    options_copy.erase(it);
                }
            }
        }

        if (!options_copy.empty())
        {
            System::printf(System::Color::error, "Unknown option(s) for command '%s':\n", this->command);
            for (auto&& option : options_copy)
            {
                System::print2("    '", option.first, "'\n");
            }
            System::print2("\n");
            failed = true;
        }

        if (failed)
        {
            display_usage(command_structure);
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        return output;
    }

    void display_usage(const CommandStructure& command_structure)
    {
        if (!command_structure.example_text.empty())
        {
            System::print2(command_structure.example_text, "\n");
        }

        System::print2("Options:\n");
        Help::HelpTableFormatter table;
        for (auto&& option : command_structure.options.switches)
        {
            table.format(option.name, option.short_help_text);
        }
        for (auto&& option : command_structure.options.settings)
        {
            table.format((option.name + "=..."), option.short_help_text);
        }
        for (auto&& option : command_structure.options.multisettings)
        {
            table.format((option.name + "=..."), option.short_help_text);
        }
        table.format("--triplet <t>", "Set the default triplet for unqualified packages");
        table.format("--overlay-ports=<path>", "Specify directories to be used when searching for ports");
        table.format("--overlay-triplets=<path>", "Specify directories containing triplets files");
        table.format("--vcpkg-root <path>",
                     "Specify the vcpkg directory to use instead of current directory or tool directory");
        table.format("--x-scripts-root=<path>",
                     "(Experimental) Specify the scripts directory to use instead of default vcpkg scripts directory");
        System::print2(table.m_str);
    }
}
