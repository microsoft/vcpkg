#include <vcpkg/base/files.h>
#include <vcpkg/base/hash.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/util.h>

#include <vcpkg/binarycaching.h>
#include <vcpkg/build.h>
#include <vcpkg/cmakevars.h>
#include <vcpkg/commands.mirror.h>
#include <vcpkg/commands.setinstalled.h>
#include <vcpkg/dependencies.h>
#include <vcpkg/globalstate.h>
#include <vcpkg/help.h>
#include <vcpkg/input.h>
#include <vcpkg/install.h>
#include <vcpkg/metrics.h>
#include <vcpkg/paragraphs.h>
#include <vcpkg/remove.h>
#include <vcpkg/vcpkglib.h>

namespace vcpkg::Commands::Mirror
{
    using namespace vcpkg;
    using namespace Dependencies;

    static constexpr StringLiteral OPTION_DRY_RUN = "dry-run";
    static constexpr StringLiteral OPTION_USE_ARIA2 = "x-use-aria2";
    static constexpr StringLiteral OPTION_WRITE_PACKAGES_CONFIG = "x-write-nuget-packages-config";

    static constexpr std::array<CommandSwitch, 2> INSTALL_SWITCHES = {{
        {OPTION_DRY_RUN, "Do not actually build or install"},
        {OPTION_USE_ARIA2, "Use aria2 to perform download tasks"},
    }};
    static constexpr std::array<CommandSetting, 1> INSTALL_SETTINGS = {{
        {OPTION_WRITE_PACKAGES_CONFIG,
         "Writes out a NuGet packages.config-formatted file for use with external binary caching.\nSee `vcpkg help "
         "binarycaching` for more information."},
    }};

    const CommandStructure COMMAND_STRUCTURE = {
        create_example_string("mirror"),
        0,
        0,
        {INSTALL_SWITCHES, INSTALL_SETTINGS},
        nullptr,
    };

    ///
    /// <summary>
    /// Run "install" command.
    /// </summary>
    ///
    void perform_and_exit(const VcpkgCmdArguments& inArgs, const VcpkgPaths& paths, Triplet default_triplet)
    {
        // input sanitization
        VcpkgCmdArguments args;
        memcpy(&args, &inArgs, sizeof(VcpkgCmdArguments));
        const ParsedArguments options = args.parse_arguments(COMMAND_STRUCTURE);

        if (args.command_arguments.size())
        {
            args.command_arguments.pop_back();
        }

        args.command_arguments = vcpkg::Install::get_all_port_names(paths);

        auto binaryprovider = create_binary_provider_from_configs(args.binary_sources).value_or_exit(VCPKG_LINE_INFO);

        const bool dry_run = Util::Sets::contains(options.switches, OPTION_DRY_RUN);
        const bool use_aria2 = Util::Sets::contains(options.switches, (OPTION_USE_ARIA2));

        auto& fs = paths.get_filesystem();

        Build::DownloadTool download_tool = Build::DownloadTool::BUILT_IN;
        if (use_aria2) download_tool = Build::DownloadTool::ARIA2;

        const Build::BuildPackageOptions install_plan_options = {
            Util::Enum::to_enum<Build::UseHeadVersion>(false),
            Util::Enum::to_enum<Build::AllowDownloads>(true),
            Util::Enum::to_enum<Build::OnlyDownloads>(true),
            Util::Enum::to_enum<Build::CleanBuildtrees>(true),
            Util::Enum::to_enum<Build::CleanPackages>(true),
            Util::Enum::to_enum<Build::CleanDownloads>(false),
            download_tool,
            Build::PurgeDecompressFailure::NO,
            Util::Enum::to_enum<Build::Editable>(false),
        };

        PortFileProvider::PathsPortFileProvider provider(paths, args.overlay_ports);
        auto var_provider_storage = CMakeVars::make_triplet_cmake_var_provider(paths);
        auto& var_provider = *var_provider_storage;

        if (paths.manifest_mode_enabled())
        {
            Optional<fs::path> pkgsconfig;
            auto it_pkgsconfig = options.settings.find(OPTION_WRITE_PACKAGES_CONFIG);
            if (it_pkgsconfig != options.settings.end())
            {
                pkgsconfig = fs::u8path(it_pkgsconfig->second);
            }

            std::error_code ec;
            auto manifest_path = paths.manifest_root_dir / fs::u8path("vcpkg.json");
            auto maybe_manifest_scf = Paragraphs::try_load_manifest(fs, "manifest", manifest_path, ec);
            if (ec)
            {
                Checks::exit_with_message(
                    VCPKG_LINE_INFO, "Failed to read manifest %s: %s", fs::u8string(manifest_path), ec.message());
            }
            else if (!maybe_manifest_scf)
            {
                print_error_message(maybe_manifest_scf.error());
                Checks::exit_with_message(VCPKG_LINE_INFO, "Failed to read manifest %s.", fs::u8string(manifest_path));
            }
            auto& manifest_scf = *maybe_manifest_scf.value_or_exit(VCPKG_LINE_INFO);

            std::vector<std::string> features;
            auto core_it = Util::find(features, "core");
            features.erase(core_it);
            auto specs = resolve_deps_as_top_level(manifest_scf, default_triplet, features, var_provider);

            auto install_plan = Dependencies::create_feature_install_plan(provider, var_provider, specs, {});

            for (InstallPlanAction& action : install_plan.install_actions)
            {
                action.build_options = install_plan_options;
                action.build_options.use_head_version = Build::UseHeadVersion::NO;
                action.build_options.editable = Build::Editable::NO;
            }

            Commands::SetInstalled::perform_and_exit_ex(args,
                                                        paths,
                                                        provider,
                                                        *binaryprovider,
                                                        var_provider,
                                                        std::move(install_plan),
                                                        dry_run ? Commands::DryRun::Yes : Commands::DryRun::No,
                                                        pkgsconfig);
        }

        const std::vector<FullPackageSpec> specs = Util::fmap(args.command_arguments, [&](auto&& arg) {
            return Input::check_and_get_full_package_spec(
                std::string(arg), default_triplet, COMMAND_STRUCTURE.example_text);
        });

        for (auto&& spec : specs)
        {
            Input::check_triplet(spec.package_spec.triplet(), paths);
        }

        // create the plan
        System::print2("Computing installation plan...\n");
        StatusParagraphs status_db = database_load_check(paths);

        // Note: action_plan will hold raw pointers to SourceControlFileLocations from this map
        auto action_plan = Dependencies::create_feature_install_plan(provider, var_provider, specs, status_db);

        for (auto&& action : action_plan.install_actions)
        {
            action.build_options = install_plan_options;
            if (action.request_type != RequestType::USER_REQUESTED)
            {
                action.build_options.use_head_version = Build::UseHeadVersion::NO;
                action.build_options.editable = Build::Editable::NO;
            }
        }

        var_provider.load_tag_vars(action_plan, provider);

        // install plan will be empty if it is already installed - need to change this at status paragraph part
        Checks::check_exit(VCPKG_LINE_INFO, !action_plan.empty(), "Install plan cannot be empty");

        // log the plan
        std::string specs_string;
        for (auto&& remove_action : action_plan.remove_actions)
        {
            if (!specs_string.empty()) specs_string.push_back(',');
            specs_string += "R$" + Hash::get_string_hash(remove_action.spec.to_string(), Hash::Algorithm::Sha256);
        }

        for (auto&& install_action : action_plan.install_actions)
        {
            if (!specs_string.empty()) specs_string.push_back(',');
            specs_string += Hash::get_string_hash(install_action.spec.to_string(), Hash::Algorithm::Sha256);
        }

#if defined(_WIN32)
        const auto maybe_common_triplet = common_projection(
            action_plan.install_actions, [](const InstallPlanAction& to_install) { return to_install.spec.triplet(); });
        if (maybe_common_triplet)
        {
            const auto& common_triplet = maybe_common_triplet.value_or_exit(VCPKG_LINE_INFO);
            const auto maybe_common_arch = common_triplet.guess_architecture();
            if (maybe_common_arch)
            {
                const auto maybe_vs_prompt = System::guess_visual_studio_prompt_target_architecture();
                if (maybe_vs_prompt)
                {
                    const auto common_arch = maybe_common_arch.value_or_exit(VCPKG_LINE_INFO);
                    const auto vs_prompt = maybe_vs_prompt.value_or_exit(VCPKG_LINE_INFO);
                    if (common_arch != vs_prompt)
                    {
                        const auto vs_prompt_view = to_zstring_view(vs_prompt);
                        System::print2(vcpkg::System::Color::warning,
                                       "warning: vcpkg appears to be in a Visual Studio prompt targeting ",
                                       vs_prompt_view,
                                       " but is installing packages for ",
                                       common_triplet.to_string(),
                                       ". Consider using --triplet ",
                                       vs_prompt_view,
                                       "-windows or --triplet ",
                                       vs_prompt_view,
                                       "-uwp.\n");
                    }
                }
            }
        }
#endif // defined(_WIN32)

        Metrics::g_metrics.lock()->track_property("installplan_1", specs_string);

        Dependencies::print_plan(action_plan, true, paths.ports);

        auto it_pkgsconfig = options.settings.find(OPTION_WRITE_PACKAGES_CONFIG);
        if (it_pkgsconfig != options.settings.end())
        {
            Build::compute_all_abis(paths, action_plan, var_provider, status_db);

            auto pkgsconfig_path = Files::combine(paths.original_cwd, fs::u8path(it_pkgsconfig->second));
            auto pkgsconfig_contents = generate_nuget_packages_config(action_plan);
            fs.write_contents(pkgsconfig_path, pkgsconfig_contents, VCPKG_LINE_INFO);
            System::print2("Wrote NuGet packages config information to ", fs::u8string(pkgsconfig_path), "\n");
        }

        if (dry_run)
        {
            Checks::exit_success(VCPKG_LINE_INFO);
        }

        const vcpkg::Install::InstallSummary summary = vcpkg::Install::perform(action_plan,
                                                                               vcpkg::Install::KeepGoing::YES,
                                                                               paths,
                                                                               status_db,
                                                                               null_binary_provider(),
                                                                               Build::null_build_logs_recorder(),
                                                                               var_provider);

        System::print2("\nTotal elapsed time: ", summary.total_elapsed_time, "\n\n");

        summary.print();

        for (auto&& result : summary.results)
        {
            if (!result.action) continue;
            if (result.action->request_type != RequestType::USER_REQUESTED) continue;
            auto bpgh = result.get_binary_paragraph();
            if (!bpgh) continue;
            vcpkg::Install::print_cmake_information(*bpgh, paths);
        }

        // rename the downloaded files
        std::error_code ec;
        auto downloads = fs.get_files_non_recursive(paths.downloads);

        for (auto&& file : downloads)
        {
            if (!fs.is_directory(file))
            {
                std::string fileHash =
                    vcpkg::Hash::get_file_hash(VCPKG_LINE_INFO, fs, file, vcpkg::Hash::Algorithm::Sha512);
                auto newpath = file.parent_path();
                newpath += "\\";
                newpath += fileHash;
                fs.rename(file, newpath, ec);
            }
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }

    void MirrorCommand::perform_and_exit(const VcpkgCmdArguments& args,
                                         const VcpkgPaths& paths,
                                         Triplet default_triplet) const
    {
        Mirror::perform_and_exit(args, paths, default_triplet);
    }
}
