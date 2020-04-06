#include "pch.h"

#include <vcpkg/base/cache.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/graphs.h>
#include <vcpkg/base/stringliteral.h>
#include <vcpkg/base/system.h>
#include <vcpkg/base/util.h>
#include <vcpkg/binarycaching.h>
#include <vcpkg/build.h>
#include <vcpkg/commands.h>
#include <vcpkg/dependencies.h>
#include <vcpkg/globalstate.h>
#include <vcpkg/help.h>
#include <vcpkg/input.h>
#include <vcpkg/install.h>
#include <vcpkg/logicexpression.h>
#include <vcpkg/packagespec.h>
#include <vcpkg/vcpkglib.h>

using namespace vcpkg;

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
                              const std::string& abi_tag,
                              const std::vector<std::string>& features)
        {
            m_collections.back().tests.push_back({spec, build_result, elapsed_time, abi_tag, features});
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
            std::vector<std::string> features;
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
            if (test.abi_tag != "")
            {
                traits_block += Strings::format(R"(<trait name="abi_tag" value="%s" />)", test.abi_tag);
            }

            if (!test.features.empty())
            {
                std::string feature_list;
                for (const auto& feature : test.features)
                {
                    if (!feature_list.empty())
                    {
                        feature_list += ", ";
                    }
                    feature_list += feature;
                }

                traits_block += Strings::format(R"(<trait name="features" value="%s" />)", feature_list);
            }

            if (!traits_block.empty())
            {
                traits_block = "<traits>" + traits_block + "</traits>";
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
        std::unordered_map<std::string, SourceControlFileLocation> default_feature_provider;
        std::map<PackageSpec, std::string> abi_map;
    };

    static bool supported_for_triplet(const CMakeVars::CMakeVarProvider& var_provider,
                                      const InstallPlanAction* install_plan)
    {
        auto&& scfl = install_plan->source_control_file_location.value_or_exit(VCPKG_LINE_INFO);
        const std::string& supports_expression = scfl.source_control_file->core_paragraph->supports_expression;
        if (supports_expression.empty())
        {
            return true; // default to 'supported'
        }

        ExpressionContext context = {var_provider.get_tag_vars(install_plan->spec).value_or_exit(VCPKG_LINE_INFO),
                                     install_plan->spec.triplet().canonical_name()};
        auto maybe_result = evaluate_expression(supports_expression, context);
        if (auto b = maybe_result.get())
            return *b;
        else
        {
            System::print2(System::Color::error,
                           "Error: while processing ",
                           install_plan->spec.to_string(),
                           "\n",
                           maybe_result.error());
            Checks::exit_fail(VCPKG_LINE_INFO);
        }
    }

    static std::unique_ptr<UnknownCIPortsResults> find_unknown_ports_for_ci(
        const VcpkgPaths& paths,
        const std::set<std::string>& exclusions,
        const PortFileProvider::PortFileProvider& provider,
        const CMakeVars::CMakeVarProvider& var_provider,
        const std::vector<FullPackageSpec>& specs,
        const bool purge_tombstones)
    {
        auto ret = std::make_unique<UnknownCIPortsResults>();

        std::set<PackageSpec> will_fail;

        const Build::BuildPackageOptions build_options = {
            Build::UseHeadVersion::NO,
            Build::AllowDownloads::YES,
            Build::OnlyDownloads::NO,
            Build::CleanBuildtrees::YES,
            Build::CleanPackages::YES,
            Build::CleanDownloads::NO,
            Build::DownloadTool::BUILT_IN,
            GlobalState::g_binary_caching ? Build::BinaryCaching::YES : Build::BinaryCaching::NO,
            Build::FailOnTombstone::YES,
        };

        std::vector<PackageSpec> packages_with_qualified_deps;
        auto has_qualifier = [](Dependency const& dep) { return !dep.qualifier.empty(); };
        for (auto&& spec : specs)
        {
            auto&& scfl = provider.get_control_file(spec.package_spec.name()).value_or_exit(VCPKG_LINE_INFO);
            if (Util::any_of(scfl.source_control_file->core_paragraph->depends, has_qualifier) ||
                Util::any_of(scfl.source_control_file->feature_paragraphs,
                             [&](auto&& pgh) { return Util::any_of(pgh->depends, has_qualifier); }))
            {
                packages_with_qualified_deps.push_back(spec.package_spec);
            }
        }

        var_provider.load_dep_info_vars(packages_with_qualified_deps);
        auto action_plan = Dependencies::create_feature_install_plan(provider, var_provider, specs, {}, {});

        std::vector<FullPackageSpec> install_specs;
        for (auto&& install_action : action_plan.install_actions)
        {
            install_specs.emplace_back(FullPackageSpec{install_action.spec, install_action.feature_list});
        }

        var_provider.load_tag_vars(install_specs, provider);

        auto timer = Chrono::ElapsedTimer::create_started();

        Checks::check_exit(VCPKG_LINE_INFO,
                           action_plan.already_installed.empty(),
                           "Cannot use CI command with packages already installed.");

        Build::compute_all_abis(paths, action_plan, var_provider, {});

        auto binaryprovider = create_archives_provider();

        std::string stdout_buffer;
        for (auto&& action : action_plan.install_actions)
        {
            auto p = &action;
            ret->abi_map.emplace(action.spec, action.package_abi.value_or_exit(VCPKG_LINE_INFO));
            ret->features.emplace(action.spec, action.feature_list);
            if (auto scfl = p->source_control_file_location.get())
            {
                auto emp = ret->default_feature_provider.emplace(p->spec.name(), *scfl);
                emp.first->second.source_control_file->core_paragraph->default_features = p->feature_list;

                p->build_options = build_options;
            }

            auto precheck_result = binaryprovider->precheck(paths, action, purge_tombstones);
            bool b_will_build = false;

            std::string state;

            if (Util::Sets::contains(exclusions, p->spec.name()))
            {
                state = "skip";
                ret->known.emplace(p->spec, BuildResult::EXCLUDED);
                will_fail.emplace(p->spec);
            }
            else if (!supported_for_triplet(var_provider, p))
            {
                // This treats unsupported ports as if they are excluded
                // which means the ports dependent on it will be cascaded due to missing dependencies
                // Should this be changed so instead it is a failure to depend on a unsupported port?
                state = "n/a";
                ret->known.emplace(p->spec, BuildResult::EXCLUDED);
                will_fail.emplace(p->spec);
            }
            else if (Util::any_of(p->package_dependencies,
                                  [&](const PackageSpec& spec) { return Util::Sets::contains(will_fail, spec); }))
            {
                state = "cascade";
                ret->known.emplace(p->spec, BuildResult::CASCADED_DUE_TO_MISSING_DEPENDENCIES);
                will_fail.emplace(p->spec);
            }
            else if (precheck_result == RestoreResult::success)
            {
                state = "pass";
                ret->known.emplace(p->spec, BuildResult::SUCCEEDED);
            }
            else if (precheck_result == RestoreResult::build_failed)
            {
                state = "fail";
                ret->known.emplace(p->spec, BuildResult::BUILD_FAILED);
                will_fail.emplace(p->spec);
            }
            else
            {
                ret->unknown.push_back(FullPackageSpec{p->spec, {p->feature_list.begin(), p->feature_list.end()}});
                b_will_build = true;
            }

            Strings::append(stdout_buffer,
                            Strings::format("%40s: %1s %8s: %s\n",
                                            p->spec,
                                            (b_will_build ? "*" : " "),
                                            state,
                                            action.package_abi.value_or_exit(VCPKG_LINE_INFO)));
            if (stdout_buffer.size() > 2048)
            {
                System::print2(stdout_buffer);
                stdout_buffer.clear();
            }
        }
        System::print2(stdout_buffer);
        stdout_buffer.clear();

        System::printf("Time to determine pass/fail: %s\n", timer.elapsed());

        return ret;
    }

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, Triplet default_triplet)
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

        PortFileProvider::PathsPortFileProvider provider(paths, args.overlay_ports.get());
        auto var_provider_storage = CMakeVars::make_triplet_cmake_var_provider(paths);
        auto& var_provider = *var_provider_storage;

        const Build::BuildPackageOptions install_plan_options = {
            Build::UseHeadVersion::NO,
            Build::AllowDownloads::YES,
            Build::OnlyDownloads::NO,
            Build::CleanBuildtrees::YES,
            Build::CleanPackages::YES,
            Build::CleanDownloads::NO,
            Build::DownloadTool::BUILT_IN,
            GlobalState::g_binary_caching ? Build::BinaryCaching::YES : Build::BinaryCaching::NO,
            Build::FailOnTombstone::YES,
            Build::PurgeDecompressFailure::YES,
        };

        std::vector<std::map<PackageSpec, BuildResult>> all_known_results;

        XunitTestResults xunitTestResults;

        std::vector<std::string> all_ports =
            Util::fmap(provider.load_all_control_files(), [](const SourceControlFileLocation*& scfl) -> std::string {
                return scfl->source_control_file.get()->core_paragraph->name;
            });
        std::vector<TripletAndSummary> results;
        auto timer = Chrono::ElapsedTimer::create_started();
        for (Triplet triplet : triplets)
        {
            Input::check_triplet(triplet, paths);

            xunitTestResults.push_collection(triplet.canonical_name());

            std::vector<PackageSpec> specs = PackageSpec::to_package_specs(all_ports, triplet);
            // Install the default features for every package
            auto all_default_full_specs = Util::fmap(specs, [&](auto& spec) {
                std::vector<std::string> default_features =
                    provider.get_control_file(spec.name()).get()->source_control_file->core_paragraph->default_features;
                default_features.emplace_back("core");
                return FullPackageSpec{spec, std::move(default_features)};
            });

            auto split_specs = find_unknown_ports_for_ci(
                paths, exclusions_set, provider, var_provider, all_default_full_specs, purge_tombstones);
            PortFileProvider::MapPortFileProvider new_default_provider(split_specs->default_feature_provider);

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

            auto action_plan = Dependencies::create_feature_install_plan(
                new_default_provider, var_provider, split_specs->unknown, status_db, serialize_options);

            for (auto&& action : action_plan.install_actions)
            {
                if (Util::Sets::contains(exclusions_set, action.spec.name()))
                {
                    action.plan_type = InstallPlanType::EXCLUDED;
                }
                else
                {
                    action.build_options = install_plan_options;
                }
            }

            if (is_dry_run)
            {
                Dependencies::print_plan(action_plan, true, paths.ports);
            }
            else
            {
                auto collection_timer = Chrono::ElapsedTimer::create_started();
                auto summary = Install::perform(action_plan, Install::KeepGoing::YES, paths, status_db, var_provider);
                auto collection_time_elapsed = collection_timer.elapsed();

                // Adding results for ports that were built or pulled from an archive
                for (auto&& result : summary.results)
                {
                    auto& port_features = split_specs->features.at(result.spec);
                    split_specs->known.erase(result.spec);
                    xunitTestResults.add_test_results(result.spec.to_string(),
                                                      result.build_result.code,
                                                      result.timing,
                                                      split_specs->abi_map.at(result.spec),
                                                      port_features);
                }

                // Adding results for ports that were not built because they have known states
                for (auto&& port : split_specs->known)
                {
                    auto& port_features = split_specs->features.at(port.first);
                    xunitTestResults.add_test_results(port.first.to_string(),
                                                      port.second,
                                                      Chrono::ElapsedTime{},
                                                      split_specs->abi_map.at(port.first),
                                                      port_features);
                }

                all_known_results.emplace_back(std::move(split_specs->known));

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
