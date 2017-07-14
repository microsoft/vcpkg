#include "pch.h"

#include "PackageSpec.h"
#include "Paragraphs.h"
#include "StatusParagraphs.h"
#include "VcpkgPaths.h"
#include "vcpkg_Dependencies.h"
#include "vcpkg_Files.h"
#include "vcpkg_Graphs.h"
#include "vcpkg_Util.h"
#include "vcpkglib.h"

namespace vcpkg::Dependencies
{
    std::vector<PackageSpec> AnyParagraph::dependencies(const Triplet& triplet) const
    {
        auto to_package_specs = [&](const std::vector<std::string>& dependencies_as_string) {
            return Util::fmap(dependencies_as_string, [&](const std::string s) {
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

        Checks::exit_with_message(VCPKG_LINE_INFO,
                                  "Cannot get dependencies because there was none of: source/binary/status paragraphs");
    }

    std::string to_output_string(RequestType request_type, const CStringView s)
    {
        switch (request_type)
        {
            case RequestType::AUTO_SELECTED: return Strings::format("  * %s", s);
            case RequestType::USER_REQUESTED: return Strings::format("    %s", s);
            default: Checks::unreachable(VCPKG_LINE_INFO);
        }
    }

    InstallPlanAction::InstallPlanAction()
        : spec(), any_paragraph(), plan_type(InstallPlanType::UNKNOWN), request_type(RequestType::UNKNOWN)
    {
    }

    InstallPlanAction::InstallPlanAction(const PackageSpec& spec,
                                         const AnyParagraph& any_paragraph,
                                         const RequestType& request_type)
        : InstallPlanAction()
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

    RemovePlanAction::RemovePlanAction() : plan_type(RemovePlanType::UNKNOWN), request_type(RequestType::UNKNOWN) {}

    RemovePlanAction::RemovePlanAction(const PackageSpec& spec,
                                       const RemovePlanType& plan_type,
                                       const RequestType& request_type)
        : spec(spec), plan_type(plan_type), request_type(request_type)
    {
    }

    bool ExportPlanAction::compare_by_name(const ExportPlanAction* left, const ExportPlanAction* right)
    {
        return left->spec.name() < right->spec.name();
    }

    ExportPlanAction::ExportPlanAction()
        : spec(), any_paragraph(), plan_type(ExportPlanType::UNKNOWN), request_type(RequestType::UNKNOWN)
    {
    }

    ExportPlanAction::ExportPlanAction(const PackageSpec& spec,
                                       const AnyParagraph& any_paragraph,
                                       const RequestType& request_type)
        : ExportPlanAction()
    {
        this->spec = spec;
        this->request_type = request_type;

        if (auto p = any_paragraph.binary_paragraph.get())
        {
            this->plan_type = ExportPlanType::ALREADY_BUILT;
            this->any_paragraph.binary_paragraph = *p;
            return;
        }

        if (auto p = any_paragraph.source_paragraph.get())
        {
            this->plan_type = ExportPlanType::PORT_AVAILABLE_BUT_NOT_BUILT;
            this->any_paragraph.source_paragraph = *p;
            return;
        }

        this->plan_type = ExportPlanType::UNKNOWN;
    }

    bool RemovePlanAction::compare_by_name(const RemovePlanAction* left, const RemovePlanAction* right)
    {
        return left->spec.name() < right->spec.name();
    }

    MapPortFile::MapPortFile(const std::unordered_map<PackageSpec, SourceControlFile>& map) : ports(map){};
    const SourceControlFile& MapPortFile::get_control_file(const PackageSpec& spec) const
    {
        auto scf = ports.find(spec);
        if (scf == ports.end())
        {
            Checks::exit_fail(VCPKG_LINE_INFO);
        }
        return scf->second;
    }

    PathsPortFile::PathsPortFile(const VcpkgPaths& paths) : ports(paths){};
    const SourceControlFile& PathsPortFile::get_control_file(const PackageSpec& spec) const
    {
        std::unordered_map<PackageSpec, SourceControlFile>::iterator cache_it = cache.find(spec);
        if (cache_it != cache.end())
        {
            return cache_it->second;
        }
        Parse::ParseExpected<SourceControlFile> source_control_file =
            Paragraphs::try_load_port(ports.get_filesystem(), ports.port_dir(spec));

        if (auto scf = source_control_file.get())
        {
            auto it = cache.emplace(spec, std::move(*scf->get()));
            return it.first->second;
        }
        print_error_message(source_control_file.error());
        Checks::exit_fail(VCPKG_LINE_INFO);
    }

    std::vector<InstallPlanAction> create_install_plan(const PortFileProvider& port_file_provider,
                                                       const std::vector<PackageSpec>& specs,
                                                       const StatusParagraphs& status_db)
    {
        struct InstallAdjacencyProvider final : Graphs::AdjacencyProvider<PackageSpec, InstallPlanAction>
        {
            const PortFileProvider& port_file_provider;
            const StatusParagraphs& status_db;
            const std::unordered_set<PackageSpec>& specs_as_set;

            InstallAdjacencyProvider(const PortFileProvider& port_file_provider,
                                     const StatusParagraphs& s,
                                     const std::unordered_set<PackageSpec>& specs_as_set)
                : port_file_provider(port_file_provider), status_db(s), specs_as_set(specs_as_set)
            {
            }

            std::vector<PackageSpec> adjacency_list(const InstallPlanAction& plan) const override
            {
                if (plan.any_paragraph.status_paragraph.get()) return std::vector<PackageSpec>{};
                return plan.any_paragraph.dependencies(plan.spec.triplet());
            }

            InstallPlanAction load_vertex_data(const PackageSpec& spec) const override
            {
                const RequestType request_type = specs_as_set.find(spec) != specs_as_set.end()
                                                     ? RequestType::USER_REQUESTED
                                                     : RequestType::AUTO_SELECTED;
                auto it = status_db.find_installed(spec);
                if (it != status_db.end()) return InstallPlanAction{spec, {*it->get(), nullopt, nullopt}, request_type};
                return InstallPlanAction{
                    spec, {nullopt, nullopt, *port_file_provider.get_control_file(spec).core_paragraph}, request_type};
            }
        };

        const std::unordered_set<PackageSpec> specs_as_set(specs.cbegin(), specs.cend());
        std::vector<InstallPlanAction> toposort =
            Graphs::topological_sort(specs, InstallAdjacencyProvider{port_file_provider, status_db, specs_as_set});
        Util::erase_remove_if(toposort, [](const InstallPlanAction& plan) {
            return plan.request_type == RequestType::AUTO_SELECTED &&
                   plan.plan_type == InstallPlanType::ALREADY_INSTALLED;
        });

        return toposort;
    }

    std::vector<RemovePlanAction> create_remove_plan(const std::vector<PackageSpec>& specs,
                                                     const StatusParagraphs& status_db)
    {
        struct RemoveAdjacencyProvider final : Graphs::AdjacencyProvider<PackageSpec, RemovePlanAction>
        {
            const StatusParagraphs& status_db;
            const std::vector<StatusParagraph*>& installed_ports;
            const std::unordered_set<PackageSpec>& specs_as_set;

            RemoveAdjacencyProvider(const StatusParagraphs& status_db,
                                    const std::vector<StatusParagraph*>& installed_ports,
                                    const std::unordered_set<PackageSpec>& specs_as_set)
                : status_db(status_db), installed_ports(installed_ports), specs_as_set(specs_as_set)
            {
            }

            std::vector<PackageSpec> adjacency_list(const RemovePlanAction& plan) const override
            {
                if (plan.plan_type == RemovePlanType::NOT_INSTALLED)
                {
                    return {};
                }

                const PackageSpec& spec = plan.spec;
                std::vector<PackageSpec> dependents;
                for (const StatusParagraph* an_installed_package : installed_ports)
                {
                    if (an_installed_package->package.spec.triplet() != spec.triplet()) continue;

                    const std::vector<std::string>& deps = an_installed_package->package.depends;
                    if (std::find(deps.begin(), deps.end(), spec.name()) == deps.end()) continue;

                    dependents.push_back(an_installed_package->package.spec);
                }

                return dependents;
            }

            RemovePlanAction load_vertex_data(const PackageSpec& spec) const override
            {
                const RequestType request_type = specs_as_set.find(spec) != specs_as_set.end()
                                                     ? RequestType::USER_REQUESTED
                                                     : RequestType::AUTO_SELECTED;
                const StatusParagraphs::const_iterator it = status_db.find_installed(spec);
                if (it == status_db.end())
                {
                    return RemovePlanAction{spec, RemovePlanType::NOT_INSTALLED, request_type};
                }
                return RemovePlanAction{spec, RemovePlanType::REMOVE, request_type};
            }
        };

        const std::vector<StatusParagraph*>& installed_ports = get_installed_ports(status_db);
        const std::unordered_set<PackageSpec> specs_as_set(specs.cbegin(), specs.cend());
        return Graphs::topological_sort(specs, RemoveAdjacencyProvider{status_db, installed_ports, specs_as_set});
    }

    std::vector<ExportPlanAction> create_export_plan(const VcpkgPaths& paths,
                                                     const std::vector<PackageSpec>& specs,
                                                     const StatusParagraphs& status_db)
    {
        struct ExportAdjacencyProvider final : Graphs::AdjacencyProvider<PackageSpec, ExportPlanAction>
        {
            const VcpkgPaths& paths;
            const StatusParagraphs& status_db;
            const std::unordered_set<PackageSpec>& specs_as_set;

            ExportAdjacencyProvider(const VcpkgPaths& p,
                                    const StatusParagraphs& s,
                                    const std::unordered_set<PackageSpec>& specs_as_set)
                : paths(p), status_db(s), specs_as_set(specs_as_set)
            {
            }

            std::vector<PackageSpec> adjacency_list(const ExportPlanAction& plan) const override
            {
                return plan.any_paragraph.dependencies(plan.spec.triplet());
            }

            ExportPlanAction load_vertex_data(const PackageSpec& spec) const override
            {
                const RequestType request_type = specs_as_set.find(spec) != specs_as_set.end()
                                                     ? RequestType::USER_REQUESTED
                                                     : RequestType::AUTO_SELECTED;

                Expected<BinaryParagraph> maybe_bpgh = Paragraphs::try_load_cached_package(paths, spec);
                if (auto bpgh = maybe_bpgh.get())
                    return ExportPlanAction{spec, {nullopt, *bpgh, nullopt}, request_type};

                auto maybe_scf = Paragraphs::try_load_port(paths.get_filesystem(), paths.port_dir(spec));
                if (auto scf = maybe_scf.get())
                    return ExportPlanAction{spec, {nullopt, nullopt, *scf->get()->core_paragraph}, request_type};
                else
                    print_error_message(maybe_scf.error());

                Checks::exit_with_message(VCPKG_LINE_INFO, "Could not find package %s", spec);
            }
        };

        const std::unordered_set<PackageSpec> specs_as_set(specs.cbegin(), specs.cend());
        std::vector<ExportPlanAction> toposort =
            Graphs::topological_sort(specs, ExportAdjacencyProvider{paths, status_db, specs_as_set});
        return toposort;
    }
}
