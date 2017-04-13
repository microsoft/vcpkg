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
    std::vector<PackageSpec> AnyParagraph::dependencies(const Triplet& triplet) const
    {
        auto to_package_specs = [&](const std::vector<std::string>& dependencies_as_string)
            {
                return Util::fmap(dependencies_as_string, [&](const std::string s)
                                  {
                                      return PackageSpec::from_name_and_triplet(s, triplet).value_or_exit(VCPKG_LINE_INFO);
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
            return to_package_specs(filter_dependencies(p->depends, triplet));
        }

        Checks::exit_with_message(VCPKG_LINE_INFO, "Cannot get dependencies because there was none of: source/binary/status paragraphs");
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

    InstallPlanAction::InstallPlanAction() : spec()
                                           , any_paragraph()
                                           , plan_type(InstallPlanType::UNKNOWN)
                                           , request_type(RequestType::UNKNOWN) { }

    InstallPlanAction::InstallPlanAction(const PackageSpec& spec, const AnyParagraph& any_paragraph, const RequestType& request_type) : InstallPlanAction()
    {
        this->spec = spec;
        this->request_type = request_type;
        if (auto p = any_paragraph.status_paragraph.get())
        {
            this->plan_type = InstallPlanType::ALREADY_INSTALLED;
            this->any_paragraph.status_paragraph = *p;
            return;
        }

        if (auto p = any_paragraph.binary_paragraph.get())
        {
            this->plan_type = InstallPlanType::INSTALL;
            this->any_paragraph.binary_paragraph = *p;
            return;
        }

        if (auto p = any_paragraph.source_paragraph.get())
        {
            this->plan_type = InstallPlanType::BUILD_AND_INSTALL;
            this->any_paragraph.source_paragraph = *p;
            return;
        }

        this->plan_type = InstallPlanType::UNKNOWN;
    }

    bool InstallPlanAction::compare_by_name(const InstallPlanAction* left, const InstallPlanAction* right)
    {
        return left->spec.name() < right->spec.name();
    }

    RemovePlanAction::RemovePlanAction() : plan_type(RemovePlanType::UNKNOWN)
                                         , request_type(RequestType::UNKNOWN) { }

    RemovePlanAction::RemovePlanAction(const PackageSpec& spec, const RemovePlanType& plan_type, const RequestType& request_type)
        : spec(spec)
        , plan_type(plan_type)
        , request_type(request_type) { }

    bool RemovePlanAction::compare_by_name(const RemovePlanAction* left, const RemovePlanAction* right)
    {
        return left->spec.name() < right->spec.name();
    }

    std::vector<InstallPlanAction> create_install_plan(const VcpkgPaths& paths, const std::vector<PackageSpec>& specs, const StatusParagraphs& status_db)
    {
        struct InstallAdjacencyProvider final : Graphs::AdjacencyProvider<PackageSpec, InstallPlanAction>
        {
            const VcpkgPaths& paths;
            const StatusParagraphs& status_db;
            const std::unordered_set<PackageSpec>& specs_as_set;

            InstallAdjacencyProvider(const VcpkgPaths& p, const StatusParagraphs& s, const std::unordered_set<PackageSpec>& specs_as_set) : paths(p)
                                                                                                                                          , status_db(s)
                                                                                                                                          , specs_as_set(specs_as_set) {}

            std::vector<PackageSpec> adjacency_list(const InstallPlanAction& p) const override
            {
                if (p.any_paragraph.status_paragraph.get())
                    return std::vector<PackageSpec>{};
                return p.any_paragraph.dependencies(p.spec.triplet());
            }

            InstallPlanAction load_vertex_data(const PackageSpec& spec) const override
            {
                const RequestType request_type = specs_as_set.find(spec) != specs_as_set.end() ? RequestType::USER_REQUESTED : RequestType::AUTO_SELECTED;
                auto it = status_db.find_installed(spec);
                if (it != status_db.end())
                    return InstallPlanAction{ spec, { *it->get(), nullopt, nullopt }, request_type };

                Expected<BinaryParagraph> maybe_bpgh = Paragraphs::try_load_cached_package(paths, spec);
                if (auto bpgh = maybe_bpgh.get())
                    return InstallPlanAction{ spec, { nullopt, *bpgh, nullopt }, request_type };

                Expected<SourceParagraph> maybe_spgh = Paragraphs::try_load_port(paths.port_dir(spec));
                if (auto spgh = maybe_spgh.get())
                    return InstallPlanAction{ spec, { nullopt, nullopt, *spgh }, request_type };

                return InstallPlanAction{ spec , { nullopt, nullopt, nullopt }, request_type };
            }
        };

        const std::unordered_set<PackageSpec> specs_as_set(specs.cbegin(), specs.cend());
        return Graphs::topological_sort(specs, InstallAdjacencyProvider{ paths, status_db, specs_as_set });
    }

    std::vector<RemovePlanAction> create_remove_plan(const std::vector<PackageSpec>& specs, const StatusParagraphs& status_db)
    {
        struct RemoveAdjacencyProvider final : Graphs::AdjacencyProvider<PackageSpec, RemovePlanAction>
        {
            const StatusParagraphs& status_db;
            const std::vector<StatusParagraph*>& installed_ports;
            const std::unordered_set<PackageSpec>& specs_as_set;

            RemoveAdjacencyProvider(const StatusParagraphs& status_db, const std::vector<StatusParagraph*>& installed_ports, const std::unordered_set<PackageSpec>& specs_as_set)
                : status_db(status_db)
                , installed_ports(installed_ports)
                , specs_as_set(specs_as_set) { }

            std::vector<PackageSpec> adjacency_list(const RemovePlanAction& p) const override
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

            RemovePlanAction load_vertex_data(const PackageSpec& spec) const override
            {
                const RequestType request_type = specs_as_set.find(spec) != specs_as_set.end() ? RequestType::USER_REQUESTED : RequestType::AUTO_SELECTED;
                const StatusParagraphs::const_iterator it = status_db.find_installed(spec);
                if (it == status_db.end())
                {
                    return RemovePlanAction{ spec, RemovePlanType::NOT_INSTALLED, request_type };
                }
                return RemovePlanAction{ spec, RemovePlanType::REMOVE, request_type };
            }
        };

        const std::vector<StatusParagraph*>& installed_ports = get_installed_ports(status_db);
        const std::unordered_set<PackageSpec> specs_as_set(specs.cbegin(), specs.cend());
        return Graphs::topological_sort(specs, RemoveAdjacencyProvider{ status_db, installed_ports, specs_as_set });
    }
}
