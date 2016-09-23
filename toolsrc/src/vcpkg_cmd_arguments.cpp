#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#include "vcpkg_cmd_arguments.h"
#include "vcpkg_Commands.h"
#include "vcpkg_Graphs.h"
#include <unordered_set>
#include "metrics.h"
#include "vcpkg.h"
#include "vcpkg_System.h"

namespace vcpkg
{
    static void parse_value(
        const std::string* arg_begin,
        const std::string* arg_end,
        const std::string& option_name,
        std::unique_ptr<std::string>& option_field)
    {
        if (arg_begin == arg_end)
        {
            System::println(System::color::error, "Error: expected value after %s", option_name);
            TrackProperty("error", "error option name");
            print_usage();
            exit(EXIT_FAILURE);
        }

        if (option_field != nullptr)
        {
            System::println(System::color::error, "Error: %s specified multiple times", option_name);
            TrackProperty("error", "error option specified multiple times");
            print_usage();
            exit(EXIT_FAILURE);
        }

        option_field = std::make_unique<std::string>(*arg_begin);
    }

    static void parse_switch(
        opt_bool new_setting,
        const std::string& option_name,
        opt_bool& option_field)
    {
        if (option_field != opt_bool::unspecified && option_field != new_setting)
        {
            System::println(System::color::error, "Error: conflicting values specified for --%s", option_name);
            TrackProperty("error", "error conflicting switches");
            print_usage();
            exit(EXIT_FAILURE);
        }
        option_field = new_setting;
    }

    vcpkg_cmd_arguments vcpkg_cmd_arguments::create_from_command_line(const int argc, const wchar_t* const* const argv)
    {
        std::vector<std::string> v;
        for (int i = 1; i < argc; ++i)
        {
            v.push_back(Strings::utf16_to_utf8(argv[i]));
        }

        return vcpkg_cmd_arguments::create_from_arg_sequence(v.data(), v.data() + v.size());
    }

    vcpkg_cmd_arguments vcpkg_cmd_arguments::create_from_arg_sequence(const std::string* arg_begin, const std::string* arg_end)
    {
        vcpkg_cmd_arguments args;

        for (; arg_begin != arg_end; ++arg_begin)
        {
            std::string arg = *arg_begin;

            if (arg.empty())
            {
                continue;
            }

            if (arg[0] == '-' && arg[1] != '-')
            {
                System::println(System::color::error, "Error: short options are not supported: %s", arg);
                TrackProperty("error", "error short options are not supported");
                exit(EXIT_FAILURE);
            }

            if (arg[0] == '-' && arg[1] == '-')
            {
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
                    parse_value(arg_begin, arg_end, "--triplet", args.target_triplet);
                    continue;
                }
                if (arg == "--debug")
                {
                    parse_switch(opt_bool::enabled, "debug", args.debug);
                    continue;
                }
                if (arg == "--sendmetrics")
                {
                    parse_switch(opt_bool::enabled, "sendmetrics", args.sendmetrics);
                    continue;
                }
                if (arg == "--printmetrics")
                {
                    parse_switch(opt_bool::enabled, "printmetrics", args.printmetrics);
                    continue;
                }
                if (arg == "--no-sendmetrics")
                {
                    parse_switch(opt_bool::disabled, "sendmetrics", args.sendmetrics);
                    continue;
                }
                if (arg == "--no-printmetrics")
                {
                    parse_switch(opt_bool::disabled, "printmetrics", args.printmetrics);
                    continue;
                }

                args.optional_command_arguments.insert(arg);
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

    std::unordered_set<std::string> vcpkg_cmd_arguments::check_and_get_optional_command_arguments(const std::vector<std::string>& valid_options) const
    {
        std::unordered_set<std::string> output;
        auto options_copy = this->optional_command_arguments;
        for (const std::string& option : valid_options)
        {
            auto it = options_copy.find(option);
            if (it != options_copy.end())
            {
                output.insert(option);
                options_copy.erase(it);
            }
        }

        if (!options_copy.empty())
        {
            System::println(System::color::error, "Unknown option(s) for command '%s':", this->command);
            for (const std::string& option : options_copy)
            {
                System::println(option.c_str());
            }
            exit(EXIT_FAILURE);
        }

        return output;
    }

    void vcpkg_cmd_arguments::check_max_args(size_t arg_count, const char* example_text) const
    {
        if (command_arguments.size() > arg_count)
        {
            System::println(System::color::error, "Error: too many arguments to command %s", command);
            if (example_text != nullptr)
                print_example(example_text);
            else
                print_usage();
            exit(EXIT_FAILURE);
        }
    }

    std::vector<package_spec> vcpkg_cmd_arguments::parse_all_arguments_as_package_specs(const vcpkg_paths& const triplet& default_target_triplet, const char* example_text) const
    {
        size_t arg_count = command_arguments.size();
        if (arg_count < 1)
        {
            System::println(System::color::error, "Error: %s requires one or more package specifiers", this->command);
            if (example_text == nullptr)
                print_example(Strings::format("%s zlib zlib:x64-windows curl boost", this->command).c_str());
            else
                print_example(example_text);
            exit(EXIT_FAILURE);
        }
        std::vector<package_spec> specs;
        specs.reserve(arg_count);

        for (const std::string& command_argument : command_arguments)
        {
            expected<package_spec> current_spec = vcpkg::parse(command_argument, default_target_triplet);
            if (auto spec = current_spec.get())
            {
                if(!spec->target_triplet.validate(paths))
                {
                    System::println(System::color::error, "Error: invalid triplet %s for package %s", spec->target_triplet.value, spec->name);
                    TrackProperty("error", "invalid triplet: " + spec->target_triplet.value);
                    help_topic_valid_triplet(paths);
                    exit(EXIT_FAILURE);
                }
                specs.push_back(std::move(*spec));
            }
            else
            {
                System::println(System::color::error, "Error: %s: %s", current_spec.error_code().message(), command_argument);
                print_example(Strings::format("%s zlib:x64-windows", this->command).c_str());
                exit(EXIT_FAILURE);
            }
        }

        return specs;
    }
}
