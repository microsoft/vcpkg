#include "vcpkg_Commands.h"
#include "vcpkg_System.h"
#include "vcpkg_Files.h"
#include "vcpkg.h"

namespace vcpkg
{
    template <class Pred>
    static void do_print(const vcpkg_paths& paths, Pred predicate)
    {
        auto it = fs::directory_iterator(paths.packages);
        const fs::directory_iterator end_it = fs::directory_iterator();

        if (it == end_it)
        {
            System::println("No packages are cached.");
            exit(EXIT_SUCCESS);
        }

        for (; it != end_it; ++it)
        {
            const fs::path& path = it->path();

            try
            {
                auto file_contents = Files::get_contents(path / "CONTROL");
                if (auto text = file_contents.get())
                {
                    auto pghs = parse_paragraphs(*text);
                    if (pghs.size() != 1)
                        continue;

                    const BinaryParagraph src = BinaryParagraph(pghs[0]);
                    const std::string displayname = src.displayname();
                    if (predicate(displayname))
                    {
                        System::println(displayname.c_str());
                    }
                }
            }
            catch (std::runtime_error const&)
            {
            }
        }
    }

    void cache_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths)
    {
        static const std::string example = Strings::format(
            "The argument should be a substring to search for, or no argument to display all cached libraries.\n%s", create_example_string("cache png"));
        args.check_max_arg_count(1, example.c_str());

        if (args.command_arguments.size() == 0)
        {
            do_print(paths, [](const std::string&) -> bool
                     {
                         return true;
                     });
            exit(EXIT_SUCCESS);
        }

        // At this point there is 1 argument
        do_print(paths, [&](const std::string& port_name) -> bool
                 {
                     return Strings::case_insensitive_ascii_find(port_name, args.command_arguments[0]) != port_name.end();
                 });

        exit(EXIT_SUCCESS);
    }
}
