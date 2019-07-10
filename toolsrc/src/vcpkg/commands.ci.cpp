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

    struct XunitTestResults
    {
    public:
        XunitTestResults() { m_assembly_run_datetime = Chrono::CTime::get_current_date_time(); }

        void add_test_results(const std::string& spec,
                              const Build::BuildResult& build_result,
                              const Chrono::ElapsedTime& elapsed_time,
                              const std::string& abi_tag)
        {
            m_collections.back().tests.push_back({spec, build_result, elapsed_time, abi_tag});
        }

        // Starting a new test collection
        void push_collection(const std::string& name) { m_collections.push_back({name}); }

        void collection_time(const vcpkg::Chrono::ElapsedTime& time) { m_collections.back().time = time; }

        const std::string& build_xml()
        {
            m_xml.clear();
            xml_start_assembly();

            for (const auto& collection : m_collections)
            {
                xml_start_collection(collection);
                for (const auto& test : collection.tests)
                {
                    xml_test(test);
                }
                xml_finish_collection();
            }

            xml_finish_assembly();
            return m_xml;
        }

        void assembly_time(const vcpkg::Chrono::ElapsedTime& assembly_time) { m_assembly_time = assembly_time; }

    private:
        struct XunitTest
        {
            std::string name;
            vcpkg::Build::BuildResult result;
            vcpkg::Chrono::ElapsedTime time;
            std::string abi_tag;
        };

        struct XunitCollection
        {
            std::string name;
            vcpkg::Chrono::ElapsedTime time;
            std::vector<XunitTest> tests;
        };

        void xml_start_assembly()
        {
            std::string datetime;
            if (m_assembly_run_datetime)
            {
                auto rawDateTime = m_assembly_run_datetime.get()->to_string();
                // The expected format is "yyyy-mm-ddThh:mm:ss.0Z"
                //                         0123456789012345678901
                datetime = Strings::format(
                    R"(run-date="%s" run-time="%s")", rawDateTime.substr(0, 10), rawDateTime.substr(11, 8));
            }

            std::string time = Strings::format(R"(time="%lld")", m_assembly_time.as<std::chrono::seconds>().count());

            m_xml += Strings::format(R"(<assemblies>)"
                                     "\n"
                                     R"(  <assembly name="vcpkg" %s %s>)"
                                     "\n",
                                     datetime,
                                     time);
        }
        void xml_finish_assembly()
        {
            m_xml += "  </assembly>\n"
                     "</assemblies>\n";
        }

        void xml_start_collection(const XunitCollection& collection)
        {
            m_xml += Strings::format(R"(    <collection name="%s" time="%lld">)"
                                     "\n",
                                     collection.name,
                                     collection.time.as<std::chrono::seconds>().count());
        }
        void xml_finish_collection() { m_xml += "    </collection>\n"; }

        void xml_test(const XunitTest& test)
        {
            std::string message_block;
            const char* result_string = "";
            switch (test.result)
            {
                case BuildResult::POST_BUILD_CHECKS_FAILED:
                case BuildResult::FILE_CONFLICTS:
                case BuildResult::BUILD_FAILED:
                    result_string = "Fail";
                    message_block =
                        Strings::format("<failure><message><![CDATA[%s]]></message></failure>", to_string(test.result));
                    break;
                case BuildResult::EXCLUDED:
                case BuildResult::CASCADED_DUE_TO_MISSING_DEPENDENCIES:
                    result_string = "Skip";
                    message_block = Strings::format("<reason><![CDATA[%s]]></reason>", to_string(test.result));
                    break;
                case BuildResult::SUCCEEDED: result_string = "Pass"; break;
                default: Checks::exit_fail(VCPKG_LINE_INFO); break;
            }

            std::string traits_block;
            if (test.abi_tag != "") // only adding if there is a known abi tag
            {
                traits_block = Strings::format(R"(<traits><trait name="abi_tag" value="%s" /></traits>)", test.abi_tag);
            }

            m_xml += Strings::format(R"(      <test name="%s" method="%s" time="%lld" result="%s">%s%s</test>)"
                                     "\n",
                                     test.name,
                                     test.name,
                                     test.time.as<std::chrono::seconds>().count(),
                                     result_string,
                                     traits_block,
                                     message_block);
        }

        Optional<vcpkg::Chrono::CTime> m_assembly_run_datetime;
        vcpkg::Chrono::ElapsedTime m_assembly_time;
        std::vector<XunitCollection> m_collections;

        std::string m_xml;
    };

    struct UnknownCIPortsResults
    {
        std::vector<FullPackageSpec> unknown;
        std::map<PackageSpec, Build::BuildResult> known;
        std::map<PackageSpec, std::vector<std::string>> features;
        std::map<PackageSpec, std::string> abi_tag_map;
    };

    static std::unique_ptr<UnknownCIPortsResults> find_unknown_ports_for_ci(
        const VcpkgPaths& paths,
        const std::set<std::string>& exclusions,
        const Dependencies::PortFileProvider& provider,
        const std::vector<FeatureSpec>& fspecs,
        const bool purge_tombstones)
    {
        auto ret = std::make_unique<UnknownCIPortsResults>();

        auto& fs = paths.get_filesystem();

        std::set<PackageSpec> will_fail;

        const Build::BuildPackageOptions build_options = {
            Build::UseHeadVersion::NO,
            Build::AllowDownloads::YES,
            Build::CleanBuildtrees::YES,
            Build::CleanPackages::YES,
            Build::CleanDownloads::NO,
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
                if (auto scfl = p->source_control_file_location.get())
                {
                    auto triplet = p->spec.triplet();

                    const Build::BuildPackageConfig build_config{
                        *scfl->source_control_file, 
                        triplet, 
                        static_cast<fs::path>(scfl->source_location), 
                        build_options, 
                        p->feature_list
                    };

                    auto dependency_abis =
                        Util::fmap(p->computed_dependencies, [&](const PackageSpec& spec) -> Build::AbiEntry {
                            auto it = ret->abi_tag_map.find(spec);

                            if (it == ret->abi_tag_map.end())
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
                        ret->abi_tag_map.emplace(p->spec, abi);
                    }
                }
                else if (auto ipv = p->installed_package.get())
                {
                    abi = ipv->core->package.abi;
                    if (!abi.empty()) ret->abi_tag_map.emplace(p->spec, abi);
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

                ret->features.emplace(p->spec,
                                      std::vector<std::string>{p->feature_list.begin(), p->feature_list.end()});

                if (Util::Sets::contains(exclusions, p->spec.name()))
                {
                    ret->known.emplace(p->spec, BuildResult::EXCLUDED);
                    will_fail.emplace(p->spec);
                }
                else if (std::any_of(p->computed_dependencies.begin(),
                                     p->computed_dependencies.end(),
                                     [&](const PackageSpec& spec) { return Util::Sets::contains(will_fail, spec); }))
                {
                    ret->known.emplace(p->spec, BuildResult::CASCADED_DUE_TO_MISSING_DEPENDENCIES);
                    will_fail.emplace(p->spec);
                }
                else if (fs.exists(archive_path))
                {
                    state += "pass";
                    ret->known.emplace(p->spec, BuildResult::SUCCEEDED);
                }
                else if (fs.exists(archive_tombstone_path))
                {
                    state += "fail";
                    ret->known.emplace(p->spec, BuildResult::BUILD_FAILED);
                    will_fail.emplace(p->spec);
                }
                else
                {
                    ret->unknown.push_back({p->spec, {p->feature_list.begin(), p->feature_list.end()}});
                    b_will_build = true;
                }

                System::printf("%40s: %1s %8s: %s\n", p->spec, (b_will_build ? "*" : " "), state, abi);
            }
        }

        System::printf("Time to determine pass/fail: %s\n", timer.elapsed());

        return ret;
    }

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet)
    {
        if (!GlobalState::g_binary_caching)
        {
            System::print2(System::Color::warning, "Warning: Running ci without binary caching!\n");
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

        std::vector<Triplet> triplets = Util::fmap(
            args.command_arguments, [](std::string s) { return Triplet::from_canonical_name(std::move(s)); });

        if (triplets.empty())
        {
            triplets.push_back(default_triplet);
        }

        StatusParagraphs status_db = database_load_check(paths);
        
        Dependencies::PathsPortFileProvider provider(paths, args.overlay_ports.get());

        const Build::BuildPackageOptions install_plan_options = {
            Build::UseHeadVersion::NO,
            Build::AllowDownloads::YES,
            Build::CleanBuildtrees::YES,
            Build::CleanPackages::YES,
            Build::CleanDownloads::NO,
            Build::DownloadTool::BUILT_IN,
            GlobalState::g_binary_caching ? Build::BinaryCaching::YES : Build::BinaryCaching::NO,
            Build::FailOnTombstone::YES,
        };

        std::vector<std::map<PackageSpec, BuildResult>> all_known_results;
        std::map<PackageSpec, std::string> abi_tag_map;

        XunitTestResults xunitTestResults;

        std::vector<std::string> all_ports =
            Util::fmap(provider.load_all_control_files(), [](auto&& scfl) -> std::string {
                return scfl->source_control_file.get()->core_paragraph->name;
            });
        std::vector<TripletAndSummary> results;
        auto timer = Chrono::ElapsedTimer::create_started();
        for (const Triplet& triplet : triplets)
        {
            Input::check_triplet(triplet, paths);

            xunitTestResults.push_collection(triplet.canonical_name());

            Dependencies::PackageGraph pgraph(provider, status_db);

            std::vector<PackageSpec> specs = PackageSpec::to_package_specs(all_ports, triplet);
            // Install the default features for every package
            auto all_feature_specs = Util::fmap(specs, [](auto& spec) { return FeatureSpec(spec, ""); });
            auto split_specs =
                find_unknown_ports_for_ci(paths, exclusions_set, provider, all_feature_specs, purge_tombstones);
            auto feature_specs = FullPackageSpec::to_feature_specs(split_specs->unknown);

            for (auto&& fspec : feature_specs)
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

                            for (auto&& feature : split_specs->features[p->spec])
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
                Dependencies::print_plan(action_plan, true, paths.ports);
            }
            else
            {
                auto collection_timer = Chrono::ElapsedTimer::create_started();
                auto summary = Install::perform(action_plan, Install::KeepGoing::YES, paths, status_db);
                auto collection_time_elapsed = collection_timer.elapsed();

                // Adding results for ports that were built or pulled from an archive
                for (auto&& result : summary.results)
                {
                    split_specs->known.erase(result.spec);
                    xunitTestResults.add_test_results(result.spec.to_string(),
                                                      result.build_result.code,
                                                      result.timing,
                                                      split_specs->abi_tag_map.at(result.spec));
                }

                // Adding results for ports that were not built because they have known states
                for (auto&& port : split_specs->known)
                {
                    xunitTestResults.add_test_results(port.first.to_string(),
                                                      port.second,
                                                      Chrono::ElapsedTime{},
                                                      split_specs->abi_tag_map.at(port.first));
                }

                all_known_results.emplace_back(std::move(split_specs->known));
                abi_tag_map.insert(split_specs->abi_tag_map.begin(), split_specs->abi_tag_map.end());

                results.push_back({triplet, std::move(summary)});

                xunitTestResults.collection_time(collection_time_elapsed);
            }
        }
        xunitTestResults.assembly_time(timer.elapsed());

        for (auto&& result : results)
        {
            System::print2("\nTriplet: ", result.triplet, "\n");
            System::print2("Total elapsed time: ", result.summary.total_elapsed_time, "\n");
            result.summary.print();
        }
        auto& fs = paths.get_filesystem();
        auto it_xunit = options.settings.find(OPTION_XUNIT);
        if (it_xunit != options.settings.end())
        {
            fs.write_contents(fs::u8path(it_xunit->second), xunitTestResults.build_xml(), VCPKG_LINE_INFO);
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
