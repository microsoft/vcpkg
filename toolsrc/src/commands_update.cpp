#include "vcpkg_Commands.h"
#include "vcpkg.h"
#include "vcpkg_System.h"
#include "vcpkg_Files.h"
#include "Paragraphs.h"
#include "vcpkg_info.h"

namespace vcpkg::Commands::Update
{
    void perform_and_exit(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths)
    {
        args.check_exact_arg_count(0);
        System::println("Using local portfile versions. To update the local portfiles, use `git pull`.");

        auto status_db = database_load_check(paths);

        std::unordered_map<std::string, std::string> src_names_to_versions;

        auto begin_it = fs::directory_iterator(paths.ports);
        auto end_it = fs::directory_iterator();
        for (; begin_it != end_it; ++begin_it)
        {
            const auto& path = begin_it->path();
            try
            {
                auto pghs = Paragraphs::get_paragraphs(path / "CONTROL");
                if (pghs.empty())
                    continue;
                auto srcpgh = SourceParagraph(pghs[0]);
                src_names_to_versions.emplace(srcpgh.name, srcpgh.version);
            }
            catch (std::runtime_error const&)
            {
            }
        }

        std::string packages_list;

        std::vector<std::string> packages_output;
        for (auto&& pgh : status_db)
        {
            if (pgh->state == install_state_t::not_installed && pgh->want == want_t::purge)
                continue;
            auto it = src_names_to_versions.find(pgh->package.spec.name());
            if (it == src_names_to_versions.end())
            {
                // Package was not installed from portfile
                continue;
            }
            if (it->second != pgh->package.version)
            {
                packages_output.push_back(Strings::format("%-27s %s -> %s",
                                                          pgh->package.displayname(),
                                                          pgh->package.version,
                                                          it->second));
                packages_list.append(" " + pgh->package.displayname());
            }
        }
        std::sort(packages_output.begin(), packages_output.end());
        if (packages_output.empty())
        {
            System::println("No packages need updating.");
        }
        else
        {
            System::println("The following packages differ from their port versions:");
            for (auto&& package : packages_output)
            {
                System::println("    %s", package.c_str());
            }
            System::println("\nTo update these packages, run\n    vcpkg remove --purge <pkgs>...\n    vcpkg install <pkgs>...");
        }

        auto version_file = Files::read_contents(paths.root / "toolsrc" / "VERSION.txt");
        if (auto version_contents = version_file.get())
        {
            int maj1, min1, rev1;
            auto num1 = sscanf_s(version_contents->c_str(), "\"%d.%d.%d\"", &maj1, &min1, &rev1);

            int maj2, min2, rev2;
            auto num2 = sscanf_s(Info::version().c_str(), "%d.%d.%d-", &maj2, &min2, &rev2);

            if (num1 == 3 && num2 == 3)
            {
                if (maj1 != maj2 || min1 != min2 || rev1 != rev2)
                {
                    System::println("Different source is available for vcpkg (%d.%d.%d -> %d.%d.%d). Use scripts\\bootstrap.ps1 to update.",
                                    maj2, min2, rev2,
                                    maj1, min1, rev1);
                }
            }
        }

        exit(EXIT_SUCCESS);
    }
}
