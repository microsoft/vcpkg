#include "pch.h"

#include <vcpkg/base/strings.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/util.h>
#include <vcpkg/commands.h>
#include <vcpkg/help.h>
#include <vcpkg/input.h>
#include <vcpkg/install.h>
#include <vcpkg/packagespec.h>
#include <vcpkg/paragraphs.h>

#include <memory>
#include <vcpkg/dependencies.h>
#include <vector>

using vcpkg::Dependencies::AnyAction;
using vcpkg::Dependencies::create_feature_install_plan;
using vcpkg::Dependencies::PathsPortFileProvider;
using vcpkg::Dependencies::InstallPlanAction;

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

            const std::string name = Strings::replace_all(std::string{source_paragraph.name}, "-", "_");
            s.append(Strings::format("%s;", name));
            for (const Dependency& d : source_paragraph.depends)
            {
                const std::string dependency_name = Strings::replace_all(std::string{d.depend.name}, "-", "_");
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

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet)
    {
        const ParsedArguments options = args.parse_arguments(COMMAND_STRUCTURE);

        const std::vector<FullPackageSpec> specs = Util::fmap(args.command_arguments, [&](auto&& arg) {
            return Input::check_and_get_full_package_spec(
                std::string{arg}, default_triplet, COMMAND_STRUCTURE.example_text);
        });

        for (auto&& spec : specs)
        {
            Input::check_triplet(spec.package_spec.triplet(), paths);
        }

        PathsPortFileProvider provider(paths, args.overlay_ports.get());

        // By passing an empty status_db, we should get a plan containing all dependencies.
        // All actions in the plan should be install actions, as there's no installed packages to remove.
        StatusParagraphs status_db;
        std::vector<AnyAction> action_plan =
            create_feature_install_plan(provider, FullPackageSpec::to_feature_specs(specs), status_db);
        std::vector<const InstallPlanAction*> install_actions =
            Util::fmap(action_plan, [&](const AnyAction& action) {
                if (auto install_action = action.install_action.get())
                {
                    return install_action;
                }
                Checks::exit_with_message(VCPKG_LINE_INFO, "Only install actions should exist in the plan");
            });

        /*if (Util::Sets::contains(options.switches, OPTION_DOT) || Util::Sets::contains(options.switches, OPTION_DGML))
        {
            const std::string graph_as_string = create_graph_as_string(options.switches, source_control_files);
            System::print2(graph_as_string, '\n');
            Checks::exit_success(VCPKG_LINE_INFO);
        }*/

        for (auto* install_action : install_actions)
        {
            Checks::check_exit(VCPKG_LINE_INFO, install_action != nullptr);
            const std::string portname = install_action->spec.name();
            const std::string features = Strings::join(", ", install_action->feature_list);

            const std::vector<std::string> deps = 
                Util::fmap(install_action->computed_dependencies, 
                    [](const PackageSpec& spec) -> std::string { return spec.name(); });
            const std::string dependencies = Strings::join(", ", deps);

            System::printf("%s[%s]: %s\n", portname, features, dependencies);
        }
        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
