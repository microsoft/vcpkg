#include "pch.h"

#include <vcpkg/base/system.print.h>
#include <vcpkg/commands.h>
#include <vcpkg/export.h>
#include <vcpkg/help.h>
#include <vcpkg/install.h>
#include <vcpkg/remove.h>

// Write environment variable names as %VARIABLE% on Windows and $VARIABLE in *nix
#ifdef _WIN32
#define ENVVAR(VARNAME) "%%" #VARNAME "%%"
#else
#define ENVVAR(VARNAME) "$" #VARNAME
#endif

namespace vcpkg::Help
{
    struct Topic
    {
        using topic_function = void (*)(const VcpkgPaths& paths);

        constexpr Topic(CStringView n, topic_function fn) : name(n), print(fn) {}

        CStringView name;
        topic_function print;
    };

    template<const CommandStructure& S>
    static void command_topic_fn(const VcpkgPaths&)
    {
        display_usage(S);
    }

    static void integrate_topic_fn(const VcpkgPaths&)
    {
        System::print2("Commands:\n", Commands::Integrate::INTEGRATE_COMMAND_HELPSTRING);
    }

    static void help_topics(const VcpkgPaths&);

    const CommandStructure COMMAND_STRUCTURE = {
        Help::create_example_string("help"),
        0,
        1,
        {},
        nullptr,
    };

    static constexpr std::array<Topic, 13> topics = {{
        {"create", command_topic_fn<Commands::Create::COMMAND_STRUCTURE>},
        {"edit", command_topic_fn<Commands::Edit::COMMAND_STRUCTURE>},
        {"depend-info", command_topic_fn<Commands::DependInfo::COMMAND_STRUCTURE>},
        {"env", command_topic_fn<Commands::Env::COMMAND_STRUCTURE>},
        {"export", command_topic_fn<Export::COMMAND_STRUCTURE>},
        {"help", command_topic_fn<Help::COMMAND_STRUCTURE>},
        {"install", command_topic_fn<Install::COMMAND_STRUCTURE>},
        {"integrate", integrate_topic_fn},
        {"list", command_topic_fn<Commands::List::COMMAND_STRUCTURE>},
        {"owns", command_topic_fn<Commands::Owns::COMMAND_STRUCTURE>},
        {"remove", command_topic_fn<Remove::COMMAND_STRUCTURE>},
        {"search", command_topic_fn<Commands::Search::COMMAND_STRUCTURE>},
        {"topics", help_topics},
    }};

    static void help_topics(const VcpkgPaths&)
    {
        System::print2("Available help topics:\n"
                       "  triplet\n"
                       "  integrate",
                       Strings::join("", topics, [](const Topic& topic) { return std::string("\n  ") + topic.name; }),
                       "\n");
    }

    void help_topic_valid_triplet(const VcpkgPaths& paths)
    {
        System::print2("Available architecture triplets:\n");
        for (auto&& triplet : paths.get_available_triplets())
        {
            System::print2("  ", triplet, '\n');
        }
    }

    void print_usage()
    {
        System::print2("Commands:\n"
                       "  vcpkg search [pat]              Search for packages available to be built\n"
                       "  vcpkg install <pkg>...          Install a package\n"
                       "  vcpkg remove <pkg>...           Uninstall a package\n"
                       "  vcpkg remove --outdated         Uninstall all out-of-date packages\n"
                       "  vcpkg list                      List installed packages\n"
                       "  vcpkg update                    Display list of packages for updating\n"
                       "  vcpkg upgrade                   Rebuild all outdated packages\n"
                       "  vcpkg x-history <pkg>           Shows the history of CONTROL versions of a package\n"
                       "  vcpkg hash <file> [alg]         Hash a file by specific algorithm, default SHA512\n"
                       "  vcpkg help topics               Display the list of help topics\n"
                       "  vcpkg help <topic>              Display help for a specific topic\n"
                       "\n",
                       Commands::Integrate::INTEGRATE_COMMAND_HELPSTRING, // Integration help
                       "\n"
                       "  vcpkg export <pkg>... [opt]...  Exports a package\n"
                       "  vcpkg edit <pkg>                Open up a port for editing (uses " ENVVAR(EDITOR) //
                       ", default 'code')\n"
                       "  vcpkg import <pkg>              Import a pre-built library\n"
                       "  vcpkg create <pkg> <url>\n"
                       "             [archivename]        Create a new package\n"
                       "  vcpkg owns <pat>                Search for files in installed packages\n"
                       "  vcpkg depend-info <pkg>...      Display a list of dependencies for packages\n"
                       "  vcpkg env                       Creates a clean shell environment for development or "
                       "compiling.\n"
                       "  vcpkg version                   Display version information\n"
                       "  vcpkg contact                   Display contact information to send feedback\n"
                       "\n"
                       "Options:\n"
                       "  --triplet <t>                   Specify the target architecture triplet\n"
                       "                                  (default: " ENVVAR(VCPKG_DEFAULT_TRIPLET) //
                       ", see 'vcpkg help triplet')\n"
                       "\n"
                       "  --overlay-ports=<path>          Specify directories to be used when searching for ports\n"
                       "\n"
                       "  --overlay-triplets=<path>       Specify directories containing triplets files\n"
                       "\n"
                       "  --vcpkg-root <path>             Specify the vcpkg root "
                       "directory\n"
                       "                                  (default: " ENVVAR(VCPKG_ROOT) //
                       ")\n"
                       "\n"
                       "  --x-scripts-root=<path>             (Experimental) Specify the scripts root directory\n"
                       "\n"
                       "  @response_file                  Specify a "
                       "response file to provide additional parameters\n"
                       "\n"
                       "For more help (including examples) see the "
                       "accompanying README.md.\n");
    }

    std::string create_example_string(const std::string& command_and_arguments)
    {
        std::string cs = Strings::format("Example:\n"
                                         "  vcpkg %s\n",
                                         command_and_arguments);
        return cs;
    }

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        Util::unused(args.parse_arguments(COMMAND_STRUCTURE));

        if (args.command_arguments.empty())
        {
            print_usage();
            Checks::exit_success(VCPKG_LINE_INFO);
        }
        const auto& topic = args.command_arguments[0];
        if (topic == "triplet" || topic == "triplets" || topic == "triple")
        {
            help_topic_valid_triplet(paths);
            Checks::exit_success(VCPKG_LINE_INFO);
        }

        auto it_topic = Util::find_if(topics, [&](const Topic& t) { return t.name == topic; });
        if (it_topic != topics.end())
        {
            it_topic->print(paths);
            Checks::exit_success(VCPKG_LINE_INFO);
        }

        System::print2(System::Color::error, "Error: unknown topic ", topic, '\n');
        help_topics(paths);
        Checks::exit_fail(VCPKG_LINE_INFO);
    }
}
