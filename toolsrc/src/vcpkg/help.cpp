#include <vcpkg/base/system.print.h>

#include <vcpkg/binarycaching.h>
#include <vcpkg/commands.create.h>
#include <vcpkg/commands.dependinfo.h>
#include <vcpkg/commands.edit.h>
#include <vcpkg/commands.env.h>
#include <vcpkg/commands.integrate.h>
#include <vcpkg/commands.list.h>
#include <vcpkg/commands.owns.h>
#include <vcpkg/commands.search.h>
#include <vcpkg/export.h>
#include <vcpkg/help.h>
#include <vcpkg/install.h>
#include <vcpkg/remove.h>

namespace vcpkg::Help
{
    struct Topic
    {
        using topic_function = void (*)(const VcpkgPaths& paths);

        constexpr Topic(CStringView n, topic_function fn) : name(n), print(fn) { }

        CStringView name;
        topic_function print;
    };

    template<const CommandStructure& S>
    static void command_topic_fn(const VcpkgPaths&)
    {
        print_usage(S);
    }

    static void integrate_topic_fn(const VcpkgPaths&)
    {
        System::print2("Commands:\n", Commands::Integrate::get_helpstring());
    }

    static void help_topics(const VcpkgPaths&);

    const CommandStructure COMMAND_STRUCTURE = {
        create_example_string("help"),
        0,
        1,
        {},
        nullptr,
    };

    static void help_topic_versioning(const VcpkgPaths&)
    {
        HelpTableFormatter tbl;
        tbl.text("Versioning allows you to deterministically control the precise revisions of dependencies used by "
                 "your project from within your manifest file.");
        tbl.blank();
        tbl.blank();
        tbl.text("** This feature is experimental and requires `--feature-flags=versions` **");
        tbl.blank();
        tbl.blank();
        tbl.header("Versions in vcpkg come in four primary flavors");
        tbl.format("version", "A dot-separated sequence of numbers (1.2.3.4)");
        tbl.format("version-date", "A date (2021-01-01.5)");
        tbl.format("version-semver", "A Semantic Version 2.0 (2.1.0-rc2)");
        tbl.format("version-string", "An exact, incomparable version (Vista)");
        tbl.blank();
        tbl.text("Each version additionally has a \"port-version\" which is a nonnegative integer. When rendered as "
                 "text, the port version (if nonzero) is added as a suffix to the primary version text separated by a "
                 "hash (#). Port-versions are sorted lexographically after the primary version text, for example:");
        tbl.blank();
        tbl.blank();
        tbl.text("    1.0.0 < 1.0.0#1 < 1.0.1 < 1.0.1#5 < 2.0.0");
        tbl.blank();
        tbl.blank();
        tbl.header("Manifests can place three kinds of constraints upon the versions used");
        tbl.format("builtin-baseline",
                   "The baseline references a commit within the vcpkg repository that establishes a minimum version on "
                   "every dependency in the graph. If no other constraints are specified (directly or transitively), "
                   "then the version from the baseline of the top level manifest will be used. Baselines of transitive "
                   "dependencies are ignored.");
        tbl.blank();
        tbl.format("version>=",
                   "Within the \"dependencies\" field, each dependency can have a minimum constraint listed. These "
                   "minimum constraints will be used when transitively depending upon this library. A minimum "
                   "port-version can additionally be specified with a '#' suffix.");
        tbl.blank();
        tbl.format(
            "overrides",
            "When used as the top-level manifest (such as when running `vcpkg install` in the directory), overrides "
            "allow a manifest to short-circuit dependency resolution and specify exactly the version to use. These can "
            "be used to handle version conflicts, such as with `version-string` dependencies. They will not be "
            "considered when transitively depended upon.");
        tbl.blank();
        tbl.text("Example manifest:");
        tbl.blank();
        tbl.text(R"({
    "name": "example",
    "version": "1.0",
    "builtin-baseline": "a14a6bcb27287e3ec138dba1b948a0cdbc337a3a",
    "dependencies": [
        { "name": "zlib", "version>=": "1.2.11#8" },
        "rapidjson"
    ],
    "overrides": [
        { "name": "rapidjson", "version": "2020-09-14" }
    ]
})");
        System::print2(tbl.m_str,
                       "\nExtended documentation is available at "
                       "https://github.com/Microsoft/vcpkg/tree/master/docs/users/versioning.md\n");
    }

    static constexpr std::array<Topic, 16> topics = {{
        {"binarycaching", help_topic_binary_caching},
        {"create", command_topic_fn<Commands::Create::COMMAND_STRUCTURE>},
        {"depend-info", command_topic_fn<Commands::DependInfo::COMMAND_STRUCTURE>},
        {"edit", command_topic_fn<Commands::Edit::COMMAND_STRUCTURE>},
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
        {"triplet", help_topic_valid_triplet},
        {"versioning", help_topic_versioning},
    }};

    static void help_topics(const VcpkgPaths&)
    {
        System::print2("Available help topics:",
                       Strings::join("", topics, [](const Topic& topic) { return std::string("\n  ") + topic.name; }),
                       "\n");
    }

    void help_topic_valid_triplet(const VcpkgPaths& paths)
    {
        std::map<std::string, std::vector<const VcpkgPaths::TripletFile*>> triplets_per_location;
        vcpkg::Util::group_by(paths.get_available_triplets(),
                              &triplets_per_location,
                              [](const VcpkgPaths::TripletFile& triplet_file) -> std::string {
                                  return fs::u8string(triplet_file.location);
                              });

        System::print2("Available architecture triplets\n");

        System::print2("VCPKG built-in triplets:\n");
        for (auto* triplet : triplets_per_location[fs::u8string(paths.triplets)])
        {
            System::print2("  ", triplet->name, '\n');
        }
        triplets_per_location.erase(fs::u8string(paths.triplets));

        System::print2("\nVCPKG community triplets:\n");
        for (auto* triplet : triplets_per_location[fs::u8string(paths.community_triplets)])
        {
            System::print2("  ", triplet->name, '\n');
        }
        triplets_per_location.erase(fs::u8string(paths.community_triplets));

        for (auto&& kv_pair : triplets_per_location)
        {
            System::print2("\nOverlay triplets from ", kv_pair.first, ":\n");
            for (auto* triplet : kv_pair.second)
            {
                System::print2("  ", triplet->name, '\n');
            }
        }
    }

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        (void)args.parse_arguments(COMMAND_STRUCTURE);

        if (args.command_arguments.empty())
        {
            print_usage();
            Checks::exit_success(VCPKG_LINE_INFO);
        }
        const auto& topic = args.command_arguments[0];
        if (topic == "triplets" || topic == "triple")
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

    void HelpCommand::perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const
    {
        Help::perform_and_exit(args, paths);
    }
}
