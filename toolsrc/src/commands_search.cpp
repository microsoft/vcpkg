#include "vcpkg_Commands.h"
#include "vcpkg_System.h"
#include "Paragraphs.h"
#include "vcpkglib_helpers.h"
#include "SourceParagraph.h"

namespace vcpkg
{
    static std::vector<SourceParagraph> read_all_source_paragraphs(const vcpkg_paths& paths)
    {
        std::vector<SourceParagraph> output;
        for (auto it = fs::directory_iterator(paths.ports); it != fs::directory_iterator(); ++it)
        {
            const fs::path& path = it->path();

            try
            {
                auto pghs = Paragraphs::get_paragraphs(path / "CONTROL");
                if (pghs.empty())
                {
                    continue;
                }

                auto srcpgh = SourceParagraph(pghs[0]);
                output.push_back(srcpgh);
            }
            catch (std::runtime_error const&)
            {
            }
        }

        return output;
    }

    static void do_print(const SourceParagraph& source_paragraph)
    {
        System::println("%-20s %-16s %s",
                        source_paragraph.name,
                        source_paragraph.version,
                        details::shorten_description(source_paragraph.description));
    }

    void search_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths)
    {
        static const std::string example = Strings::format("The argument should be a substring to search for, or no argument to display all libraries.\n%s", create_example_string("search png"));
        args.check_max_arg_count(1, example.c_str());

        const std::vector<SourceParagraph> source_paragraphs = read_all_source_paragraphs(paths);

        if (args.command_arguments.size() == 0)
        {
            for (const SourceParagraph& source_paragraph : source_paragraphs)
            {
                do_print(source_paragraph);
            }
        }
        else
        {
            // At this point there is 1 argument
            for (const SourceParagraph& source_paragraph : source_paragraphs)
            {
                if (Strings::case_insensitive_ascii_find(source_paragraph.name, args.command_arguments[0]) == source_paragraph.name.end())
                {
                    continue;
                }

                do_print(source_paragraph);
            }
        }

        System::println("\nIf your library is not listed, please open an issue at:\n"
            "    https://github.com/Microsoft/vcpkg/issues");

        exit(EXIT_SUCCESS);
    }
}
