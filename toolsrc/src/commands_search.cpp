#include "pch.h"

#include "Paragraphs.h"
#include "SourceParagraph.h"
#include "vcpkg_Commands.h"
#include "vcpkg_GlobalState.h"
#include "vcpkg_System.h"
#include "vcpkglib.h"

namespace vcpkg::Commands::Search
{
    static const std::string OPTION_GRAPH = "--graph";          // TODO: This should find a better home, eventually
    static const std::string OPTION_FULLDESC = "--x-full-desc"; // TODO: This should find a better home, eventually

    static std::string replace_dashes_with_underscore(const std::string& input)
    {
        std::string output = input;
        std::replace(output.begin(), output.end(), '-', '_');
        return output;
    }

    static std::string create_graph_as_string(
        const std::vector<std::unique_ptr<SourceControlFile>>& source_control_files)
    {
        int empty_node_count = 0;

        std::string s;
        s.append("digraph G{ rankdir=LR; edge [minlen=3]; overlap=false;");

        for (const auto& source_control_file : source_control_files)
        {
            const SourceParagraph& source_paragraph = *source_control_file->core_paragraph;
            if (source_paragraph.depends.empty())
            {
                empty_node_count++;
                continue;
            }

            const std::string name = replace_dashes_with_underscore(source_paragraph.name);
            s.append(Strings::format("%s;", name));
            for (const Dependency& d : source_paragraph.depends)
            {
                const std::string dependency_name = replace_dashes_with_underscore(d.name());
                s.append(Strings::format("%s -> %s;", name, dependency_name));
            }
        }

        s.append(Strings::format("empty [label=\"%d singletons...\"]; }", empty_node_count));
        return s;
    }
    static void do_print(const SourceParagraph& source_paragraph, bool full_desc)
    {
        if (full_desc)
        {
            System::println(
                "%-20s %-16s %s", source_paragraph.name, source_paragraph.version, source_paragraph.description);
        }
        else
        {
            System::println("%-20s %-16s %s",
                            vcpkg::shorten_text(source_paragraph.name, 20),
                            vcpkg::shorten_text(source_paragraph.version, 16),
                            vcpkg::shorten_text(source_paragraph.description, 81));
        }
    }

    static void do_print(const std::string& name, const FeatureParagraph& feature_paragraph, bool full_desc)
    {
        if (full_desc)
        {
            System::println("%-37s %s", name + "[" + feature_paragraph.name + "]", feature_paragraph.description);
        }
        else
        {
            System::println("%-37s %s",
                            vcpkg::shorten_text(name + "[" + feature_paragraph.name + "]", 37),
                            vcpkg::shorten_text(feature_paragraph.description, 81));
        }
    }

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        static const std::string EXAMPLE = Strings::format(
            "The argument should be a substring to search for, or no argument to display all libraries.\n%s",
            Commands::Help::create_example_string("search png"));
        args.check_max_arg_count(1, EXAMPLE);
        const std::unordered_set<std::string> options =
            args.check_and_get_optional_command_arguments({OPTION_GRAPH, OPTION_FULLDESC});

        auto source_paragraphs = Paragraphs::load_all_ports(paths.get_filesystem(), paths.ports);

        if (options.find(OPTION_GRAPH) != options.cend())
        {
            const std::string graph_as_string = create_graph_as_string(source_paragraphs);
            System::println(graph_as_string);
            Checks::exit_success(VCPKG_LINE_INFO);
        }

        if (args.command_arguments.empty())
        {
            for (const auto& source_control_file : source_paragraphs)
            {
                do_print(*source_control_file->core_paragraph, options.find(OPTION_FULLDESC) != options.cend());
                for (auto&& feature_paragraph : source_control_file->feature_paragraphs)
                {
                    do_print(source_control_file->core_paragraph->name,
                             *feature_paragraph,
                             options.find(OPTION_FULLDESC) != options.cend());
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

                bool contains_name = icontains(sp.name, args_zero);
                if (contains_name || icontains(sp.description, args_zero))
                {
                    do_print(sp, options.find(OPTION_FULLDESC) != options.cend());
                }

                for (auto&& feature_paragraph : source_control_file->feature_paragraphs)
                {
                    if (contains_name || icontains(feature_paragraph->name, args_zero) ||
                        icontains(feature_paragraph->description, args_zero))
                    {
                        do_print(sp.name, *feature_paragraph, options.find(OPTION_FULLDESC) != options.cend());
                    }
                }
            }
        }

        System::println(
            "\nIf your library is not listed, please open an issue at and/or consider making a pull request:\n"
            "    https://github.com/Microsoft/vcpkg/issues");

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
