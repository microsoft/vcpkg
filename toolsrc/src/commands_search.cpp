#include "pch.h"

#include "Paragraphs.h"
#include "SourceParagraph.h"
#include "vcpkg_Commands.h"
#include "vcpkg_System.h"
#include "vcpkglib.h"
#include "vcpkglib_helpers.h"

namespace vcpkg::Commands::Search
{
    static const std::string OPTION_GRAPH = "--graph"; // TODO: This should find a better home, eventually

    static std::string replace_dashes_with_underscore(const std::string& input)
    {
        std::string output = input;
        std::replace(output.begin(), output.end(), '-', '_');
        return output;
    }

    static std::string create_graph_as_string(const std::vector<SourceControlFile>& source_control_files)
    {
        int empty_node_count = 0;

        std::string s;
        s.append("digraph G{ rankdir=LR; edge [minlen=3]; overlap=false;");

        for (const SourceControlFile& source_control_file : source_control_files)
        {
            const SourceParagraph& source_paragraph = source_control_file.core_paragraph;
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

    static void do_print(const SourceControlFile& source_control_file, const std::string& feature_name)
    {
        if (feature_name.empty())
            System::println("%-20s %-16s %s",
                            source_control_file.core_paragraph.name,
                            source_control_file.core_paragraph.version,
                            details::shorten_description(source_control_file.core_paragraph.description));
        if (feature_packages)
        {
            for (auto&& feature : source_control_file.feature_paragraphs)
            {
                if (!feature_name.empty())
                {
                    if (feature_name.compare(feature->name) != 0)
                    {
                        continue;
                    }
                }
                System::println("%s%-31s %s",
                                source_control_file.core_paragraph.name,
                                "[" + feature->name + "]",
                                details::shorten_description(feature->description));
            }
        }
    }

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        static const std::string example = Strings::format(
            "The argument should be a substring to search for, or no argument to display all libraries.\n%s",
            Commands::Help::create_example_string("search png"));
        args.check_max_arg_count(1, example);
        const std::unordered_set<std::string> options = args.check_and_get_optional_command_arguments({OPTION_GRAPH});

        auto sources_and_errors = Paragraphs::try_load_all_ports(paths.get_filesystem(), paths.ports);

        if (!sources_and_errors.errors.empty())
        {
            if (vcpkg::g_debugging)
            {
                print_error_message(sources_and_errors.errors);
            }
            else
            {
                for (auto&& error : sources_and_errors.errors)
                {
                    System::println(
                        System::Color::warning, "Warning: an error occurred while parsing '%s'\n", error.name);
                }
                System::println(System::Color::warning,
                                "Use '--debug' to get more information about the parse failures.\n");
            }
        }

        auto& source_paragraphs = sources_and_errors.paragraphs;
        // check above line?
        if (options.find(OPTION_GRAPH) != options.cend())
        {
            // rename source_paragraphs
            const std::string graph_as_string = create_graph_as_string(source_paragraphs);
            System::println(graph_as_string);
            Checks::exit_success(VCPKG_LINE_INFO);
        }

        if (args.command_arguments.empty())
        {
            for (const SourceControlFile& source_control_file : source_paragraphs)
            {
                do_print(source_control_file, "");
            }
        }
        else
        {
            // At this point there is 1 argument
            for (const SourceControlFile& source_control_file : source_paragraphs)
            {
                if (Strings::case_insensitive_ascii_find(source_control_file.core_paragraph.name,
                                                         args.command_arguments[0]) ==
                    source_control_file.core_paragraph.name.end())
                {
                    if (Strings::case_insensitive_ascii_find(source_control_file.core_paragraph.description,
                                                             args.command_arguments[0]) ==
                        source_control_file.core_paragraph.description.end())
                    {
                        for (auto&& feature_paragraph : source_control_file.feature_paragraphs)
                        {
                            if (Strings::case_insensitive_ascii_find(feature_paragraph->name,
                                                                     args.command_arguments[0]) !=
                                feature_paragraph->name.end())
                            {
                                do_print(source_control_file, feature_paragraph->name);
                            }
                        }
                        continue;
                    }
                }

                do_print(source_control_file, "");
            }
        }

        System::println(
            "\nIf your library is not listed, please open an issue at and/or consider making a pull request:\n"
            "    https://github.com/Microsoft/vcpkg/issues");

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
