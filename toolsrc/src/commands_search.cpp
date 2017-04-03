#include "pch.h"
#include "vcpkg_Commands.h"
#include "vcpkg_System.h"
#include "Paragraphs.h"
#include "vcpkglib_helpers.h"
#include "SourceParagraph.h"

namespace vcpkg::Commands::Search
{
    static const std::string OPTION_GRAPH = "--graph"; //TODO: This should find a better home, eventually

    static std::string replace_dashes_with_underscore(const std::string& input)
    {
        std::string output = input;
        std::replace(output.begin(), output.end(), '-', '_');
        return output;
    }

    static std::string create_graph_as_string(const std::vector<SourceParagraph>& source_paragraphs)
    {
        int empty_node_count = 0;

        std::string s;
        s.append("digraph G{ rankdir=LR; edge [minlen=3]; overlap=false;");

        for (const SourceParagraph& source_paragraph : source_paragraphs)
        {
            if (source_paragraph.depends.empty())
            {
                empty_node_count++;
                continue;
            }

            const std::string name = replace_dashes_with_underscore(source_paragraph.name);
            s.append(Strings::format("%s;", name));
            for (const Dependency& d : source_paragraph.depends)
            {
                const std::string dependency_name = replace_dashes_with_underscore(d.name);
                s.append(Strings::format("%s -> %s;", name, dependency_name));
            }
        }

        s.append(Strings::format("empty [label=\"%d singletons...\"]; }", empty_node_count));
        return s;
    }

    static void do_print(const SourceParagraph& source_paragraph)
    {
        System::println("%-20s %-16s %s",
                        source_paragraph.name,
                        source_paragraph.version,
                        details::shorten_description(source_paragraph.description));
    }

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        static const std::string example = Strings::format("The argument should be a substring to search for, or no argument to display all libraries.\n%s",
                                                           Commands::Help::create_example_string("search png"));
        args.check_max_arg_count(1, example);
        const std::unordered_set<std::string> options = args.check_and_get_optional_command_arguments({ OPTION_GRAPH });

        const std::vector<SourceParagraph> source_paragraphs = Paragraphs::load_all_ports(paths.ports);
        if (options.find(OPTION_GRAPH) != options.cend())
        {
            const std::string graph_as_string = create_graph_as_string(source_paragraphs);
            System::println(graph_as_string);
            Checks::exit_success(VCPKG_LINE_INFO);
        }

        if (args.command_arguments.empty())
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

        System::println("\nIf your library is not listed, please open an issue at and/or consider making a pull request:\n"
            "    https://github.com/Microsoft/vcpkg/issues");

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
