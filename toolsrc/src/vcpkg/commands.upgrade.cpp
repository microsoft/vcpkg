#include "pch.h"

#include <vcpkg/commands.h>
#include <vcpkg/dependencies.h>
#include <vcpkg/globalstate.h>
#include <vcpkg/help.h>
#include <vcpkg/input.h>
#include <vcpkg/install.h>
#include <vcpkg/statusparagraphs.h>
#include <vcpkg/update.h>
#include <vcpkg/vcpkglib.h>

#include <vcpkg/base/system.print.h>
#include <vcpkg/base/util.h>

namespace vcpkg::Commands::Upgrade
{
    using Install::KeepGoing;
    using Install::to_keep_going;

    static constexpr StringLiteral OPTION_NO_DRY_RUN = "--no-dry-run";
    static constexpr StringLiteral OPTION_KEEP_GOING = "--keep-going";

    static constexpr std::array<CommandSwitch, 2> INSTALL_SWITCHES = {{
        {OPTION_NO_DRY_RUN, "Actually upgrade"},
        {OPTION_KEEP_GOING, "Continue installing packages on failure"},
    }};

    const CommandStructure COMMAND_STRUCTURE = {
        Help::create_example_string("upgrade --no-dry-run"),
        0,
        SIZE_MAX,
        {INSTALL_SWITCHES, {}},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet)
    {
        const ParsedArguments options = args.parse_arguments(COMMAND_STRUCTURE);

        const bool no_dry_run = Util::Sets::contains(options.switches, OPTION_NO_DRY_RUN);
        const KeepGoing keep_going = to_keep_going(Util::Sets::contains(options.switches, OPTION_KEEP_GOING));

        StatusParagraphs status_db = database_load_check(paths);

        // Load ports from ports dirs
        PortFileProvider::PathsPortFileProvider provider(paths, args.overlay_ports.get());
        CMakeVars::TripletCMakeVarProvider var_provider(paths);

        // input sanitization
        const std::vector<PackageSpec> specs = Util::fmap(args.command_arguments, [&](auto&& arg) {
            return Input::check_and_get_package_spec(std::string(arg), default_triplet, COMMAND_STRUCTURE.example_text);
        });

        for (auto&& spec : specs)
        {
            Input::check_triplet(spec.triplet(), paths);
        }

        Dependencies::ActionPlan action_plan;
        if (specs.empty())
        {
            // If no packages specified, upgrade all outdated packages.
            auto outdated_packages = Update::find_outdated_packages(provider, status_db);

            if (outdated_packages.empty())
            {
                System::print2("All installed packages are up-to-date with the local portfiles.\n");
                Checks::exit_success(VCPKG_LINE_INFO);
            }

            action_plan = Dependencies::create_upgrade_plan(
                provider,
                var_provider,
                Util::fmap(outdated_packages, [](const Update::OutdatedPackage& package) { return package.spec; }),
                status_db);
        }
        else
        {
            std::vector<PackageSpec> not_installed;
            std::vector<PackageSpec> no_portfile;
            std::vector<PackageSpec> to_upgrade;
            std::vector<PackageSpec> up_to_date;

            for (auto&& spec : specs)
            {
                auto it = status_db.find_installed(spec);
                if (it == status_db.end())
                {
                    not_installed.push_back(spec);
                }

                auto maybe_scfl = provider.get_control_file(spec.name());
                if (auto p_scfl = maybe_scfl.get())
                {
                    if (it != status_db.end())
                    {
                        if (p_scfl->source_control_file->core_paragraph->version != (*it)->package.version)
                        {
                            to_upgrade.push_back(spec);
                        }
                        else
                        {
                            up_to_date.push_back(spec);
                        }
                    }
                }
                else
                {
                    no_portfile.push_back(spec);
                }
            }

            Util::sort(not_installed);
            Util::sort(no_portfile);
            Util::sort(up_to_date);
            Util::sort(to_upgrade);

            if (!up_to_date.empty())
            {
                System::print2(System::Color::success, "The following packages are up-to-date:\n");
                System::print2(Strings::join("",
                                             up_to_date,
                                             [](const PackageSpec& spec) { return "    " + spec.to_string() + "\n"; }),
                               '\n');
            }

            if (!not_installed.empty())
            {
                System::print2(System::Color::error, "The following packages are not installed:\n");
                System::print2(Strings::join("",
                                             not_installed,
                                             [](const PackageSpec& spec) { return "    " + spec.to_string() + "\n"; }),
                               '\n');
            }

            if (!no_portfile.empty())
            {
                System::print2(System::Color::error, "The following packages do not have a valid portfile:\n");
                System::print2(Strings::join("",
                                             no_portfile,
                                             [](const PackageSpec& spec) { return "    " + spec.to_string() + "\n"; }),
                               '\n');
            }

            Checks::check_exit(VCPKG_LINE_INFO, not_installed.empty() && no_portfile.empty());

            if (to_upgrade.empty()) Checks::exit_success(VCPKG_LINE_INFO);

            action_plan = Dependencies::create_upgrade_plan(provider, var_provider, to_upgrade, status_db);
        }

        Checks::check_exit(VCPKG_LINE_INFO, !action_plan.empty());

        const Build::BuildPackageOptions install_plan_options = {
            Build::UseHeadVersion::NO,
            Build::AllowDownloads::YES,
            Build::OnlyDownloads::NO,
            Build::CleanBuildtrees::NO,
            Build::CleanPackages::NO,
            Build::CleanDownloads::NO,
            Build::DownloadTool::BUILT_IN,
            GlobalState::g_binary_caching ? Build::BinaryCaching::YES : Build::BinaryCaching::NO,
            Build::FailOnTombstone::NO,
        };

        // Set build settings for all install actions
        for (auto&& action : action_plan.install_actions)
        {
            action.build_options = install_plan_options;
        }

        Dependencies::print_plan(action_plan, true, paths.ports);

        if (!no_dry_run)
        {
            System::print2(System::Color::warning,
                           "If you are sure you want to rebuild the above packages, run this command with the "
                           "--no-dry-run option.\n");
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        const Install::InstallSummary summary =
            Install::perform(action_plan, keep_going, paths, status_db, var_provider);

        System::print2("\nTotal elapsed time: ", summary.total_elapsed_time, "\n\n");

        if (keep_going == KeepGoing::YES)
        {
            summary.print();
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
