#include "vcpkg_Commands.h"
#include "vcpkg_System.h"
#include "vcpkg_info.h"

namespace vcpkg::Commands
{
    void version_command(const vcpkg_cmd_arguments& args)
    {
        args.check_exact_arg_count(0);
        System::println("Vcpkg package management program version %s\n"
                        "\n"
                        "See LICENSE.txt for license information.", Info::version()
        );
        exit(EXIT_SUCCESS);
    }

    void help_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths)
    {
        args.check_max_arg_count(1);
        if (args.command_arguments.empty())
        {
            Commands::Helpers::print_usage();
            exit(EXIT_SUCCESS);
        }
        const auto& topic = args.command_arguments[0];
        if (topic == "triplet")
        {
            Commands::help_topic_valid_triplet(paths);
        }
        else
        {
            System::println(System::color::error, "Error: unknown topic %s", topic);
            Commands::Helpers::print_usage();
            exit(EXIT_FAILURE);
        }
        exit(EXIT_SUCCESS);
    }

    void contact_command(const vcpkg_cmd_arguments& args)
    {
        args.check_exact_arg_count(0);
        System::println("Send an email to %s with any feedback.", Info::email());
        exit(EXIT_SUCCESS);
    }

    void help_topic_valid_triplet(const vcpkg_paths& paths)
    {
        System::println("Available architecture triplets:");
        auto it = fs::directory_iterator(paths.triplets);
        for (; it != fs::directory_iterator(); ++it)
        {
            System::println("  %s", it->path().stem().filename().string());
        }
    }
}
