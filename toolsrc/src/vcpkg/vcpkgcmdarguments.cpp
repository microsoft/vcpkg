#include "pch.h"

#include <vcpkg/base/system.h>
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
            System::println(System::Color::error, "Error: expected value after %s", option_name);
            Metrics::g_metrics.lock()->track_property("error", "error option name");
            Help::print_usage();
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        if (option_field != nullptr)
        {
            System::println(System::Color::error, "Error: %s specified multiple times", option_name);
            Metrics::g_metrics.lock()->track_property("error", "error option specified multiple times");
            Help::print_usage();
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        option_field = std::make_unique<std::string>(*arg_begin);
    }

    static void parse_switch(bool new_setting, const std::string& option_name, Optional<bool>& option_field)
    {
        if (option_field && option_field != new_setting)
        {
            System::println(System::Color::error, "Error: conflicting values specified for --%s", option_name);
            Metrics::g_metrics.lock()->track_property("error", "error conflicting switches");
            Help::print_usage();
            Checks::exit_fail(VCPKG_LINE_INFO);
        }
        option_field = new_setting;
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
                    System::println(System::Color::error, "Error: Could not open response file %s", arg);
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
                // make argument case insensitive
                auto& f = std::use_facet<std::ctype<char>>(std::locale());
                f.tolower(&arg[0], &arg[0] + arg.size());
                // command switch
                if (arg == "--vcpkg-root")
                {
                    ++arg_begin;
                    parse_value(arg_begin, arg_end, "--vcpkg-root", args.vcpkg_root_dir);
                    continue;
                }
                if (arg == "--triplet")
                {
                    ++arg_begin;
                    parse_value(arg_begin, arg_end, "--triplet", args.triplet);
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
                    args.optional_command_arguments.emplace(arg.substr(0, eq_pos), arg.substr(eq_pos + 1));
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
                System::println(System::Color::error,
                                "Error: '%s' requires %u arguments, but %u were provided.",
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
                System::println(System::Color::error,
                                "Error: '%s' requires at least %u arguments, but %u were provided",
                                this->command,
                                command_structure.minimum_arity,
                                actual_arg_count);
                failed = true;
            }
            if (actual_arg_count > command_structure.maximum_arity)
            {
                System::println(System::Color::error,
                                "Error: '%s' requires at most %u arguments, but %u were provided",
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
                    System::println(
                        System::Color::error, "Error: The option '%s' does not accept an argument.", option.name);
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
                    System::println(
                        System::Color::error, "Error: The option '%s' must be passed an argument.", option.name);
                    failed = true;
                }
                else
                {
                    output.settings.emplace(option.name, it->second.value_or_exit(VCPKG_LINE_INFO));
                    options_copy.erase(it);
                }
            }
        }

        if (!options_copy.empty())
        {
            System::println(System::Color::error, "Unknown option(s) for command '%s':", this->command);
            for (auto&& option : options_copy)
            {
                System::println("    %s", option.first);
            }
            System::println();
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
            System::println("%s", command_structure.example_text);
        }

        System::println("Options:");
        for (auto&& option : command_structure.options.switches)
        {
            System::println("    %-40s %s", option.name, option.short_help_text);
        }
        for (auto&& option : command_structure.options.settings)
        {
            System::println("    %-40s %s", (option.name + "=..."), option.short_help_text);
        }
        System::println("    %-40s %s", "--triplet <t>", "Set the default triplet for unqualified packages");
        System::println("    %-40s %s",
                        "--vcpkg-root <path>",
                        "Specify the vcpkg directory to use instead of current directory or tool directory");
    }
}
