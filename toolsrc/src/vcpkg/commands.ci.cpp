#include "pch.h"

#include <vcpkg/base/files.h>
#include <vcpkg/base/system.h>
#include <vcpkg/base/util.h>
#include <vcpkg/build.h>
#include <vcpkg/commands.h>
#include <vcpkg/dependencies.h>
#include <vcpkg/help.h>
#include <vcpkg/input.h>
#include <vcpkg/install.h>
#include <vcpkg/vcpkglib.h>

namespace vcpkg::Commands::CI
{
    using Build::BuildResult;
    using Dependencies::InstallPlanAction;
    using Dependencies::InstallPlanType;

    static Install::InstallSummary run_ci_on_triplet(const Triplet& triplet,
                                                     const VcpkgPaths& paths,
                                                     const std::vector<std::string>& ports,
                                                     const std::set<std::string>& exclusions_set)
    {
        Input::check_triplet(triplet, paths);

        const std::vector<PackageSpec> specs = PackageSpec::to_package_specs(ports, triplet);

        StatusParagraphs status_db = database_load_check(paths);
        const auto& paths_port_file = Dependencies::PathsPortFile(paths);
        std::vector<InstallPlanAction> install_plan =
            Dependencies::create_install_plan(paths_port_file, specs, status_db);

        for (InstallPlanAction& plan : install_plan)
        {
            if (Util::Sets::contains(exclusions_set, plan.spec.name()))
            {
                plan.plan_type = InstallPlanType::EXCLUDED;
            }
        }

        Checks::check_exit(VCPKG_LINE_INFO, !install_plan.empty(), "Install plan cannot be empty");

        const Build::BuildPackageOptions install_plan_options = {
            Build::UseHeadVersion::NO,
            Build::AllowDownloads::YES,
            Build::CleanBuildtrees::YES,
        };

        const std::vector<Dependencies::AnyAction> action_plan =
            Util::fmap(install_plan, [&install_plan_options](InstallPlanAction& install_action) {
                install_action.build_options = install_plan_options;
                return Dependencies::AnyAction(std::move(install_action));
            });

        return Install::perform(action_plan, Install::KeepGoing::YES, paths, status_db);
    }

    struct TripletAndSummary
    {
        Triplet triplet;
        Install::InstallSummary summary;
    };

    static const std::string OPTION_EXCLUDE = "--exclude";
    static const std::string OPTION_XUNIT = "--x-xunit";

    static const std::array<CommandSetting, 2> CI_SETTINGS = {{
        {OPTION_EXCLUDE, "Comma separated list of ports to skip"},
        {OPTION_XUNIT, "File to output results in XUnit format (internal)"},
    }};

    const CommandStructure COMMAND_STRUCTURE = {
        Help::create_example_string("ci x64-windows"),
        0,
        SIZE_MAX,
        {{}, CI_SETTINGS},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet)
    {
        const ParsedArguments options = args.parse_arguments(COMMAND_STRUCTURE);

        std::set<std::string> exclusions_set;
        auto it_exclusions = options.settings.find(OPTION_EXCLUDE);
        if (it_exclusions != options.settings.end())
        {
            auto exclusions = Strings::split(it_exclusions->second, ",");
            exclusions_set.insert(exclusions.begin(), exclusions.end());
        }

        std::vector<Triplet> triplets;
        for (const std::string& triplet : args.command_arguments)
        {
            triplets.push_back(Triplet::from_canonical_name(triplet));
        }

        if (triplets.empty())
        {
            triplets.push_back(default_triplet);
        }

        const std::vector<std::string> ports = Install::get_all_port_names(paths);
        std::vector<TripletAndSummary> results;
        for (const Triplet& triplet : triplets)
        {
            Install::InstallSummary summary = run_ci_on_triplet(triplet, paths, ports, exclusions_set);
            results.push_back({triplet, std::move(summary)});
        }

        for (auto&& result : results)
        {
            System::println("\nTriplet: %s", result.triplet);
            System::println("Total elapsed time: %s", result.summary.total_elapsed_time);
            result.summary.print();
        }

        auto it_xunit = options.settings.find(OPTION_XUNIT);
        if (it_xunit != options.settings.end())
        {
            std::string xunit_doc = "<assemblies><assembly><collection>\n";

            for (auto&& result : results)
                xunit_doc += result.summary.xunit_results();

            xunit_doc += "</collection></assembly></assemblies>\n";
            paths.get_filesystem().write_contents(fs::u8path(it_xunit->second), xunit_doc);
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
