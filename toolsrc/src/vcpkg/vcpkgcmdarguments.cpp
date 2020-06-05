#include "pch.h"

#include <vcpkg/base/system.print.h>
#include <vcpkg/commands.h>
#include <vcpkg/globalstate.h>
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
            print_usage();
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        if (option_field != nullptr)
        {
            System::print2(System::Color::error, "Error: ", option_name, " specified multiple times\n");
            Metrics::g_metrics.lock()->track_property("error", "error option specified multiple times");
            print_usage();
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
            print_usage();
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
            print_usage();
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
            print_usage();
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
            print_usage();
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        option_field.emplace_back(std::move(new_value));
    }

    VcpkgCmdArguments VcpkgCmdArguments::create_from_command_line(const Files::Filesystem& fs,
                                                                  const int argc,
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
                if (Strings::starts_with(arg, "--x-buildtrees-root="))
                {
                    parse_cojoined_value(arg.substr(sizeof("--x-buildtrees-root=") - 1),
                                         "--x-buildtrees-root",
                                         args.buildtrees_root_dir);
                    continue;
                }
                if (Strings::starts_with(arg, "--downloads-root="))
                {
                    parse_cojoined_value(
                        arg.substr(sizeof("--downloads-root=") - 1), "--downloads-root", args.downloads_root_dir);
                    continue;
                }
                if (Strings::starts_with(arg, "--x-install-root="))
                {
                    parse_cojoined_value(
                        arg.substr(sizeof("--x-install-root=") - 1), "--x-install-root=", args.install_root_dir);
                    continue;
                }
                if (Strings::starts_with(arg, "--x-packages-root="))
                {
                    parse_cojoined_value(
                        arg.substr(sizeof("--x-packages-root=") - 1), "--x-packages-root=", args.packages_root_dir);
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
                    parse_switch(true, "sendmetrics", args.send_metrics);
                    continue;
                }
                if (arg == "--printmetrics")
                {
                    parse_switch(true, "printmetrics", args.print_metrics);
                    continue;
                }
                if (arg == "--disable-metrics")
                {
                    parse_switch(true, "disable-metrics", args.disable_metrics);
                    continue;
                }
                if (arg == "--no-sendmetrics")
                {
                    parse_switch(false, "no-sendmetrics", args.send_metrics);
                    continue;
                }
                if (arg == "--no-printmetrics")
                {
                    parse_switch(false, "no-printmetrics", args.print_metrics);
                    continue;
                }
                if (arg == "--no-disable-metrics")
                {
                    parse_switch(false, "no-disable-metrics", args.disable_metrics);
                    continue;
                }
                if (arg == "--featurepackages")
                {
                    parse_switch(true, "featurepackages", args.feature_packages);
                    continue;
                }
                if (arg == "--no-featurepackages")
                {
                    parse_switch(false, "featurepackages", args.feature_packages);
                    continue;
                }
                if (arg == "--binarycaching")
                {
                    parse_switch(true, "binarycaching", args.binary_caching);
                    continue;
                }
                if (arg == "--no-binarycaching")
                {
                    parse_switch(false, "no-binarycaching", args.binary_caching);
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
            print_usage(command_structure);
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        return output;
    }

    void print_usage()
    {
        HelpTableFormatter table;
        table.header("Commands");
        table.format("vcpkg search [pat]", "Search for packages available to be built");
        table.format("vcpkg install <pkg>...", "Install a package");
        table.format("vcpkg remove <pkg>...", "Uninstall a package");
        table.format("vcpkg remove --outdated", "Uninstall all out-of-date packages");
        table.format("vcpkg list", "List installed packages");
        table.format("vcpkg update", "Display list of packages for updating");
        table.format("vcpkg upgrade", "Rebuild all outdated packages");
        table.format("vcpkg x-history <pkg>", "(Experimental) Shows the history of CONTROL versions of a package");
        table.format("vcpkg hash <file> [alg]", "Hash a file by specific algorithm, default SHA512");
        table.format("vcpkg help topics", "Display the list of help topics");
        table.format("vcpkg help <topic>", "Display help for a specific topic");
        table.blank();
        Commands::Integrate::append_helpstring(table);
        table.blank();
        table.format("vcpkg export <pkg>... [opt]...", "Exports a package");
        table.format("vcpkg edit <pkg>",
                     "Open up a port for editing (uses " + format_environment_variable("EDITOR") + ", default 'code')");
        table.format("vcpkg import <pkg>", "Import a pre-built library");
        table.format("vcpkg create <pkg> <url> [archivename]", "Create a new package");
        table.format("vcpkg owns <pat>", "Search for files in installed packages");
        table.format("vcpkg depend-info <pkg>...", "Display a list of dependencies for packages");
        table.format("vcpkg env", "Creates a clean shell environment for development or compiling");
        table.format("vcpkg version", "Display version information");
        table.format("vcpkg contact", "Display contact information to send feedback");
        table.blank();
        table.header("Options");
        VcpkgCmdArguments::append_common_options(table);
        table.blank();
        table.format("@response_file", "Specify a response file to provide additional parameters");
        table.blank();
        table.example("For more help (including examples) see the accompanying README.md and docs folder.");
        System::print2(table.m_str);
    }

    void print_usage(const CommandStructure& command_structure)
    {
        HelpTableFormatter table;
        if (!command_structure.example_text.empty())
        {
            table.example(command_structure.example_text);
        }

        table.header("Options");
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

        VcpkgCmdArguments::append_common_options(table);
        System::print2(table.m_str);
    }

    void VcpkgCmdArguments::append_common_options(HelpTableFormatter& table)
    {
        table.format("--triplet <t>", "Specify the target architecture triplet. See 'vcpkg help triplet'");
        table.format("", "(default: " + format_environment_variable("VCPKG_DEFAULT_TRIPLET") + ')');
        table.format("--overlay-ports=<path>", "Specify directories to be used when searching for ports");
        table.format("--overlay-triplets=<path>", "Specify directories containing triplets files");
        table.format("--downloads-root=<path>", "Specify the downloads root directory");
        table.format("", "(default: " + format_environment_variable("VCPKG_DOWNLOADS") + ')');
        table.format("--vcpkg-root <path>", "Specify the vcpkg root directory");
        table.format("", "(default: " + format_environment_variable("VCPKG_ROOT") + ')');
        table.format("--x-buildtrees-root=<path>", "(Experimental) Specify the buildtrees root directory");
        table.format("--x-install-root=<path>", "(Experimental) Specify the install root directory");
        table.format("--x-packages-root=<path>", "(Experimental) Specify the packages root directory");
        table.format("--x-scripts-root=<path>", "(Experimental) Specify the scripts root directory");
    }

    void VcpkgCmdArguments::imbue_from_environment()
    {
        if (!disable_metrics)
        {
            const auto vcpkg_disable_metrics_env = System::get_environment_variable("VCPKG_DISABLE_METRICS");
            if (vcpkg_disable_metrics_env)
            {
                disable_metrics = true;
            }
        }

        if (!triplet)
        {
            const auto vcpkg_default_triplet_env = System::get_environment_variable("VCPKG_DEFAULT_TRIPLET");
            if (const auto unpacked = vcpkg_default_triplet_env.get())
            {
                triplet = std::make_unique<std::string>(*unpacked);
            }
        }

        if (!vcpkg_root_dir)
        {
            const auto vcpkg_root_env = System::get_environment_variable("VCPKG_ROOT");
            if (const auto unpacked = vcpkg_root_env.get())
            {
                vcpkg_root_dir = std::make_unique<std::string>(*unpacked);
            }
        }

        if (!downloads_root_dir)
        {
            const auto vcpkg_downloads_env = vcpkg::System::get_environment_variable("VCPKG_DOWNLOADS");
            if (const auto unpacked = vcpkg_downloads_env.get())
            {
                downloads_root_dir = std::make_unique<std::string>(*unpacked);
            }
        }

        {
            const auto vcpkg_visual_studio_path_env = System::get_environment_variable("VCPKG_VISUAL_STUDIO_PATH");
            if (const auto unpacked = vcpkg_visual_studio_path_env.get())
            {
                default_visual_studio_path = std::make_unique<std::string>(*unpacked);
            }
        }
    }

    std::string format_environment_variable(StringLiteral lit)
    {
        std::string result;
#if defined(_WIN32)
        result.reserve(lit.size() + 2);
        result.push_back('%');
        result.append(lit.data(), lit.size());
        result.push_back('%');
#else
        result.reserve(lit.size() + 1);
        result.push_back('$');
        result.append(lit.data(), lit.size());
#endif
        return result;
    }

    std::string create_example_string(const std::string& command_and_arguments)
    {
        std::string cs = Strings::format("Example:\n"
                                         "  vcpkg %s\n",
                                         command_and_arguments);
        return cs;
    }

    static void help_table_newline_indent(std::string& target)
    {
        target.push_back('\n');
        target.append(34, ' ');
    }

    void HelpTableFormatter::format(StringView col1, StringView col2)
    {
        // 2 space, 31 col1, 1 space, 65 col2 = 99
        m_str.append(2, ' ');
        Strings::append(m_str, col1);
        if (col1.size() > 31)
        {
            help_table_newline_indent(m_str);
        }
        else
        {
            m_str.append(32 - col1.size(), ' ');
        }
        const char* line_start = col2.begin();
        const char* const e = col2.end();
        const char* best_break = std::find_if(line_start, e, [](char ch) { return ch == ' ' || ch == '\n'; });

        while (best_break != e)
        {
            const char* next_break = std::find_if(best_break + 1, e, [](char ch) { return ch == ' ' || ch == '\n'; });
            if (next_break - line_start > 65 || *best_break == '\n')
            {
                m_str.append(line_start, best_break);
                line_start = best_break + 1;
                best_break = next_break;
                if (line_start != e)
                {
                    help_table_newline_indent(m_str);
                }
            }
            else
            {
                best_break = next_break;
            }
        }
        m_str.append(line_start, best_break);
        m_str.push_back('\n');
    }

    void HelpTableFormatter::header(StringView name)
    {
        m_str.append(name.data(), name.size());
        m_str.push_back(':');
        m_str.push_back('\n');
    }

    void HelpTableFormatter::example(StringView example_text)
    {
        m_str.append(example_text.data(), example_text.size());
        m_str.push_back('\n');
    }

    void HelpTableFormatter::blank() { m_str.push_back('\n'); }
}
