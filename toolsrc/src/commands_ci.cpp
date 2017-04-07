#include "pch.h"
#include "vcpkg_Commands.h"
#include "vcpkglib.h"
#include "vcpkg_Files.h"
#include "vcpkg_System.h"
#include "vcpkg_Dependencies.h"
#include "vcpkg_Input.h"
#include "vcpkg_Chrono.h"
#include "Paragraphs.h"

namespace vcpkg::Commands::CI
{
    using Dependencies::PackageSpecWithInstallPlan;
    using Dependencies::InstallPlanType;
    using Build::BuildResult;

    static std::vector<PackageSpec> load_all_package_specs(const fs::path& ports_directory, const Triplet& target_triplet)
    {
        std::vector<SourceParagraph> ports = Paragraphs::load_all_ports(ports_directory);
        std::vector<PackageSpec> specs;
        for (const SourceParagraph& p : ports)
        {
            specs.push_back(PackageSpec::from_name_and_triplet(p.name, target_triplet).value_or_exit(VCPKG_LINE_INFO));
        }

        return specs;
    }

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_target_triplet)
    {
        static const std::string example = Commands::Help::create_example_string("ci x64-windows");
        args.check_max_arg_count(1, example);
        const Triplet target_triplet = args.command_arguments.size() == 1 ? Triplet::from_canonical_name(args.command_arguments.at(0)) : default_target_triplet;
        Input::check_triplet(target_triplet, paths);
        args.check_and_get_optional_command_arguments({});
        const std::vector<PackageSpec> specs = load_all_package_specs(paths.ports, target_triplet);

        StatusParagraphs status_db = database_load_check(paths);
        const std::vector<PackageSpecWithInstallPlan> install_plan = Dependencies::create_install_plan(paths, specs, status_db);
        Checks::check_exit(VCPKG_LINE_INFO, !install_plan.empty(), "Install plan cannot be empty");

        std::vector<BuildResult> results;
        std::vector<std::chrono::milliseconds::rep> timing;
        const ElapsedTime timer = ElapsedTime::create_started();
        size_t counter = 0;
        const size_t package_count = install_plan.size();
        for (const PackageSpecWithInstallPlan& action : install_plan)
        {
            const ElapsedTime build_timer = ElapsedTime::create_started();
            counter++;
            const std::string display_name = action.spec.display_name();
            System::println("Starting package %d/%d: %s", counter, package_count, display_name);

            timing.push_back(-1);
            results.push_back(BuildResult::NULLVALUE);

            try
            {
                if (action.plan.plan_type == InstallPlanType::ALREADY_INSTALLED)
                {
                    results.back() = BuildResult::SUCCEEDED;
                    System::println(System::Color::success, "Package %s is already installed", display_name);
                }
                else if (action.plan.plan_type == InstallPlanType::BUILD_AND_INSTALL)
                {
                    const BuildResult result = Commands::Build::build_package(action.plan.source_pgh.value_or_exit(VCPKG_LINE_INFO),
                                                                              action.spec,
                                                                              paths,
                                                                              paths.port_dir(action.spec),
                                                                              status_db);
                    timing.back() = build_timer.elapsed<std::chrono::milliseconds>().count();
                    results.back() = result;
                    if (result != BuildResult::SUCCEEDED)
                    {
                        System::println(System::Color::error, Build::create_error_message(result, action.spec));
                        continue;
                    }
                    const BinaryParagraph bpgh = Paragraphs::try_load_cached_package(paths, action.spec).value_or_exit(VCPKG_LINE_INFO);
                    Install::install_package(paths, bpgh, &status_db);
                    System::println(System::Color::success, "Package %s is installed", display_name);
                }
                else if (action.plan.plan_type == InstallPlanType::INSTALL)
                {
                    results.back() = BuildResult::SUCCEEDED;
                    Install::install_package(paths, action.plan.binary_pgh.value_or_exit(VCPKG_LINE_INFO), &status_db);
                    System::println(System::Color::success, "Package %s is installed from cache", display_name);
                }
                else
                    Checks::unreachable(VCPKG_LINE_INFO);
            }
            catch (const std::exception& e)
            {
                System::println(System::Color::error, "Error: Could not install package %s: %s", action.spec.display_name(), e.what());
                results.back() = BuildResult::NULLVALUE;
            }
            System::println("Elapsed time for package %s: %s", action.spec.display_name(), build_timer.to_string());
        }

        System::println("Total time taken: %s", timer.to_string());

        for (size_t i = 0; i < results.size(); i++)
        {
            System::println("%s: %s: %dms", install_plan[i].spec.to_string(), Build::to_string(results[i]), timing[i]);
        }

        std::map<BuildResult, int> summary;
        for (const BuildResult& v : Build::BuildResult_values)
        {
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
