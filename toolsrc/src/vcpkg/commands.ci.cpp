#include "pch.h"

#include <vcpkg/base/cache.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/graphs.h>
#include <vcpkg/base/stringliteral.h>
#include <vcpkg/base/system.h>
#include <vcpkg/base/util.h>
#include <vcpkg/build.h>
#include <vcpkg/commands.h>
#include <vcpkg/dependencies.h>
#include <vcpkg/globalstate.h>
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
    static constexpr StringLiteral OPTION_PURGE_TOMBSTONES = "--purge-tombstones";
    static constexpr StringLiteral OPTION_XUNIT = "--x-xunit";
    static constexpr StringLiteral OPTION_RANDOMIZE = "--x-randomize";

    static constexpr std::array<CommandSetting, 2> CI_SETTINGS = {{
        {OPTION_EXCLUDE, "Comma separated list of ports to skip"},
        {OPTION_XUNIT, "File to output results in XUnit format (internal)"},
    }};

    static constexpr std::array<CommandSwitch, 3> CI_SWITCHES = {{
        {OPTION_DRY_RUN, "Print out plan without execution"},
        {OPTION_RANDOMIZE, "Randomize the install order"},
        {OPTION_PURGE_TOMBSTONES, "Purge failure tombstones and retry building the ports"},
    }};

    const CommandStructure COMMAND_STRUCTURE = {
        Help::create_example_string("ci x64-windows"),
        1,
        SIZE_MAX,
        {CI_SWITCHES, CI_SETTINGS},
        nullptr,
    };

    struct UnknownCIPortsResults
    {
        std::vector<FullPackageSpec> unknown;
        std::map<PackageSpec, Build::BuildResult> known;
        std::map<PackageSpec, std::vector<std::string>> features;
    };

    static UnknownCIPortsResults find_unknown_ports_for_ci(const VcpkgPaths& paths,
                                                           const std::set<std::string>& exclusions,
                                                           const Dependencies::PortFileProvider& provider,
                                                           const std::vector<FeatureSpec>& fspecs,
                                                           const bool purge_tombstones)
    {
        UnknownCIPortsResults ret;

        auto& fs = paths.get_filesystem();

        std::map<PackageSpec, std::string> abi_tag_map;
        std::set<PackageSpec> will_fail;

        const Build::BuildPackageOptions build_options = {
            Build::UseHeadVersion::NO,
            Build::AllowDownloads::YES,
            Build::CleanBuildtrees::YES,
            Build::CleanPackages::YES,
            Build::DownloadTool::BUILT_IN,
            GlobalState::g_binary_caching ? Build::BinaryCaching::YES : Build::BinaryCaching::NO,
            Build::FailOnTombstone::YES,
        };

        vcpkg::Cache<Triplet, Build::PreBuildInfo> pre_build_info_cache;

        auto action_plan = Dependencies::create_feature_install_plan(provider, fspecs, {}, {});

        auto timer = Chrono::ElapsedTimer::create_started();

        for (auto&& action : action_plan)
        {
            if (auto p = action.install_action.get())
            {
                // determine abi tag
                std::string abi;
                if (auto scf = p->source_control_file.get())
                {
                    auto triplet = p->spec.triplet();

                    const Build::BuildPackageConfig build_config {
                        *scf, triplet, paths.port_dir(p->spec), build_options, p->feature_list};

                    auto dependency_abis =
                        Util::fmap(p->computed_dependencies, [&](const PackageSpec& spec) -> Build::AbiEntry {
                            auto it = abi_tag_map.find(spec);

                            if (it == abi_tag_map.end())
                                return {spec.name(), ""};
                            else
                                return {spec.name(), it->second};
                        });
                    const auto& pre_build_info = pre_build_info_cache.get_lazy(
                        triplet, [&]() { return Build::PreBuildInfo::from_triplet_file(paths, triplet); });

                    auto maybe_tag_and_file =
                        Build::compute_abi_tag(paths, build_config, pre_build_info, dependency_abis);
                    if (auto tag_and_file = maybe_tag_and_file.get())
                    {
                        abi = tag_and_file->tag;
                        abi_tag_map.emplace(p->spec, abi);
                    }
                }
                else if (auto ipv = p->installed_package.get())
                {
                    abi = ipv->core->package.abi;
                    if (!abi.empty()) abi_tag_map.emplace(p->spec, abi);
                }

                std::string state;

                auto archives_root_dir = paths.root / "archives";
                auto archive_name = abi + ".zip";
                auto archive_subpath = fs::u8path(abi.substr(0, 2)) / archive_name;
                auto archive_path = archives_root_dir / archive_subpath;
                auto archive_tombstone_path = archives_root_dir / "fail" / archive_subpath;

                if (purge_tombstones)
                {
                    std::error_code ec;
                    fs.remove(archive_tombstone_path, ec); // Ignore error
                }

                bool b_will_build = false;

                ret.features.emplace(p->spec,
                                     std::vector<std::string> {p->feature_list.begin(), p->feature_list.end()});

                if (Util::Sets::contains(exclusions, p->spec.name()))
                {
                    ret.known.emplace(p->spec, BuildResult::EXCLUDED);
                    will_fail.emplace(p->spec);
                }
                else if (std::any_of(p->computed_dependencies.begin(),
                                     p->computed_dependencies.end(),
                                     [&](const PackageSpec& spec) { return Util::Sets::contains(will_fail, spec); }))
                {
                    ret.known.emplace(p->spec, BuildResult::CASCADED_DUE_TO_MISSING_DEPENDENCIES);
                    will_fail.emplace(p->spec);
                }
                else if (fs.exists(archive_path))
                {
                    state += "pass";
                    ret.known.emplace(p->spec, BuildResult::SUCCEEDED);
                }
                else if (fs.exists(archive_tombstone_path))
                {
                    state += "fail";
                    ret.known.emplace(p->spec, BuildResult::BUILD_FAILED);
                    will_fail.emplace(p->spec);
                }
                else
                {
                    ret.unknown.push_back({p->spec, {p->feature_list.begin(), p->feature_list.end()}});
                    b_will_build = true;
                }

                System::println("%40s: %1s %8s: %s", p->spec, (b_will_build ? "*" : " "), state, abi);
            }
        }

        System::print("Time to determine pass/fail: %s\n", timer.elapsed().to_string());

        return ret;
    }

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet)
    {
        if (!GlobalState::g_binary_caching)
        {
            System::println(System::Color::warning, "Warning: Running ci without binary caching!");
        }

        const ParsedArguments options = args.parse_arguments(COMMAND_STRUCTURE);

        std::set<std::string> exclusions_set;
        auto it_exclusions = options.settings.find(OPTION_EXCLUDE);
        if (it_exclusions != options.settings.end())
        {
            auto exclusions = Strings::split(it_exclusions->second, ",");
            exclusions_set.insert(exclusions.begin(), exclusions.end());
        }

        const auto is_dry_run = Util::Sets::contains(options.switches, OPTION_DRY_RUN);
        const auto purge_tombstones = Util::Sets::contains(options.switches, OPTION_PURGE_TOMBSTONES);

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

        const Build::BuildPackageOptions install_plan_options = {
            Build::UseHeadVersion::NO,
            Build::AllowDownloads::YES,
            Build::CleanBuildtrees::YES,
            Build::CleanPackages::YES,
            Build::DownloadTool::BUILT_IN,
            GlobalState::g_binary_caching ? Build::BinaryCaching::YES : Build::BinaryCaching::NO,
            Build::FailOnTombstone::YES,
        };

        std::vector<std::map<PackageSpec, BuildResult>> all_known_results;

        std::vector<std::string> all_ports = Install::get_all_port_names(paths);
        std::vector<TripletAndSummary> results;
        for (const Triplet& triplet : triplets)
        {
            Input::check_triplet(triplet, paths);

            Dependencies::PackageGraph pgraph(paths_port_file, status_db);

            std::vector<PackageSpec> specs = PackageSpec::to_package_specs(all_ports, triplet);
            // Install the default features for every package
            auto all_fspecs = Util::fmap(specs, [](auto& spec) { return FeatureSpec(spec, ""); });
            auto split_specs =
                find_unknown_ports_for_ci(paths, exclusions_set, paths_port_file, all_fspecs, purge_tombstones);
            auto fspecs = FullPackageSpec::to_feature_specs(split_specs.unknown);

            for (auto&& fspec : fspecs)
                pgraph.install(fspec);

            Dependencies::CreateInstallPlanOptions serialize_options;

            struct RandomizerInstance : Graphs::Randomizer
            {
                virtual int random(int i) override
                {
                    if (i <= 1) return 0;
                    std::uniform_int_distribution<int> d(0, i - 1);
                    return d(e);
                }

                std::random_device e;
            } randomizer_instance;

            if (Util::Sets::contains(options.switches, OPTION_RANDOMIZE))
            {
                serialize_options.randomizer = &randomizer_instance;
            }

            auto action_plan = [&]() {
                int iterations = 0;
                do
                {
                    bool inconsistent = false;
                    auto action_plan = pgraph.serialize(serialize_options);

                    for (auto&& action : action_plan)
                    {
                        if (auto p = action.install_action.get())
                        {
                            p->build_options = install_plan_options;
                            if (Util::Sets::contains(exclusions_set, p->spec.name()))
                            {
                                p->plan_type = InstallPlanType::EXCLUDED;
                            }

                            for (auto&& feature : split_specs.features[p->spec])
                                if (p->feature_list.find(feature) == p->feature_list.end())
                                {
                                    pgraph.install({p->spec, feature});
                                    inconsistent = true;
                                }
                        }
                    }

                    if (!inconsistent) return action_plan;
                    Checks::check_exit(VCPKG_LINE_INFO, ++iterations < 100);
                } while (true);
            }();

            if (is_dry_run)
            {
                Dependencies::print_plan(action_plan);
            }
            else
            {
                auto summary = Install::perform(action_plan, Install::KeepGoing::YES, paths, status_db);
                for (auto&& result : summary.results)
                    split_specs.known.erase(result.spec);
                results.push_back({triplet, std::move(summary)});
                all_known_results.emplace_back(std::move(split_specs.known));
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
            for (auto&& known_result : all_known_results)
            {
                for (auto&& result : known_result)
                {
                    xunit_doc +=
                        Install::InstallSummary::xunit_result(result.first, Chrono::ElapsedTime {}, result.second);
                }
            }

            xunit_doc += "</collection></assembly></assemblies>\n";
            paths.get_filesystem().write_contents(fs::u8path(it_xunit->second), xunit_doc);
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
