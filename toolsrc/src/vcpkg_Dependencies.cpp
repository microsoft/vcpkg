#include "vcpkg_Dependencies.h"
#include <vector>
#include "vcpkg_Graphs.h"
#include "vcpkg_paths.h"
#include "package_spec.h"
#include "StatusParagraphs.h"
#include <unordered_set>
#include "vcpkg_Maps.h"
#include "vcpkg_Files.h"
#include "vcpkg.h"

namespace vcpkg { namespace Dependencies
{
    std::vector<std::pair<package_spec, install_plan_action>> create_install_plan(const vcpkg_paths& paths, const std::vector<package_spec>& specs, const StatusParagraphs& status_db)
    {
        std::unordered_map<package_spec, install_plan_action> was_examined; // Examine = we have checked its immediate (non-recursive) dependencies
        Graphs::Graph<package_spec> graph;
        graph.add_vertices(specs);

        std::vector<package_spec> examine_stack(specs);
        while (!examine_stack.empty())
        {
            const package_spec spec = examine_stack.back();
            examine_stack.pop_back();

            if (was_examined.find(spec) != was_examined.end())
            {
                continue;
            }

            auto process_dependencies = [&](const std::vector<std::string>& dependencies_as_string)
                {
                    for (const std::string& dep_as_string : dependencies_as_string)
                    {
                        const package_spec current_dep = package_spec::from_name_and_triplet(dep_as_string, spec.target_triplet()).get_or_throw();
                        graph.add_edge(spec, current_dep);
                        if (was_examined.find(current_dep) == was_examined.end())
                        {
                            examine_stack.push_back(std::move(current_dep));
                        }
                    }
                };

            auto it = status_db.find(spec);
            if (it != status_db.end() && (*it)->want == want_t::install)
            {
                was_examined.emplace(spec, install_plan_action{install_plan_kind::ALREADY_INSTALLED, nullptr, nullptr});
                continue;
            }

            expected<BinaryParagraph> maybe_bpgh = try_load_cached_package(paths, spec);
            if (BinaryParagraph* bpgh = maybe_bpgh.get())
            {
                process_dependencies(bpgh->depends);
                was_examined.emplace(spec, install_plan_action{install_plan_kind::INSTALL, std::make_unique<BinaryParagraph>(std::move(*bpgh)), nullptr});
                continue;
            }

            expected<SourceParagraph> maybe_spgh = try_load_port(paths, spec.name());
            SourceParagraph* spgh = maybe_spgh.get();
            Checks::check_exit(spgh != nullptr, "Cannot find package");
            process_dependencies(filter_dependencies(spgh->depends, spec.target_triplet()));
            was_examined.emplace(spec, install_plan_action{install_plan_kind::BUILD_AND_INSTALL, nullptr, std::make_unique<SourceParagraph>(std::move(*spgh))});
        }

        std::vector<std::pair<package_spec, install_plan_action>> ret;

        std::vector<package_spec> pkgs = graph.find_topological_sort();
        for (package_spec& pkg : pkgs)
        {
            ret.emplace_back(pkg, std::move(was_examined[pkg]));
        }
        return ret;
    }
}}
