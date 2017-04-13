#include "pch.h"
#include "vcpkg_Dependencies.h"
#include "vcpkg_Graphs.h"
#include "VcpkgPaths.h"
#include "PackageSpec.h"
#include "StatusParagraphs.h"
#include "vcpkg_Files.h"
#include "vcpkg_Util.h"
#include "vcpkglib.h"
#include "Paragraphs.h"

namespace vcpkg::Dependencies
{
    std::vector<PackageSpec> AnyParagraph::dependencies() const
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
        struct InstallAdjacencyProvider final : Graphs::AdjacencyProvider<PackageSpec, AnyParagraph>
        {
            const VcpkgPaths& paths;
            const StatusParagraphs& status_db;

            InstallAdjacencyProvider(const VcpkgPaths& p, const StatusParagraphs& s) : paths(p)
                                                                                     , status_db(s) {}

            std::vector<PackageSpec> adjacency_list(const AnyParagraph& p) const override
            {
                if (p.status_paragraph.get())
                    return std::vector<PackageSpec>{};
                return p.dependencies();
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

        const std::vector<AnyParagraph> toposort = Graphs::topological_sort(specs, InstallAdjacencyProvider{ paths, status_db });

        const std::unordered_set<PackageSpec> specs_as_set(specs.cbegin(), specs.cend());
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

    struct SpecAndRemovePlanType
    {
        PackageSpec spec;
        RemovePlanType plan_type;
    };

    std::vector<PackageSpecWithRemovePlan> create_remove_plan(const std::vector<PackageSpec>& specs, const StatusParagraphs& status_db)
    {
        struct RemoveAdjacencyProvider final : Graphs::AdjacencyProvider<PackageSpec, SpecAndRemovePlanType>
        {
            const StatusParagraphs& status_db;
            const std::vector<StatusParagraph*>& installed_ports;

            RemoveAdjacencyProvider(const StatusParagraphs& status_db, const std::vector<StatusParagraph*>& installed_ports)
                : status_db(status_db)
                , installed_ports(installed_ports) { }

            std::vector<PackageSpec> adjacency_list(const SpecAndRemovePlanType& p) const override
            {
                if (p.plan_type == RemovePlanType::NOT_INSTALLED)
                {
                    return {};
                }

                const PackageSpec& spec = p.spec;
                std::vector<PackageSpec> dependents;
                for (const StatusParagraph* an_installed_package : installed_ports)
                {
                    if (an_installed_package->package.spec.triplet() != spec.triplet())
                        continue;

                    const std::vector<std::string>& deps = an_installed_package->package.depends;
                    if (std::find(deps.begin(), deps.end(), spec.name()) == deps.end())
                        continue;

                    dependents.push_back(an_installed_package->package.spec);
                }

                return dependents;
            }

            SpecAndRemovePlanType load_vertex_data(const PackageSpec& spec) const override
            {
                const StatusParagraphs::const_iterator it = status_db.find_installed(spec);
                if (it == status_db.end())
                {
                    return {spec, RemovePlanType::NOT_INSTALLED};
                }
                return { spec, RemovePlanType::REMOVE };
            }
        };

        const std::vector<StatusParagraph*>& installed_ports = get_installed_ports(status_db);
        const std::vector<SpecAndRemovePlanType> toposort = Graphs::topological_sort(specs, RemoveAdjacencyProvider{ status_db, installed_ports });

        const std::unordered_set<PackageSpec> specs_as_set(specs.cbegin(), specs.cend());
        std::vector<PackageSpecWithRemovePlan> ret;
        for (const SpecAndRemovePlanType& pkg : toposort)
        {
            auto spec = pkg.spec;
            const RequestType request_type = specs_as_set.find(spec) != specs_as_set.end() ? RequestType::USER_REQUESTED : RequestType::AUTO_SELECTED;
            RemovePlanAction r(pkg.plan_type, request_type);
            ret.push_back(PackageSpecWithRemovePlan(spec, std::move(r)));
        }
        return ret;
    }
}
