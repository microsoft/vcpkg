#include <vcpkg/base/system.print.h>

#include <vcpkg/binarycaching.h>
#include <vcpkg/commands.setinstalled.h>
#include <vcpkg/globalstate.h>
#include <vcpkg/help.h>
#include <vcpkg/input.h>
#include <vcpkg/install.h>
#include <vcpkg/metrics.h>
#include <vcpkg/portfileprovider.h>
#include <vcpkg/remove.h>
#include <vcpkg/vcpkgcmdarguments.h>
#include <vcpkg/vcpkglib.h>

namespace vcpkg::Commands::SetInstalled
{
    static constexpr StringLiteral OPTION_DRY_RUN = "dry-run";
    static constexpr StringLiteral OPTION_WRITE_PACKAGES_CONFIG = "x-write-nuget-packages-config";

    static constexpr CommandSwitch INSTALL_SWITCHES[] = {
        {OPTION_DRY_RUN, "Do not actually build or install"},
    };
    static constexpr CommandSetting INSTALL_SETTINGS[] = {
        {OPTION_WRITE_PACKAGES_CONFIG,
         "Writes out a NuGet packages.config-formatted file for use with external binary caching.\n"
         "See `vcpkg help binarycaching` for more information."},
    };

    const CommandStructure COMMAND_STRUCTURE = {
        create_example_string(R"(x-set-installed <package>...)"),
        0,
        SIZE_MAX,
        {INSTALL_SWITCHES, INSTALL_SETTINGS},
        nullptr,
    };

    void perform_and_exit_ex(const VcpkgCmdArguments& args,
                             const VcpkgPaths& paths,
                             const PortFileProvider::PathsPortFileProvider& provider,
                             IBinaryProvider& binary_provider,
                             const CMakeVars::CMakeVarProvider& cmake_vars,
                             Dependencies::ActionPlan action_plan,
                             DryRun dry_run,
                             const Optional<fs::path>& maybe_pkgsconfig)
    {
        cmake_vars.load_tag_vars(action_plan, provider);
        Build::compute_all_abis(paths, action_plan, cmake_vars, {});

        std::set<std::string> all_abis;

        for (const auto& action : action_plan.install_actions)
        {
            all_abis.insert(action.abi_info.value_or_exit(VCPKG_LINE_INFO).package_abi);
        }

        // currently (or once) installed specifications
        auto status_db = database_load_check(paths);
        std::vector<PackageSpec> specs_to_remove;
        std::set<PackageSpec> specs_installed;
        for (auto&& status_pgh : status_db)
        {
            if (!status_pgh->is_installed()) continue;
            if (status_pgh->package.is_feature()) continue;

            const auto& abi = status_pgh->package.abi;
            if (abi.empty() || !Util::Sets::contains(all_abis, abi))
            {
                specs_to_remove.push_back(status_pgh->package.spec);
            }
            else
            {
                specs_installed.emplace(status_pgh->package.spec);
            }
        }

        action_plan.remove_actions = Dependencies::create_remove_plan(specs_to_remove, status_db);

        for (const auto& action : action_plan.remove_actions)
        {
            // This should not technically be needed, however ensuring that all specs to be removed are not included in
            // `specs_installed` acts as a sanity check
            specs_installed.erase(action.spec);
        }

        Util::erase_remove_if(action_plan.install_actions, [&](const Dependencies::InstallPlanAction& ipa) {
            return Util::Sets::contains(specs_installed, ipa.spec);
        });

        Dependencies::print_plan(action_plan, true, paths.ports);

        if (auto p_pkgsconfig = maybe_pkgsconfig.get())
        {
            Build::compute_all_abis(paths, action_plan, cmake_vars, status_db);
            auto& fs = paths.get_filesystem();
            auto pkgsconfig_path = Files::combine(paths.original_cwd, *p_pkgsconfig);
            auto pkgsconfig_contents = generate_nuget_packages_config(action_plan);
            fs.write_contents(pkgsconfig_path, pkgsconfig_contents, VCPKG_LINE_INFO);
            System::print2("Wrote NuGet packages config information to ", fs::u8string(pkgsconfig_path), "\n");
        }

        if (dry_run == DryRun::Yes)
        {
            Checks::exit_success(VCPKG_LINE_INFO);
        }

        const auto summary = Install::perform(action_plan,
                                              Install::KeepGoing::NO,
                                              paths,
                                              status_db,
                                              args.binary_caching_enabled() ? binary_provider : null_binary_provider(),
                                              Build::null_build_logs_recorder(),
                                              cmake_vars);

        System::print2("\nTotal elapsed time: ", summary.total_elapsed_time, "\n\n");

        Checks::exit_success(VCPKG_LINE_INFO);
    }

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

        auto binary_provider = create_binary_provider_from_configs(args.binary_sources).value_or_exit(VCPKG_LINE_INFO);

        const bool dry_run = Util::Sets::contains(options.switches, OPTION_DRY_RUN);

        PortFileProvider::PathsPortFileProvider provider(paths, args.overlay_ports);
        auto cmake_vars = CMakeVars::make_triplet_cmake_var_provider(paths);

        Optional<fs::path> pkgsconfig;
        auto it_pkgsconfig = options.settings.find(OPTION_WRITE_PACKAGES_CONFIG);
        if (it_pkgsconfig != options.settings.end())
        {
            Metrics::g_metrics.lock()->track_property("x-write-nuget-packages-config", "defined");
            pkgsconfig = it_pkgsconfig->second;
        }

        // We have a set of user-requested specs.
        // We need to know all the specs which are required to fulfill dependencies for those specs.
        // Therefore, we see what we would install into an empty installed tree, so we can use the existing code.
        auto action_plan = Dependencies::create_feature_install_plan(provider, *cmake_vars, specs, {});

        for (auto&& action : action_plan.install_actions)
        {
            action.build_options = Build::default_build_package_options;
        }

        perform_and_exit_ex(args,
                            paths,
                            provider,
                            *binary_provider,
                            *cmake_vars,
                            std::move(action_plan),
                            dry_run ? DryRun::Yes : DryRun::No,
                            pkgsconfig);
    }

    void SetInstalledCommand::perform_and_exit(const VcpkgCmdArguments& args,
                                               const VcpkgPaths& paths,
                                               Triplet default_triplet) const
    {
        SetInstalled::perform_and_exit(args, paths, default_triplet);
    }
}
