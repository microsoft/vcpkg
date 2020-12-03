#include <vcpkg/base/json.h>
#include <vcpkg/base/system.debug.h>
#include <vcpkg/base/system.print.h>

#include <vcpkg/commands.h>
#include <vcpkg/commands.integrate.h>
#include <vcpkg/globalstate.h>
#include <vcpkg/metrics.h>
#include <vcpkg/vcpkgcmdarguments.h>

namespace vcpkg
{
    static void set_from_feature_flag(const std::vector<std::string>& flags, StringView flag, Optional<bool>& place)
    {
        if (!place.has_value())
        {
            const auto not_flag = [flag](const std::string& el) {
                return !el.empty() && el[0] == '-' && flag == StringView{el.data() + 1, el.data() + el.size()};
            };

            if (std::find(flags.begin(), flags.end(), flag) != flags.end())
            {
                place = true;
            }
            if (std::find_if(flags.begin(), flags.end(), not_flag) != flags.end())
            {
                if (place.has_value())
                {
                    System::printf(
                        System::Color::error, "Error: both %s and -%s were specified as feature flags\n", flag, flag);
                    Metrics::g_metrics.lock()->track_property("error", "error feature flag +-" + flag.to_string());
                    Checks::exit_fail(VCPKG_LINE_INFO);
                }

                place = false;
            }
        }
    }

    static void parse_feature_flags(const std::vector<std::string>& flags, VcpkgCmdArguments& args)
    {
        // NOTE: when these features become default, switch the value_or(false) to value_or(true)
        struct FeatureFlag
        {
            StringView flag_name;
            Optional<bool>& local_option;
        };

        const FeatureFlag flag_descriptions[] = {
            {VcpkgCmdArguments::BINARY_CACHING_FEATURE, args.binary_caching},
            {VcpkgCmdArguments::MANIFEST_MODE_FEATURE, args.manifest_mode},
            {VcpkgCmdArguments::COMPILER_TRACKING_FEATURE, args.compiler_tracking},
            {VcpkgCmdArguments::REGISTRIES_FEATURE, args.registries_feature},
            {VcpkgCmdArguments::VERSIONS_FEATURE, args.versions_feature},
        };

        for (const auto& desc : flag_descriptions)
        {
            set_from_feature_flag(flags, desc.flag_name, desc.local_option);
        }
    }

    static void parse_cojoined_value(StringView new_value,
                                     StringView option_name,
                                     std::unique_ptr<std::string>& option_field)
    {
        if (nullptr != option_field)
        {
            System::printf(System::Color::error, "Error: --%s specified multiple times\n", option_name);
            Metrics::g_metrics.lock()->track_property("error", "error option specified multiple times");
            print_usage();
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        option_field = std::make_unique<std::string>(new_value.begin(), new_value.end());
    }

    static void parse_switch(bool new_setting, StringView option_name, Optional<bool>& option_field)
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

    static void parse_cojoined_multivalue(StringView new_value,
                                          StringView option_name,
                                          std::vector<std::string>& option_field)
    {
        if (new_value.size() == 0)
        {
            System::print2(System::Color::error, "Error: expected value after ", option_name, '\n');
            Metrics::g_metrics.lock()->track_property("error", "error option name");
            print_usage();
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        option_field.emplace_back(new_value.begin(), new_value.end());
    }

    static void parse_cojoined_list_multivalue(StringView new_value,
                                               StringView option_name,
                                               std::vector<std::string>& option_field)
    {
        if (new_value.size() == 0)
        {
            System::print2(System::Color::error, "Error: expected value after ", option_name, '\n');
            Metrics::g_metrics.lock()->track_property("error", "error option name");
            print_usage();
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        for (const auto& v : Strings::split(new_value, ','))
        {
            option_field.emplace_back(v.begin(), v.end());
        }
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

    enum class TryParseArgumentResult
    {
        NotFound,
        Found,
        FoundAndConsumedLookahead
    };

    template<class T, class F>
    static TryParseArgumentResult try_parse_argument_as_option(
        StringView arg, Optional<StringView> lookahead, StringView option, T& place, F parser)
    {
        if (Strings::starts_with(arg, "x-") && !Strings::starts_with(option, "x-"))
        {
            arg = arg.substr(2);
        }

        if (Strings::starts_with(arg, option))
        {
            if (arg.size() == option.size())
            {
                if (auto next = lookahead.get())
                {
                    parser(*next, option, place);
                    return TryParseArgumentResult::FoundAndConsumedLookahead;
                }

                System::print2(System::Color::error, "Error: expected value after ", option, '\n');
                Metrics::g_metrics.lock()->track_property("error", "error option name");
                print_usage();
                Checks::exit_fail(VCPKG_LINE_INFO);
            }

            if (arg.byte_at_index(option.size()) == '=')
            {
                parser(arg.substr(option.size() + 1), option, place);
                return TryParseArgumentResult::Found;
            }
        }

        return TryParseArgumentResult::NotFound;
    }

    static bool equals_modulo_experimental(StringView arg, StringView option)
    {
        if (Strings::starts_with(arg, "x-") && !Strings::starts_with(option, "x-"))
        {
            return arg.substr(2) == option;
        }
        else
        {
            return arg == option;
        }
    }

    // returns true if this does parse this argument as this option
    template<class T>
    static bool try_parse_argument_as_switch(StringView option, StringView arg, T& place)
    {
        if (equals_modulo_experimental(arg, option))
        {
            parse_switch(true, option, place);
            return true;
        }

        if (Strings::starts_with(arg, "no-") && equals_modulo_experimental(arg.substr(3), option))
        {
            parse_switch(false, option, place);
            return true;
        }

        return false;
    }

    VcpkgCmdArguments VcpkgCmdArguments::create_from_arg_sequence(const std::string* arg_first,
                                                                  const std::string* arg_last)
    {
        VcpkgCmdArguments args;
        std::vector<std::string> feature_flags;

        for (auto it = arg_first; it != arg_last; ++it)
        {
            std::string basic_arg = *it;

            if (basic_arg.empty())
            {
                continue;
            }

            if (basic_arg.size() >= 2 && basic_arg[0] == '-' && basic_arg[1] != '-')
            {
                Metrics::g_metrics.lock()->track_property("error", "error short options are not supported");
                Checks::exit_with_message(VCPKG_LINE_INFO, "Error: short options are not supported: %s", basic_arg);
            }

            if (basic_arg.size() < 2 || basic_arg[0] != '-')
            {
                if (args.command.empty())
                {
                    args.command = std::move(basic_arg);
                }
                else
                {
                    args.command_arguments.push_back(std::move(basic_arg));
                }
                continue;
            }

            // make argument case insensitive before the first =
            auto first_eq = std::find(std::begin(basic_arg), std::end(basic_arg), '=');
            Strings::ascii_to_lowercase(std::begin(basic_arg), first_eq);
            // basic_arg[0] == '-' && basic_arg[1] == '-'
            StringView arg = StringView(basic_arg).substr(2);
            constexpr static std::pair<StringView, std::unique_ptr<std::string> VcpkgCmdArguments::*>
                cojoined_values[] = {
                    {VCPKG_ROOT_DIR_ARG, &VcpkgCmdArguments::vcpkg_root_dir},
                    {TRIPLET_ARG, &VcpkgCmdArguments::triplet},
                    {MANIFEST_ROOT_DIR_ARG, &VcpkgCmdArguments::manifest_root_dir},
                    {BUILDTREES_ROOT_DIR_ARG, &VcpkgCmdArguments::buildtrees_root_dir},
                    {DOWNLOADS_ROOT_DIR_ARG, &VcpkgCmdArguments::downloads_root_dir},
                    {INSTALL_ROOT_DIR_ARG, &VcpkgCmdArguments::install_root_dir},
                    {PACKAGES_ROOT_DIR_ARG, &VcpkgCmdArguments::packages_root_dir},
                    {SCRIPTS_ROOT_DIR_ARG, &VcpkgCmdArguments::scripts_root_dir},
                };

            constexpr static std::pair<StringView, std::vector<std::string> VcpkgCmdArguments::*>
                cojoined_multivalues[] = {
                    {OVERLAY_PORTS_ARG, &VcpkgCmdArguments::overlay_ports},
                    {OVERLAY_TRIPLETS_ARG, &VcpkgCmdArguments::overlay_triplets},
                    {BINARY_SOURCES_ARG, &VcpkgCmdArguments::binary_sources},
                    {CMAKE_SCRIPT_ARG, &VcpkgCmdArguments::cmake_args},
                };

            constexpr static std::pair<StringView, Optional<bool> VcpkgCmdArguments::*> switches[] = {
                {DEBUG_SWITCH, &VcpkgCmdArguments::debug},
                {DISABLE_METRICS_SWITCH, &VcpkgCmdArguments::disable_metrics},
                {SEND_METRICS_SWITCH, &VcpkgCmdArguments::send_metrics},
                {PRINT_METRICS_SWITCH, &VcpkgCmdArguments::print_metrics},
                {FEATURE_PACKAGES_SWITCH, &VcpkgCmdArguments::feature_packages},
                {BINARY_CACHING_SWITCH, &VcpkgCmdArguments::binary_caching},
                {WAIT_FOR_LOCK_SWITCH, &VcpkgCmdArguments::wait_for_lock},
                {IGNORE_LOCK_FAILURES_SWITCH, &VcpkgCmdArguments::ignore_lock_failures},
                {JSON_SWITCH, &VcpkgCmdArguments::json},
            };

            Optional<StringView> lookahead;
            if (it + 1 != arg_last)
            {
                lookahead = it[1];
            }

            bool found = false;
            for (const auto& pr : cojoined_values)
            {
                switch (try_parse_argument_as_option(arg, lookahead, pr.first, args.*pr.second, parse_cojoined_value))
                {
                    case TryParseArgumentResult::FoundAndConsumedLookahead: ++it; [[fallthrough]];
                    case TryParseArgumentResult::Found: found = true; break;
                    case TryParseArgumentResult::NotFound: break;
                    default: Checks::unreachable(VCPKG_LINE_INFO);
                }
            }
            if (found) continue;

            for (const auto& pr : cojoined_multivalues)
            {
                switch (
                    try_parse_argument_as_option(arg, lookahead, pr.first, args.*pr.second, parse_cojoined_multivalue))
                {
                    case TryParseArgumentResult::FoundAndConsumedLookahead: ++it; [[fallthrough]];
                    case TryParseArgumentResult::Found: found = true; break;
                    case TryParseArgumentResult::NotFound: break;
                    default: Checks::unreachable(VCPKG_LINE_INFO);
                }
            }
            if (found) continue;

            switch (try_parse_argument_as_option(
                arg, lookahead, FEATURE_FLAGS_ARG, feature_flags, parse_cojoined_list_multivalue))
            {
                case TryParseArgumentResult::FoundAndConsumedLookahead: ++it; [[fallthrough]];
                case TryParseArgumentResult::Found: found = true; break;
                case TryParseArgumentResult::NotFound: break;
                default: Checks::unreachable(VCPKG_LINE_INFO);
            }

            for (const auto& pr : switches)
            {
                if (try_parse_argument_as_switch(pr.first, arg, args.*pr.second))
                {
                    found = true;
                    break;
                }
            }
            if (found) continue;

            const auto eq_pos = std::find(arg.begin(), arg.end(), '=');
            if (eq_pos != arg.end())
            {
                const auto& key = StringView(arg.begin(), eq_pos);
                const auto& value = StringView(eq_pos + 1, arg.end());

                args.command_options[key.to_string()].push_back(value.to_string());
            }
            else
            {
                args.command_switches.insert(arg.to_string());
            }
        }

        parse_feature_flags(feature_flags, args);

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

        auto switches_copy = this->command_switches;
        auto options_copy = this->command_options;

        const auto find_option = [](const auto& set, StringLiteral name) {
            auto it = set.find(name);
            if (it == set.end() && !Strings::starts_with(name, "x-"))
            {
                it = set.find(Strings::format("x-%s", name));
            }

            return it;
        };

        for (const auto& switch_ : command_structure.options.switches)
        {
            const auto it = find_option(switches_copy, switch_.name);
            if (it != switches_copy.end())
            {
                output.switches.insert(switch_.name);
                switches_copy.erase(it);
            }
            const auto option_it = find_option(options_copy, switch_.name);
            if (option_it != options_copy.end())
            {
                // This means that the switch was passed like '--a=xyz'
                System::printf(
                    System::Color::error, "Error: The option '--%s' does not accept an argument.\n", switch_.name);
                options_copy.erase(option_it);
                failed = true;
            }
        }

        for (const auto& option : command_structure.options.settings)
        {
            const auto it = find_option(options_copy, option.name);
            if (it != options_copy.end())
            {
                const auto& value = it->second;
                if (value.empty())
                {
                    Checks::unreachable(VCPKG_LINE_INFO);
                }

                if (value.size() > 1)
                {
                    System::printf(
                        System::Color::error, "Error: The option '%s' can only be passed once.\n", option.name);
                    failed = true;
                }
                else if (value.front().empty())
                {
                    // Fail when not given a value, e.g.: "vcpkg install sqlite3 --additional-ports="
                    System::printf(System::Color::error,
                                   "Error: The option '--%s' must be passed a non-empty argument.\n",
                                   option.name);
                    failed = true;
                }
                else
                {
                    output.settings.emplace(option.name, value.front());
                    options_copy.erase(it);
                }
            }
            const auto switch_it = find_option(switches_copy, option.name);
            if (switch_it != switches_copy.end())
            {
                // This means that the option was passed like '--a'
                System::printf(
                    System::Color::error, "Error: The option '--%s' must be passed an argument.\n", option.name);
                switches_copy.erase(switch_it);
                failed = true;
            }
        }

        for (const auto& option : command_structure.options.multisettings)
        {
            const auto it = find_option(options_copy, option.name);
            if (it != options_copy.end())
            {
                const auto& value = it->second;
                for (const auto& v : value)
                {
                    if (v.empty())
                    {
                        System::printf(System::Color::error,
                                       "Error: The option '--%s' must be passed non-empty arguments.\n",
                                       option.name);
                        failed = true;
                    }
                    else
                    {
                        output.multisettings[option.name].push_back(v);
                    }
                }
                options_copy.erase(it);
            }
            const auto switch_it = find_option(switches_copy, option.name);
            if (switch_it != switches_copy.end())
            {
                // This means that the option was passed like '--a'
                System::printf(
                    System::Color::error, "Error: The option '--%s' must be passed an argument.\n", option.name);
                switches_copy.erase(switch_it);
                failed = true;
            }
        }

        if (!switches_copy.empty() || !options_copy.empty())
        {
            System::printf(System::Color::error, "Unknown option(s) for command '%s':\n", this->command);
            for (auto&& switch_ : switches_copy)
            {
                System::print2("    '--", switch_, "'\n");
            }
            for (auto&& option : options_copy)
            {
                System::print2("    '--", option.first, "'\n");
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
            table.format(Strings::format("--%s", option.name), option.short_help_text);
        }
        for (auto&& option : command_structure.options.settings)
        {
            table.format(Strings::format("--%s=...", option.name), option.short_help_text);
        }
        for (auto&& option : command_structure.options.multisettings)
        {
            table.format(Strings::format("--%s=...", option.name), option.short_help_text);
        }

        VcpkgCmdArguments::append_common_options(table);
        System::print2(table.m_str);
    }

    void VcpkgCmdArguments::append_common_options(HelpTableFormatter& table)
    {
        static auto opt = [](StringView arg, StringView joiner, StringView value) {
            return Strings::concat("--", arg, joiner, value);
        };

        table.format(opt(TRIPLET_ARG, "=", "<t>"), "Specify the target architecture triplet. See 'vcpkg help triplet'");
        table.format("", "(default: " + format_environment_variable("VCPKG_DEFAULT_TRIPLET") + ')');
        table.format(opt(OVERLAY_PORTS_ARG, "=", "<path>"), "Specify directories to be used when searching for ports");
        table.format("", "(also: " + format_environment_variable("VCPKG_OVERLAY_PORTS") + ')');
        table.format(opt(OVERLAY_TRIPLETS_ARG, "=", "<path>"), "Specify directories containing triplets files");
        table.format("", "(also: " + format_environment_variable("VCPKG_OVERLAY_TRIPLETS") + ')');
        table.format(opt(BINARY_SOURCES_ARG, "=", "<path>"),
                     "Add sources for binary caching. See 'vcpkg help binarycaching'");
        table.format(opt(DOWNLOADS_ROOT_DIR_ARG, "=", "<path>"), "Specify the downloads root directory");
        table.format("", "(default: " + format_environment_variable("VCPKG_DOWNLOADS") + ')');
        table.format(opt(VCPKG_ROOT_DIR_ARG, "=", "<path>"), "Specify the vcpkg root directory");
        table.format("", "(default: " + format_environment_variable("VCPKG_ROOT") + ')');
        table.format(opt(BUILDTREES_ROOT_DIR_ARG, "=", "<path>"),
                     "(Experimental) Specify the buildtrees root directory");
        table.format(opt(INSTALL_ROOT_DIR_ARG, "=", "<path>"), "(Experimental) Specify the install root directory");
        table.format(opt(PACKAGES_ROOT_DIR_ARG, "=", "<path>"), "(Experimental) Specify the packages root directory");
        table.format(opt(SCRIPTS_ROOT_DIR_ARG, "=", "<path>"), "(Experimental) Specify the scripts root directory");
        table.format(opt(JSON_SWITCH, "", ""), "(Experimental) Request JSON output");
    }

    static void from_env(ZStringView var, std::unique_ptr<std::string>& dst)
    {
        if (dst) return;

        auto maybe_val = System::get_environment_variable(var);
        if (auto val = maybe_val.get())
        {
            dst = std::make_unique<std::string>(std::move(*val));
        }
    }

    void VcpkgCmdArguments::imbue_from_environment()
    {
        static bool s_reentrancy_guard = false;
        Checks::check_exit(VCPKG_LINE_INFO,
                           !s_reentrancy_guard,
                           "VcpkgCmdArguments::imbue_from_environment() modifies global state and thus may only be "
                           "called once per process.");
        s_reentrancy_guard = true;

        if (!disable_metrics)
        {
            const auto vcpkg_disable_metrics_env = System::get_environment_variable(DISABLE_METRICS_ENV);
            if (vcpkg_disable_metrics_env.has_value())
            {
                disable_metrics = true;
            }
        }

        from_env(TRIPLET_ENV, triplet);
        from_env(VCPKG_ROOT_DIR_ENV, vcpkg_root_dir);
        from_env(DOWNLOADS_ROOT_DIR_ENV, downloads_root_dir);
        from_env(DEFAULT_VISUAL_STUDIO_PATH_ENV, default_visual_studio_path);

        {
            const auto vcpkg_disable_lock = System::get_environment_variable(IGNORE_LOCK_FAILURES_ENV);
            if (vcpkg_disable_lock.has_value() && !ignore_lock_failures.has_value())
            {
                ignore_lock_failures = true;
            }
        }

        {
            const auto vcpkg_overlay_ports_env = System::get_environment_variable(OVERLAY_PORTS_ENV);
            if (const auto unpacked = vcpkg_overlay_ports_env.get())
            {
                auto overlays = Strings::split_paths(*unpacked);
                overlay_ports.insert(std::end(overlay_ports), std::begin(overlays), std::end(overlays));
            }
        }
        {
            const auto vcpkg_overlay_triplets_env = System::get_environment_variable(OVERLAY_TRIPLETS_ENV);
            if (const auto unpacked = vcpkg_overlay_triplets_env.get())
            {
                auto triplets = Strings::split_paths(*unpacked);
                overlay_triplets.insert(std::end(overlay_triplets), std::begin(triplets), std::end(triplets));
            }
        }
        {
            const auto vcpkg_feature_flags_env = System::get_environment_variable(FEATURE_FLAGS_ENV);
            if (const auto v = vcpkg_feature_flags_env.get())
            {
                auto flags = Strings::split(*v, ',');
                parse_feature_flags(flags, *this);
            }
        }

        {
            auto maybe_vcpkg_recursive_data = System::get_environment_variable(RECURSIVE_DATA_ENV);
            if (auto vcpkg_recursive_data = maybe_vcpkg_recursive_data.get())
            {
                m_is_recursive_invocation = true;

                auto rec_doc = Json::parse(*vcpkg_recursive_data).value_or_exit(VCPKG_LINE_INFO).first;
                const auto& obj = rec_doc.object();

                if (auto entry = obj.get(DOWNLOADS_ROOT_DIR_ENV))
                {
                    downloads_root_dir = std::make_unique<std::string>(entry->string().to_string());
                }

                if (obj.get(DISABLE_METRICS_ENV))
                {
                    disable_metrics = true;
                }

                // Setting the recursive data to 'poison' prevents more than one level of recursion because
                // Json::parse() will fail.
                System::set_environment_variable(RECURSIVE_DATA_ENV, "poison");
            }
            else
            {
                Json::Object obj;
                if (downloads_root_dir)
                {
                    obj.insert(DOWNLOADS_ROOT_DIR_ENV, Json::Value::string(*downloads_root_dir.get()));
                }

                if (disable_metrics)
                {
                    obj.insert(DISABLE_METRICS_ENV, Json::Value::boolean(true));
                }

                System::set_environment_variable(RECURSIVE_DATA_ENV,
                                                 Json::stringify(obj, Json::JsonStyle::with_spaces(0)));
            }
        }
    }

    void VcpkgCmdArguments::check_feature_flag_consistency() const
    {
        struct
        {
            StringView flag;
            StringView option;
            bool is_inconsistent;
        } possible_inconsistencies[] = {
            {BINARY_CACHING_FEATURE, BINARY_SOURCES_ARG, !binary_sources.empty() && !binary_caching.value_or(true)},
            {MANIFEST_MODE_FEATURE, MANIFEST_ROOT_DIR_ARG, manifest_root_dir && !manifest_mode.value_or(true)},
        };
        for (const auto& el : possible_inconsistencies)
        {
            if (el.is_inconsistent)
            {
                System::printf(System::Color::warning,
                               "Warning: %s feature specifically turned off, but --%s was specified.\n",
                               el.flag,
                               el.option);
                System::printf(System::Color::warning, "Warning: Defaulting to %s being on.\n", el.flag);
                Metrics::g_metrics.lock()->track_property(
                    "warning", Strings::format("warning %s alongside %s", el.flag, el.option));
            }
        }
    }

    void VcpkgCmdArguments::debug_print_feature_flags() const
    {
        struct
        {
            StringView name;
            Optional<bool> flag;
        } flags[] = {
            {BINARY_CACHING_FEATURE, binary_caching},
            {MANIFEST_MODE_FEATURE, manifest_mode},
            {COMPILER_TRACKING_FEATURE, compiler_tracking},
            {REGISTRIES_FEATURE, registries_feature},
            {VERSIONS_FEATURE, versions_feature},
        };

        for (const auto& flag : flags)
        {
            if (auto r = flag.flag.get())
            {
                Debug::print("Feature flag '", flag.name, "' = ", *r ? "on" : "off", "\n");
            }
            else
            {
                Debug::print("Feature flag '", flag.name, "' unset\n");
            }
        }
    }

    void VcpkgCmdArguments::track_feature_flag_metrics() const
    {
        struct
        {
            StringView flag;
            bool enabled;
        } flags[] = {
            {BINARY_CACHING_FEATURE, binary_caching_enabled()},
            {COMPILER_TRACKING_FEATURE, compiler_tracking_enabled()},
            {REGISTRIES_FEATURE, registries_enabled()},
            {VERSIONS_FEATURE, versions_enabled()},
        };

        for (const auto& flag : flags)
        {
            Metrics::g_metrics.lock()->track_feature(flag.flag.to_string(), flag.enabled);
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

    static constexpr ptrdiff_t S_MAX_LINE_LENGTH = 100;

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
        text(col2, 34);

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

    // Note: this formatting code does not properly handle unicode, however all of our documentation strings are English
    // ASCII.
    void HelpTableFormatter::text(StringView text, int indent)
    {
        const char* line_start = text.begin();
        const char* const e = text.end();
        const char* best_break = std::find_if(line_start, e, [](char ch) { return ch == ' ' || ch == '\n'; });

        while (best_break != e)
        {
            const char* next_break = std::find_if(best_break + 1, e, [](char ch) { return ch == ' ' || ch == '\n'; });
            if (*best_break == '\n' || next_break - line_start + indent > S_MAX_LINE_LENGTH)
            {
                m_str.append(line_start, best_break);
                m_str.push_back('\n');
                line_start = best_break + 1;
                best_break = next_break;
                m_str.append(indent, ' ');
            }
            else
            {
                best_break = next_break;
            }
        }
        m_str.append(line_start, best_break);
    }

    // out-of-line definitions since C++14 doesn't allow inline constexpr static variables
    constexpr StringLiteral VcpkgCmdArguments::VCPKG_ROOT_DIR_ENV;
    constexpr StringLiteral VcpkgCmdArguments::VCPKG_ROOT_DIR_ARG;
    constexpr StringLiteral VcpkgCmdArguments::MANIFEST_ROOT_DIR_ARG;

    constexpr StringLiteral VcpkgCmdArguments::BUILDTREES_ROOT_DIR_ARG;
    constexpr StringLiteral VcpkgCmdArguments::DOWNLOADS_ROOT_DIR_ENV;
    constexpr StringLiteral VcpkgCmdArguments::DOWNLOADS_ROOT_DIR_ARG;
    constexpr StringLiteral VcpkgCmdArguments::INSTALL_ROOT_DIR_ARG;
    constexpr StringLiteral VcpkgCmdArguments::PACKAGES_ROOT_DIR_ARG;
    constexpr StringLiteral VcpkgCmdArguments::SCRIPTS_ROOT_DIR_ARG;

    constexpr StringLiteral VcpkgCmdArguments::DEFAULT_VISUAL_STUDIO_PATH_ENV;

    constexpr StringLiteral VcpkgCmdArguments::TRIPLET_ENV;
    constexpr StringLiteral VcpkgCmdArguments::TRIPLET_ARG;
    constexpr StringLiteral VcpkgCmdArguments::OVERLAY_PORTS_ENV;
    constexpr StringLiteral VcpkgCmdArguments::OVERLAY_PORTS_ARG;
    constexpr StringLiteral VcpkgCmdArguments::OVERLAY_TRIPLETS_ENV;
    constexpr StringLiteral VcpkgCmdArguments::OVERLAY_TRIPLETS_ARG;

    constexpr StringLiteral VcpkgCmdArguments::BINARY_SOURCES_ARG;

    constexpr StringLiteral VcpkgCmdArguments::DEBUG_SWITCH;
    constexpr StringLiteral VcpkgCmdArguments::SEND_METRICS_SWITCH;
    constexpr StringLiteral VcpkgCmdArguments::DISABLE_METRICS_ENV;
    constexpr StringLiteral VcpkgCmdArguments::DISABLE_METRICS_SWITCH;
    constexpr StringLiteral VcpkgCmdArguments::PRINT_METRICS_SWITCH;

    constexpr StringLiteral VcpkgCmdArguments::WAIT_FOR_LOCK_SWITCH;
    constexpr StringLiteral VcpkgCmdArguments::IGNORE_LOCK_FAILURES_SWITCH;
    constexpr StringLiteral VcpkgCmdArguments::IGNORE_LOCK_FAILURES_ENV;

    constexpr StringLiteral VcpkgCmdArguments::JSON_SWITCH;

    constexpr StringLiteral VcpkgCmdArguments::FEATURE_FLAGS_ENV;
    constexpr StringLiteral VcpkgCmdArguments::FEATURE_FLAGS_ARG;

    constexpr StringLiteral VcpkgCmdArguments::FEATURE_PACKAGES_SWITCH;
    constexpr StringLiteral VcpkgCmdArguments::BINARY_CACHING_FEATURE;
    constexpr StringLiteral VcpkgCmdArguments::BINARY_CACHING_SWITCH;
    constexpr StringLiteral VcpkgCmdArguments::COMPILER_TRACKING_FEATURE;
    constexpr StringLiteral VcpkgCmdArguments::MANIFEST_MODE_FEATURE;
    constexpr StringLiteral VcpkgCmdArguments::REGISTRIES_FEATURE;
    constexpr StringLiteral VcpkgCmdArguments::RECURSIVE_DATA_ENV;
    constexpr StringLiteral VcpkgCmdArguments::VERSIONS_FEATURE;

    constexpr StringLiteral VcpkgCmdArguments::CMAKE_SCRIPT_ARG;
}
