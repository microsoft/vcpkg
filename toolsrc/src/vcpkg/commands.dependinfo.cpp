#include "pch.h"

#include <vcpkg/base/strings.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/util.h>
#include <vcpkg/commands.h>
#include <vcpkg/help.h>
#include <vcpkg/paragraphs.h>
#include <vcpkg/dependencies.h>

using vcpkg::Dependencies::PathsPortFileProvider;

namespace vcpkg::Commands::DependInfo
{
    constexpr StringLiteral OPTION_DOT = "--dot";
    constexpr StringLiteral OPTION_DGML = "--dgml";
    constexpr StringLiteral OPTION_NO_RECURSE = "--no-recurse";

    constexpr std::array<CommandSwitch, 3> DEPEND_SWITCHES = {{
        {OPTION_DOT, "Creates graph on basis of dot"},
        {OPTION_DGML, "Creates graph on basis of dgml"},
        {OPTION_NO_RECURSE,
         "Computes only immediate dependencies of packages explicitly specified on the command-line"},
    }};

    const CommandStructure COMMAND_STRUCTURE = {
        Help::create_example_string(R"###(depend-info [pat])###"),
        0,
        SIZE_MAX,
        {DEPEND_SWITCHES, {}},
        nullptr,
    };

    std::string replace_dashes_with_underscore(const std::string& input)
    {
        std::string output = input;
        std::replace(output.begin(), output.end(), '-', '_');
        return output;
    }

    std::string create_dot_as_string(const std::vector<const SourceControlFile*>& source_control_files)
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
                const std::string dependency_name = replace_dashes_with_underscore(d.depend.name);
                s.append(Strings::format("%s -> %s;", name, dependency_name));
            }
        }

        s.append(Strings::format("empty [label=\"%d singletons...\"]; }", empty_node_count));
        return s;
    }

    std::string create_dgml_as_string(const std::vector<const SourceControlFile*>& source_control_files)
    {
        std::string s;
        s.append("<?xml version=\"1.0\" encoding=\"utf-8\"?>");
        s.append("<DirectedGraph xmlns=\"http://schemas.microsoft.com/vs/2009/dgml\">");

        std::string nodes, links;
        for (const auto& source_control_file : source_control_files)
        {
            const SourceParagraph& source_paragraph = *source_control_file->core_paragraph;
            const std::string name = source_paragraph.name;
            nodes.append(Strings::format("<Node Id=\"%s\" />", name));

            // Iterate over dependencies.
            for (const Dependency& d : source_paragraph.depends)
            {
                if (d.qualifier.empty())
                    links.append(Strings::format("<Link Source=\"%s\" Target=\"%s\" />", name, d.depend.name));
                else
                    links.append(Strings::format(
                        "<Link Source=\"%s\" Target=\"%s\" StrokeDashArray=\"4\" />", name, d.depend.name));
            }

            // Iterate over feature dependencies.
            const std::vector<std::unique_ptr<FeatureParagraph>>& feature_paragraphs =
                source_control_file->feature_paragraphs;
            for (const auto& feature_paragraph : feature_paragraphs)
            {
                for (const Dependency& d : feature_paragraph->depends)
                {
                    links.append(Strings::format(
                        "<Link Source=\"%s\" Target=\"%s\" StrokeDashArray=\"4\" />", name, d.depend.name));
                }
            }
        }

        s.append(Strings::format("<Nodes>%s</Nodes>", nodes));

        s.append(Strings::format("<Links>%s</Links>", links));

        s.append("</DirectedGraph>");
        return s;
    }

    std::string create_graph_as_string(const std::unordered_set<std::string>& switches,
                                       const std::vector<const SourceControlFile*>& source_control_files)
    {
        if (Util::Sets::contains(switches, OPTION_DOT))
        {
            return create_dot_as_string(source_control_files);
        }
        else if (Util::Sets::contains(switches, OPTION_DGML))
        {
            return create_dgml_as_string(source_control_files);
        }
        return "";
    }

    void build_dependencies_list(std::set<std::string>& packages_to_keep,
                                 const std::string& requested_package,
                                 const std::vector<const SourceControlFile*>& source_control_files,
                                 const std::unordered_set<std::string>& switches)
    {
        const auto source_control_file =
            Util::find_if(source_control_files, [&requested_package](const auto& source_control_file) {
                return source_control_file->core_paragraph->name == requested_package;
            });

        if (source_control_file != source_control_files.end())
        {
            const auto new_package = packages_to_keep.insert(requested_package).second;

            if (new_package && !Util::Sets::contains(switches, OPTION_NO_RECURSE))
            {
                for (const auto& dependency : (*source_control_file)->core_paragraph->depends)
                {
                    build_dependencies_list(packages_to_keep, dependency.depend.name, source_control_files, switches);
                }
            }
        }
        else
        {
            System::print2(System::Color::warning, "package '", requested_package, "' does not exist\n");
        }
    }

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        const ParsedArguments options = args.parse_arguments(COMMAND_STRUCTURE);

        // TODO: Optimize implementation, current implementation needs to load all ports from disk which is too slow.
        PathsPortFileProvider provider(paths, args.overlay_ports.get());
        auto source_control_files = Util::fmap(provider.load_all_control_files(), [](auto&& scfl) -> const SourceControlFile * {
            return scfl->source_control_file.get();
        });

        if (args.command_arguments.size() >= 1)
        {
            std::set<std::string> packages_to_keep;
            for (const auto& requested_package : args.command_arguments)
            {
                build_dependencies_list(packages_to_keep, requested_package, source_control_files, options.switches);
            }

            Util::erase_remove_if(source_control_files, [&packages_to_keep](const auto& source_control_file) {
                return !Util::Sets::contains(packages_to_keep, source_control_file->core_paragraph->name);
            });
        }

        if (Util::Sets::contains(options.switches, OPTION_DOT) || Util::Sets::contains(options.switches, OPTION_DGML))
        {
            const std::string graph_as_string = create_graph_as_string(options.switches, source_control_files);
            System::print2(graph_as_string, '\n');
            Checks::exit_success(VCPKG_LINE_INFO);
        }

        for (auto&& source_control_file : source_control_files)
        {
            const SourceParagraph& source_paragraph = *source_control_file->core_paragraph.get();
            const auto s = Strings::join(", ", source_paragraph.depends, [](const Dependency& d) { return d.name(); });
            System::print2(source_paragraph.name, ": ", s, "\n");
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
