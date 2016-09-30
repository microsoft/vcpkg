#include "vcpkg_Commands.h"
#include "vcpkg.h"
#include "vcpkg_System.h"

namespace vcpkg
{
    void list_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths)
    {
        args.check_max_arg_count(0);

        std::vector<std::string> packages_output;
        for (auto&& pgh : database_load_check(paths))
        {
            if (pgh->state == install_state_t::not_installed && pgh->want == want_t::purge)
                continue;
            packages_output.push_back(Strings::format("%-27s %-16s %s",
                                                      pgh->package.displayname(),
                                                      pgh->package.version,
                                                      shorten_description(pgh->package.description)));
        }
        std::sort(packages_output.begin(), packages_output.end());
        for (auto&& package : packages_output)
        {
            System::println(package.c_str());
        }
        if (packages_output.empty())
        {
            System::println("No packages are installed. Did you mean `search`?");
        }
        exit(EXIT_SUCCESS);
    }
}
