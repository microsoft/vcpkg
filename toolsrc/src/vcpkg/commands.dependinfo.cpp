#include "pch.h"

#include <vcpkg/base/strings.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/util.h>
#include <vcpkg/commands.h>
#include <vcpkg/dependencies.h>
#include <vcpkg/help.h>
#include <vcpkg/input.h>
#include <vcpkg/install.h>
#include <vcpkg/packagespec.h>
#include <vector>

using vcpkg::Dependencies::ActionPlan;
using vcpkg::Dependencies::InstallPlanAction;
using vcpkg::PortFileProvider::PathsPortFileProvider;

namespace vcpkg::Commands::DependInfo
{
    namespace
    {
        constexpr StringLiteral OPTION_DOT = "--dot";
        constexpr StringLiteral OPTION_DGML = "--dgml";
        constexpr StringLiteral OPTION_SHOW_DEPTH = "--show-depth";
        constexpr StringLiteral OPTION_MAX_RECURSE = "--max-recurse";
        constexpr StringLiteral OPTION_SORT = "--sort";

        constexpr int NO_RECURSE_LIMIT_VALUE = -1;

        constexpr std::array<CommandSwitch, 3> DEPEND_SWITCHES = {
            {{OPTION_DOT, "Creates graph on basis of dot"},
             {OPTION_DGML, "Creates graph on basis of dgml"},
             {OPTION_SHOW_DEPTH, "Show recursion depth in output"}}};

        constexpr std::array<CommandSetting, 2> DEPEND_SETTINGS = {
            {{OPTION_MAX_RECURSE, "Set max recursion depth, a value of -1 indicates no limit"},
             {OPTION_SORT,
              "Set sort order for the list of dependencies, accepted values are: lexicographical, topological "
              "(default), "
              "reverse"}}};

        struct PackageDependInfo
        {
            std::string package;
            int depth;
            std::unordered_set<std::string> features;
            std::vector<std::string> dependencies;
        };

        enum SortMode
        {
            Lexicographical = 0,
            Topological,
            ReverseTopological,
            Default = Topological
        };

        int get_max_depth(const ParsedArguments& options)
        {
            auto iter = options.settings.find(OPTION_MAX_RECURSE);
            if (iter != options.settings.end())
            {
                std::string value = iter->second;
                try
                {
                    return std::stoi(value);
                }
                catch (std::exception&)
                {
                    Checks::exit_with_message(VCPKG_LINE_INFO, "Value of --max-depth must be an integer");
                }
            }
            // No --max-depth set, default to no limit.
            return NO_RECURSE_LIMIT_VALUE;
        }

        SortMode get_sort_mode(const ParsedArguments& options)
        {
            constexpr StringLiteral OPTION_SORT_LEXICOGRAPHICAL = "lexicographical";
            constexpr StringLiteral OPTION_SORT_TOPOLOGICAL = "topological";
            constexpr StringLiteral OPTION_SORT_REVERSE = "reverse";

            static const std::map<std::string, SortMode> sortModesMap{{OPTION_SORT_LEXICOGRAPHICAL, Lexicographical},
                                                                      {OPTION_SORT_TOPOLOGICAL, Topological},
                                                                      {OPTION_SORT_REVERSE, ReverseTopological}};

            auto iter = options.settings.find(OPTION_SORT);
            if (iter != options.settings.end())
            {
                const std::string value = Strings::ascii_to_lowercase(std::string{iter->second});
                auto it = sortModesMap.find(value);
                if (it != sortModesMap.end())
                {
                    return it->second;
                }
                Checks::exit_with_message(VCPKG_LINE_INFO,
                                          "Value of --sort must be one of `%s`, `%s`, or `%s`",
                                          OPTION_SORT_LEXICOGRAPHICAL,
                                          OPTION_SORT_TOPOLOGICAL,
                                          OPTION_SORT_REVERSE);
            }
            return Default;
        }

        std::string create_dot_as_string(const std::vector<PackageDependInfo>& depend_info)
        {
            int empty_node_count = 0;

            std::string s;
            s.append("digraph G{ rankdir=LR; edge [minlen=3]; overlap=false;");

            for (const auto& package : depend_info)
            {
                if (package.dependencies.empty())
                {
                    empty_node_count++;
                    continue;
                }

                const std::string name = Strings::replace_all(std::string{package.package}, "-", "_");
                s.append(Strings::format("%s;", name));
                for (const auto& d : package.dependencies)
                {
                    const std::string dependency_name = Strings::replace_all(std::string{d}, "-", "_");
                    s.append(Strings::format("%s -> %s;", name, dependency_name));
                }
            }

            s.append(Strings::format("empty [label=\"%d singletons...\"]; }", empty_node_count));
            return s;
        }

        std::string create_dgml_as_string(const std::vector<PackageDependInfo>& depend_info)
        {
            std::string s;
            s.append("<?xml version=\"1.0\" encoding=\"utf-8\"?>");
            s.append("<DirectedGraph xmlns=\"http://schemas.microsoft.com/vs/2009/dgml\">");

            std::string nodes, links;
            for (const auto& package : depend_info)
            {
                const std::string name = package.package;
                nodes.append(Strings::format("<Node Id=\"%s\" />", name));

                // Iterate over dependencies.
                for (const auto& d : package.dependencies)
                {
                    links.append(Strings::format("<Link Source=\"%s\" Target=\"%s\" />", name, d));
                }
            }

            s.append(Strings::format("<Nodes>%s</Nodes>", nodes));

            s.append(Strings::format("<Links>%s</Links>", links));

            s.append("</DirectedGraph>");
            return s;
        }

        std::string create_graph_as_string(const std::unordered_set<std::string>& switches,
                                           const std::vector<PackageDependInfo>& depend_info)
        {
            if (Util::Sets::contains(switches, OPTION_DOT))
            {
                return create_dot_as_string(depend_info);
            }
            else if (Util::Sets::contains(switches, OPTION_DGML))
            {
                return create_dgml_as_string(depend_info);
            }
            return "";
        }

        void assign_depth_to_dependencies(const std::string& package,
                                          const int depth,
                                          const int max_depth,
                                          std::map<std::string, PackageDependInfo>& dependencies_map)
        {
            auto iter = dependencies_map.find(package);
            Checks::check_exit(
                VCPKG_LINE_INFO, iter != dependencies_map.end(), "Package not found in dependency graph");

            PackageDependInfo& info = iter->second;

            if (depth > info.depth)
            {
                info.depth = depth;
                if (depth < max_depth || max_depth == NO_RECURSE_LIMIT_VALUE)
                {
                    for (auto&& dependency : info.dependencies)
                    {
                        assign_depth_to_dependencies(dependency, depth + 1, max_depth, dependencies_map);
                    }
                }
            }
        }

        std::vector<PackageDependInfo> extract_depend_info(const std::vector<const InstallPlanAction*>& install_actions,
                                                           const int max_depth)
        {
            std::map<std::string, PackageDependInfo> package_dependencies;
            for (const InstallPlanAction* pia : install_actions)
            {
                const InstallPlanAction& install_action = *pia;

                const std::vector<std::string> dependencies = Util::fmap(
                    install_action.package_dependencies, [](const PackageSpec& spec) { return spec.name(); });

                std::unordered_set<std::string> features{install_action.feature_list.begin(),
                                                         install_action.feature_list.end()};
                features.erase("core");

                std::string port_name = install_action.spec.name();

                PackageDependInfo info{port_name, -1, features, dependencies};
                package_dependencies.emplace(port_name, std::move(info));
            }

            const InstallPlanAction& init = *install_actions.back();
            assign_depth_to_dependencies(init.spec.name(), 0, max_depth, package_dependencies);

            std::vector<PackageDependInfo> out =
                Util::fmap(package_dependencies, [](auto&& kvpair) -> PackageDependInfo { return kvpair.second; });
            Util::erase_remove_if(out, [](auto&& info) { return info.depth < 0; });
            return out;
        }
    }

    const CommandStructure COMMAND_STRUCTURE = {
        Help::create_example_string("depend-info sqlite3"),
        1,
        1,
        {DEPEND_SWITCHES, DEPEND_SETTINGS},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet)
    {
        const ParsedArguments options = args.parse_arguments(COMMAND_STRUCTURE);
        const int max_depth = get_max_depth(options);
        const SortMode sort_mode = get_sort_mode(options);
        const bool show_depth = Util::Sets::contains(options.switches, OPTION_SHOW_DEPTH);

        const std::vector<FullPackageSpec> specs = Util::fmap(args.command_arguments, [&](auto&& arg) {
            return Input::check_and_get_full_package_spec(
                std::string{arg}, default_triplet, COMMAND_STRUCTURE.example_text);
        });

        for (auto&& spec : specs)
        {
            Input::check_triplet(spec.package_spec.triplet(), paths);
        }

        PathsPortFileProvider provider(paths, args.overlay_ports.get());
        CMakeVars::TripletCMakeVarProvider var_provider(paths);

        // By passing an empty status_db, we should get a plan containing all dependencies.
        // All actions in the plan should be install actions, as there's no installed packages to remove.
        StatusParagraphs status_db;
        auto action_plan = Dependencies::create_feature_install_plan(provider, var_provider, specs, status_db);
        Checks::check_exit(
            VCPKG_LINE_INFO, action_plan.remove_actions.empty(), "Only install actions should exist in the plan");
        std::vector<const InstallPlanAction*> install_actions =
            Util::fmap(action_plan.already_installed, [&](const auto& action) { return &action; });
        for (auto&& action : action_plan.install_actions)
            install_actions.push_back(&action);

        std::vector<PackageDependInfo> depend_info = extract_depend_info(install_actions, max_depth);

        if (Util::Sets::contains(options.switches, OPTION_DOT) || Util::Sets::contains(options.switches, OPTION_DGML))
        {
            const std::vector<const SourceControlFile*> source_control_files =
                Util::fmap(install_actions, [](const InstallPlanAction* install_action) {
                    const SourceControlFileLocation& scfl =
                        install_action->source_control_file_location.value_or_exit(VCPKG_LINE_INFO);
                    return const_cast<const SourceControlFile*>(scfl.source_control_file.get());
                });

            const std::string graph_as_string = create_graph_as_string(options.switches, depend_info);
            System::print2(graph_as_string, '\n');
            Checks::exit_success(VCPKG_LINE_INFO);
        }

        // TODO: Improve this code
        auto lex = [](const PackageDependInfo& lhs, const PackageDependInfo& rhs) -> bool {
            return lhs.package < rhs.package;
        };
        auto topo = [](const PackageDependInfo& lhs, const PackageDependInfo& rhs) -> bool {
            return lhs.depth > rhs.depth;
        };
        auto reverse = [](const PackageDependInfo& lhs, const PackageDependInfo& rhs) -> bool {
            return lhs.depth < rhs.depth;
        };

        switch (sort_mode)
        {
            case SortMode::Lexicographical: std::sort(std::begin(depend_info), std::end(depend_info), lex); break;
            case SortMode::ReverseTopological:
                std::sort(std::begin(depend_info), std::end(depend_info), reverse);
                break;
            case SortMode::Topological: std::sort(std::begin(depend_info), std::end(depend_info), topo); break;
            default: Checks::unreachable(VCPKG_LINE_INFO);
        }

        for (auto&& info : depend_info)
        {
            if (info.depth >= 0)
            {
                std::string features = Strings::join(", ", info.features);
                const std::string dependencies = Strings::join(", ", info.dependencies);

                if (show_depth)
                {
                    System::print2(System::Color::error, "(", info.depth, ") ");
                }
                System::print2(System::Color::success, info.package);
                if (!features.empty())
                {
                    System::print2("[");
                    System::print2(System::Color::warning, features);
                    System::print2("]");
                }
                System::print2(": ", dependencies, "\n");
            }
        }
        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
