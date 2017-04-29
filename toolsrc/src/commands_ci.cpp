#include "pch.h"

#include "Paragraphs.h"
#include "vcpkg_Chrono.h"
#include "vcpkg_Commands.h"
#include "vcpkg_Dependencies.h"
#include "vcpkg_Enums.h"
#include "vcpkg_Files.h"
#include "vcpkg_Input.h"
#include "vcpkg_System.h"
#include "vcpkglib.h"

namespace vcpkg::Commands::CI
{
    using Dependencies::InstallPlanAction;
    using Dependencies::InstallPlanType;
    using Build::BuildResult;

    static std::vector<PackageSpec> load_all_package_specs(Files::Filesystem& fs,
                                                           const fs::path& ports_directory,
                                                           const Triplet& triplet)
    {
        std::vector<SourceParagraph> ports = Paragraphs::load_all_ports(fs, ports_directory);
        std::vector<PackageSpec> specs;
        for (const SourceParagraph& p : ports)
        {
            specs.push_back(PackageSpec::from_name_and_triplet(p.name, triplet).value_or_exit(VCPKG_LINE_INFO));
        }

        return specs;
    }

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet)
    {
        static const std::string example = Commands::Help::create_example_string("ci x64-windows");
        args.check_max_arg_count(1, example);
        const Triplet triplet = args.command_arguments.size() == 1
                                    ? Triplet::from_canonical_name(args.command_arguments.at(0))
                                    : default_triplet;
        Input::check_triplet(triplet, paths);
        args.check_and_get_optional_command_arguments({});
        const std::vector<PackageSpec> specs = load_all_package_specs(paths.get_filesystem(), paths.ports, triplet);

        StatusParagraphs status_db = database_load_check(paths);
        const std::vector<InstallPlanAction> install_plan = Dependencies::create_install_plan(paths, specs, status_db);
        Checks::check_exit(VCPKG_LINE_INFO, !install_plan.empty(), "Install plan cannot be empty");

        std::vector<BuildResult> results;
        std::vector<std::string> timing;
        const ElapsedTime timer = ElapsedTime::create_started();
        size_t counter = 0;
        const size_t package_count = install_plan.size();
        for (const InstallPlanAction& action : install_plan)
        {
            const ElapsedTime build_timer = ElapsedTime::create_started();
            counter++;
            const std::string display_name = action.spec.to_string();
            System::println("Starting package %d/%d: %s", counter, package_count, display_name);

            timing.push_back("0");
            results.push_back(BuildResult::NULLVALUE);

            try
            {
                switch (action.plan_type)
                {
                    case InstallPlanType::ALREADY_INSTALLED:
                        results.back() = BuildResult::SUCCEEDED;
                        System::println(System::Color::success, "Package %s is already installed", display_name);
                        break;
                    case InstallPlanType::BUILD_AND_INSTALL:
                    {
                        System::println("Building package %s... ", display_name);
                        auto&& source_paragraph = action.any_paragraph.source_paragraph.value_or_exit(VCPKG_LINE_INFO);
                        const auto result_ex = Commands::Build::build_package(
                            source_paragraph, action.spec, paths, paths.port_dir(action.spec), status_db);
                        const auto result = result_ex.code;

                        timing.back() = build_timer.to_string();
                        results.back() = result;
                        if (result != BuildResult::SUCCEEDED)
                        {
                            System::println(System::Color::error, Build::create_error_message(result, action.spec));
                            continue;
                        }
                        System::println(System::Color::success, "Building package %s... done", display_name);

                        const BinaryParagraph bpgh =
                            Paragraphs::try_load_cached_package(paths, action.spec).value_or_exit(VCPKG_LINE_INFO);
                        System::println("Installing package %s... ", display_name);
                        Install::install_package(paths, bpgh, &status_db);
                        System::println(System::Color::success, "Installing package %s... done", display_name);
                        break;
                    }
                    case InstallPlanType::INSTALL:
                        results.back() = BuildResult::SUCCEEDED;
                        System::println("Installing package %s... ", display_name);
                        Install::install_package(
                            paths, action.any_paragraph.binary_paragraph.value_or_exit(VCPKG_LINE_INFO), &status_db);
                        System::println(System::Color::success, "Installing package %s... done", display_name);
                        break;
                    default: Checks::unreachable(VCPKG_LINE_INFO);
                }
            }
            catch (const std::exception& e)
            {
                System::println(System::Color::error, "Error: Could not install package %s: %s", action.spec, e.what());
                results.back() = BuildResult::NULLVALUE;
            }
            System::println("Elapsed time for package %s: %s", action.spec, build_timer.to_string());
        }

        System::println("Total time taken: %s", timer.to_string());

        for (size_t i = 0; i < results.size(); i++)
        {
            System::println("%s: %s: %s", install_plan[i].spec, Build::to_string(results[i]), timing[i]);
        }

        std::map<BuildResult, int> summary;
        for (BuildResult v : Enums::make_enum_range<BuildResult>())
        {
            if (v == BuildResult::NULLVALUE) continue;
            summary[v] = 0;
        }

        for (const BuildResult& r : results)
        {
            summary[r]++;
        }

        System::println("\n\nSUMMARY");
        for (const std::pair<const BuildResult, int>& entry : summary)
        {
            System::println("    %s: %d", Build::to_string(entry.first), entry.second);
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
