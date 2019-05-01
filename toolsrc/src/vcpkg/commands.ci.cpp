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
    static constexpr StringLiteral OPTION_COUNT = "--count";

    static constexpr std::array<CommandSetting, 3> CI_SETTINGS = {{
        {OPTION_EXCLUDE, "Comma separated list of ports to skip"},
        {OPTION_XUNIT, "File to output results in XUnit format (internal)"},
        {OPTION_COUNT, "Number of ports to install from the plan"},
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

        XunitTestResults()
        {
            m_assembly_run_datetime = Chrono::CTime::get_current_date_time();
        }

        void add_test_results(const std::string& spec, const Build::BuildResult& build_result, const Chrono::ElapsedTime& elapsed_time, const std::string& abi_tag)
        {
            m_collections.back().tests.push_back({ spec, build_result, elapsed_time, abi_tag });
        }

        // Starting a new test collection
        void push_collection( const std::string& name)
        {
            m_collections.push_back({name});
        }

        void collection_time(const vcpkg::Chrono::ElapsedTime& time)
        {
            m_collections.back().time = time;
        }

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

        void assembly_time(const vcpkg::Chrono::ElapsedTime& assembly_time)
        {
            m_assembly_time = assembly_time;
        }

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
                datetime = Strings::format(R"(run-date="%s" run-time="%s")",
                    rawDateTime.substr(0, 10), rawDateTime.substr(11, 8));
            }

            std::string time = Strings::format(R"(time="%lld")", m_assembly_time.as<std::chrono::seconds>().count());

            m_xml += Strings::format(
                R"(<assemblies>)" "\n"
                R"(  <assembly name="vcpkg" %s %s>)"  "\n"
                , datetime, time);
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
        void xml_finish_collection()
        {
            m_xml += "    </collection>\n";
        }

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
                message_block = Strings::format("<failure><message><![CDATA[%s]]></message></failure>", to_string(test.result));
                break;
            case BuildResult::EXCLUDED:
            case BuildResult::CASCADED_DUE_TO_MISSING_DEPENDENCIES:
                result_string = "Skip";
                message_block = Strings::format("<reason><![CDATA[%s]]></reason>", to_string(test.result));
                break;
            case BuildResult::SUCCEEDED:
                result_string = "Pass";
                break;
            default:
                Checks::exit_fail(VCPKG_LINE_INFO);
                break;
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

    struct CIPortsResults
    {
        std::unordered_map<PackageSpec, Build::BuildResult> known;
        std::vector<Dependencies::AnyAction> action_plan;
    };

    static CIPortsResults find_unknown_ports_for_ci(
        const VcpkgPaths& paths,
        const std::set<std::string>& exclusions,
        const std::vector<FeatureSpec>& feature_specs,
        const bool purge_tombstones,
        const Dependencies::CreateInstallPlanOptions& install_options,
        const Dependencies::PortFileProvider& provider,
        const StatusParagraphs& status_db,
        const Optional<unsigned>& max_install_count)
    {
        CIPortsResults results;

        auto &fs = paths.get_filesystem();

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

        std::unordered_map<PackageSpec, std::string> abi_tag_map;
        std::vector<FullPackageSpec> unknown;

        //Create pgraph and serialize based on all the ports + features
        auto action_plan =
            Dependencies::create_feature_install_plan(
                    provider,
                    feature_specs,
                    status_db,
                    install_options,
                    build_options);

        auto timer = Chrono::ElapsedTimer::create_started();

        auto archives_root_dir = paths.root / "archives";
        auto archives_tombstone_dir = archives_root_dir / "fail";

        if (purge_tombstones)
        {
            std::error_code ec;
            fs.remove(archives_tombstone_dir, ec); // Ignore error
        }

        //For each computed action
        for (const Dependencies::AnyAction& action : action_plan)
        {
            bool will_build = false;
            std::string state;
            std::string abi;

            if (const InstallPlanAction* install_action = action.install_action.get())
            {
                //The computed action is actually an installation action
                if (Util::Sets::contains(exclusions, install_action->spec.name()))
                {
                    //The port is in the exclusions list
                    state = "skip";
                    results.known[install_action->spec] = BuildResult::EXCLUDED;
                }
                else if (std::any_of(install_action->computed_dependencies.begin(),
                            install_action->computed_dependencies.end(),
                            [&](const PackageSpec& spec) {
                        auto known_result = results.known.find(spec);
                        if (known_result != results.known.end())
                        {
                            switch (known_result->second)
                            {
                            case Build::BuildResult::NULLVALUE:
                            case Build::BuildResult::SUCCEEDED:
                                return false;
                            default:
                                return true;
                            }
                        }

                        return false;
                    }))
                {
                    //One of the dependencies was skipped or is in a failed state.
                    state = "fail";
                    results.known[install_action->spec] = BuildResult::CASCADED_DUE_TO_MISSING_DEPENDENCIES;
                }
                else
                {
                    //There are no known missing dependencies
                    const InstalledPackageView* ipv = install_action->installed_package.get();
                    if (ipv && ipv->core && !ipv->core->package.abi.empty())
                    {
                        //If port is already installed check if the abi tag
                        //is already computed.
                        abi = ipv->core->package.abi;
                        abi_tag_map.emplace(install_action->spec, ipv->core->package.abi);
                    }
                    else if (const SourceControlFile* scf = install_action->source_control_file.get())
                    {
                        //Calculate the abi tag
                        const Triplet triplet = install_action->spec.triplet();
                        const Build::BuildPackageConfig build_config {
                            *scf,
                            triplet,
                            paths.port_dir(install_action->spec),
                            build_options,
                            install_action->feature_list};

                        const Build::PreBuildInfo &pre_build_info = pre_build_info_cache.get_lazy(
                            triplet, [&](){ return Build::PreBuildInfo::from_triplet_file(paths, triplet); });

                        //Find the stored abi_tag for each of the dependencies.
                        //We should always be able to find the tags but if not
                        //insert a tag with an empty value. This will cause the
                        //abi calculation to fail, forcing us to rebuild no
                        //matter what.
                        const std::vector<Build::AbiEntry> dependency_abis =
                            Util::fmap(install_action->computed_dependencies,
                                [&](const PackageSpec& spec) -> Build::AbiEntry
                                {
                                    auto it = abi_tag_map.find(spec);
                                    if (it != abi_tag_map.end())
                                    {
                                        //We've already computed the abi tag.
                                        return {spec.name(), it->second};
                                    }

                                    //If we don't have an abi tag insert an empty
                                    //tag, this forces the package to be rebuilt
                                    //no matter what.
                                    return {spec.name(), ""};
                                });

                        Optional<Build::AbiTagAndFile> maybe_tag_and_file =
                            Build::compute_abi_tag(paths, build_config, pre_build_info, dependency_abis); 

                        if (const Build::AbiTagAndFile* tag_and_file = maybe_tag_and_file.get())
                        {
                            abi = tag_and_file->tag;
                            abi_tag_map.emplace(install_action->spec, abi);
                        }
                    }
                    
                    auto archive_name = abi + ".zip";
                    auto archive_subpath = fs::u8path(abi.substr(0, 2)) / archive_name;
                    auto archive_path = archives_root_dir / archive_subpath;
                    auto archive_tombstone_path = archives_tombstone_dir / archive_subpath;
                   
                    if (fs.exists(archive_path))
                    {
                        //We found an archive with the same hash as our port
                        state = "pass";
                        results.known[install_action->spec] = BuildResult::SUCCEEDED;
                    }
                    else if (!purge_tombstones && fs.exists(archive_tombstone_path))
                    {
                        //We're not purging the tombstones and one exists for
                        //this port.
                        state = "fail";
                        results.known[install_action->spec] = BuildResult::BUILD_FAILED;
                    }
                    else
                    {
                        //We actually need to build this port.
                        state = "build";
                        will_build = true;
                        unknown.emplace_back(
                                install_action->spec,
                                install_action->feature_list.begin(),
                                install_action->feature_list.end());
                    }

                    System::printf(
                            "%40s: %1s %8s: %s\n",
                            install_action->spec,
                            (will_build ? "*" : " "),
                            state,
                            abi);
                }
            }
        }

        //Create pgraph and serialize based on all the port we actually need to
        //build.
        action_plan =
            Dependencies::create_feature_install_plan(
                    provider,
                    FullPackageSpec::to_feature_specs(unknown),
                    status_db,
                    install_options,
                    build_options);

        if (max_install_count.has_value())
        {
            using plan_itr = decltype(action_plan)::iterator;
            unsigned max_install_count_val =
                max_install_count.value_or_exit(VCPKG_LINE_INFO);
            //Remove any unnecessary ports from the build plan based on --count
            //parameter.
            results.action_plan =
                {std::move_iterator<plan_itr>(action_plan.begin()),
                action_plan.size() > max_install_count_val ? 
                    std::move_iterator<plan_itr>(action_plan.begin()) + max_install_count_val :
                    std::move_iterator<plan_itr>(action_plan.end())};
        }
        else
        {
            results.action_plan = std::move(action_plan);
        }

        System::printf("Time to determine pass/fail: %s\n", timer.elapsed());

        return results;
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

        Optional<unsigned> max_install_count;
        auto it_count = options.settings.find(OPTION_COUNT);
        if (it_count != options.settings.end())
        {
            max_install_count = Optional<unsigned>(std::stoul(it_count->second));
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

        XunitTestResults xunitTestResults;

        std::vector<std::string> all_ports = Install::get_all_port_names(paths);

        std::vector<TripletAndSummary> results;
        auto timer = Chrono::ElapsedTimer::create_started();
        for (const Triplet& triplet : triplets)
        {
            Input::check_triplet(triplet, paths);

            xunitTestResults.push_collection(triplet.canonical_name());

            std::vector<PackageSpec> specs = PackageSpec::to_package_specs(all_ports, triplet);

            // Install the default features for every package
            auto all_feature_specs = Util::fmap(specs, [](auto& spec) { return FeatureSpec(spec, ""); });

            //This needs to be in scope until we are done installing everything
            //the SourceControlFiles are unique_ptrs insider of it.
            const Dependencies::PortFileProvider &provider = Dependencies::PathsPortFileProvider(paths);

            //Determine the build plan.
            auto split_specs = find_unknown_ports_for_ci(
                paths,
                exclusions_set,
                all_feature_specs,
                purge_tombstones,
                serialize_options,
                provider,
                status_db,
                max_install_count);

            if (is_dry_run)
            {
                Dependencies::print_plan(split_specs.action_plan);
            }
            else
            {
                auto collection_timer = Chrono::ElapsedTimer::create_started();
                auto summary = Install::perform(
                        split_specs.action_plan,
                        Install::KeepGoing::YES,
                        paths,
                        status_db);
                auto collection_time_elapsed = collection_timer.elapsed();

                // Adding results for newly installed ports
                for (auto&& result : summary.results)
                {
                    split_specs.known.erase(result.spec);

                    xunitTestResults.add_test_results(
                        result.spec.to_string(),
                        result.build_result.code,
                        result.timing,
                        result.get_binary_paragraph() ?
                            result.get_binary_paragraph()->abi : "");
                }

                // Adding results for ports that were not built because they have known states
                for (const std::pair<PackageSpec, Build::BuildResult>& known : split_specs.known)
                {
                    System::print2("Here's a known spec");
                    xunitTestResults.add_test_results(
                        known.first.to_string(),
                        known.second,
                        Chrono::ElapsedTime{},
                        "");
                }

                results.push_back({ triplet, std::move(summary)});

                xunitTestResults.collection_time( collection_time_elapsed );
            }
        }

        xunitTestResults.assembly_time(timer.elapsed());

        for (auto&& result : results)
        {
            System::print2("\nTriplet: ", result.triplet, "\n");
            System::print2("Total elapsed time: ", result.summary.total_elapsed_time, "\n");
            result.summary.print();
        }

        auto it_xunit = options.settings.find(OPTION_XUNIT);
        if (it_xunit != options.settings.end())
        {
            paths.get_filesystem().write_contents(fs::u8path(it_xunit->second), xunitTestResults.build_xml());
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
