#include "pch.h"

#include <vcpkg/commands.h>
#include <vcpkg/dependencies.h>
#include <vcpkg/help.h>
#include <vcpkg/install.h>
#include <vcpkg/statusparagraphs.h>
#include <vcpkg/update.h>
#include <vcpkg/vcpkglib.h>

namespace vcpkg::Commands::Upgrade
{
    using Install::KeepGoing;
    using Install::to_keep_going;

    static const std::string OPTION_NO_DRY_RUN = "--no-dry-run";
    static const std::string OPTION_KEEP_GOING = "--keep-going";

    static const std::array<CommandSwitch, 2> INSTALL_SWITCHES = {{
        {OPTION_NO_DRY_RUN, "Actually upgrade"},
        {OPTION_KEEP_GOING, "Continue installing packages on failure"},
    }};

    const CommandStructure COMMAND_STRUCTURE = {
        Help::create_example_string("upgrade --no-dry-run"),
        0,
        0,
        {INSTALL_SWITCHES, {}},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet&)
    {
        // input sanitization
        const ParsedArguments options = args.parse_arguments(COMMAND_STRUCTURE);

        const bool no_dry_run = Util::Sets::contains(options.switches, OPTION_NO_DRY_RUN);
        const KeepGoing keep_going = to_keep_going(Util::Sets::contains(options.switches, OPTION_KEEP_GOING));

        // create the plan
        StatusParagraphs status_db = database_load_check(paths);

        Dependencies::PathsPortFileProvider provider(paths);
        Dependencies::PackageGraph graph(provider, status_db);

        auto outdated_packages = Update::find_outdated_packages(provider, status_db);
        for (auto&& outdated_package : outdated_packages)
            graph.upgrade(outdated_package.spec);

        auto plan = graph.serialize();

        if (plan.empty())
        {
            System::println("All packages are up-to-date.");
            Checks::exit_success(VCPKG_LINE_INFO);
        }

        Dependencies::print_plan(plan, true);

        if (!no_dry_run)
        {
            System::println(System::Color::warning,
                            "If you are sure you want to rebuild the above packages, run this command with the "
                            "--no-dry-run option.");
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        const Install::InstallSummary summary = Install::perform(plan, keep_going, paths, status_db);

        System::println("\nTotal elapsed time: %s\n", summary.total_elapsed_time);

        if (keep_going == KeepGoing::YES)
        {
            summary.print();
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
