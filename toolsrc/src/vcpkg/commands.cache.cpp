#include <vcpkg/base/files.h>
#include <vcpkg/base/system.print.h>

#include <vcpkg/binaryparagraph.h>
#include <vcpkg/commands.cache.h>
#include <vcpkg/help.h>
#include <vcpkg/paragraphs.h>
#include <vcpkg/vcpkgcmdarguments.h>
#include <vcpkg/vcpkgpaths.h>

namespace vcpkg::Commands::Cache
{
    static std::vector<BinaryParagraph> read_all_binary_paragraphs(const VcpkgPaths& paths)
    {
        std::vector<BinaryParagraph> output;
        for (auto&& path : paths.get_filesystem().get_files_non_recursive(paths.packages))
        {
            const auto pghs = Paragraphs::get_single_paragraph(paths.get_filesystem(), path / fs::u8path("CONTROL"));
            if (const auto p = pghs.get())
            {
                const BinaryParagraph binary_paragraph = BinaryParagraph(*p);
                output.push_back(binary_paragraph);
            }
        }

        return output;
    }

    const CommandStructure COMMAND_STRUCTURE = {
        Strings::format(
            "The argument should be a substring to search for, or no argument to display all cached libraries.\n%s",
            create_example_string("cache png")),
        0,
        1,
        {},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        (void)(args.parse_arguments(COMMAND_STRUCTURE));

        const std::vector<BinaryParagraph> binary_paragraphs = read_all_binary_paragraphs(paths);
        if (binary_paragraphs.empty())
        {
            System::print2("No packages are cached.\n");
            Checks::exit_success(VCPKG_LINE_INFO);
        }

        if (args.command_arguments.empty())
        {
            for (const BinaryParagraph& binary_paragraph : binary_paragraphs)
            {
                System::print2(binary_paragraph.displayname(), '\n');
            }
        }
        else
        {
            // At this point there is 1 argument
            for (const BinaryParagraph& binary_paragraph : binary_paragraphs)
            {
                const std::string displayname = binary_paragraph.displayname();
                if (!Strings::case_insensitive_ascii_contains(displayname, args.command_arguments[0]))
                {
                    continue;
                }

                System::print2(displayname, '\n');
            }
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }

    void CacheCommand::perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const
    {
        Cache::perform_and_exit(args, paths);
    }
}
