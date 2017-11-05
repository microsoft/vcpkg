#include "pch.h"

#include <vcpkg/base/files.h>
#include <vcpkg/base/graphs.h>
#include <vcpkg/base/strings.h>
#include <vcpkg/base/util.h>
#include <vcpkg/dependencies.h>
#include <vcpkg/packagespec.h>
#include <vcpkg/paragraphs.h>
#include <vcpkg/statusparagraphs.h>
#include <vcpkg/vcpkglib.h>
#include <vcpkg/vcpkgpaths.h>

namespace vcpkg::Dependencies
{
    struct FeatureNodeEdges
    {
        std::vector<FeatureSpec> remove_edges;
        std::vector<FeatureSpec> build_edges;
        bool plus = false;
    };

    struct Cluster : Util::MoveOnlyBase
    {
        std::vector<StatusParagraph*> status_paragraphs;
        Optional<const SourceControlFile*> source_control_file;
        PackageSpec spec;
        std::unordered_map<std::string, FeatureNodeEdges> edges;
        std::unordered_set<std::string> to_install_features;
        std::unordered_set<std::string> original_features;
        bool will_remove = false;
        bool transient_uninstalled = true;
        RequestType request_type = RequestType::AUTO_SELECTED;
    };

    struct ClusterPtr
    {
        Cluster* ptr;

        Cluster* operator->() const { return ptr; }
    };

    bool operator==(const ClusterPtr& l, const ClusterPtr& r) { return l.ptr == r.ptr; }
}

namespace std
{
    template<>
    struct hash<vcpkg::Dependencies::ClusterPtr>
    {
        size_t operator()(const vcpkg::Dependencies::ClusterPtr& value) const
        {
            return std::hash<vcpkg::PackageSpec>()(value.ptr->spec);
        }
    };
}

namespace vcpkg::Dependencies
{
    struct GraphPlan
    {
        Graphs::Graph<ClusterPtr> remove_graph;
        Graphs::Graph<ClusterPtr> install_graph;
    };

    struct ClusterGraph : Util::MoveOnlyBase
    {
        explicit ClusterGraph(std::unordered_map<std::string, const SourceControlFile*>&& ports)
            : m_ports(std::move(ports))
        {
        }

        Cluster& get(const PackageSpec& spec)
        {
            auto it = m_graph.find(spec);
            if (it == m_graph.end())
            {
                // Load on-demand from m_ports
                auto it_ports = m_ports.find(spec.name());
                if (it_ports != m_ports.end())
                {
                    auto& clust = m_graph[spec];
                    clust.spec = spec;
                    cluster_from_scf(*it_ports->second, clust);
                    return clust;
                }
                return m_graph[spec];
            }
            return it->second;
        }

    private:
        void cluster_from_scf(const SourceControlFile& scf, Cluster& out_cluster) const
        {
            FeatureNodeEdges core_dependencies;
            core_dependencies.build_edges =
                filter_dependencies_to_specs(scf.core_paragraph->depends, out_cluster.spec.triplet());
            out_cluster.edges.emplace("core", std::move(core_dependencies));

            for (const auto& feature : scf.feature_paragraphs)
            {
                FeatureNodeEdges added_edges;
                added_edges.build_edges = filter_dependencies_to_specs(feature->depends, out_cluster.spec.triplet());
                out_cluster.edges.emplace(feature->name, std::move(added_edges));
            }
            out_cluster.source_control_file = &scf;
        }

        std::unordered_map<PackageSpec, Cluster> m_graph;
        std::unordered_map<std::string, const SourceControlFile*> m_ports;
    };

    std::vector<PackageSpec> AnyParagraph::dependencies(const Triplet& triplet) const
    {
        if (const auto p = this->status_paragraph.get())
        {
            return PackageSpec::to_package_specs(p->package.depends, triplet);
        }

        if (const auto p = this->binary_control_file.get())
        {
            auto deps = Util::fmap_flatten(p->features, [](const BinaryParagraph& pgh) { return pgh.depends; });
            deps.insert(deps.end(), p->core_paragraph.depends.cbegin(), p->core_paragraph.depends.cend());
            return PackageSpec::to_package_specs(deps, triplet);
        }

        if (const auto p = this->source_paragraph.get())
        {
            return PackageSpec::to_package_specs(filter_dependencies(p->depends, triplet), triplet);
        }

        Checks::exit_with_message(VCPKG_LINE_INFO,
                                  "Cannot get dependencies because there was none of: source/binary/status paragraphs");
    }

    std::string to_output_string(RequestType request_type,
                                 const CStringView s,
                                 const Build::BuildPackageOptions& options)
    {
        const char* const from_head = options.use_head_version == Build::UseHeadVersion::YES ? " (from HEAD)" : "";

        switch (request_type)
        {
            case RequestType::AUTO_SELECTED: return Strings::format("  * %s%s", s, from_head);
            case RequestType::USER_REQUESTED: return Strings::format("    %s%s", s, from_head);
            default: Checks::unreachable(VCPKG_LINE_INFO);
        }
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

    InstallPlanAction::InstallPlanAction() : plan_type(InstallPlanType::UNKNOWN), request_type(RequestType::UNKNOWN) {}

    InstallPlanAction::InstallPlanAction(const PackageSpec& spec,
                                         const SourceControlFile& any_paragraph,
                                         const std::unordered_set<std::string>& features,
                                         const RequestType& request_type)
        : spec(spec), plan_type(InstallPlanType::BUILD_AND_INSTALL), request_type(request_type), feature_list(features)
    {
        this->any_paragraph.source_control_file = &any_paragraph;
    }

    InstallPlanAction::InstallPlanAction(const PackageSpec& spec,
                                         const std::unordered_set<std::string>& features,
                                         const RequestType& request_type)
        : spec(spec), plan_type(InstallPlanType::ALREADY_INSTALLED), request_type(request_type), feature_list(features)
    {
    }

    InstallPlanAction::InstallPlanAction(const PackageSpec& spec,
                                         const AnyParagraph& any_paragraph,
                                         const RequestType& request_type)
        : spec(spec), any_paragraph(any_paragraph), plan_type(InstallPlanType::UNKNOWN), request_type(request_type)
    {
        if (auto p = any_paragraph.status_paragraph.get())
        {
            this->plan_type = InstallPlanType::ALREADY_INSTALLED;
            return;
        }

        if (auto p = any_paragraph.binary_control_file.get())
        {
            this->plan_type = InstallPlanType::INSTALL;
            return;
        }

        if (auto p = any_paragraph.source_paragraph.get())
        {
            this->plan_type = InstallPlanType::BUILD_AND_INSTALL;
            return;
        }
    }

    std::string InstallPlanAction::displayname() const
    {
        if (this->feature_list.empty())
        {
            return this->spec.to_string();
        }

        const std::string features = Strings::join(",", this->feature_list);
        return Strings::format("%s[%s]:%s", this->spec.name(), features, this->spec.triplet());
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

    const PackageSpec& AnyAction::spec() const
    {
        if (const auto p = install_plan.get())
        {
            return p->spec;
        }

        if (const auto p = remove_plan.get())
        {
            return p->spec;
        }

        Checks::exit_with_message(VCPKG_LINE_INFO, "Null action");
    }

    bool ExportPlanAction::compare_by_name(const ExportPlanAction* left, const ExportPlanAction* right)
    {
        return left->spec.name() < right->spec.name();
    }

    ExportPlanAction::ExportPlanAction() : plan_type(ExportPlanType::UNKNOWN), request_type(RequestType::UNKNOWN) {}

    ExportPlanAction::ExportPlanAction(const PackageSpec& spec,
                                       const AnyParagraph& any_paragraph,
                                       const RequestType& request_type)
        : spec(spec), any_paragraph(any_paragraph), plan_type(ExportPlanType::UNKNOWN), request_type(request_type)
    {
        if (auto p = any_paragraph.binary_control_file.get())
        {
            this->plan_type = ExportPlanType::ALREADY_BUILT;
            return;
        }

        if (auto p = any_paragraph.source_paragraph.get())
        {
            this->plan_type = ExportPlanType::PORT_AVAILABLE_BUT_NOT_BUILT;
            return;
        }
    }

    bool RemovePlanAction::compare_by_name(const RemovePlanAction* left, const RemovePlanAction* right)
    {
        return left->spec.name() < right->spec.name();
    }

    MapPortFile::MapPortFile(const std::unordered_map<std::string, SourceControlFile>& map) : ports(map) {}

    const SourceControlFile& MapPortFile::get_control_file(const std::string& spec) const
    {
        auto scf = ports.find(spec);
        if (scf == ports.end())
        {
            Checks::exit_fail(VCPKG_LINE_INFO);
        }
        return scf->second;
    }

    PathsPortFile::PathsPortFile(const VcpkgPaths& paths) : ports(paths) {}

    const SourceControlFile& PathsPortFile::get_control_file(const std::string& spec) const
    {
        auto cache_it = cache.find(spec);
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
                    spec,
                    {nullopt, nullopt, *port_file_provider.get_control_file(spec.name()).core_paragraph},
                    request_type};
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

                Expected<BinaryControlFile> maybe_bpgh = Paragraphs::try_load_cached_control_package(paths, spec);
                if (auto bcf = maybe_bpgh.get())
                    return ExportPlanAction{spec, AnyParagraph{nullopt, std::move(*bcf), nullopt}, request_type};

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

    enum class MarkPlusResult
    {
        FEATURE_NOT_FOUND,
        SUCCESS,
    };

    MarkPlusResult mark_plus(const std::string& feature,
                             Cluster& cluster,
                             ClusterGraph& pkg_to_cluster,
                             GraphPlan& graph_plan);
    void mark_minus(Cluster& cluster, ClusterGraph& pkg_to_cluster, GraphPlan& graph_plan);

    MarkPlusResult mark_plus(const std::string& feature, Cluster& cluster, ClusterGraph& graph, GraphPlan& graph_plan)
    {
        if (feature.empty())
        {
            // Indicates that core was not specified in the reference
            return mark_plus("core", cluster, graph, graph_plan);
        }

        auto it = cluster.edges.find(feature);
        if (it == cluster.edges.end()) return MarkPlusResult::FEATURE_NOT_FOUND;

        if (cluster.edges[feature].plus) return MarkPlusResult::SUCCESS;

        if (cluster.original_features.find(feature) == cluster.original_features.end())
        {
            cluster.transient_uninstalled = true;
        }

        if (!cluster.transient_uninstalled)
        {
            return MarkPlusResult::SUCCESS;
        }
        cluster.edges[feature].plus = true;

        if (!cluster.original_features.empty())
        {
            mark_minus(cluster, graph, graph_plan);
        }

        graph_plan.install_graph.add_vertex({&cluster});
        auto& tracked = cluster.to_install_features;
        tracked.insert(feature);

        if (feature != "core")
        {
            // All features implicitly depend on core
            auto res = mark_plus("core", cluster, graph, graph_plan);

            // Should be impossible for "core" to not exist
            Checks::check_exit(VCPKG_LINE_INFO, res == MarkPlusResult::SUCCESS);
        }

        for (auto&& depend : cluster.edges[feature].build_edges)
        {
            auto& depend_cluster = graph.get(depend.spec());
            auto res = mark_plus(depend.feature(), depend_cluster, graph, graph_plan);

            Checks::check_exit(VCPKG_LINE_INFO,
                               res == MarkPlusResult::SUCCESS,
                               "Error: Unable to satisfy dependency %s of %s",
                               depend,
                               FeatureSpec(cluster.spec, feature));

            if (&depend_cluster == &cluster) continue;
            graph_plan.install_graph.add_edge({&cluster}, {&depend_cluster});
        }

        return MarkPlusResult::SUCCESS;
    }

    void mark_minus(Cluster& cluster, ClusterGraph& graph, GraphPlan& graph_plan)
    {
        if (cluster.will_remove) return;
        cluster.will_remove = true;

        graph_plan.remove_graph.add_vertex({&cluster});
        for (auto&& pair : cluster.edges)
        {
            auto& remove_edges_edges = pair.second.remove_edges;
            for (auto&& depend : remove_edges_edges)
            {
                auto& depend_cluster = graph.get(depend.spec());
                graph_plan.remove_graph.add_edge({&cluster}, {&depend_cluster});
                mark_minus(depend_cluster, graph, graph_plan);
            }
        }

        cluster.transient_uninstalled = true;
        for (auto&& original_feature : cluster.original_features)
        {
            auto res = mark_plus(original_feature, cluster, graph, graph_plan);
            if (res != MarkPlusResult::SUCCESS)
            {
                System::println(System::Color::warning,
                                "Warning: could not reinstall feature %s",
                                FeatureSpec{cluster.spec, original_feature});
            }
        }
    }

    static ClusterGraph create_feature_install_graph(const std::unordered_map<std::string, SourceControlFile>& map,
                                                     const StatusParagraphs& status_db)
    {
        std::unordered_map<std::string, const SourceControlFile*> ptr_map;
        for (auto&& p : map)
            ptr_map.emplace(p.first, &p.second);
        ClusterGraph graph(std::move(ptr_map));

        auto installed_ports = get_installed_ports(status_db);

        for (auto&& status_paragraph : installed_ports)
        {
            Cluster& cluster = graph.get(status_paragraph->package.spec);

            cluster.transient_uninstalled = false;

            cluster.status_paragraphs.emplace_back(status_paragraph);

            auto& status_paragraph_feature = status_paragraph->package.feature;
            // In this case, empty string indicates the "core" paragraph for a package.
            if (status_paragraph_feature.empty())
            {
                cluster.original_features.insert("core");
            }
            else
            {
                cluster.original_features.insert(status_paragraph_feature);
            }
        }

        for (auto&& status_paragraph : installed_ports)
        {
            auto& spec = status_paragraph->package.spec;
            auto& status_paragraph_feature = status_paragraph->package.feature;
            auto reverse_edges = FeatureSpec::from_strings_and_triplet(status_paragraph->package.depends,
                                                                       status_paragraph->package.spec.triplet());

            for (auto&& dependency : reverse_edges)
            {
                auto& dep_cluster = graph.get(dependency.spec());

                auto depends_name = dependency.feature();
                if (depends_name.empty()) depends_name = "core";

                auto& target_node = dep_cluster.edges[depends_name];
                target_node.remove_edges.emplace_back(FeatureSpec{spec, status_paragraph_feature});
            }
        }
        return graph;
    }

    std::vector<AnyAction> create_feature_install_plan(const std::unordered_map<std::string, SourceControlFile>& map,
                                                       const std::vector<FeatureSpec>& specs,
                                                       const StatusParagraphs& status_db)
    {
        ClusterGraph graph = create_feature_install_graph(map, status_db);

        GraphPlan graph_plan;
        for (auto&& spec : specs)
        {
            Cluster& spec_cluster = graph.get(spec.spec());
            spec_cluster.request_type = RequestType::USER_REQUESTED;
            if (spec.feature() == "*")
            {
                if (auto p_scf = spec_cluster.source_control_file.value_or(nullptr))
                {
                    for (auto&& feature : p_scf->feature_paragraphs)
                    {
                        auto res = mark_plus(feature->name, spec_cluster, graph, graph_plan);

                        Checks::check_exit(VCPKG_LINE_INFO,
                                           res == MarkPlusResult::SUCCESS,
                                           "Error: Unable to locate feature %s",
                                           spec);
                    }

                    auto res = mark_plus("core", spec_cluster, graph, graph_plan);

                    Checks::check_exit(
                        VCPKG_LINE_INFO, res == MarkPlusResult::SUCCESS, "Error: Unable to locate feature %s", spec);
                }
                else
                {
                    Checks::exit_with_message(
                        VCPKG_LINE_INFO, "Error: Unable to handle '*' because can't find CONTROL for %s", spec.spec());
                }
            }
            else
            {
                auto res = mark_plus(spec.feature(), spec_cluster, graph, graph_plan);

                Checks::check_exit(
                    VCPKG_LINE_INFO, res == MarkPlusResult::SUCCESS, "Error: Unable to locate feature %s", spec);
            }

            graph_plan.install_graph.add_vertex(ClusterPtr{&spec_cluster});
        }

        Graphs::GraphAdjacencyProvider<ClusterPtr> adjacency_remove_graph(graph_plan.remove_graph.adjacency_list());
        auto remove_vertex_list = graph_plan.remove_graph.vertex_list();
        auto remove_toposort = Graphs::topological_sort(remove_vertex_list, adjacency_remove_graph);

        Graphs::GraphAdjacencyProvider<ClusterPtr> adjacency_install_graph(graph_plan.install_graph.adjacency_list());
        auto insert_vertex_list = graph_plan.install_graph.vertex_list();
        auto insert_toposort = Graphs::topological_sort(insert_vertex_list, adjacency_install_graph);

        std::vector<AnyAction> plan;

        for (auto&& p_cluster : remove_toposort)
        {
            auto scf = *p_cluster->source_control_file.get();
            auto spec = PackageSpec::from_name_and_triplet(scf->core_paragraph->name, p_cluster->spec.triplet())
                            .value_or_exit(VCPKG_LINE_INFO);
            plan.emplace_back(RemovePlanAction{
                std::move(spec),
                RemovePlanType::REMOVE,
                p_cluster->request_type,
            });
        }

        for (auto&& p_cluster : insert_toposort)
        {
            if (p_cluster->transient_uninstalled)
            {
                // If it will be transiently uninstalled, we need to issue a full installation command
                auto pscf = p_cluster->source_control_file.value_or_exit(VCPKG_LINE_INFO);
                Checks::check_exit(VCPKG_LINE_INFO, pscf != nullptr);
                plan.emplace_back(InstallPlanAction{
                    p_cluster->spec,
                    *pscf,
                    p_cluster->to_install_features,
                    p_cluster->request_type,
                });
            }
            else
            {
                // If the package isn't transitively installed, still include it if the user explicitly requested it
                if (p_cluster->request_type != RequestType::USER_REQUESTED) continue;
                plan.emplace_back(InstallPlanAction{
                    p_cluster->spec,
                    p_cluster->original_features,
                    p_cluster->request_type,
                });
            }
        }

        return plan;
    }
}
