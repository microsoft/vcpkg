#include "pch.h"

#include "Paragraphs.h"
#include "vcpkg_Build.h"
#include "vcpkg_Chrono.h"
#include "vcpkg_Commands.h"
#include "vcpkg_Dependencies.h"
#include "vcpkg_Files.h"
#include "vcpkg_Input.h"
#include "vcpkg_System.h"
#include "vcpkg_Util.h"
#include "vcpkglib.h"

namespace vcpkg::Commands::CI
{
    using Build::BuildResult;
    using Dependencies::InstallPlanAction;
    using Dependencies::InstallPlanType;

    static std::vector<PackageSpec> load_all_package_specs(Files::Filesystem& fs,
                                                           const fs::path& ports_directory,
                                                           const Triplet& triplet)
    {
        auto ports = Paragraphs::load_all_ports(fs, ports_directory);
        return Util::fmap(ports, [&](auto&& control_file) -> PackageSpec {
            return PackageSpec::from_name_and_triplet(control_file->core_paragraph->name, triplet)
                .value_or_exit(VCPKG_LINE_INFO);
        });
    }

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet)
    {
        static const std::string EXAMPLE = Commands::Help::create_example_string("ci x64-windows");
        args.check_max_arg_count(1, EXAMPLE);
        const Triplet triplet = args.command_arguments.size() == 1
                                    ? Triplet::from_canonical_name(args.command_arguments.at(0))
                                    : default_triplet;
        Input::check_triplet(triplet, paths);
        args.check_and_get_optional_command_arguments({});
        const std::vector<PackageSpec> specs = load_all_package_specs(paths.get_filesystem(), paths.ports, triplet);

        StatusParagraphs status_db = database_load_check(paths);
        const auto& paths_port_file = Dependencies::PathsPortFile(paths);
        const std::vector<InstallPlanAction> install_plan =
            Dependencies::create_install_plan(paths_port_file, specs, status_db);
        Checks::check_exit(VCPKG_LINE_INFO, !install_plan.empty(), "Install plan cannot be empty");

        std::vector<BuildResult> results;
        std::vector<std::string> timing;
        const ElapsedTime timer = ElapsedTime::create_started();
        size_t counter = 0;
        const size_t package_count = install_plan.size();
        const Build::BuildPackageOptions install_plan_options = {Build::UseHeadVersion::NO, Build::AllowDownloads::YES};

        for (const InstallPlanAction& action : install_plan)
        {
            const ElapsedTime build_timer = ElapsedTime::create_started();
            counter++;
            const std::string display_name = action.spec.to_string();
            System::println("Starting package %d/%d: %s", counter, package_count, display_name);

            timing.push_back("0");
            results.push_back(BuildResult::NULLVALUE);

            const BuildResult result =
                Install::perform_install_plan_action(paths, action, install_plan_options, status_db);
            timing.back() = build_timer.to_string();
            results.back() = result;
            System::println("Elapsed time for package %s: %s", action.spec, build_timer.to_string());
        }

        System::println("Total time taken: %s", timer.to_string());

        for (size_t i = 0; i < results.size(); i++)
        {
            System::println("%s: %s: %s", install_plan[i].spec, Build::to_string(results[i]), timing[i]);
        }

        std::map<BuildResult, int> summary;
        for (const BuildResult& v : Build::BUILD_RESULT_VALUES)
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
