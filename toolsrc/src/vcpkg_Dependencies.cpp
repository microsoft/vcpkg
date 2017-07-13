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
                                         const SourceControlFile& any_paragraph,
                                         std::unordered_set<std::string> features,
                                         const RequestType& request_type)
        : InstallPlanAction()
    {
        this->spec = spec;
        this->request_type = request_type;

        this->plan_type = InstallPlanType::BUILD_AND_INSTALL;
        this->any_paragraph.source_control_file = &any_paragraph;
        this->feature_list = features;
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

    std::vector<FeatureSpec> to_feature_specs(const std::vector<std::string> depends,
                                              const std::unordered_map<std::string, PackageSpec> str_to_spec)
    {
        std::vector<FeatureSpec> f_specs;
        for (auto&& depend : depends)
        {
            int end = (int)depend.find(']');
            if (end != std::string::npos)
            {
                int start = (int)depend.find('[');

                auto feature_name = depend.substr(start + 1, end - start - 1);
                auto package_name = depend.substr(0, start);
                auto p_spec = str_to_spec.find(package_name);
                if (p_spec != str_to_spec.end())
                {
                    auto feature_spec = FeatureSpec{p_spec->second, feature_name};
                    f_specs.emplace_back(std::move(feature_spec));
                }
            }
            else
            {
                auto p_spec = str_to_spec.find(depend);
                if (p_spec != str_to_spec.end())
                {
                    auto feature_spec = FeatureSpec{p_spec->second, ""};
                    f_specs.emplace_back(std::move(feature_spec));
                }
            }
        }
        return f_specs;
    }

    bool mark_plus(const std::string& feature,
                   Cluster& cluster,
                   std::unordered_map<PackageSpec, Cluster>& pkg_to_cluster,
                   GraphPlan& graph_plan)
    {
        auto it = cluster.edges.find(feature);
        std::string updated_feature = feature;
        if (updated_feature == "")
        {
            updated_feature = "core";
            it = cluster.edges.find("core");
        }
        if (it == cluster.edges.end())
        {
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        if (cluster.edges[updated_feature].plus) return true;

        if (cluster.original_nodes.find(updated_feature) == cluster.original_nodes.end())
        {
            cluster.zero = true;
        }

        if (!cluster.zero)
        {
            return false;
        }
        cluster.edges[updated_feature].plus = true;

        if (!cluster.original_nodes.empty())
        {
            mark_minus(cluster, pkg_to_cluster, graph_plan);
        }

        graph_plan.install_graph.add_vertex(&cluster);
        auto& tracked = cluster.tracked_nodes;
        tracked.insert(updated_feature);
        if (tracked.find("core") == tracked.end() && tracked.find("") == tracked.end())
        {
            cluster.tracked_nodes.insert("core");
            for (auto&& depend : cluster.edges["core"].dashed)
            {
                auto& depend_cluster = pkg_to_cluster[depend.spec];
                mark_plus(depend.feature_name, depend_cluster, pkg_to_cluster, graph_plan);
                graph_plan.install_graph.add_edge(&cluster, &depend_cluster);
            }
        }

        for (auto&& depend : cluster.edges[updated_feature].dashed)
        {
            auto& depend_cluster = pkg_to_cluster[depend.spec];
            mark_plus(depend.feature_name, depend_cluster, pkg_to_cluster, graph_plan);
            if (&depend_cluster == &cluster) continue;
            graph_plan.install_graph.add_edge(&cluster, &depend_cluster);
        }
        return true;
    }

    void mark_minus(Cluster& cluster, std::unordered_map<PackageSpec, Cluster>& pkg_to_cluster, GraphPlan& graph_plan)
    {
        if (cluster.minus) return;
        cluster.minus = true;

        graph_plan.remove_graph.add_vertex(&cluster);
        for (auto&& pair : cluster.edges)
        {
            auto& dotted_edges = pair.second.dotted;
            for (auto&& depend : dotted_edges)
            {
                auto& depend_cluster = pkg_to_cluster[depend.spec];
                graph_plan.remove_graph.add_edge(&cluster, &depend_cluster);
                depend_cluster.zero = true;
                mark_minus(depend_cluster, pkg_to_cluster, graph_plan);
            }
        }
        for (auto&& original_feature : cluster.original_nodes)
        {
            cluster.zero = true;
            mark_plus(original_feature, cluster, pkg_to_cluster, graph_plan);
        }
    }

    std::vector<AnyAction> create_feature_install_plan(const std::unordered_map<PackageSpec, SourceControlFile>& map,
                                                       const std::vector<FullPackageSpec>& specs,
                                                       const StatusParagraphs& status_db)
    {
        const auto triplet = Triplet::X86_WINDOWS;
        std::unordered_map<PackageSpec, Cluster> pkg_spec_to_package_node;
        std::unordered_map<std::string, PackageSpec> str_to_spec;

        for (const auto& it : map)
        {
            str_to_spec.emplace(it.first.name(), it.first);
        }

        for (const auto& it : map)
        {
            Cluster& node = pkg_spec_to_package_node[it.first];
            FeatureNodeEdges core_dependencies;
            core_dependencies.dashed =
                to_feature_specs(filter_dependencies(it.second.core_paragraph->depends, triplet), str_to_spec);
            node.edges["core"] = std::move(core_dependencies);

            for (const auto& feature : it.second.feature_paragraphs)
            {
                FeatureNodeEdges added_edges;
                added_edges.dashed = to_feature_specs(filter_dependencies(feature->depends, triplet), str_to_spec);
                node.edges.emplace(feature->name, std::move(added_edges));
            }
            node.cluster_node.source_paragraph = &it.second;
        }

        for (auto&& status_paragraph : status_db)
        {
            auto& spec = status_paragraph->package.spec;
            auto& status_paragraph_feature = status_paragraph->package.feature;
            Cluster& cluster = pkg_spec_to_package_node[spec];

            cluster.zero = false;
            auto reverse_edges = to_feature_specs(status_paragraph->package.depends, str_to_spec);

            for (auto&& dependency : reverse_edges)
            {
                auto pkg_node = pkg_spec_to_package_node.find(dependency.spec);
                auto depends_name = dependency.feature_name;
                if (depends_name == "")
                {
                    for (auto&& default_feature : status_paragraph->package.default_features)
                    {
                        auto& target_node = pkg_node->second.edges[default_feature];
                        target_node.dotted.emplace_back(FeatureSpec{spec, status_paragraph_feature});
                    }
                    depends_name = "core";
                }
                auto& target_node = pkg_node->second.edges[depends_name];
                target_node.dotted.emplace_back(FeatureSpec{spec, status_paragraph_feature});
            }
            cluster.cluster_node.status_paragraphs.emplace_back(*status_paragraph);
            if (status_paragraph_feature == "")
            {
                cluster.original_nodes.insert("core");
            }
            else
            {
                cluster.original_nodes.insert(status_paragraph_feature);
            }
        }

        GraphPlan graph_plan;
        for (auto&& spec : specs)
        {
            Cluster& spec_cluster = pkg_spec_to_package_node[spec.package_spec];
            for (auto&& feature : spec.features)
            {
                mark_plus(feature, spec_cluster, pkg_spec_to_package_node, graph_plan);
            }
        }

        Graphs::GraphAdjacencyProvider<Cluster*> adjacency_remove_graph(graph_plan.remove_graph.adjacency_list());
        auto remove_vertex_list = graph_plan.remove_graph.vertex_list();
        auto remove_toposort = Graphs::topological_sort(remove_vertex_list, adjacency_remove_graph);

        Graphs::GraphAdjacencyProvider<Cluster*> adjacency_install_graph(graph_plan.install_graph.adjacency_list());
        auto insert_vertex_list = graph_plan.install_graph.vertex_list();
        auto insert_toposort = Graphs::topological_sort(insert_vertex_list, adjacency_install_graph);

        std::vector<AnyAction> install_plan;

        for (auto&& cluster : remove_toposort)
        {
            auto scf = *cluster->cluster_node.source_paragraph.get();

            AnyAction any_plan;
            any_plan.remove_plan = RemovePlanAction{
                str_to_spec[scf->core_paragraph->name], RemovePlanType::REMOVE, RequestType::AUTO_SELECTED};

            install_plan.emplace_back(std::move(any_plan));
        }

        for (auto&& cluster : insert_toposort)
        {
            if (!cluster->zero) continue;

            auto scf = *cluster->cluster_node.source_paragraph.get();
            auto& pkg_spec = str_to_spec[scf->core_paragraph->name];
            auto action = InstallPlanAction{
                pkg_spec, map.find(pkg_spec)->second, cluster->tracked_nodes, RequestType::AUTO_SELECTED};

            AnyAction any_plan;
            any_plan.install_plan = std::move(action);
            install_plan.emplace_back(std::move(any_plan));
        }

        return install_plan;
    }
}
