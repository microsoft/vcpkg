#include "pch.h"

#include <vcpkg/base/system.print.h>
#include <vcpkg/commands.h>
#include <vcpkg/globalstate.h>
#include <vcpkg/help.h>
#include <vcpkg/input.h>
#include <vcpkg/install.h>
#include <vcpkg/remove.h>
#include <vcpkg/vcpkglib.h>

namespace vcpkg::Commands::SetInstalled
{
    using Install::KeepGoing;

    static constexpr StringLiteral OPTION_NO_DOWNLOADS = "--no-downloads";
    static constexpr StringLiteral OPTION_KEEP_GOING = "--keep-going";
    static constexpr StringLiteral OPTION_USE_ARIA2 = "--x-use-aria2";
    static constexpr StringLiteral OPTION_CLEAN_AFTER_BUILD = "--clean-after-build";

    static constexpr std::array<CommandSwitch, 4> INSTALL_SWITCHES = {{
        {OPTION_NO_DOWNLOADS, "Do not download new sources"},
        {OPTION_KEEP_GOING, "Continue installing packages on failure"},
        {OPTION_USE_ARIA2, "Use aria2 to perform download tasks"},
        {OPTION_CLEAN_AFTER_BUILD, "Clean buildtrees, packages and downloads after building each package"},
    }};

    const CommandStructure COMMAND_STRUCTURE = {
        Help::create_example_string(R"(x-set-installed <package>...)"),
        1,
        SIZE_MAX,
        {INSTALL_SWITCHES},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet)
    {
        // input sanitization
        const ParsedArguments options = args.parse_arguments(COMMAND_STRUCTURE);

        if (!GlobalState::g_binary_caching)
        {
            Checks::exit_with_message(VCPKG_LINE_INFO, "x-set-installed requires --binarycaching");
        }

        const std::vector<FullPackageSpec> specs = Util::fmap(args.command_arguments, [&](auto&& arg) {
            return Input::check_and_get_full_package_spec(
                std::string(arg), default_triplet, COMMAND_STRUCTURE.example_text);
        });

        for (auto&& spec : specs)
        {
            Input::check_triplet(spec.package_spec.triplet(), paths);
        }

        const bool no_downloads = Util::Sets::contains(options.switches, (OPTION_NO_DOWNLOADS));
        const bool use_aria2 = Util::Sets::contains(options.switches, (OPTION_USE_ARIA2));
        const bool clean_after_build = Util::Sets::contains(options.switches, (OPTION_CLEAN_AFTER_BUILD));
        const KeepGoing keep_going = Install::to_keep_going(Util::Sets::contains(options.switches, OPTION_KEEP_GOING));

        Dependencies::PathsPortFileProvider provider(paths);

        auto expanded_specs = FullPackageSpec::to_feature_specs(specs);
        auto target_action_plan = Dependencies::create_feature_install_plan(provider, expanded_specs, {}, {});

        vcpkg::Cache<Triplet, Build::PreBuildInfo> pre_build_info_cache;
        std::map<PackageSpec, std::string> abi_tag_map;
        std::set<std::string> all_abis;

        for (auto&& action : target_action_plan)
        {
            auto& p = action.install_action.value_or_exit(VCPKG_LINE_INFO);
            auto abi = Dependencies::compute_abi_tag(paths, pre_build_info_cache, abi_tag_map, p);
            if (!abi.empty())
            {
                abi_tag_map.emplace(p.spec, abi);
                all_abis.insert(abi);
            }
        }

        auto status_db = database_load_check(paths);

        std::vector<PackageSpec> specs_to_remove;
        Dependencies::PackageGraph pgraph(provider, status_db);
        for (auto&& status_pgh : status_db)
        {
            if (!status_pgh->is_installed()) continue;
            if (status_pgh->package.is_feature()) continue;
            if (status_pgh->package.abi.empty() || !Util::Sets::contains(all_abis, status_pgh->package.abi))
            {
                specs_to_remove.push_back(status_pgh->package.spec);
            }
        }

        auto remove_plan = Dependencies::create_remove_plan(specs_to_remove, status_db);

        for (const auto& action : remove_plan)
        {
            Remove::perform_remove_plan_action(paths, action, Remove::Purge::NO, &status_db);
        }

        auto real_action_plan = Dependencies::create_feature_install_plan(provider, expanded_specs, status_db, {});

        const Build::BuildPackageOptions install_plan_options = {
            Build::UseHeadVersion::NO,
            Util::Enum::to_enum<Build::AllowDownloads>(!no_downloads),
            clean_after_build ? Build::CleanBuildtrees::YES : Build::CleanBuildtrees::NO,
            clean_after_build ? Build::CleanPackages::YES : Build::CleanPackages::NO,
            clean_after_build ? Build::CleanDownloads::YES : Build::CleanDownloads::NO,
            use_aria2 ? Build::DownloadTool::ARIA2 : Build::DownloadTool::BUILT_IN,
            GlobalState::g_binary_caching ? Build::BinaryCaching::YES : Build::BinaryCaching::NO,
            Build::FailOnTombstone::NO,
        };

        for (auto& action : real_action_plan)
        {
            if (auto p = action.install_action.get())
            {
                p->build_options = install_plan_options;
            }
        }

        Dependencies::print_plan(real_action_plan, true);

        const auto summary = perform(real_action_plan, keep_going, paths, status_db);

        System::print2("\nTotal elapsed time: ", summary.total_elapsed_time, "\n\n");

        if (keep_going == KeepGoing::YES)
        {
            summary.print();
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
