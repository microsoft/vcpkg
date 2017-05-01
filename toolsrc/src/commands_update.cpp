#include "pch.h"

#include "Paragraphs.h"
#include "vcpkg_Commands.h"
#include "vcpkg_Files.h"
#include "vcpkg_System.h"
#include "vcpkglib.h"

namespace vcpkg::Commands::Update
{
    bool OutdatedPackage::compare_by_name(const OutdatedPackage& left, const OutdatedPackage& right)
    {
        return left.spec.name() < right.spec.name();
    }

    std::vector<OutdatedPackage> find_outdated_packages(const VcpkgPaths& paths, const StatusParagraphs& status_db)
    {
        const std::vector<SourceParagraph> source_paragraphs =
            Paragraphs::load_all_ports(paths.get_filesystem(), paths.ports);
        const std::map<std::string, VersionT> src_names_to_versions =
            Paragraphs::extract_port_names_and_versions(source_paragraphs);
        const std::vector<StatusParagraph*> installed_packages = get_installed_ports(status_db);

        std::vector<OutdatedPackage> output;
        for (const StatusParagraph* pgh : installed_packages)
        {
            auto it = src_names_to_versions.find(pgh->package.spec.name());
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

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        args.check_exact_arg_count(0);
        args.check_and_get_optional_command_arguments({});
        System::println("Using local portfile versions. To update the local portfiles, use `git pull`.");

        const StatusParagraphs status_db = database_load_check(paths);

        const auto outdated_packages =
            SortedVector<OutdatedPackage>(find_outdated_packages(paths, status_db), &OutdatedPackage::compare_by_name);

        if (outdated_packages.empty())
        {
            System::println("No packages need updating.");
        }
        else
        {
            System::println("The following packages differ from their port versions:");
            for (auto&& package : outdated_packages)
            {
                System::println("    %-32s %s", package.spec, package.version_diff.to_string());
            }
            System::println("\n"
                            "To update these packages, run\n"
                            "    vcpkg remove --outdated\n"
                            "    vcpkg install <pkgs>...");
        }

        auto version_file = paths.get_filesystem().read_contents(paths.root / "toolsrc" / "VERSION.txt");
        if (auto version_contents = version_file.get())
        {
            int maj1, min1, rev1;
            auto num1 = sscanf_s(version_contents->c_str(), "\"%d.%d.%d\"", &maj1, &min1, &rev1);

            int maj2, min2, rev2;
            auto num2 = sscanf_s(Version::version().c_str(), "%d.%d.%d-", &maj2, &min2, &rev2);

            if (num1 == 3 && num2 == 3)
            {
                if (maj1 != maj2 || min1 != min2 || rev1 != rev2)
                {
                    System::println("Different source is available for vcpkg (%d.%d.%d -> %d.%d.%d). Use "
                                    ".\\bootstrap-vcpkg.bat to update.",
                                    maj2,
                                    min2,
                                    rev2,
                                    maj1,
                                    min1,
                                    rev1);
                }
            }
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
