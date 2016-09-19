#include "vcpkg_Commands.h"
#include "vcpkg.h"
#include "vcpkg_System.h"

namespace vcpkg
{
    void version_command(const vcpkg_cmd_arguments& args)
    {
        args.check_max_args(0);
        System::println("Vcpkg package management program version %s\n"
                        "\n"
                        "Vcpkg is provided \"as-is\" without warranty of any kind, express or implied.\n"
                        "All rights reserved.", vcpkg::version()
        );
        exit(EXIT_SUCCESS);
    }

    void help_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths)
    {
        args.check_max_args(1);
        if (args.command_arguments.empty())
        {
            print_usage();
            exit(EXIT_SUCCESS);
        }
        const auto& topic = args.command_arguments[0];
        if (topic == "triplet")
        {
            help_topic_valid_triplet(paths);
        }
        else
        {
            System::println(System::color::error, "Error: unknown topic %s", topic);
            print_usage();
            exit(EXIT_FAILURE);
        }
        exit(EXIT_SUCCESS);
    }

    void contact_command(const vcpkg_cmd_arguments& /*args*/)
    {
        System::println("Send an email to vcpkg@microsoft.com with any feedback.");
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
