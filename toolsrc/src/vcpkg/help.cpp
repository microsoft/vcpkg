#include "pch.h"

#include <vcpkg/base/system.print.h>
#include <vcpkg/commands.h>
#include <vcpkg/export.h>
#include <vcpkg/help.h>
#include <vcpkg/install.h>
#include <vcpkg/remove.h>

namespace vcpkg::Help
{
    void HelpTableFormatter::format(StringView col1, StringView col2)
    {
        // 1 space, 32 col1, 1 space, 85 col2 = 119
        m_str.append(1, ' ');
        Strings::append(m_str, col1);
        if (col1.size() > 32)
        {
            newline_indent();
        }
        else
        {
            m_str.append(33 - col1.size(), ' ');
        }
        const char* line_start = col2.begin();
        const char* const e = col2.end();
        const char* best_break = std::find_if(line_start, e, [](char ch) { return ch == ' ' || ch == '\n'; });

        while (best_break != e)
        {
            const char* next_break = std::find_if(best_break + 1, e, [](char ch) { return ch == ' ' || ch == '\n'; });
            if (next_break - line_start > 85 || *best_break == '\n')
            {
                m_str.append(line_start, best_break);
                line_start = best_break + 1;
                best_break = next_break;
                if (line_start != e)
                {
                    newline_indent();
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
    void HelpTableFormatter::newline_indent()
    {
        m_str.push_back('\n');
        indent();
    }
    void HelpTableFormatter::indent() { m_str.append(34, ' '); }

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
        std::map<std::string, std::vector<const VcpkgPaths::TripletFile*>> triplets_per_location;
        vcpkg::Util::group_by(paths.get_available_triplets(),
                              &triplets_per_location,
                              [](const VcpkgPaths::TripletFile& triplet_file) -> std::string {
                                  return triplet_file.location.u8string();
                              });

        System::print2("Available architecture triplets\n");

        System::print2("VCPKG built-in triplets:\n");
        for (auto* triplet : triplets_per_location[paths.triplets.u8string()])
        {
            System::print2("  ", triplet->name, '\n');
        }
        triplets_per_location.erase(paths.triplets.u8string());

        System::print2("\nVCPKG community triplets:\n");
        for (auto* triplet : triplets_per_location[paths.community_triplets.u8string()])
        {
            System::print2("  ", triplet->name, '\n');
        }
        triplets_per_location.erase(paths.community_triplets.u8string());

        for (auto&& kv_pair : triplets_per_location)
        {
            System::print2("\nOverlay triplets from ", kv_pair.first, ":\n");
            for (auto* triplet : kv_pair.second)
            {
                System::print2("  ", triplet->name, '\n');
            }
        }
    }

    void print_usage()
    {
// Write environment variable names as %VARIABLE% on Windows and $VARIABLE in *nix
#ifdef _WIN32
#define ENVVAR(VARNAME) "%" #VARNAME "%"
#else
#define ENVVAR(VARNAME) "$" #VARNAME
#endif

        System::print2(
            "Commands:\n"
            "  vcpkg search [pat]              Search for packages available to be built\n"
            "  vcpkg install <pkg>...          Install a package\n"
            "  vcpkg remove <pkg>...           Uninstall a package\n"
            "  vcpkg remove --outdated         Uninstall all out-of-date packages\n"
            "  vcpkg list                      List installed packages\n"
            "  vcpkg update                    Display list of packages for updating\n"
            "  vcpkg upgrade                   Rebuild all outdated packages\n"
            "  vcpkg x-history <pkg>           (Experimental) Shows the history of CONTROL versions of a package\n"
            "  vcpkg hash <file> [alg]         Hash a file by specific algorithm, default SHA512\n"
            "  vcpkg help topics               Display the list of help topics\n"
            "  vcpkg help <topic>              Display help for a specific topic\n"
            "\n",
            Commands::Integrate::INTEGRATE_COMMAND_HELPSTRING, // Integration help
            "\n"
            "  vcpkg export <pkg>... [opt]...  Exports a package\n"
            // clang-format off
            "  vcpkg edit <pkg>                Open up a port for editing (uses " ENVVAR(EDITOR) ", default 'code')\n"
            "  vcpkg import <pkg>              Import a pre-built library\n"
            "  vcpkg create <pkg> <url> <archivename/REF>\n"
            "               [TRPLET(windows/linux/osx)\n"
            "                BUILD_TYPE(cmake/make/nmake/msbuild/qmake)]\n"
            "  vcpkg owns <pat>                Search for files in installed packages\n"
            "  vcpkg depend-info <pkg>...      Display a list of dependencies for packages\n"
            "  vcpkg env                       Creates a clean shell environment for development or compiling.\n"
            "  vcpkg version                   Display version information\n"
            "  vcpkg contact                   Display contact information to send feedback\n"
            "\n"
            "Options:\n"
            "  --triplet <t>                   Specify the target architecture triplet. See 'vcpkg help triplet'\n"
            "                                  (default: " ENVVAR(VCPKG_DEFAULT_TRIPLET) ")\n"
            "  --overlay-ports=<path>          Specify directories to be used when searching for ports\n"
            "  --overlay-triplets=<path>       Specify directories containing triplets files\n"
            "  --vcpkg-root <path>             Specify the vcpkg root directory\n"
            "                                  (default: " ENVVAR(VCPKG_ROOT) ")\n"
            "  --x-scripts-root=<path>         (Experimental) Specify the scripts root directory\n"
            "\n"
            "  @response_file                  Specify a response file to provide additional parameters\n"
            "\n"
            "For more help (including examples) see the accompanying README.md and docs folder.\n");
        // clang-format on
#undef ENVVAR
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
