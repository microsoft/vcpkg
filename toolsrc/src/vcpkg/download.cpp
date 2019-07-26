#include "pch.h"

#include <vcpkg/base/files.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/util.h>
#include <vcpkg/build.h>
#include <vcpkg/commands.h>
#include <vcpkg/dependencies.h>
#include <vcpkg/download.h>
#include <vcpkg/globalstate.h>
#include <vcpkg/help.h>
#include <vcpkg/input.h>
#include <vcpkg/metrics.h>
#include <vcpkg/paragraphs.h>
#include <vcpkg/remove.h>
#include <vcpkg/vcpkglib.h>

namespace vcpkg::Download
{
    using namespace Dependencies;

    using Build::BuildResult;
    using Build::ExtendedBuildResult;

	/*
    ExtendedBuildResult perform_install_plan_action(const VcpkgPaths& paths,
                                                    const InstallPlanAction& action,
                                                    StatusParagraphs& status_db)
    {
        const InstallPlanType& plan_type = action.plan_type;
        const std::string display_name = action.spec.to_string();
        const std::string display_name_with_features = action.displayname();

        const bool is_user_requested = action.request_type == RequestType::USER_REQUESTED;
        const bool use_head_version = Util::Enum::to_bool(action.build_options.use_head_version);

        auto aux_install = [&](const std::string& name, const BinaryControlFile& bcf) -> BuildResult {
            System::printf("Downloading package %s...\n", name);
            const auto install_result = Install::install_package(paths, bcf, &status_db);
            switch (install_result)
            {
                case Install::InstallResult::SUCCESS:
                    System::printf(System::Color::success, "Downloading package %s... done\n", name);
                    return BuildResult::SUCCEEDED;
                case Install::InstallResult::FILE_CONFLICTS: return BuildResult::FILE_CONFLICTS;
                default: Checks::unreachable(VCPKG_LINE_INFO);
            }
        };

        if (use_head_version)
            System::printf("Downloading package %s from HEAD...\n", display_name_with_features);
        else
            System::printf("Downloading package %s...\n", display_name_with_features);

        auto result = [&]() -> Build::ExtendedBuildResult {
            const auto& scfl = action.source_control_file_location.value_or_exit(VCPKG_LINE_INFO);
            const Build::BuildPackageConfig build_config{
                scfl, action.spec.triplet(), action.build_options, action.feature_list};
            return Build::build_package(paths, build_config, status_db);
        }();

        if (result.code != Build::BuildResult::SUCCEEDED)
        {
            System::print2(System::Color::error, Build::create_error_message(result, action.spec), "\n");
            return result;
        }

        System::printf("Downloading package %s... done\n", display_name_with_features);

        return result;

        Checks::unreachable(VCPKG_LINE_INFO);
    }
	*/

    /*
     
    Install::InstallSummary perform(const std::vector<AnyAction>& action_plan,
                                    const Install::KeepGoing keep_going,
                                    const VcpkgPaths& paths,
                                    StatusParagraphs& status_db)
    {
        std::vector<Install::SpecSummary> results;

        const auto timer = Chrono::ElapsedTimer::create_started();
        size_t counter = 0;
        const size_t package_count = action_plan.size();

        for (const auto& action : action_plan)
        {
            const auto build_timer = Chrono::ElapsedTimer::create_started();
            counter++;

            const PackageSpec& spec = action.spec();
            const std::string display_name = spec.to_string();
            System::printf("Starting package %zd/%zd: %s\n", counter, package_count, display_name);

            results.emplace_back(spec, &action);

            if (const auto install_action = action.install_action.get())
            {
                auto result = perform_install_plan_action(paths, *install_action, status_db);

                if (result.code != BuildResult::SUCCEEDED && keep_going == Install::KeepGoing::NO)
                {
                    System::print2(Build::create_user_troubleshooting_message(install_action->spec), '\n');
                    Checks::exit_fail(VCPKG_LINE_INFO);
                }

                results.back().build_result = std::move(result);
            }
            else if (const auto remove_action = action.remove_action.get())
            {
                Remove::perform_remove_plan_action(paths, *remove_action, Remove::Purge::YES, &status_db);
            }
            else
            {
                Checks::unreachable(VCPKG_LINE_INFO);
            }

            results.back().timing = build_timer.elapsed();
            System::printf("Elapsed time for package %s: %s\n", display_name, results.back().timing);
        }

        return Install::InstallSummary{std::move(results), timer.to_string()};
    }
	*/

    static constexpr StringLiteral OPTION_USE_HEAD_VERSION = "--head";
    static constexpr StringLiteral OPTION_KEEP_GOING = "--keep-going";
    static constexpr StringLiteral OPTION_USE_ARIA2 = "--x-use-aria2";

    static constexpr std::array<CommandSwitch, 3> INSTALL_SWITCHES = {{
        {OPTION_USE_HEAD_VERSION, "Install the libraries on the command line using the latest upstream sources"},
        {OPTION_KEEP_GOING, "Continue installing packages on failure"},
        {OPTION_USE_ARIA2, "Use aria2 to perform download tasks"},
    }};

    const CommandStructure COMMAND_STRUCTURE = {
        Help::create_example_string("download zlib zlib:x64-windows curl boost"),
        1,
        SIZE_MAX,
        {INSTALL_SWITCHES},
        &Install::get_all_port_names,
    };

    ///
    /// <summary>
    /// Run "install" command.
    /// </summary>
    ///
    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet)
    {
        // input sanitization
        const ParsedArguments options = args.parse_arguments(COMMAND_STRUCTURE);

        const bool use_head_version = Util::Sets::contains(options.switches, (OPTION_USE_HEAD_VERSION));
        const bool use_aria2 = Util::Sets::contains(options.switches, (OPTION_USE_ARIA2));

        Build::DownloadTool download_tool = Build::DownloadTool::BUILT_IN;
        if (use_aria2) download_tool = Build::DownloadTool::ARIA2;

        const Build::BuildPackageOptions install_plan_options = {
            Util::Enum::to_enum<Build::UseHeadVersion>(use_head_version),
            Build::AllowDownloads::YES,
            Build::CleanBuildtrees::NO,
            Build::CleanPackages::NO,
            Build::CleanDownloads::NO,
            download_tool,
            Build::BinaryCaching::NO,
            Build::FailOnTombstone::NO,
            Build::DownloadOnly::YES,
        };

        // delegate the rest of this to however "Install" works.
        Install::perform_and_exit(args, paths, default_triplet, install_plan_options, options);
    }
}
