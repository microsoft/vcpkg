#include "pch.h"

#include <vcpkg/base/system.print.h>
#include <vcpkg/commands.h>
#include <vcpkg/globalstate.h>
#include <vcpkg/help.h>
#include <vcpkg/input.h>
#include <vcpkg/install.h>
#include <vcpkg/remove.h>
#include <vcpkg/portfileprovider.h>
#include <vcpkg/vcpkglib.h>

namespace vcpkg::Commands::SetInstalled
{
    const CommandStructure COMMAND_STRUCTURE = {
        Help::create_example_string(R"(x-set-installed <package>...)"),
        1,
        SIZE_MAX,
        {},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, Triplet default_triplet)
    {
        // input sanitization
        const ParsedArguments options = args.parse_arguments(COMMAND_STRUCTURE);

        const std::vector<FullPackageSpec> specs = Util::fmap(args.command_arguments, [&](auto&& arg) {
            return Input::check_and_get_full_package_spec(
                std::string(arg), default_triplet, COMMAND_STRUCTURE.example_text);
        });

        for (auto&& spec : specs)
        {
            Input::check_triplet(spec.package_spec.triplet(), paths);
        }

        const Build::BuildPackageOptions install_plan_options = {
            Build::UseHeadVersion::NO,
            Build::AllowDownloads::YES,
            Build::OnlyDownloads::NO,
            Build::CleanBuildtrees::YES,
            Build::CleanPackages::YES,
            Build::CleanDownloads::YES,
            Build::DownloadTool::BUILT_IN,
            GlobalState::g_binary_caching ? Build::BinaryCaching::YES : Build::BinaryCaching::NO,
            Build::FailOnTombstone::NO,
        };


        PortFileProvider::PathsPortFileProvider provider(paths, args.overlay_ports.get());
        auto cmake_vars = CMakeVars::make_triplet_cmake_var_provider(paths);

        // We have a set of user-requested specs.
        // We need to know all the specs which are required to fulfill dependencies for those specs.
        // Therefore, we see what we would install into an empty installed tree, so we can use the existing code.
        auto action_plan = Dependencies::create_feature_install_plan(provider, *cmake_vars, specs, {});

        for (auto&& action : action_plan.install_actions)
        {
            action.build_options = install_plan_options;
        }

        cmake_vars->load_tag_vars(action_plan, provider);
        Build::compute_all_abis(paths, action_plan, *cmake_vars, {});

        std::set<std::string> all_abis;

        for (const auto& action : action_plan.install_actions) {
            all_abis.insert(action.package_abi.value_or_exit(VCPKG_LINE_INFO));
        }

        // currently (or once) installed specifications
        auto status_db = database_load_check(paths);
        std::vector<PackageSpec> specs_to_remove;
        for (auto&& status_pgh : status_db)
        {
            if (!status_pgh->is_installed()) continue;
            if (status_pgh->package.is_feature()) continue;

            const auto& abi = status_pgh->package.abi;
            if (abi.empty() || !Util::Sets::contains(all_abis, abi))
            {
                specs_to_remove.push_back(status_pgh->package.spec);
            }
        }

        auto remove_plan = Dependencies::create_remove_plan(specs_to_remove, status_db);

        for (const auto& action : remove_plan)
        {
            Remove::perform_remove_plan_action(paths, action, Remove::Purge::NO, &status_db);
        }

        auto real_action_plan = Dependencies::create_feature_install_plan(provider, *cmake_vars, specs, status_db);

        for (auto& action : real_action_plan.install_actions)
        {
            action.build_options = install_plan_options;
        }

        Dependencies::print_plan(real_action_plan, true);

        const auto summary = Install::perform(real_action_plan, Install::KeepGoing::NO, paths, status_db, *cmake_vars);

        System::print2("\nTotal elapsed time: ", summary.total_elapsed_time, "\n\n");

        Checks::exit_success(VCPKG_LINE_INFO);
    }

}
