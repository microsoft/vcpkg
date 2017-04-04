#include "pch.h"
#include "vcpkg_Commands.h"
#include "vcpkg_System.h"

namespace vcpkg::Commands::Help
{
    void help_topic_valid_triplet(const vcpkg_paths& paths)
    {
        System::println("Available architecture triplets:");
        auto it = fs::directory_iterator(paths.triplets);
        for (; it != fs::directory_iterator(); ++it)
        {
            System::println("  %s", it->path().stem().filename().string());
        }
    }

    void print_usage()
    {
        System::println(
            "Commands:\n"
            "  vcpkg search [pat]              Search for packages available to be built\n"
            "  vcpkg install <pkg>...          Install a package\n"
            "  vcpkg remove <pkg>...           Uninstall a package\n"
            "  vcpkg remove --outdated         Uninstall all out-of-date packages\n"
            "  vcpkg list                      List installed packages\n"
            "  vcpkg update                    Display list of packages for updating\n"
            "  vcpkg hash <file> [alg]         Hash a file by specific algorithm, default SHA512\n"
            "\n"
            "%s" // Integration help
            "\n"
            "  vcpkg edit <pkg>                Open up a port for editing (uses %%EDITOR%%, default 'code')\n"
            "  vcpkg import <pkg>              Import a pre-built library\n"
            "  vcpkg create <pkg> <url>\n"
            "             [archivename]        Create a new package\n"
            "  vcpkg owns <pat>                Search for files in installed packages\n"
            "  vcpkg cache                     List cached compiled packages\n"
            "  vcpkg version                   Display version information\n"
            "  vcpkg contact                   Display contact information to send feedback\n"
            "\n"
            //"internal commands:\n"
            //"  --check-build-deps <controlfile>\n"
            //"  --create-binary-control <controlfile>\n"
            //"\n"
            "Options:\n"
            "  --triplet <t>                   Specify the target architecture triplet.\n"
            "                                  (default: %%VCPKG_DEFAULT_TRIPLET%%, see 'vcpkg help triplet')\n"
            "\n"
            "  --vcpkg-root <path>             Specify the vcpkg root directory\n"
            "                                  (default: %%VCPKG_ROOT%%)\n"
            "\n"
            "For more help (including examples) see the accompanying README.md."
            , Integrate::INTEGRATE_COMMAND_HELPSTRING);
    }

    std::string create_example_string(const std::string& command_and_arguments)
    {
        std::string cs = Strings::format("Example:\n"
                                         "  vcpkg %s", command_and_arguments);
        return cs;
    }

    void print_example(const std::string& command_and_arguments)
    {
        System::println(create_example_string(command_and_arguments));
    }

    void perform_and_exit(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths)
    {
        args.check_max_arg_count(1);
        args.check_and_get_optional_command_arguments({});

        if (args.command_arguments.empty())
        {
            print_usage();
            Checks::exit_success(VCPKG_LINE_INFO);
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
            Checks::exit_fail(VCPKG_LINE_INFO);
        }
        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
