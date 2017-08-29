#include "pch.h"

#include "Paragraphs.h"
#include "PostBuildLint.h"
#include "StatusParagraphs.h"
#include "vcpkg_Commands.h"
#include "vcpkg_Dependencies.h"
#include "vcpkg_Enums.h"
#include "vcpkg_Input.h"
#include "vcpkg_System.h"
#include "vcpkglib.h"

using vcpkg::Build::BuildResult;
using vcpkg::Parse::ParseControlErrorInfo;
using vcpkg::Parse::ParseExpected;

namespace vcpkg::Commands::BuildCommand
{
    using Dependencies::InstallPlanAction;
    using Dependencies::InstallPlanType;

    static const std::string OPTION_CHECKS_ONLY = "--checks-only";

    void perform_and_exit(const FullPackageSpec& full_spec,
                          const fs::path& port_dir,
                          const std::unordered_set<std::string>& options,
                          const VcpkgPaths& paths)
    {
        const PackageSpec& spec = full_spec.package_spec;
        if (options.find(OPTION_CHECKS_ONLY) != options.end())
        {
            const auto pre_build_info = Build::PreBuildInfo::from_triplet_file(paths, spec.triplet());
            const auto build_info = Build::read_build_info(paths.get_filesystem(), paths.build_info_file_path(spec));
            const size_t error_count = PostBuildLint::perform_all_checks(spec, paths, pre_build_info, build_info);
            Checks::check_exit(VCPKG_LINE_INFO, error_count == 0);
            Checks::exit_success(VCPKG_LINE_INFO);
        }

        const ParseExpected<SourceControlFile> source_control_file =
            Paragraphs::try_load_port(paths.get_filesystem(), port_dir);

        if (!source_control_file.has_value())
        {
            print_error_message(source_control_file.error());
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        for (const std::string& str : full_spec.features)
        {
            System::println("%s \n", str);
        }
        const auto& scf = source_control_file.value_or_exit(VCPKG_LINE_INFO);
        Checks::check_exit(VCPKG_LINE_INFO,
                           spec.name() == scf->core_paragraph->name,
                           "The Name: field inside the CONTROL does not match the port directory: '%s' != '%s'",
                           scf->core_paragraph->name,
                           spec.name());

        const StatusParagraphs status_db = database_load_check(paths);
        const Build::BuildPackageOptions build_package_options{Build::UseHeadVersion::NO, Build::AllowDownloads::YES};

        const Build::BuildPackageConfig build_config{
            *scf->core_paragraph, spec.triplet(), paths.port_dir(spec), build_package_options};

        const auto result = Build::build_package(paths, build_config, status_db);
        if (result.code == BuildResult::CASCADED_DUE_TO_MISSING_DEPENDENCIES)
        {
            System::println(System::Color::error,
                            "The build command requires all dependencies to be already installed.");
            System::println("The following dependencies are missing:");
            System::println();
            for (const auto& p : result.unmet_dependencies)
            {
                System::println("    %s", p);
            }
            System::println();
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        if (result.code != BuildResult::SUCCEEDED)
        {
            System::println(System::Color::error, Build::create_error_message(result.code, spec));
            System::println(Build::create_user_troubleshooting_message(spec));
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet)
    {
        static const std::string example = Commands::Help::create_example_string("build zlib:x64-windows");
        args.check_exact_arg_count(
            1, example); // Build only takes a single package and all dependencies must already be installed
        const std::string command_argument = args.command_arguments.at(0);
        const FullPackageSpec spec = Input::check_and_get_full_package_spec(command_argument, default_triplet, example);
        Input::check_triplet(spec.package_spec.triplet(), paths);
        const std::unordered_set<std::string> options =
            args.check_and_get_optional_command_arguments({OPTION_CHECKS_ONLY});
        perform_and_exit(spec, paths.port_dir(spec.package_spec), options, paths);
    }
}
