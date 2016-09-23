#include "vcpkg_Dependencies.h"
#include <vector>
#include "vcpkg_Graphs.h"
#include "vcpkg_paths.h"
#include "package_spec.h"
#include "StatusParagraphs.h"
#include <unordered_set>
#include "vcpkg.h"
#include "vcpkg_Maps.h"
#include "vcpkg_Sets.h"

namespace vcpkg { namespace Dependencies
{
    static Graphs::Graph<package_spec> build_dependency_graph(const vcpkg_paths& paths, const std::vector<package_spec>& specs, const StatusParagraphs& status_db)
    {
        std::vector<package_spec> examine_stack(specs);
        std::unordered_set<package_spec> was_examined; // Examine = we have checked its immediate (non-recursive) dependencies
        Graphs::Graph<package_spec> graph;
        graph.add_vertices(examine_stack);

        while (!examine_stack.empty())
        {
            package_spec spec = examine_stack.back();
            examine_stack.pop_back();

            if (was_examined.find(spec) != was_examined.end())
            {
                continue;
            }

            std::vector<std::string> dependencies_as_string = get_unmet_package_dependencies(paths, spec, status_db);

            for (const std::string& dep_as_string : dependencies_as_string)
            {
                package_spec current_dep = {dep_as_string, spec.target_triplet};
                auto it = status_db.find(current_dep.name, current_dep.target_triplet);
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

    std::unordered_set<package_spec> find_unmet_dependencies(const vcpkg_paths& paths, const package_spec& spec, const StatusParagraphs& status_db)
    {
        const Graphs::Graph<package_spec> dependency_graph = build_dependency_graph(paths, {spec}, status_db);
        std::unordered_set<package_spec> key_set = Maps::extract_key_set(dependency_graph.adjacency_list());
        key_set.erase(spec);
        return key_set;
    }
}}
