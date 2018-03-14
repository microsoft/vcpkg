#include "pch.h"

#include <vcpkg/base/files.h>
#include <vcpkg/base/stringliteral.h>
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

    struct TripletAndSummary
    {
        Triplet triplet;
        Install::InstallSummary summary;
    };

    static constexpr StringLiteral OPTION_DRY_RUN = "--dry-run";
    static constexpr StringLiteral OPTION_EXCLUDE = "--exclude";
    static constexpr StringLiteral OPTION_XUNIT = "--x-xunit";

    static constexpr std::array<CommandSetting, 2> CI_SETTINGS = {{
        {OPTION_EXCLUDE, "Comma separated list of ports to skip"},
        {OPTION_XUNIT, "File to output results in XUnit format (internal)"},
    }};

    static constexpr std::array<CommandSwitch, 1> CI_SWITCHES = {
        {{OPTION_DRY_RUN, "Print out plan without execution"}}};

    const CommandStructure COMMAND_STRUCTURE = {
        Help::create_example_string("ci x64-windows"),
        1,
        SIZE_MAX,
        {CI_SWITCHES, CI_SETTINGS},
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

        auto is_dry_run = Util::Sets::contains(options.switches, OPTION_DRY_RUN);

        std::vector<Triplet> triplets;
        for (const std::string& triplet : args.command_arguments)
        {
            triplets.push_back(Triplet::from_canonical_name(triplet));
        }

        if (triplets.empty())
        {
            triplets.push_back(default_triplet);
        }

        StatusParagraphs status_db = database_load_check(paths);
        const auto& paths_port_file = Dependencies::PathsPortFileProvider(paths);

        const Build::BuildPackageOptions install_plan_options = {Build::UseHeadVersion::NO,
                                                                 Build::AllowDownloads::YES,
                                                                 Build::CleanBuildtrees::YES,
                                                                 Build::CleanPackages::YES};

        std::vector<std::string> ports = Install::get_all_port_names(paths);
        std::vector<TripletAndSummary> results;
        for (const Triplet& triplet : triplets)
        {
            Input::check_triplet(triplet, paths);
            std::vector<PackageSpec> specs = PackageSpec::to_package_specs(ports, triplet);
            // Install the default features for every package
            const auto featurespecs = Util::fmap(specs, [](auto& spec) { return FeatureSpec(spec, ""); });

            auto action_plan = Dependencies::create_feature_install_plan(paths_port_file, featurespecs, status_db);

            for (auto&& action : action_plan)
            {
                if (auto p = action.install_action.get())
                {
                    p->build_options = install_plan_options;
                    if (Util::Sets::contains(exclusions_set, p->spec.name()))
                    {
                        p->plan_type = InstallPlanType::EXCLUDED;
                    }
                }
            }

            if (is_dry_run)
            {
                Dependencies::print_plan(action_plan);
            }
            else
            {
                auto summary = Install::perform(action_plan, Install::KeepGoing::YES, paths, status_db);
                results.push_back({triplet, std::move(summary)});
            }
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
