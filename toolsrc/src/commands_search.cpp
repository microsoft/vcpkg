#include "vcpkg_Commands.h"
#include "vcpkg_System.h"
#include "vcpkg.h"
#include <iostream>
#include <iomanip>

namespace fs = std::tr2::sys;

namespace vcpkg
{
    template <class Pred>
    static void do_print(const vcpkg_paths& paths, Pred predicate)
    {
        for (auto it = fs::directory_iterator(paths.ports); it != fs::directory_iterator(); ++it)
        {
            const fs::path& path = it->path();

            try
            {
                auto pghs = get_paragraphs(path / "CONTROL");
                if (pghs.empty())
                    continue;
                auto srcpgh = SourceParagraph(pghs[0]);

                if (predicate(srcpgh.name))
                {
                    std::cout << std::left
                        << std::setw(20) << srcpgh.name << ' '
                        << std::setw(16) << srcpgh.version << ' '
                        << shorten_description(srcpgh.description) << '\n';
                }
            }
            catch (std::runtime_error const&)
            {
            }
        }
    }

    void search_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths)
    {
        static const std::string example = Strings::format("The argument should be a substring to search for, or no argument to display all libraries.\n%s", create_example_string("search png"));
        args.check_max_arg_count(1, example.c_str());

        if (args.command_arguments.size() == 0)
        {
            do_print(paths, [](std::string&) -> bool
                     {
                         return true;
                     });
            exit(EXIT_SUCCESS);
        }

        // At this point there is 1 argument
        do_print(paths, [&](std::string& port_name) -> bool
                 {
                     return Strings::case_insensitive_ascii_find(port_name, args.command_arguments[0]) != port_name.end();
                 });

        System::println("\nIf your library is not listed, please open an issue at:\n"
            "    https://github.com/Microsoft/vcpkg/issues");

        exit(EXIT_SUCCESS);
    }
}
