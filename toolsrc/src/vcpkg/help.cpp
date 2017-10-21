#include "pch.h"

#include <vcpkg/base/system.h>
#include <vcpkg/commands.h>

namespace vcpkg::Help
{
    void help_topics()
    {
        System::println("Available help topics:\n"
                        "  triplet\n"
                        "  integrate\n"
                        "  export");
    }

    void help_topic_valid_triplet(const VcpkgPaths& paths)
    {
        System::println("Available architecture triplets:");
        for (auto&& triplet : paths.get_available_triplets())
        {
            System::println("  %s", triplet);
        }
    }

    void help_topic_export()
    {
        System::println("Summary:\n"
                        "  vcpkg export [options] <pkgs>...\n"
                        "\n"
                        "Options:\n"
                        "  --7zip                          Export to a 7zip (.7z) file\n"
                        "  --dry-run                       Do not actually export\n"
                        "  --nuget                         Export a NuGet package\n"
                        "  --nuget-id=<id>                 Specify the id for the exported NuGet package\n"
                        "  --nuget-version=<ver>           Specify the version for the exported NuGet package\n"
                        "  --raw                           Export to an uncompressed directory\n"
                        "  --zip                           Export to a zip file");
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
            "  vcpkg help topics               Display the list of help topics\n"
            "  vcpkg help <topic>              Display help for a specific topic\n"
            "\n"
            "%s" // Integration help
            "\n"
            "  vcpkg export <pkg>... [opt]...  Exports a package\n"
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
            "For more help (including examples) see the accompanying README.md.",
            Commands::Integrate::INTEGRATE_COMMAND_HELPSTRING);
    }

    std::string create_example_string(const std::string& command_and_arguments)
    {
        std::string cs = Strings::format("Example:\n"
                                         "  vcpkg %s\n",
                                         command_and_arguments);
        return cs;
    }

    void print_example(const std::string& command_and_arguments)
    {
        System::println(create_example_string(command_and_arguments));
    }

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        args.check_max_arg_count(1);
        args.check_and_get_optional_command_arguments({});

        if (args.command_arguments.empty())
        {
            print_usage();
            Checks::exit_success(VCPKG_LINE_INFO);
        }
        const auto& topic = args.command_arguments[0];
        if (topic == "triplet" || topic == "triplets" || topic == "triple")
        {
            help_topic_valid_triplet(paths);
        }
        else if (topic == "export")
        {
            help_topic_export();
        }
        else if (topic == "integrate")
        {
            System::print("Commands:\n"
                          "%s",
                          Commands::Integrate::INTEGRATE_COMMAND_HELPSTRING);
        }
        else if (topic == "topics")
        {
            help_topics();
        }
        else
        {
            System::println(System::Color::error, "Error: unknown topic %s", topic);
            help_topics();
            Checks::exit_fail(VCPKG_LINE_INFO);
        }
        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
