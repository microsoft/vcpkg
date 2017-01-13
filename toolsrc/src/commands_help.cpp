#include "vcpkg_Commands.h"
#include "vcpkg_System.h"

namespace vcpkg::Commands
{
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
