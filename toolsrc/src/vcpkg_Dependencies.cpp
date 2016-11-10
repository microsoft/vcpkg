#include "vcpkg_Dependencies.h"
#include <vector>
#include "vcpkg_Graphs.h"
#include "vcpkg_paths.h"
#include "package_spec.h"
#include "StatusParagraphs.h"
#include <unordered_set>
#include "vcpkg_Maps.h"
#include "vcpkg_Files.h"
#include "Paragraphs.h"

namespace vcpkg { namespace Dependencies
{
    // TODO: Refactoring between this function and install_package
    static std::vector<std::string> get_single_level_unmet_dependencies(const vcpkg_paths& paths, const package_spec& spec)
    {
        const fs::path packages_dir_control_file_path = paths.package_dir(spec) / "CONTROL";

        auto control_contents_maybe = Files::get_contents(packages_dir_control_file_path);
        if (auto control_contents = control_contents_maybe.get())
        {
            std::vector<std::unordered_map<std::string, std::string>> pghs;
            try
            {
                pghs = Paragraphs::parse_paragraphs(*control_contents);
            }
            catch (std::runtime_error)
            {
            }
            Checks::check_exit(pghs.size() == 1, "Invalid control file at %s", packages_dir_control_file_path.string());
            return BinaryParagraph(pghs[0]).depends;
        }

        return get_unmet_package_build_dependencies(paths, spec);
    }

    static Graphs::Graph<package_spec> build_dependency_graph(const vcpkg_paths& paths, const std::vector<package_spec>& specs, const StatusParagraphs& status_db)
    {
        std::vector<package_spec> examine_stack(specs);
        std::unordered_set<package_spec> was_examined; // Examine = we have checked its immediate (non-recursive) dependencies
        Graphs::Graph<package_spec> graph;
        graph.add_vertices(examine_stack);

        while (!examine_stack.empty())
        {
            const package_spec spec = examine_stack.back();
            examine_stack.pop_back();

            if (was_examined.find(spec) != was_examined.end())
            {
                continue;
            }

            std::vector<std::string> dependencies_as_string = get_single_level_unmet_dependencies(paths, spec);

            for (const std::string& dep_as_string : dependencies_as_string)
            {
                const package_spec current_dep = package_spec::from_name_and_triplet(dep_as_string, spec.target_triplet()).get_or_throw();
                auto it = status_db.find(current_dep.name(), current_dep.target_triplet());
                if (it != status_db.end() && (*it)->want == want_t::install)
                {
                    continue;
                }

                graph.add_edge(spec, current_dep);
                if (was_examined.find(current_dep) == was_examined.end())
                {
                    examine_stack.push_back(std::move(current_dep));
                }
            }

            was_examined.insert(spec);
        }

        return graph;
    }

    std::vector<package_spec> create_dependency_ordered_install_plan(const vcpkg_paths& paths, const std::vector<package_spec>& specs, const StatusParagraphs& status_db)
    {
        return build_dependency_graph(paths, specs, status_db).find_topological_sort();
    }

    std::unordered_set<package_spec> get_unmet_dependencies(const vcpkg_paths& paths, const std::vector<package_spec>& specs, const StatusParagraphs& status_db)
    {
        const Graphs::Graph<package_spec> dependency_graph = build_dependency_graph(paths, specs, status_db);
        return Maps::extract_key_set(dependency_graph.adjacency_list());
    }

    std::vector<std::string> get_unmet_package_build_dependencies(const vcpkg_paths& paths, const package_spec& spec)
    {
        const fs::path ports_dir_control_file_path = paths.port_dir(spec) / "CONTROL";
        auto control_contents_maybe = Files::get_contents(ports_dir_control_file_path);
        if (auto control_contents = control_contents_maybe.get())
        {
            std::vector<std::unordered_map<std::string, std::string>> pghs;
            try
            {
                pghs = Paragraphs::parse_paragraphs(*control_contents);
            }
            catch (std::runtime_error)
            {
            }
            Checks::check_exit(pghs.size() == 1, "Invalid control file at %s", ports_dir_control_file_path.string());
            return filter_dependencies(SourceParagraph(pghs[0]).depends, spec.target_triplet());
        }

        Checks::exit_with_message("Could not find package named %s", spec);
    }
}}
