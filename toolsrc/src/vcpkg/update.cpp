#include "pch.h"

#include <vcpkg/base/system.h>
#include <vcpkg/commands.h>
#include <vcpkg/help.h>
#include <vcpkg/paragraphs.h>
#include <vcpkg/update.h>
#include <vcpkg/vcpkglib.h>

namespace vcpkg::Update
{
    bool OutdatedPackage::compare_by_name(const OutdatedPackage& left, const OutdatedPackage& right)
    {
        return left.spec.name() < right.spec.name();
    }

    std::vector<OutdatedPackage> find_outdated_packages(const std::map<std::string, VersionT>& src_names_to_versions,
                                                        const StatusParagraphs& status_db)
    {
        const std::vector<StatusParagraph*> installed_packages = get_installed_ports(status_db);

        std::vector<OutdatedPackage> output;
        for (const StatusParagraph* pgh : installed_packages)
        {
            if (!pgh->package.feature.empty())
            {
                // Skip feature packages; only consider master packages for needing updates.
                continue;
            }

            const auto it = src_names_to_versions.find(pgh->package.spec.name());
            if (it == src_names_to_versions.end())
            {
                // Package was not installed from portfile
                continue;
            }
            if (it->second != pgh->package.version)
            {
                output.push_back({pgh->package.spec, VersionDiff(pgh->package.version, it->second)});
            }
        }

        return output;
    }

    const CommandStructure COMMAND_STRUCTURE = {
        Help::create_example_string("update"),
        0,
        0,
        {},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        args.parse_arguments(COMMAND_STRUCTURE);
        System::println("Using local portfile versions. To update the local portfiles, use `git pull`.");

        const StatusParagraphs status_db = database_load_check(paths);

        const auto outdated_packages = SortedVector<OutdatedPackage>(
            find_outdated_packages(Paragraphs::load_all_port_names_and_versions(paths.get_filesystem(), paths.ports),
                                   status_db),
            &OutdatedPackage::compare_by_name);

        if (outdated_packages.empty())
        {
            System::println("No packages need updating.");
        }
        else
        {
            std::string install_line;
            System::println("The following packages differ from their port versions:");
            for (auto&& package : outdated_packages)
            {
                install_line += package.spec.to_string();
                install_line += " ";
                System::println("    %-32s %s", package.spec, package.version_diff.to_string());
            }
            System::println("\n"
                            "To update these packages, run\n"
                            "    .\\vcpkg remove --outdated\n"
                            "    .\\vcpkg install " +
                            install_line);
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
