#include "vcpkg_Commands.h"
#include "vcpkg_System.h"
#include "vcpkg.h"
#include <iostream>
#include <iomanip>

namespace fs = std::tr2::sys;

namespace vcpkg
{
    void search_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths)
    {
        args.check_max_args(1);

        if (args.command_arguments.size() == 1)
        {
            System::println(System::color::warning, "Search strings are not yet implemented; showing full list of packages.");
        }

        for (auto it = fs::directory_iterator(paths.ports); it != fs::directory_iterator(); ++it)
        {
            const fs::path& path = it->path();

            try
            {
                auto pghs = get_paragraphs(path / "CONTROL");
                if (pghs.empty())
                    continue;
                auto srcpgh = SourceParagraph(pghs[0]);
                std::cout << std::left
                    << std::setw(20) << srcpgh.name << ' '
                    << std::setw(16) << srcpgh.version << ' '
                    << shorten_description(srcpgh.description) << '\n';
            }
            catch (std::runtime_error const&)
            {
            }
        }

        System::println("\nIf your library is not listed, please open an issue at:\n"
            "    https://github.com/Microsoft/vcpkg/issues");

        exit(EXIT_SUCCESS);
    }
}
