#include <vcpkg/base/system.print.h>

#include <vcpkg/commands.h>
#include <vcpkg/help.h>
#include <vcpkg/paragraphs.h>
#include <vcpkg/portfileprovider.h>
#include <vcpkg/update.h>
#include <vcpkg/vcpkgcmdarguments.h>
#include <vcpkg/vcpkglib.h>

namespace vcpkg::Update
{
    bool OutdatedPackage::compare_by_name(const OutdatedPackage& left, const OutdatedPackage& right)
    {
        return left.spec.name() < right.spec.name();
    }

    std::vector<OutdatedPackage> find_outdated_packages(const PortFileProvider::PortFileProvider& provider,
                                                        const StatusParagraphs& status_db)
    {
        auto installed_packages = get_installed_ports(status_db);

        std::vector<OutdatedPackage> output;
        for (auto&& ipv : installed_packages)
        {
            const auto& pgh = ipv.core;
            auto maybe_scfl = provider.get_control_file(pgh->package.spec.name());
            if (auto p_scfl = maybe_scfl.get())
            {
                const auto& latest_pgh = *p_scfl->source_control_file->core_paragraph;
                auto latest_version = VersionT(latest_pgh.version, latest_pgh.port_version);
                auto installed_version = VersionT(pgh->package.version, pgh->package.port_version);
                if (latest_version != installed_version)
                {
                    output.push_back(
                        {pgh->package.spec, VersionDiff(std::move(installed_version), std::move(latest_version))});
                }
            }
            else
            {
                // No portfile available
            }
        }

        return output;
    }

    const CommandStructure COMMAND_STRUCTURE = {
        create_example_string("update"),
        0,
        0,
        {},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        (void)args.parse_arguments(COMMAND_STRUCTURE);
        System::print2("Using local portfile versions. To update the local portfiles, use `git pull`.\n");

        const StatusParagraphs status_db = database_load_check(paths);

        PortFileProvider::PathsPortFileProvider provider(paths, args.overlay_ports);

        const auto outdated_packages = SortedVector<OutdatedPackage>(find_outdated_packages(provider, status_db),
                                                                     &OutdatedPackage::compare_by_name);

        if (outdated_packages.empty())
        {
            System::print2("No packages need updating.\n");
        }
        else
        {
            System::print2("The following packages differ from their port versions:\n");
            for (auto&& package : outdated_packages)
            {
                System::printf("    %-32s %s\n", package.spec, package.version_diff.to_string());
            }

#if defined(_WIN32)
            auto vcpkg_cmd = ".\\vcpkg";
#else
            auto vcpkg_cmd = "./vcpkg";
#endif
            System::printf("\n"
                           "To update these packages and all dependencies, run\n"
                           "    %s upgrade\n"
                           "\n"
                           "To only remove outdated packages, run\n"
                           "    %s remove --outdated\n"
                           "\n",
                           vcpkg_cmd,
                           vcpkg_cmd);
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }

    void UpdateCommand::perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const
    {
        Update::perform_and_exit(args, paths);
    }
}
