#include "pch.h"
#include "vcpkg_Commands.h"
#include "vcpkglib.h"
#include "vcpkg_Environment.h"
#include "vcpkg_Files.h"
#include "vcpkg_System.h"
#include "vcpkg_Dependencies.h"
#include "vcpkg_Input.h"
#include "Stopwatch.h"

namespace vcpkg::Commands::CI
{
    using Dependencies::package_spec_with_install_plan;
    using Dependencies::install_plan_type;

    void perform_and_exit(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths, const triplet& default_target_triplet)
    {
        static const std::string example = Commands::Help::create_example_string("ci x64-windows");
        args.check_max_arg_count(1, example);
        const triplet target_triplet = args.command_arguments.size() == 1 ? triplet::from_canonical_name(args.command_arguments.at(0)) : default_target_triplet;
        Input::check_triplet(target_triplet, paths);

        StatusParagraphs status_db = database_load_check(paths);

        std::vector<fs::path> port_folders;
        Files::non_recursive_find_matching_paths_in_dir(paths.ports, [](const fs::path& current)
                                                        {
                                                            return fs::is_directory(current);
                                                        }, &port_folders);

        std::vector<package_spec> specs;
        for (const fs::path& p : port_folders)
        {
            specs.push_back(package_spec::from_name_and_triplet(p.filename().generic_string(), target_triplet).get_or_throw());
        }

        std::vector<package_spec_with_install_plan> install_plan = Dependencies::create_install_plan(paths, specs, status_db);
        Checks::check_exit(!install_plan.empty(), "Install plan cannot be empty");

        std::vector<Build::BuildResult> results;

        Environment::ensure_utilities_on_path(paths);

        Stopwatch stopwatch = Stopwatch::createStarted();
        for (const package_spec_with_install_plan& action : install_plan)
        {
            System::println(stopwatch.toString());
            try
            {
                if (action.plan.plan_type == install_plan_type::ALREADY_INSTALLED)
                {
                    results.push_back(Build::BuildResult::SUCCEEDED);
                    System::println(System::color::success, "Package %s is already installed", action.spec);
                }
                else if (action.plan.plan_type == install_plan_type::BUILD_AND_INSTALL)
                {
                    const Build::BuildResult result = Commands::Build::build_package(*action.plan.source_pgh, action.spec, paths, paths.port_dir(action.spec), status_db);
                    results.push_back(result);
                    if (result != Build::BuildResult::SUCCEEDED)
                    {
                        System::println(System::color::error, Build::create_error_message(action.spec.toString(), result));
                        continue;
                    }
                    const BinaryParagraph bpgh = try_load_cached_package(paths, action.spec).get_or_throw();
                    Install::install_package(paths, bpgh, &status_db);
                    System::println(System::color::success, "Package %s is installed", action.spec);
                }
                else if (action.plan.plan_type == install_plan_type::INSTALL)
                {
                    results.push_back(Build::BuildResult::SUCCEEDED);
                    Install::install_package(paths, *action.plan.binary_pgh, &status_db);
                    System::println(System::color::success, "Package %s is installed", action.spec);
                }
                else
                    Checks::unreachable();
            }
            catch (const std::exception& e)
            {
                System::println(System::color::error, "Error: Could not install package %s: %s", action.spec, e.what());
                exit(EXIT_FAILURE);
            }
        }

        for (int i = 0; i < results.size(); i++)
        {
            System::println("%s: %s", install_plan[i].spec.toString(), Build::to_string(results[i]));
        }

        System::println(stopwatch.toString());
        exit(EXIT_SUCCESS);
    }
}
