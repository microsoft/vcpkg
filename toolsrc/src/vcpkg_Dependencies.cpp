#include "pch.h"
#include "vcpkg_Dependencies.h"
#include "vcpkg_Graphs.h"
#include "vcpkg_paths.h"
#include "package_spec.h"
#include "StatusParagraphs.h"
#include "vcpkg_Files.h"
#include "PostBuildLint_BuildInfo.h"

namespace vcpkg::Dependencies
{
    install_plan_action::install_plan_action() : plan_type(install_plan_type::UNKNOWN), binary_pgh(nullptr), source_pgh(nullptr)
    {
    }

    install_plan_action::install_plan_action(const install_plan_type& plan_type, optional<BinaryParagraph> binary_pgh, optional<SourceParagraph> source_pgh)
        : plan_type(std::move(plan_type)), binary_pgh(std::move(binary_pgh)), source_pgh(std::move(source_pgh))
    {
    }

    package_spec_with_install_plan::package_spec_with_install_plan(const package_spec& spec, install_plan_action&& plan) : spec(spec), plan(std::move(plan))
    {
    }

    remove_plan_action::remove_plan_action() : plan_type(remove_plan_type::UNKNOWN), request_type(request_type::UNKNOWN)
    {
    }

    remove_plan_action::remove_plan_action(const remove_plan_type& plan_type, const Dependencies::request_type& request_type) : plan_type(plan_type), request_type(request_type)
    {
    }

    package_spec_with_remove_plan::package_spec_with_remove_plan(const package_spec& spec, remove_plan_action&& plan)
        : spec(spec), plan(std::move(plan))
    {
    }

    std::vector<package_spec_with_install_plan> create_install_plan(const vcpkg_paths& paths, const std::vector<package_spec>& specs, const StatusParagraphs& status_db)
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
                was_examined.emplace(spec, install_plan_action{install_plan_type::ALREADY_INSTALLED, nullptr, nullptr});
                continue;
            }

            expected<BinaryParagraph> maybe_bpgh = Paragraphs::try_load_cached_package(paths, spec);
            if (BinaryParagraph* bpgh = maybe_bpgh.get())
            {
                process_dependencies(bpgh->depends);
                was_examined.emplace(spec, install_plan_action{install_plan_type::INSTALL, std::make_unique<BinaryParagraph>(std::move(*bpgh)), nullptr});
                continue;
            }

            expected<SourceParagraph> maybe_spgh = Paragraphs::try_load_port(paths.port_dir(spec));
            SourceParagraph* spgh = maybe_spgh.get();
            Checks::check_exit(spgh != nullptr, "Cannot find package %s", spec.name());
            process_dependencies(filter_dependencies(spgh->depends, spec.target_triplet()));
            was_examined.emplace(spec, install_plan_action{install_plan_type::BUILD_AND_INSTALL, nullptr, std::make_unique<SourceParagraph>(std::move(*spgh))});
        }

        std::vector<package_spec_with_install_plan> ret;

        const std::vector<package_spec> pkgs = graph.find_topological_sort();
        for (const package_spec& pkg : pkgs)
        {
            ret.push_back(package_spec_with_install_plan(pkg, std::move(was_examined[pkg])));
        }
        return ret;
    }

    std::vector<package_spec_with_remove_plan> create_remove_plan(const std::vector<package_spec>& specs, const StatusParagraphs& status_db)
    {
        std::unordered_set<package_spec> specs_as_set(specs.cbegin(), specs.cend());

        std::unordered_map<package_spec, remove_plan_action> was_examined; // Examine = we have checked its immediate (non-recursive) dependencies
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

            const StatusParagraphs::const_iterator it = status_db.find(spec);
            if (it == status_db.end() || (*it)->state == install_state_t::not_installed)
            {
                was_examined.emplace(spec, remove_plan_action(remove_plan_type::NOT_INSTALLED, request_type::USER_REQUESTED));
                continue;
            }

            for (const std::unique_ptr<StatusParagraph>& an_installed_package : status_db)
            {
                if (an_installed_package->want != want_t::install)
                    continue;
                if (an_installed_package->package.spec.target_triplet() != spec.target_triplet())
                    continue;

                const std::vector<std::string>& deps = an_installed_package->package.depends;
                if (std::find(deps.begin(), deps.end(), spec.name()) == deps.end())
                {
                    continue;
                }

                graph.add_edge(spec, an_installed_package.get()->package.spec);
                examine_stack.push_back(an_installed_package.get()->package.spec);
            }

            const request_type request_type = specs_as_set.find(spec) != specs_as_set.end() ? request_type::USER_REQUESTED : request_type::AUTO_SELECTED;
            was_examined.emplace(spec, remove_plan_action(remove_plan_type::REMOVE, request_type));
        }

        std::vector<package_spec_with_remove_plan> ret;

        const std::vector<package_spec> pkgs = graph.find_topological_sort();
        for (const package_spec& pkg : pkgs)
        {
            ret.push_back(package_spec_with_remove_plan(pkg, std::move(was_examined[pkg])));
        }
        return ret;
    }
}
