#include "pch.h"
#include "vcpkg_Dependencies.h"
#include "vcpkg_Graphs.h"
#include "vcpkg_paths.h"
#include "PackageSpec.h"
#include "StatusParagraphs.h"
#include "vcpkg_Files.h"
#include "Paragraphs.h"

namespace vcpkg::Dependencies
{
    InstallPlanAction::InstallPlanAction() : plan_type(InstallPlanType::UNKNOWN), binary_pgh(nullopt), source_pgh(nullopt)
    {
    }

    InstallPlanAction::InstallPlanAction(const InstallPlanType& plan_type, optional<BinaryParagraph> binary_pgh, optional<SourceParagraph> source_pgh)
        : plan_type(std::move(plan_type)), binary_pgh(std::move(binary_pgh)), source_pgh(std::move(source_pgh))
    {
    }

    PackageSpecWithInstallPlan::PackageSpecWithInstallPlan(const PackageSpec& spec, InstallPlanAction&& plan) : spec(spec), plan(std::move(plan))
    {
    }

    RemovePlanAction::RemovePlanAction() : plan_type(RemovePlanType::UNKNOWN), request_type(RequestType::UNKNOWN)
    {
    }

    RemovePlanAction::RemovePlanAction(const RemovePlanType& plan_type, const Dependencies::RequestType& request_type) : plan_type(plan_type), request_type(request_type)
    {
    }

    PackageSpecWithRemovePlan::PackageSpecWithRemovePlan(const PackageSpec& spec, RemovePlanAction&& plan)
        : spec(spec), plan(std::move(plan))
    {
    }

    std::vector<PackageSpecWithInstallPlan> create_install_plan(const vcpkg_paths& paths, const std::vector<PackageSpec>& specs, const StatusParagraphs& status_db)
    {
        std::unordered_map<PackageSpec, InstallPlanAction> was_examined; // Examine = we have checked its immediate (non-recursive) dependencies
        Graphs::Graph<PackageSpec> graph;
        graph.add_vertices(specs);

        std::vector<PackageSpec> examine_stack(specs);
        while (!examine_stack.empty())
        {
            const PackageSpec spec = examine_stack.back();
            examine_stack.pop_back();

            if (was_examined.find(spec) != was_examined.end())
            {
                continue;
            }

            auto process_dependencies = [&](const std::vector<std::string>& dependencies_as_string)
                {
                    for (const std::string& dep_as_string : dependencies_as_string)
                    {
                        const PackageSpec current_dep = PackageSpec::from_name_and_triplet(dep_as_string, spec.target_triplet()).value_or_exit(VCPKG_LINE_INFO);
                        graph.add_edge(spec, current_dep);
                        if (was_examined.find(current_dep) == was_examined.end())
                        {
                            examine_stack.push_back(std::move(current_dep));
                        }
                    }
                };

            auto it = status_db.find(spec);
            if (it != status_db.end() && (*it)->want == Want::INSTALL)
            {
                was_examined.emplace(spec, InstallPlanAction{InstallPlanType::ALREADY_INSTALLED, nullopt, nullopt });
                continue;
            }

            expected<BinaryParagraph> maybe_bpgh = Paragraphs::try_load_cached_package(paths, spec);
            if (BinaryParagraph* bpgh = maybe_bpgh.get())
            {
                process_dependencies(bpgh->depends);
                was_examined.emplace(spec, InstallPlanAction{InstallPlanType::INSTALL, std::move(*bpgh), nullopt });
                continue;
            }

            expected<SourceParagraph> maybe_spgh = Paragraphs::try_load_port(paths.port_dir(spec));
            if (auto spgh = maybe_spgh.get())
            {
                process_dependencies(filter_dependencies(spgh->depends, spec.target_triplet()));
                was_examined.emplace(spec, InstallPlanAction{ InstallPlanType::BUILD_AND_INSTALL, nullopt, std::move(*spgh) });
            }
            else
            {
                Checks::exit_with_message(VCPKG_LINE_INFO, "Cannot find package %s", spec.name());
            }
        }

        std::vector<PackageSpecWithInstallPlan> ret;

        const std::vector<PackageSpec> pkgs = graph.find_topological_sort();
        for (const PackageSpec& pkg : pkgs)
        {
            ret.push_back(PackageSpecWithInstallPlan(pkg, std::move(was_examined[pkg])));
        }
        return ret;
    }

    std::vector<PackageSpecWithRemovePlan> create_remove_plan(const std::vector<PackageSpec>& specs, const StatusParagraphs& status_db)
    {
        std::unordered_set<PackageSpec> specs_as_set(specs.cbegin(), specs.cend());

        std::unordered_map<PackageSpec, RemovePlanAction> was_examined; // Examine = we have checked its immediate (non-recursive) dependencies
        Graphs::Graph<PackageSpec> graph;
        graph.add_vertices(specs);

        std::vector<PackageSpec> examine_stack(specs);
        while (!examine_stack.empty())
        {
            const PackageSpec spec = examine_stack.back();
            examine_stack.pop_back();

            if (was_examined.find(spec) != was_examined.end())
            {
                continue;
            }

            const StatusParagraphs::const_iterator it = status_db.find(spec);
            if (it == status_db.end() || (*it)->state == InstallState::NOT_INSTALLED)
            {
                was_examined.emplace(spec, RemovePlanAction(RemovePlanType::NOT_INSTALLED, RequestType::USER_REQUESTED));
                continue;
            }

            for (const std::unique_ptr<StatusParagraph>& an_installed_package : status_db)
            {
                if (an_installed_package->want != Want::INSTALL)
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

            const RequestType request_type = specs_as_set.find(spec) != specs_as_set.end() ? RequestType::USER_REQUESTED : RequestType::AUTO_SELECTED;
            was_examined.emplace(spec, RemovePlanAction(RemovePlanType::REMOVE, request_type));
        }

        std::vector<PackageSpecWithRemovePlan> ret;

        const std::vector<PackageSpec> pkgs = graph.find_topological_sort();
        for (const PackageSpec& pkg : pkgs)
        {
            ret.push_back(PackageSpecWithRemovePlan(pkg, std::move(was_examined[pkg])));
        }
        return ret;
    }
}
