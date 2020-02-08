#include "pch.h"

#include <vcpkg/base/system.print.h>
#include <vcpkg/commands.h>
#include <vcpkg/dependencies.h>
#include <vcpkg/globalstate.h>
#include <vcpkg/help.h>
#include <vcpkg/paragraphs.h>
#include <vcpkg/sourceparagraph.h>
#include <vcpkg/vcpkglib.h>

using vcpkg::PortFileProvider::PathsPortFileProvider;

namespace vcpkg::Commands::Search
{
    static constexpr StringLiteral OPTION_FULLDESC =
        "--x-full-desc"; // TODO: This should find a better home, eventually

    static void do_print(const SourceParagraph& source_paragraph, bool full_desc)
    {
        if (full_desc)
        {
            System::printf(
                "%-20s %-16s %s\n", source_paragraph.name, source_paragraph.version, source_paragraph.description);
        }
        else
        {
            System::printf("%-20s %-16s %s\n",
                           vcpkg::shorten_text(source_paragraph.name, 20),
                           vcpkg::shorten_text(source_paragraph.version, 16),
                           vcpkg::shorten_text(source_paragraph.description, 81));
        }
    }

    static void do_print(const std::string& name, const FeatureParagraph& feature_paragraph, bool full_desc)
    {
        auto full_feature_name = Strings::concat(name, "[", feature_paragraph.name, "]");
        if (full_desc)
        {
            System::printf("%-37s %s\n", full_feature_name, feature_paragraph.description);
        }
        else
        {
            System::printf("%-37s %s\n",
                           vcpkg::shorten_text(full_feature_name, 37),
                           vcpkg::shorten_text(feature_paragraph.description, 81));
        }
    }

    static constexpr std::array<CommandSwitch, 1> SEARCH_SWITCHES = {{
        {OPTION_FULLDESC, "Do not truncate long text"},
    }};

    const CommandStructure COMMAND_STRUCTURE = {
        Strings::format(
            "The argument should be a substring to search for, or no argument to display all libraries.\n%s",
            Help::create_example_string("search png")),
        0,
        1,
        {SEARCH_SWITCHES, {}},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        const ParsedArguments options = args.parse_arguments(COMMAND_STRUCTURE);
        const bool full_description = Util::Sets::contains(options.switches, OPTION_FULLDESC);

        PathsPortFileProvider provider(paths, args.overlay_ports.get());
        auto source_paragraphs =
            Util::fmap(provider.load_all_control_files(),
                       [](auto&& port) -> const SourceControlFile* { return port->source_control_file.get(); });

        if (args.command_arguments.empty())
        {
            for (const auto& source_control_file : source_paragraphs)
            {
                do_print(*source_control_file->core_paragraph, full_description);
                for (auto&& feature_paragraph : source_control_file->feature_paragraphs)
                {
                    do_print(source_control_file->core_paragraph->name, *feature_paragraph, full_description);
                }
            }
        }
        else
        {
            const auto& icontains = Strings::case_insensitive_ascii_contains;

            // At this point there is 1 argument
            auto&& args_zero = args.command_arguments[0];
            for (const auto& source_control_file : source_paragraphs)
            {
                auto&& sp = *source_control_file->core_paragraph;

                const bool contains_name = icontains(sp.name, args_zero);
                if (contains_name || icontains(sp.description, args_zero))
                {
                    do_print(sp, full_description);
                }

                for (auto&& feature_paragraph : source_control_file->feature_paragraphs)
                {
                    if (contains_name || icontains(feature_paragraph->name, args_zero) ||
                        icontains(feature_paragraph->description, args_zero))
                    {
                        do_print(sp.name, *feature_paragraph, full_description);
                    }
                }
            }
        }

        System::print2(
            "\nIf your library is not listed, please open an issue at and/or consider making a pull request:\n"
            "    https://github.com/Microsoft/vcpkg/issues\n");

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
