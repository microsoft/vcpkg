#include "pch.h"

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

    static constexpr std::array<Topic, 15> topics = {{
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

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        Util::unused(args.parse_arguments(COMMAND_STRUCTURE));

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
