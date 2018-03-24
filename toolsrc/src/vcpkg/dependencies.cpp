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

    /// <summary>
    /// Representation of a package and its features in a ClusterGraph.
    /// </summary>
    struct Cluster : Util::MoveOnlyBase
    {
        InstalledPackageView installed_package;

        Optional<const SourceControlFile*> source_control_file;
        PackageSpec spec;
        std::unordered_map<std::string, FeatureNodeEdges> edges_by_feature;
        std::set<std::string> to_install_features;
        std::set<std::string> original_features;
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

    /// <summary>
    /// Directional graph representing a collection of packages with their features connected by their dependencies.
    /// </summary>
    struct ClusterGraph : Util::MoveOnlyBase
    {
        explicit ClusterGraph(const PortFileProvider& provider) : m_provider(provider) {}

        /// <summary>
        ///     Find the cluster associated with spec or if not found, create it from the PortFileProvider.
        /// </summary>
        /// <param name="spec">Package spec to get the cluster for.</param>
        /// <returns>The cluster found or created for spec.</returns>
        Cluster& get(const PackageSpec& spec)
        {
            auto it = m_graph.find(spec);
            if (it == m_graph.end())
            {
                // Load on-demand from m_provider
                auto maybe_scf = m_provider.get_control_file(spec.name());
                auto& clust = m_graph[spec];
                clust.spec = spec;
                if (auto p_scf = maybe_scf.get()) cluster_from_scf(*p_scf, clust);
                return clust;
            }
            return it->second;
        }

    private:
        void cluster_from_scf(const SourceControlFile& scf, Cluster& out_cluster) const
        {
            FeatureNodeEdges core_dependencies;
            core_dependencies.build_edges =
                filter_dependencies_to_specs(scf.core_paragraph->depends, out_cluster.spec.triplet());
            out_cluster.edges_by_feature.emplace("core", std::move(core_dependencies));

            for (const auto& feature : scf.feature_paragraphs)
            {
                FeatureNodeEdges added_edges;
                added_edges.build_edges = filter_dependencies_to_specs(feature->depends, out_cluster.spec.triplet());
                out_cluster.edges_by_feature.emplace(feature->name, std::move(added_edges));
            }
            out_cluster.source_control_file = &scf;
        }

        std::unordered_map<PackageSpec, Cluster> m_graph;
        const PortFileProvider& m_provider;
    };

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
                                         const SourceControlFile& scf,
                                         const std::set<std::string>& features,
                                         const RequestType& request_type,
                                         std::vector<PackageSpec>&& dependencies)
        : spec(spec)
        , source_control_file(scf)
        , plan_type(InstallPlanType::BUILD_AND_INSTALL)
        , request_type(request_type)
        , feature_list(features)
        , computed_dependencies(std::move(dependencies))
    {
    }

    InstallPlanAction::InstallPlanAction(const PackageSpec& spec,
                                         InstalledPackageView&& ipv,
                                         const std::set<std::string>& features,
                                         const RequestType& request_type)
        : spec(spec)
        , installed_package(std::move(ipv))
        , plan_type(InstallPlanType::ALREADY_INSTALLED)
        , request_type(request_type)
        , feature_list(features)
        , computed_dependencies(installed_package.get()->dependencies())
    {
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
        if (const auto p = install_action.get())
        {
            return p->spec;
        }

        if (const auto p = remove_action.get())
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
                                       InstalledPackageView&& installed_package,
                                       const RequestType& request_type)
        : spec(spec)
        , plan_type(ExportPlanType::ALREADY_BUILT)
        , request_type(request_type)
        , m_installed_package(std::move(installed_package))
    {
    }

    ExportPlanAction::ExportPlanAction(const PackageSpec& spec, const RequestType& request_type)
        : spec(spec), plan_type(ExportPlanType::NOT_BUILT), request_type(request_type)
    {
    }

    Optional<const BinaryParagraph&> ExportPlanAction::core_paragraph() const
    {
        if (auto p_ip = m_installed_package.get())
        {
            return p_ip->core->package;
        }
        return nullopt;
    }

    std::vector<PackageSpec> ExportPlanAction::dependencies(const Triplet&) const
    {
        if (auto p_ip = m_installed_package.get())
            return p_ip->dependencies();
        else
            return {};
    }

    bool RemovePlanAction::compare_by_name(const RemovePlanAction* left, const RemovePlanAction* right)
    {
        return left->spec.name() < right->spec.name();
    }

    MapPortFileProvider::MapPortFileProvider(const std::unordered_map<std::string, SourceControlFile>& map) : ports(map)
    {
    }

    Optional<const SourceControlFile&> MapPortFileProvider::get_control_file(const std::string& spec) const
    {
        auto scf = ports.find(spec);
        if (scf == ports.end()) return nullopt;
        return scf->second;
    }

    PathsPortFileProvider::PathsPortFileProvider(const VcpkgPaths& paths) : ports(paths) {}

    Optional<const SourceControlFile&> PathsPortFileProvider::get_control_file(const std::string& spec) const
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
        return nullopt;
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

                    std::vector<std::string> deps = an_installed_package->package.depends;
                    // <hack>
                    // This is a hack to work around existing installations that put featurespecs into binary packages
                    // (example: curl[core]) Eventually, this can be returned to a simple string search.
                    for (auto&& dep : deps)
                    {
                        dep.erase(std::find(dep.begin(), dep.end(), '['), dep.end());
                    }
                    Util::unstable_keep_if(deps,
                                           [&](auto&& e) { return e != an_installed_package->package.spec.name(); });
                    // </hack>
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

            std::string to_string(const PackageSpec& spec) const override { return spec.to_string(); }
        };

        const std::vector<StatusParagraph*>& installed_ports = get_installed_ports(status_db);
        const std::unordered_set<PackageSpec> specs_as_set(specs.cbegin(), specs.cend());
        return Graphs::topological_sort(specs, RemoveAdjacencyProvider{status_db, installed_ports, specs_as_set});
    }

    std::vector<ExportPlanAction> create_export_plan(const std::vector<PackageSpec>& specs,
                                                     const StatusParagraphs& status_db)
    {
        struct ExportAdjacencyProvider final : Graphs::AdjacencyProvider<PackageSpec, ExportPlanAction>
        {
            const StatusParagraphs& status_db;
            const std::unordered_set<PackageSpec>& specs_as_set;

            ExportAdjacencyProvider(const StatusParagraphs& s, const std::unordered_set<PackageSpec>& specs_as_set)
                : status_db(s), specs_as_set(specs_as_set)
            {
            }

            std::vector<PackageSpec> adjacency_list(const ExportPlanAction& plan) const override
            {
                return plan.dependencies(plan.spec.triplet());
            }

            ExportPlanAction load_vertex_data(const PackageSpec& spec) const override
            {
                const RequestType request_type = specs_as_set.find(spec) != specs_as_set.end()
                                                     ? RequestType::USER_REQUESTED
                                                     : RequestType::AUTO_SELECTED;

                auto maybe_ipv = status_db.find_all_installed(spec);

                if (auto p_ipv = maybe_ipv.get())
                {
                    return ExportPlanAction{spec, std::move(*p_ipv), request_type};
                }

                return ExportPlanAction{spec, request_type};
            }

            std::string to_string(const PackageSpec& spec) const override { return spec.to_string(); }
        };

        const std::unordered_set<PackageSpec> specs_as_set(specs.cbegin(), specs.cend());
        std::vector<ExportPlanAction> toposort =
            Graphs::topological_sort(specs, ExportAdjacencyProvider{status_db, specs_as_set});
        return toposort;
    }

    enum class MarkPlusResult
    {
        FEATURE_NOT_FOUND,
        SUCCESS,
    };

    static MarkPlusResult mark_plus(const std::string& feature,
                                    Cluster& cluster,
                                    ClusterGraph& graph,
                                    GraphPlan& graph_plan,
                                    const std::unordered_set<std::string>& prevent_default_features = {});

    static void mark_minus(Cluster& cluster, ClusterGraph& graph, GraphPlan& graph_plan);

    MarkPlusResult mark_plus(const std::string& feature,
                             Cluster& cluster,
                             ClusterGraph& graph,
                             GraphPlan& graph_plan,
                             const std::unordered_set<std::string>& prevent_default_features)
    {
        if (feature.empty())
        {
            if (prevent_default_features.find(cluster.spec.name()) == prevent_default_features.end())
            {
                // Indicates that core was not specified in the reference

                // Add default features for this package, if this is the "core" feature and we
                // are not supposed to prevent default features for this package
                if (auto scf = cluster.source_control_file.value_or(nullptr))
                {
                    for (auto&& default_feature : scf->core_paragraph.get()->default_features)
                    {
                        auto res = mark_plus(default_feature, cluster, graph, graph_plan, prevent_default_features);
                        if (res != MarkPlusResult::SUCCESS)
                        {
                            return res;
                        }
                    }
                }

                // "core" is always an implicit default feature. In case we did not add it as
                // a dependency above (e.g. no default features), add it here.
                auto res = mark_plus("core", cluster, graph, graph_plan, prevent_default_features);
                if (res != MarkPlusResult::SUCCESS)
                {
                    return res;
                }

                return MarkPlusResult::SUCCESS;
            }
            else
            {
                // Skip adding the default features, as explicitly told not to.
                return MarkPlusResult::SUCCESS;
            }
        }

        auto it = cluster.edges_by_feature.find(feature);
        if (it == cluster.edges_by_feature.end()) return MarkPlusResult::FEATURE_NOT_FOUND;

        if (cluster.edges_by_feature[feature].plus) return MarkPlusResult::SUCCESS;

        if (cluster.original_features.find(feature) == cluster.original_features.end())
        {
            cluster.transient_uninstalled = true;
        }

        if (!cluster.transient_uninstalled)
        {
            return MarkPlusResult::SUCCESS;
        }
        cluster.edges_by_feature[feature].plus = true;

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
            auto res = mark_plus("core", cluster, graph, graph_plan, prevent_default_features);

            // Should be impossible for "core" to not exist
            Checks::check_exit(VCPKG_LINE_INFO, res == MarkPlusResult::SUCCESS);
        }
        else
        {
            // Add the default features of this package.
            auto res = mark_plus("", cluster, graph, graph_plan, prevent_default_features);
        }

        for (auto&& depend : cluster.edges_by_feature[feature].build_edges)
        {
            auto& depend_cluster = graph.get(depend.spec());
            auto res = mark_plus(depend.feature(), depend_cluster, graph, graph_plan, prevent_default_features);

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

        std::unordered_set<std::string> prevent_default_features;

        if (cluster.request_type == RequestType::USER_REQUESTED)
        {
            // Do not install default features for packages which the user
            // installed explicitly. New default features for dependent
            // clusters should still be upgraded.
            prevent_default_features.insert(cluster.spec.name());

            // For dependent packages this is handles through the recursion
        }

        graph_plan.remove_graph.add_vertex({&cluster});
        for (auto&& pair : cluster.edges_by_feature)
        {
            auto& remove_edges_edges = pair.second.remove_edges;
            for (auto&& depend : remove_edges_edges)
            {
                auto& depend_cluster = graph.get(depend.spec());
                if (&depend_cluster != &cluster) graph_plan.remove_graph.add_edge({&cluster}, {&depend_cluster});
                mark_minus(depend_cluster, graph, graph_plan);
            }
        }

        cluster.transient_uninstalled = true;
        for (auto&& original_feature : cluster.original_features)
        {
            auto res = mark_plus(original_feature, cluster, graph, graph_plan, prevent_default_features);
            if (res != MarkPlusResult::SUCCESS)
            {
                System::println(System::Color::warning,
                                "Warning: could not reinstall feature %s",
                                FeatureSpec{cluster.spec, original_feature});
            }
        }

        // Check if any default features have been added
        if (auto scf = cluster.source_control_file.value_or(nullptr))
        {
            auto& previous_df = cluster.installed_package.core->package.default_features;
            for (auto&& default_feature : scf->core_paragraph->default_features)
            {
                if (std::find(previous_df.begin(), previous_df.end(), default_feature) == previous_df.end())
                {
                    // this is a new default feature, mark it for installation
                    auto res = mark_plus(default_feature, cluster, graph, graph_plan);
                    if (res != MarkPlusResult::SUCCESS)
                    {
                        System::println(System::Color::warning,
                                        "Warning: could not install new default feature %s",
                                        FeatureSpec{cluster.spec, default_feature});
                    }
                }
            }
        }
    }

    /// <summary>Figure out which actions are required to install features specifications in `specs`.</summary>
    /// <param name="provider">Contains the ports of the current environment.</param>
    /// <param name="specs">Feature specifications to resolve dependencies for.</param>
    /// <param name="status_db">Status of installed packages in the current environment.</param>
    std::vector<AnyAction> create_feature_install_plan(const PortFileProvider& provider,
                                                       const std::vector<FeatureSpec>& specs,
                                                       const StatusParagraphs& status_db)
    {
        std::unordered_set<std::string> prevent_default_features;
        for (auto&& spec : specs)
        {
            // When "core" is explicitly listed, default features should not be installed.
            if (spec.feature() == "core") prevent_default_features.insert(spec.name());
        }

        PackageGraph pgraph(provider, status_db);
        for (auto&& spec : specs)
            pgraph.install(spec, prevent_default_features);

        return pgraph.serialize();
    }

    /// <summary>Figure out which actions are required to install features specifications in `specs`.</summary>
    /// <param name="map">Map of all source files in the current environment.</param>
    /// <param name="specs">Feature specifications to resolve dependencies for.</param>
    /// <param name="status_db">Status of installed packages in the current environment.</param>
    std::vector<AnyAction> create_feature_install_plan(const std::unordered_map<std::string, SourceControlFile>& map,
                                                       const std::vector<FeatureSpec>& specs,
                                                       const StatusParagraphs& status_db)
    {
        MapPortFileProvider provider(map);
        return create_feature_install_plan(provider, specs, status_db);
    }

    /// <param name="prevent_default_features">
    /// List of package names for which default features should not be installed instead of the core package (e.g. if
    /// the user is currently installing specific features of that package).
    /// </param>
    void PackageGraph::install(const FeatureSpec& spec,
                               const std::unordered_set<std::string>& prevent_default_features) const
    {
        Cluster& spec_cluster = m_graph->get(spec.spec());
        spec_cluster.request_type = RequestType::USER_REQUESTED;
        if (spec.feature() == "*")
        {
            if (auto p_scf = spec_cluster.source_control_file.value_or(nullptr))
            {
                for (auto&& feature : p_scf->feature_paragraphs)
                {
                    auto res =
                        mark_plus(feature->name, spec_cluster, *m_graph, *m_graph_plan, prevent_default_features);

                    Checks::check_exit(
                        VCPKG_LINE_INFO, res == MarkPlusResult::SUCCESS, "Error: Unable to locate feature %s", spec);
                }

                auto res = mark_plus("core", spec_cluster, *m_graph, *m_graph_plan, prevent_default_features);

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
            auto res = mark_plus(spec.feature(), spec_cluster, *m_graph, *m_graph_plan, prevent_default_features);

            Checks::check_exit(
                VCPKG_LINE_INFO, res == MarkPlusResult::SUCCESS, "Error: Unable to locate feature %s", spec);
        }

        m_graph_plan->install_graph.add_vertex(ClusterPtr{&spec_cluster});
    }

    void PackageGraph::upgrade(const PackageSpec& spec) const
    {
        Cluster& spec_cluster = m_graph->get(spec);
        spec_cluster.request_type = RequestType::USER_REQUESTED;

        mark_minus(spec_cluster, *m_graph, *m_graph_plan);
    }

    std::vector<AnyAction> PackageGraph::serialize() const
    {
        auto remove_vertex_list = m_graph_plan->remove_graph.vertex_list();
        auto remove_toposort = Graphs::topological_sort(remove_vertex_list, m_graph_plan->remove_graph);

        auto insert_vertex_list = m_graph_plan->install_graph.vertex_list();
        auto insert_toposort = Graphs::topological_sort(insert_vertex_list, m_graph_plan->install_graph);

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

                auto dep_specs = Util::fmap(m_graph_plan->install_graph.adjacency_list(p_cluster),
                                            [](ClusterPtr const& p) { return p->spec; });
                Util::sort_unique_erase(dep_specs);

                plan.emplace_back(InstallPlanAction{
                    p_cluster->spec,
                    *pscf,
                    p_cluster->to_install_features,
                    p_cluster->request_type,
                    std::move(dep_specs),
                });
            }
            else
            {
                // If the package isn't transitively installed, still include it if the user explicitly requested it
                if (p_cluster->request_type != RequestType::USER_REQUESTED) continue;
                plan.emplace_back(InstallPlanAction{
                    p_cluster->spec,
                    InstalledPackageView{p_cluster->installed_package},
                    p_cluster->original_features,
                    p_cluster->request_type,
                });
            }
        }

        return plan;
    }

    static std::unique_ptr<ClusterGraph> create_feature_install_graph(const PortFileProvider& map,
                                                                      const StatusParagraphs& status_db)
    {
        std::unique_ptr<ClusterGraph> graph = std::make_unique<ClusterGraph>(map);

        auto installed_ports = get_installed_ports(status_db);

        for (auto&& status_paragraph : installed_ports)
        {
            Cluster& cluster = graph->get(status_paragraph->package.spec);

            cluster.transient_uninstalled = false;

            auto& status_paragraph_feature = status_paragraph->package.feature;

            // In this case, empty string indicates the "core" paragraph for a package.
            if (status_paragraph_feature.empty())
            {
                cluster.original_features.insert("core");
                cluster.installed_package.core = status_paragraph;
            }
            else
            {
                cluster.original_features.insert(status_paragraph_feature);
                cluster.installed_package.features.emplace_back(status_paragraph);
            }
        }

        // Populate the graph with "remove edges", which are the reverse of the Build-Depends edges.
        for (auto&& status_paragraph : installed_ports)
        {
            auto& spec = status_paragraph->package.spec;
            auto& status_paragraph_feature = status_paragraph->package.feature;
            auto reverse_edges = FeatureSpec::from_strings_and_triplet(status_paragraph->package.depends,
                                                                       status_paragraph->package.spec.triplet());

            for (auto&& dependency : reverse_edges)
            {
                auto& dep_cluster = graph->get(dependency.spec());

                auto depends_name = dependency.feature();
                if (depends_name.empty()) depends_name = "core";

                auto& target_node = dep_cluster.edges_by_feature[depends_name];
                target_node.remove_edges.emplace_back(FeatureSpec{spec, status_paragraph_feature});
            }
        }
        return graph;
    }

    PackageGraph::PackageGraph(const PortFileProvider& provider, const StatusParagraphs& status_db)
        : m_graph_plan(std::make_unique<GraphPlan>()), m_graph(create_feature_install_graph(provider, status_db))
    {
    }

    PackageGraph::~PackageGraph() = default;

    void print_plan(const std::vector<AnyAction>& action_plan, const bool is_recursive)
    {
        std::vector<const RemovePlanAction*> remove_plans;
        std::vector<const InstallPlanAction*> rebuilt_plans;
        std::vector<const InstallPlanAction*> only_install_plans;
        std::vector<const InstallPlanAction*> new_plans;
        std::vector<const InstallPlanAction*> already_installed_plans;
        std::vector<const InstallPlanAction*> excluded;

        const bool has_non_user_requested_packages = Util::find_if(action_plan, [](const AnyAction& package) -> bool {
                                                         if (auto iplan = package.install_action.get())
                                                             return iplan->request_type != RequestType::USER_REQUESTED;
                                                         else
                                                             return false;
                                                     }) != action_plan.cend();

        for (auto&& action : action_plan)
        {
            if (auto install_action = action.install_action.get())
            {
                // remove plans are guaranteed to come before install plans, so we know the plan will be contained if at
                // all.
                auto it = Util::find_if(
                    remove_plans, [&](const RemovePlanAction* plan) { return plan->spec == install_action->spec; });
                if (it != remove_plans.end())
                {
                    rebuilt_plans.emplace_back(install_action);
                }
                else
                {
                    switch (install_action->plan_type)
                    {
                        case InstallPlanType::ALREADY_INSTALLED:
                            if (install_action->request_type == RequestType::USER_REQUESTED)
                                already_installed_plans.emplace_back(install_action);
                            break;
                        case InstallPlanType::BUILD_AND_INSTALL: new_plans.emplace_back(install_action); break;
                        case InstallPlanType::EXCLUDED: excluded.emplace_back(install_action); break;
                        default: Checks::unreachable(VCPKG_LINE_INFO);
                    }
                }
            }
            else if (auto remove_action = action.remove_action.get())
            {
                remove_plans.emplace_back(remove_action);
            }
        }

        std::sort(remove_plans.begin(), remove_plans.end(), &RemovePlanAction::compare_by_name);
        std::sort(rebuilt_plans.begin(), rebuilt_plans.end(), &InstallPlanAction::compare_by_name);
        std::sort(only_install_plans.begin(), only_install_plans.end(), &InstallPlanAction::compare_by_name);
        std::sort(new_plans.begin(), new_plans.end(), &InstallPlanAction::compare_by_name);
        std::sort(already_installed_plans.begin(), already_installed_plans.end(), &InstallPlanAction::compare_by_name);
        std::sort(excluded.begin(), excluded.end(), &InstallPlanAction::compare_by_name);

        static auto actions_to_output_string = [](const std::vector<const InstallPlanAction*>& v) {
            return Strings::join("\n", v, [](const InstallPlanAction* p) {
                return to_output_string(p->request_type, p->displayname(), p->build_options);
            });
        };

        if (!excluded.empty())
        {
            System::println("The following packages are excluded:\n%s", actions_to_output_string(excluded));
        }

        if (!already_installed_plans.empty())
        {
            System::println("The following packages are already installed:\n%s",
                            actions_to_output_string(already_installed_plans));
        }

        if (!rebuilt_plans.empty())
        {
            System::println("The following packages will be rebuilt:\n%s", actions_to_output_string(rebuilt_plans));
        }

        if (!new_plans.empty())
        {
            System::println("The following packages will be built and installed:\n%s",
                            actions_to_output_string(new_plans));
        }

        if (!only_install_plans.empty())
        {
            System::println("The following packages will be directly installed:\n%s",
                            actions_to_output_string(only_install_plans));
        }

        if (has_non_user_requested_packages)
            System::println("Additional packages (*) will be modified to complete this operation.");

        if (!remove_plans.empty() && !is_recursive)
        {
            System::println(System::Color::warning,
                            "If you are sure you want to rebuild the above packages, run the command with the "
                            "--recurse option");
            Checks::exit_fail(VCPKG_LINE_INFO);
        }
    }
}
