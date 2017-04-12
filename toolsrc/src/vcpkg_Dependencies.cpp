#include "pch.h"
#include "vcpkg_Dependencies.h"
#include "vcpkg_Graphs.h"
#include "VcpkgPaths.h"
#include "PackageSpec.h"
#include "StatusParagraphs.h"
#include "vcpkg_Files.h"
#include "vcpkg_Util.h"

namespace vcpkg::Dependencies
{
    std::vector<PackageSpec> AnyParagraph::edges() const
    {
        auto to_package_specs = [&](const std::vector<std::string>& dependencies_as_string)
            {
                return Util::fmap(dependencies_as_string, [&](const std::string s)
                                  {
                                      return PackageSpec::from_name_and_triplet(s, this->spec.triplet()).value_or_exit(VCPKG_LINE_INFO);
                                  });
            };

        if (auto p = this->status_paragraph.get())
        {
            return to_package_specs(p->package.depends);
        }

        if (auto p = this->binary_paragraph.get())
        {
            return to_package_specs(p->depends);
        }

        if (auto p = this->source_paragraph.get())
        {
            return to_package_specs(filter_dependencies(p->depends, this->spec.triplet()));
        }

        Checks::exit_with_message(VCPKG_LINE_INFO, "Cannot get dependencies for package %s because there was none of: source/binary/status paragraphs", spec.to_string());
    }

    std::string to_output_string(RequestType request_type, const CStringView s)
    {
        switch (request_type)
        {
            case RequestType::AUTO_SELECTED:
                return Strings::format("  * %s", s);
            case RequestType::USER_REQUESTED:
                return Strings::format("    %s", s);
            default:
                Checks::unreachable(VCPKG_LINE_INFO);
        }
    }

    InstallPlanAction::InstallPlanAction() : plan_type(InstallPlanType::UNKNOWN)
                                           , request_type(RequestType::UNKNOWN)
                                           , binary_pgh(nullopt)
                                           , source_pgh(nullopt) { }

    InstallPlanAction::InstallPlanAction(const AnyParagraph& any_paragraph, const RequestType& request_type) : InstallPlanAction()
    {
        this->request_type = request_type;
        if (any_paragraph.status_paragraph.get())
        {
            this->plan_type = InstallPlanType::ALREADY_INSTALLED;
            return;
        }

        if (auto p = any_paragraph.binary_paragraph.get())
        {
            this->plan_type = InstallPlanType::INSTALL;
            this->binary_pgh = *p;
            return;
        }

        if (auto p = any_paragraph.source_paragraph.get())
        {
            this->plan_type = InstallPlanType::BUILD_AND_INSTALL;
            this->source_pgh = *p;
            return;
        }

        this->plan_type = InstallPlanType::UNKNOWN;
    }

    InstallPlanAction::InstallPlanAction(const InstallPlanType& plan_type, const RequestType& request_type, Optional<BinaryParagraph> binary_pgh, Optional<SourceParagraph> source_pgh)
        : plan_type(std::move(plan_type))
        , request_type(request_type)
        , binary_pgh(std::move(binary_pgh))
        , source_pgh(std::move(source_pgh)) { }

    bool PackageSpecWithInstallPlan::compare_by_name(const PackageSpecWithInstallPlan* left, const PackageSpecWithInstallPlan* right)
    {
        return left->spec.name() < right->spec.name();
    }

    PackageSpecWithInstallPlan::PackageSpecWithInstallPlan(const PackageSpec& spec, InstallPlanAction&& plan)
        : spec(spec)
        , plan(std::move(plan)) { }

    RemovePlanAction::RemovePlanAction() : plan_type(RemovePlanType::UNKNOWN)
                                         , request_type(RequestType::UNKNOWN) { }

    RemovePlanAction::RemovePlanAction(const RemovePlanType& plan_type, const RequestType& request_type)
        : plan_type(plan_type)
        , request_type(request_type) { }

    bool PackageSpecWithRemovePlan::compare_by_name(const PackageSpecWithRemovePlan* left, const PackageSpecWithRemovePlan* right)
    {
        return left->spec.name() < right->spec.name();
    }

    PackageSpecWithRemovePlan::PackageSpecWithRemovePlan(const PackageSpec& spec, RemovePlanAction&& plan)
        : spec(spec)
        , plan(std::move(plan)) { }

    std::vector<PackageSpecWithInstallPlan> create_install_plan(const VcpkgPaths& paths, const std::vector<PackageSpec>& specs, const StatusParagraphs& status_db)
    {
        std::unordered_set<PackageSpec> specs_as_set(specs.cbegin(), specs.cend());

        struct InstallAdjacencyProvider final : Graphs::AdjacencyProvider<PackageSpec, AnyParagraph>
        {
            const VcpkgPaths& paths;
            const StatusParagraphs& status_db;

            InstallAdjacencyProvider(const VcpkgPaths& p, const StatusParagraphs & s) : paths(p)
                                                                                     , status_db(s) {}

            std::vector<PackageSpec> adjacency_list(const AnyParagraph& p) const override
            {
                if (p.status_paragraph.get())
                    return std::vector<PackageSpec>{};
                return p.edges();
            }

            AnyParagraph load_vertex_data(const PackageSpec& spec) const override
            {
                auto it = status_db.find_installed(spec);
                if (it != status_db.end())
                    return { spec, *it->get(), nullopt, nullopt };

                Expected<BinaryParagraph> maybe_bpgh = Paragraphs::try_load_cached_package(paths, spec);
                if (auto bpgh = maybe_bpgh.get())
                    return { spec, nullopt, *bpgh, nullopt };

                Expected<SourceParagraph> maybe_spgh = Paragraphs::try_load_port(paths.port_dir(spec));
                if (auto spgh = maybe_spgh.get())
                    return { spec, nullopt, nullopt, *spgh };

                return { spec , nullopt, nullopt, nullopt };
            }
        };

        auto toposort = Graphs::topological_sort(specs, InstallAdjacencyProvider{ paths, status_db });

        std::vector<PackageSpecWithInstallPlan> ret;
        for (const AnyParagraph& pkg : toposort)
        {
            auto spec = pkg.spec;
            const RequestType request_type = specs_as_set.find(spec) != specs_as_set.end() ? RequestType::USER_REQUESTED : RequestType::AUTO_SELECTED;
            if (pkg.status_paragraph && request_type != RequestType::USER_REQUESTED)
                continue;
            InstallPlanAction a(pkg, request_type);
            ret.push_back(PackageSpecWithInstallPlan(spec, std::move(a)));
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
                if (an_installed_package->package.spec.triplet() != spec.triplet())
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

        const std::vector<PackageSpec> pkgs = graph.topological_sort();
        for (const PackageSpec& pkg : pkgs)
        {
            ret.push_back(PackageSpecWithRemovePlan(pkg, std::move(was_examined[pkg])));
        }
        return ret;
    }
}
