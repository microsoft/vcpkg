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

namespace vcpkg::Commands::BuildCommand
{
    using Dependencies::InstallPlanAction;
    using Dependencies::InstallPlanType;

    static const std::string OPTION_CHECKS_ONLY = "--checks-only";

    void perform_and_exit(const PackageSpec& spec,
                          const fs::path& port_dir,
                          const std::unordered_set<std::string>& options,
                          const VcpkgPaths& paths)
    {
        if (options.find(OPTION_CHECKS_ONLY) != options.end())
        {
            auto pre_build_info = Build::PreBuildInfo::from_triplet_file(paths, spec.triplet());
            auto build_info = Build::read_build_info(paths.get_filesystem(), paths.build_info_file_path(spec));
            const size_t error_count = PostBuildLint::perform_all_checks(spec, paths, pre_build_info, build_info);
            Checks::check_exit(VCPKG_LINE_INFO, error_count == 0);
            Checks::exit_success(VCPKG_LINE_INFO);
        }

        const Expected<SourceParagraph> maybe_spgh = Paragraphs::try_load_port(paths.get_filesystem(), port_dir);
        Checks::check_exit(VCPKG_LINE_INFO,
                           !maybe_spgh.error_code(),
                           "Could not find package %s: %s",
                           spec,
                           maybe_spgh.error_code().message());
        const SourceParagraph& spgh = *maybe_spgh.get();
        Checks::check_exit(VCPKG_LINE_INFO,
                           spec.name() == spgh.name,
                           "The Name: field inside the CONTROL does not match the port directory: '%s' != '%s'",
                           spgh.name,
                           spec.name());

        StatusParagraphs status_db = database_load_check(paths);
        const Build::BuildPackageConfig build_config{
            spgh, spec.triplet(), paths.port_dir(spec),
        };
        const auto result = Build::build_package(paths, build_config, status_db);
        if (result.code == BuildResult::CASCADED_DUE_TO_MISSING_DEPENDENCIES)
        {
            System::println(System::Color::error,
                            "The build command requires all dependencies to be already installed.");
            System::println("The following dependencies are missing:");
            System::println("");
            for (const auto& p : result.unmet_dependencies)
            {
                System::println("    %s", p);
            }
            System::println("");
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
        const PackageSpec spec =
            Input::check_and_get_package_spec(args.command_arguments.at(0), default_triplet, example);
        Input::check_triplet(spec.triplet(), paths);
        const std::unordered_set<std::string> options =
            args.check_and_get_optional_command_arguments({OPTION_CHECKS_ONLY});
        perform_and_exit(spec, paths.port_dir(spec), options, paths);
    }
}
