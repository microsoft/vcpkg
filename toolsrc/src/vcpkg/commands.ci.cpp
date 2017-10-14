#include "pch.h"

#include <vcpkg/base/chrono.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/system.h>
#include <vcpkg/base/util.h>
#include <vcpkg/build.h>
#include <vcpkg/commands.h>
#include <vcpkg/dependencies.h>
#include <vcpkg/help.h>
#include <vcpkg/input.h>
#include <vcpkg/install.h>
#include <vcpkg/paragraphs.h>
#include <vcpkg/vcpkglib.h>

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
        static const std::string EXAMPLE = Help::create_example_string("ci x64-windows");
        args.check_max_arg_count(1, EXAMPLE);
        const Triplet triplet = args.command_arguments.size() == 1
                                    ? Triplet::from_canonical_name(args.command_arguments.at(0))
                                    : default_triplet;
        Input::check_triplet(triplet, paths);
        args.check_and_get_optional_command_arguments({});
        const std::vector<PackageSpec> specs = load_all_package_specs(paths.get_filesystem(), paths.ports, triplet);

        StatusParagraphs status_db = database_load_check(paths);
        const auto& paths_port_file = Dependencies::PathsPortFile(paths);
        std::vector<InstallPlanAction> install_plan =
            Dependencies::create_install_plan(paths_port_file, specs, status_db);
        Checks::check_exit(VCPKG_LINE_INFO, !install_plan.empty(), "Install plan cannot be empty");

        const Build::BuildPackageOptions install_plan_options = {Build::UseHeadVersion::NO, Build::AllowDownloads::YES};

        const std::vector<Dependencies::AnyAction> action_plan =
            Util::fmap(install_plan, [](InstallPlanAction& install_action) {
                return Dependencies::AnyAction(std::move(install_action));
            });

        Install::perform_and_exit_ex(
            action_plan, install_plan_options, Install::KeepGoing::YES, Install::PrintSummary::YES, paths, status_db);

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
