#include "pch.h"
#include "vcpkg_Commands.h"
#include "StatusParagraphs.h"
#include "vcpkglib.h"
#include "vcpkg_Input.h"
#include "PostBuildLint.h"
#include "vcpkg_Dependencies.h"
#include "vcpkg_System.h"
#include "vcpkg_Chrono.h"
#include "metrics.h"
#include "vcpkg_Enums.h"
#include "Paragraphs.h"

namespace vcpkg::Commands::Build
{
    using Dependencies::PackageSpecWithInstallPlan;
    using Dependencies::InstallPlanType;

    static const std::string OPTION_CHECKS_ONLY = "--checks-only";

    static void create_binary_control_file(const VcpkgPaths& paths, const SourceParagraph& source_paragraph, const Triplet& target_triplet)
    {
        const BinaryParagraph bpgh = BinaryParagraph(source_paragraph, target_triplet);
        const fs::path binary_control_file = paths.packages / bpgh.dir() / "CONTROL";
        std::ofstream(binary_control_file) << bpgh;
    }

    std::wstring make_build_env_cmd(const Triplet& target_triplet, const Toolset& toolset)
    {
        return Strings::wformat(LR"("%s" %s >nul 2>&1)",
            toolset.vcvarsall.native(),
            Strings::utf8_to_utf16(target_triplet.architecture()));
    }

    BuildResult build_package(const SourceParagraph& source_paragraph, const PackageSpec& spec, const VcpkgPaths& paths, const fs::path& port_dir, const StatusParagraphs& status_db)
    {
        Checks::check_exit(VCPKG_LINE_INFO, spec.name() == source_paragraph.name, "inconsistent arguments to build_package()");

        const Triplet& target_triplet = spec.target_triplet();
        for (auto&& dep : filter_dependencies(source_paragraph.depends, target_triplet))
        {
            if (status_db.find_installed(dep, target_triplet) == status_db.end())
            {
                return BuildResult::CASCADED_DUE_TO_MISSING_DEPENDENCIES;
            }
        }

        const fs::path& cmake_exe_path = paths.get_cmake_exe();
        const fs::path& git_exe_path = paths.get_git_exe();

        const fs::path ports_cmake_script_path = paths.ports_cmake;
        const Toolset& toolset = paths.get_toolset();
        const auto cmd_set_environment = make_build_env_cmd(target_triplet, toolset);

        const std::wstring cmd_launch_cmake = make_cmake_cmd(cmake_exe_path, ports_cmake_script_path,
                                                             {
                                                                 { L"CMD", L"BUILD" },
                                                                 { L"PORT", source_paragraph.name },
                                                                 { L"CURRENT_PORT_DIR", port_dir / "/." },
                                                                 { L"TARGET_TRIPLET", target_triplet.canonical_name() },
                                                                 { L"VCPKG_PLATFORM_TOOLSET", toolset.version },
                                                                 { L"GIT", git_exe_path }
                                                             });

        const std::wstring command = Strings::wformat(LR"(%s && %s)", cmd_set_environment, cmd_launch_cmake);

        const ElapsedTime timer = ElapsedTime::create_started();

        int return_code = System::cmd_execute_clean(command);
        auto buildtimeus = timer.microseconds();
        Metrics::track_metric("buildtimeus-" + spec.toString(), buildtimeus);

        if (return_code != 0)
        {
            Metrics::track_property("error", "build failed");
            Metrics::track_property("build_error", spec.toString());
            return BuildResult::BUILD_FAILED;
        }

        const size_t error_count = PostBuildLint::perform_all_checks(spec, paths);

        if (error_count != 0)
        {
            return BuildResult::POST_BUILD_CHECKS_FAILED;
        }

        create_binary_control_file(paths, source_paragraph, target_triplet);

        // const fs::path port_buildtrees_dir = paths.buildtrees / spec.name;
        // delete_directory(port_buildtrees_dir);

        return BuildResult::SUCCEEDED;
    }

    const std::string& to_string(const BuildResult build_result)
    {
        static const std::string NULLVALUE_STRING = Enums::nullvalue_to_string("vcpkg::Commands::Build::BuildResult");
        static const std::string SUCCEEDED_STRING = "SUCCEEDED";
        static const std::string BUILD_FAILED_STRING = "BUILD_FAILED";
        static const std::string POST_BUILD_CHECKS_FAILED_STRING = "POST_BUILD_CHECKS_FAILED";
        static const std::string CASCADED_DUE_TO_MISSING_DEPENDENCIES_STRING = "CASCADED_DUE_TO_MISSING_DEPENDENCIES";

        switch (build_result)
        {
            case BuildResult::NULLVALUE: return NULLVALUE_STRING;
            case BuildResult::SUCCEEDED: return SUCCEEDED_STRING;
            case BuildResult::BUILD_FAILED: return BUILD_FAILED_STRING;
            case BuildResult::POST_BUILD_CHECKS_FAILED: return POST_BUILD_CHECKS_FAILED_STRING;
            case BuildResult::CASCADED_DUE_TO_MISSING_DEPENDENCIES: return CASCADED_DUE_TO_MISSING_DEPENDENCIES_STRING;
            default: Checks::unreachable(VCPKG_LINE_INFO);
        }
    }

    std::string create_error_message(const BuildResult build_result, const PackageSpec& spec)
    {
        return Strings::format("Error: Building package %s failed with: %s", spec.toString(), Build::to_string(build_result));
    }

    std::string create_user_troubleshooting_message(const PackageSpec& spec)
    {
        return Strings::format("Please ensure you're using the latest portfiles with `.\\vcpkg update`, then\n"
                               "submit an issue at https://github.com/Microsoft/vcpkg/issues including:\n"
                               "  Package: %s\n"
                               "  Vcpkg version: %s\n"
                               "\n"
                               "Additionally, attach any relevant sections from the log files above."
                               , spec.toString(), Version::version());
    }

    void perform_and_exit(const PackageSpec& spec, const fs::path& port_dir, const std::unordered_set<std::string>& options, const VcpkgPaths& paths)
    {
        if (options.find(OPTION_CHECKS_ONLY) != options.end())
        {
            const size_t error_count = PostBuildLint::perform_all_checks(spec, paths);
            Checks::check_exit(VCPKG_LINE_INFO, error_count == 0);
            Checks::exit_success(VCPKG_LINE_INFO);
        }

        const Expected<SourceParagraph> maybe_spgh = Paragraphs::try_load_port(port_dir);
        Checks::check_exit(VCPKG_LINE_INFO, !maybe_spgh.error_code(), "Could not find package named %s: %s", spec, maybe_spgh.error_code().message());
        const SourceParagraph& spgh = *maybe_spgh.get();

        StatusParagraphs status_db = database_load_check(paths);
        const BuildResult result = build_package(spgh, spec, paths, paths.port_dir(spec), status_db);
        if (result == BuildResult::CASCADED_DUE_TO_MISSING_DEPENDENCIES)
        {
            std::vector<PackageSpecWithInstallPlan> unmet_dependencies = Dependencies::create_install_plan(paths, { spec }, status_db);
            unmet_dependencies.erase(
                std::remove_if(unmet_dependencies.begin(), unmet_dependencies.end(), [&spec](const PackageSpecWithInstallPlan& p)
                               {
                                   return (p.spec == spec) || (p.plan.plan_type == InstallPlanType::ALREADY_INSTALLED);
                               }),
                unmet_dependencies.end());

            Checks::check_exit(VCPKG_LINE_INFO, !unmet_dependencies.empty());
            System::println(System::Color::error, "The build command requires all dependencies to be already installed.");
            System::println("The following dependencies are missing:");
            System::println("");
            for (const PackageSpecWithInstallPlan& p : unmet_dependencies)
            {
                System::println("    %s", p.spec.toString());
            }
            System::println("");
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        if (result != BuildResult::SUCCEEDED)
        {
            System::println(System::Color::error, Build::create_error_message(result, spec));
            System::println(Build::create_user_troubleshooting_message(spec));
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_target_triplet)
    {
        static const std::string example = Commands::Help::create_example_string("build zlib:x64-windows");
        args.check_exact_arg_count(1, example); // Build only takes a single package and all dependencies must already be installed
        const PackageSpec spec = Input::check_and_get_package_spec(args.command_arguments.at(0), default_target_triplet, example);
        Input::check_triplet(spec.target_triplet(), paths);
        const std::unordered_set<std::string> options = args.check_and_get_optional_command_arguments({ OPTION_CHECKS_ONLY });
        perform_and_exit(spec, paths.port_dir(spec), options, paths);
    }
}
