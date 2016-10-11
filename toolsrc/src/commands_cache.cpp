#include "vcpkg_Commands.h"
#include "vcpkg_System.h"
#include "vcpkg_Files.h"
#include "vcpkg.h"

namespace vcpkg
{
    void cache_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths)
    {
        args.check_exact_arg_count(0);

        auto begin_it = fs::directory_iterator(paths.packages);
        auto end_it = fs::directory_iterator();

        if (begin_it == end_it)
        {
            System::println("No packages are cached.");
            exit(EXIT_SUCCESS);
        }

        for (; begin_it != end_it; ++begin_it)
        {
            const auto& path = begin_it->path();

            auto file_contents = Files::get_contents(path / "CONTROL");
            if (auto text = file_contents.get())
            {
                auto pghs = parse_paragraphs(*text);
                if (pghs.size() != 1)
                    continue;

                auto src = BinaryParagraph(pghs[0]);
                System::println(src.displayname().c_str());
            }
        }

        exit(EXIT_SUCCESS);
    }
}
