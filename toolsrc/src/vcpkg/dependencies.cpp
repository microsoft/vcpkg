#include "pch.h"

#include <vcpkg/base/files.h>
#include <vcpkg/base/graphs.h>
#include <vcpkg/base/strings.h>
#include <vcpkg/base/util.h>
#include <vcpkg/dependencies.h>
#include <vcpkg/packagespec.h>
#include <vcpkg/paragraphs.h>
#include <vcpkg/portfileprovider.h>
#include <vcpkg/statusparagraphs.h>
#include <vcpkg/vcpkglib.h>
#include <vcpkg/vcpkgpaths.h>

using namespace vcpkg;

namespace vcpkg::Dependencies
{
    namespace
    {
        struct ClusterInstalled
        {
            ClusterInstalled(const InstalledPackageView& ipv) : ipv(ipv)
            {
                original_features.emplace("core");
                for (auto&& feature : ipv.features)
                {
                    original_features.emplace(feature->package.feature);
                }
            }

            InstalledPackageView ipv;
            std::unordered_set<PackageSpec> remove_edges;
            std::unordered_set<std::string> original_features;

            // Tracks whether an incoming request has asked for the default features -- on reinstall, add them
            bool defaults_requested = false;
        };

        struct ClusterInstallInfo
        {
            std::unordered_map<std::string, std::vector<FeatureSpec>> build_edges;
            bool defaults_requested = false;
        };

        /// <summary>
        /// Representation of a package and its features in a ClusterGraph.
        /// </summary>
        struct Cluster : Util::MoveOnlyBase
        {
            Cluster(const InstalledPackageView& ipv, const SourceControlFileLocation& scfl)
                : m_spec(ipv.spec()), m_scfl(scfl), m_installed(ipv)
            {
            }

            Cluster(const PackageSpec& spec, const SourceControlFileLocation& scfl) : m_spec(spec), m_scfl(scfl) {}

            bool has_feature_installed(const std::string& feature) const
            {
                if (const ClusterInstalled* inst = m_installed.get())
                {
                    return inst->original_features.find(feature) != inst->original_features.end();
                }
                return false;
            }

            bool has_defaults_installed() const
            {
                if (const ClusterInstalled* inst = m_installed.get())
                {
                    return std::all_of(inst->ipv.core->package.default_features.begin(),
                                       inst->ipv.core->package.default_features.end(),
                                       [&](const std::string& feature) {
                                           return inst->original_features.find(feature) !=
                                                  inst->original_features.end();
                                       });
                }
                return false;
            }

            // Returns dependencies which were added as a result of this call.
            // Precondition: must have called "mark_for_reinstall()" or "create_install_info()" on this cluster
            void add_feature(const std::string& feature,
                             const CMakeVars::CMakeVarProvider& var_provider,
                             std::vector<FeatureSpec>& out_new_dependencies)
            {
                ClusterInstallInfo& info = m_install_info.value_or_exit(VCPKG_LINE_INFO);
                if (feature == "default")
                {
                    if (!info.defaults_requested)
                    {
                        info.defaults_requested = true;
                        for (auto&& f : m_scfl.source_control_file->core_paragraph->default_features)
                            out_new_dependencies.emplace_back(m_spec, f);
                    }
                    return;
                }

                if (Util::Sets::contains(info.build_edges, feature))
                {
                    // This feature has already been completely handled
                    return;
                }
                auto maybe_vars = var_provider.get_dep_info_vars(m_spec);
                const std::vector<Dependency>* qualified_deps =
                    &m_scfl.source_control_file->find_dependencies_for_feature(feature).value_or_exit(VCPKG_LINE_INFO);

                std::vector<FeatureSpec> dep_list;
                if (maybe_vars)
                {
                    // Qualified dependency resolution is available
                    auto fullspec_list = filter_dependencies(
                        *qualified_deps, m_spec.triplet(), maybe_vars.value_or_exit(VCPKG_LINE_INFO));

                    for (auto&& fspec : fullspec_list)
                    {
                        // TODO: this is incorrect and does not handle default features nor "*"
                        Util::Vectors::append(&dep_list, fspec.to_feature_specs({"default"}, {}));
                    }

                    Util::sort_unique_erase(dep_list);
                    info.build_edges.emplace(feature, dep_list);
                }
                else
                {
                    bool requires_qualified_resolution = false;
                    for (const Dependency& dep : *qualified_deps)
                    {
                        if (dep.qualifier.empty())
                        {
                            Util::Vectors::append(
                                &dep_list,
                                FullPackageSpec(PackageSpec::from_name_and_triplet(dep.depend.name, m_spec.triplet())
                                                    .value_or_exit(VCPKG_LINE_INFO),
                                                dep.depend.features)
                                    .to_feature_specs({"default"}, {}));
                        }
                        else
                        {
                            requires_qualified_resolution = true;
                        }
                    }
                    Util::sort_unique_erase(dep_list);
                    if (!requires_qualified_resolution)
                    {
                        info.build_edges.emplace(feature, dep_list);
                    }
                }
                Util::Vectors::append(&out_new_dependencies, dep_list);
            }

            void create_install_info(std::vector<FeatureSpec>& out_reinstall_requirements)
            {
                bool defaults_requested = false;
                if (const ClusterInstalled* inst = m_installed.get())
                {
                    for (const std::string& installed_feature : inst->original_features)
                    {
                        out_reinstall_requirements.emplace_back(m_spec, installed_feature);
                    }
                    defaults_requested = inst->defaults_requested;
                }

                Checks::check_exit(VCPKG_LINE_INFO, !m_install_info.has_value());
                m_install_info = make_optional(ClusterInstallInfo{});

                if (defaults_requested)
                {
                    for (auto&& def_feature : m_scfl.source_control_file->core_paragraph->default_features)
                        out_reinstall_requirements.emplace_back(m_spec, def_feature);
                }
                else if (request_type != RequestType::USER_REQUESTED)
                {
                    // If the user did not explicitly request this installation, we need to add all new default features
                    auto&& new_defaults = m_scfl.source_control_file->core_paragraph->default_features;
                    std::set<std::string> defaults_set{new_defaults.begin(), new_defaults.end()};

                    // Install only features that were not previously available
                    if (auto p_inst = m_installed.get())
                    {
                        for (auto&& prev_default : p_inst->ipv.core->package.default_features)
                        {
                            defaults_set.erase(prev_default);
                        }
                    }

                    for (const std::string& feature : defaults_set)
                    {
                        // Instead of dealing with adding default features to each of our dependencies right
                        // away we just defer to the next pass of the loop.
                        out_reinstall_requirements.emplace_back(m_spec, feature);
                    }
                }
            }

            PackageSpec m_spec;
            const SourceControlFileLocation& m_scfl;

            Optional<ClusterInstalled> m_installed;
            Optional<ClusterInstallInfo> m_install_info;

            RequestType request_type = RequestType::AUTO_SELECTED;
        };

        struct PackageGraph
        {
            PackageGraph(const PortFileProvider::PortFileProvider& provider,
                         const CMakeVars::CMakeVarProvider& var_provider,
                         const StatusParagraphs& status_db);
            ~PackageGraph();

            void install(Span<const FeatureSpec> specs);
            void upgrade(Span<const PackageSpec> specs);
            void mark_user_requested(const PackageSpec& spec);

            ActionPlan serialize(const CreateInstallPlanOptions& options = {}) const;

            void mark_for_reinstall(const PackageSpec& spec, std::vector<FeatureSpec>& out_reinstall_requirements);
            const CMakeVars::CMakeVarProvider& m_var_provider;

            std::unique_ptr<ClusterGraph> m_graph;
        };

    }

    /// <summary>
    /// Directional graph representing a collection of packages with their features connected by their dependencies.
    /// </summary>
    struct ClusterGraph : Util::MoveOnlyBase
    {
        explicit ClusterGraph(const PortFileProvider::PortFileProvider& port_provider) : m_port_provider(port_provider)
        {
        }

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
                const SourceControlFileLocation* scfl = m_port_provider.get_control_file(spec.name()).get();

                Checks::check_exit(
                    VCPKG_LINE_INFO, scfl, "Error: Cannot find definition for package `%s`.", spec.name());

                return m_graph
                    .emplace(std::piecewise_construct, std::forward_as_tuple(spec), std::forward_as_tuple(spec, *scfl))
                    .first->second;
            }

            return it->second;
        }

        Cluster& get(const InstalledPackageView& ipv)
        {
            auto it = m_graph.find(ipv.spec());

            if (it == m_graph.end())
            {
                Optional<const SourceControlFileLocation&> maybe_scfl =
                    m_port_provider.get_control_file(ipv.spec().name());

                if (!maybe_scfl)
                    Checks::exit_with_message(
                        VCPKG_LINE_INFO,
                        "We could not find a CONTROL file for '%s'. Please run \"vcpkg remove %s\" and re-attempt.",
                        ipv.spec().to_string(),
                        ipv.spec().to_string());

                return m_graph
                    .emplace(std::piecewise_construct,
                             std::forward_as_tuple(ipv.spec()),
                             std::forward_as_tuple(ipv, *maybe_scfl.get()))
                    .first->second;
            }

            if (!it->second.m_installed)
            {
                it->second.m_installed = {ipv};
            }

            return it->second;
        }

        const Cluster& find_or_exit(const PackageSpec& spec, LineInfo linfo) const
        {
            auto it = m_graph.find(spec);
            Checks::check_exit(linfo, it != m_graph.end(), "Failed to locate spec in graph");
            return it->second;
        }

        auto begin() const { return m_graph.begin(); }
        auto end() const { return m_graph.end(); }

    private:
        std::unordered_map<PackageSpec, Cluster> m_graph;
        const PortFileProvider::PortFileProvider& m_port_provider;
    };

    static std::string to_output_string(RequestType request_type,
                                        const CStringView s,
                                        const Build::BuildPackageOptions& options,
                                        const fs::path& install_port_path,
                                        const fs::path& default_port_path)
    {
        if (!default_port_path.empty() &&
            !Strings::case_insensitive_ascii_starts_with(install_port_path.u8string(), default_port_path.u8string()))
        {
            const char* const from_head = options.use_head_version == Build::UseHeadVersion::YES ? " (from HEAD)" : "";
            switch (request_type)
            {
                case RequestType::AUTO_SELECTED:
                    return Strings::format("  * %s%s -- %s", s, from_head, install_port_path.u8string());
                case RequestType::USER_REQUESTED:
                    return Strings::format("    %s%s -- %s", s, from_head, install_port_path.u8string());
                default: Checks::unreachable(VCPKG_LINE_INFO);
            }
        }
        return to_output_string(request_type, s, options);
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

    InstallPlanAction::InstallPlanAction() noexcept
        : plan_type(InstallPlanType::UNKNOWN), request_type(RequestType::UNKNOWN), build_options{}
    {
    }

    InstallPlanAction::InstallPlanAction(const PackageSpec& spec,
                                         const SourceControlFileLocation& scfl,
                                         const RequestType& request_type,
                                         std::unordered_map<std::string, std::vector<FeatureSpec>>&& dependencies)
        : spec(spec)
        , source_control_file_location(scfl)
        , plan_type(InstallPlanType::BUILD_AND_INSTALL)
        , request_type(request_type)
        , build_options{}
        , feature_dependencies(std::move(dependencies))
    {
        for (const auto& kv : feature_dependencies)
        {
            feature_list.emplace_back(kv.first);
            for (const FeatureSpec& fspec : kv.second)
            {
                if (spec != fspec.spec())
                {
                    package_dependencies.emplace_back(fspec.spec());
                }
            }
        }

        Util::sort_unique_erase(package_dependencies);
        Util::sort_unique_erase(feature_list);
    }

    InstallPlanAction::InstallPlanAction(InstalledPackageView&& ipv, const RequestType& request_type)
        : spec(ipv.spec())
        , installed_package(std::move(ipv))
        , plan_type(InstallPlanType::ALREADY_INSTALLED)
        , request_type(request_type)
        , build_options{}
        , feature_dependencies(installed_package.get()->feature_dependencies())
        , package_dependencies(installed_package.get()->dependencies())
    {
        for (const auto& kv : feature_dependencies)
        {
            feature_list.emplace_back(kv.first);
        }
    }

    std::string InstallPlanAction::displayname() const
    {
        if (this->feature_list.empty())
        {
            return this->spec.to_string();
        }

        const std::string features = Strings::join(",", feature_list);
        return Strings::format("%s[%s]:%s", this->spec.name(), features, this->spec.triplet());
    }

    bool InstallPlanAction::compare_by_name(const InstallPlanAction* left, const InstallPlanAction* right)
    {
        return left->spec.name() < right->spec.name();
    }

    RemovePlanAction::RemovePlanAction() noexcept
        : plan_type(RemovePlanType::UNKNOWN), request_type(RequestType::UNKNOWN)
    {
    }

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

    ExportPlanAction::ExportPlanAction() noexcept
        : plan_type(ExportPlanType::UNKNOWN), request_type(RequestType::UNKNOWN)
    {
    }

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

    std::vector<RemovePlanAction> create_remove_plan(const std::vector<PackageSpec>& specs,
                                                     const StatusParagraphs& status_db)
    {
        struct RemoveAdjacencyProvider final : Graphs::AdjacencyProvider<PackageSpec, RemovePlanAction>
        {
            const StatusParagraphs& status_db;
            const std::vector<InstalledPackageView>& installed_ports;
            const std::unordered_set<PackageSpec>& specs_as_set;

            RemoveAdjacencyProvider(const StatusParagraphs& status_db,
                                    const std::vector<InstalledPackageView>& installed_ports,
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
                for (auto&& ipv : installed_ports)
                {
                    auto deps = ipv.dependencies();

                    if (std::find(deps.begin(), deps.end(), spec) == deps.end()) continue;

                    dependents.push_back(ipv.spec());
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

        auto installed_ports = get_installed_ports(status_db);
        const std::unordered_set<PackageSpec> specs_as_set(specs.cbegin(), specs.cend());
        return Graphs::topological_sort(
            std::move(specs), RemoveAdjacencyProvider{status_db, installed_ports, specs_as_set}, {});
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
            Graphs::topological_sort(specs, ExportAdjacencyProvider{status_db, specs_as_set}, {});
        return toposort;
    }

    void PackageGraph::mark_user_requested(const PackageSpec& spec)
    {
        m_graph->get(spec).request_type = RequestType::USER_REQUESTED;
    }

    ActionPlan create_feature_install_plan(const PortFileProvider::PortFileProvider& port_provider,
                                           const CMakeVars::CMakeVarProvider& var_provider,
                                           const std::vector<FullPackageSpec>& specs,
                                           const StatusParagraphs& status_db,
                                           const CreateInstallPlanOptions& options)
    {
        PackageGraph pgraph(port_provider, var_provider, status_db);

        std::vector<FeatureSpec> feature_specs;
        for (const FullPackageSpec& spec : specs)
        {
            const SourceControlFileLocation* scfl = port_provider.get_control_file(spec.package_spec.name()).get();

            Checks::check_exit(
                VCPKG_LINE_INFO, scfl, "Error: Cannot find definition for package `%s`.", spec.package_spec.name());

            const std::vector<std::string> all_features =
                Util::fmap(scfl->source_control_file->feature_paragraphs,
                           [](auto&& feature_paragraph) { return feature_paragraph->name; });

            auto fspecs =
                spec.to_feature_specs(scfl->source_control_file->core_paragraph->default_features, all_features);
            feature_specs.insert(
                feature_specs.end(), std::make_move_iterator(fspecs.begin()), std::make_move_iterator(fspecs.end()));
        }
        Util::sort_unique_erase(feature_specs);

        for (const FeatureSpec& spec : feature_specs)
        {
            pgraph.mark_user_requested(spec.spec());
        }
        pgraph.install(feature_specs);

        return pgraph.serialize(options);
    }

    void PackageGraph::mark_for_reinstall(const PackageSpec& first_remove_spec,
                                          std::vector<FeatureSpec>& out_reinstall_requirements)
    {
        std::set<PackageSpec> removed;
        std::vector<PackageSpec> to_remove{first_remove_spec};

        while (!to_remove.empty())
        {
            PackageSpec remove_spec = std::move(to_remove.back());
            to_remove.pop_back();

            if (!removed.insert(remove_spec).second) continue;

            Cluster& clust = m_graph->get(remove_spec);
            ClusterInstalled& info = clust.m_installed.value_or_exit(VCPKG_LINE_INFO);

            if (!clust.m_install_info)
            {
                clust.create_install_info(out_reinstall_requirements);
            }

            to_remove.insert(to_remove.end(), info.remove_edges.begin(), info.remove_edges.end());
        }
    }

    /// The list of specs to install should already have default features expanded
    void PackageGraph::install(Span<const FeatureSpec> specs)
    {
        // We batch resolving qualified dependencies, because it's an invocation of CMake which
        // takes ~150ms per call.
        std::vector<FeatureSpec> qualified_dependencies;
        std::vector<FeatureSpec> next_dependencies{specs.begin(), specs.end()};

        // Keep running while there is any chance of finding more dependencies
        while (!next_dependencies.empty())
        {
            // Keep running until the only dependencies left are qualified
            while (!next_dependencies.empty())
            {
                // Extract the top of the stack
                FeatureSpec spec = std::move(next_dependencies.back());
                next_dependencies.pop_back();

                // Get the cluster for the PackageSpec of the FeatureSpec we are adding to the install graph
                Cluster& clust = m_graph->get(spec.spec());

                // If this spec hasn't already had its qualified dependencies resolved
                if (!m_var_provider.get_dep_info_vars(spec.spec()).has_value())
                {
                    // TODO: There's always the chance that we don't find the feature we're looking for (probably a
                    // malformed CONTROL file somewhere). We should probably output a better error.
                    const std::vector<Dependency>* paragraph_depends = nullptr;
                    if (spec.feature() == "core")
                    {
                        paragraph_depends = &clust.m_scfl.source_control_file->core_paragraph->depends;
                    }
                    else if (spec.feature() == "default")
                    {
                    }
                    else
                    {
                        auto maybe_paragraph = clust.m_scfl.source_control_file->find_feature(spec.feature());
                        Checks::check_exit(VCPKG_LINE_INFO,
                                           maybe_paragraph.has_value(),
                                           "Package %s does not have a %s feature",
                                           spec.name(),
                                           spec.feature());
                        paragraph_depends = &maybe_paragraph.value_or_exit(VCPKG_LINE_INFO).depends;
                    }

                    // And it has at least one qualified dependency
                    if (paragraph_depends &&
                        Util::any_of(*paragraph_depends, [](auto&& dep) { return !dep.qualifier.empty(); }))
                    {
                        // Add it to the next batch run
                        qualified_dependencies.emplace_back(spec);
                    }
                }

                if (clust.m_install_info.has_value())
                {
                    clust.add_feature(spec.feature(), m_var_provider, next_dependencies);
                }
                else
                {
                    if (!clust.m_installed.has_value())
                    {
                        clust.create_install_info(next_dependencies);
                        clust.add_feature(spec.feature(), m_var_provider, next_dependencies);
                    }
                    else
                    {
                        if (spec.feature() == "default")
                        {
                            if (!clust.m_installed.get()->defaults_requested)
                            {
                                clust.m_installed.get()->defaults_requested = true;
                                if (!clust.has_defaults_installed())
                                {
                                    mark_for_reinstall(spec.spec(), next_dependencies);
                                }
                            }
                        }
                        else if (!clust.has_feature_installed(spec.feature()))
                        {
                            // If install_info is not present and it is already installed, we have never added a feature
                            // which hasn't already been installed to this cluster. In this case, we need to reinstall
                            // the port if the feature isn't already present.
                            mark_for_reinstall(spec.spec(), next_dependencies);
                            clust.add_feature(spec.feature(), m_var_provider, next_dependencies);
                        }
                    }
                }
            }

            if (!qualified_dependencies.empty())
            {
                Util::sort_unique_erase(qualified_dependencies);

                // Extract the package specs we need to get dependency info from. We don't run the triplet on a per
                // feature basis. We run it once for the whole port.
                auto qualified_package_specs =
                    Util::fmap(qualified_dependencies, [](const FeatureSpec& fspec) { return fspec.spec(); });
                Util::sort_unique_erase(qualified_package_specs);
                m_var_provider.load_dep_info_vars(qualified_package_specs);

                // Put all the FeatureSpecs for which we had qualified dependencies back on the dependencies stack.
                // We need to recheck if evaluating the triplet revealed any new dependencies.
                next_dependencies.insert(next_dependencies.end(),
                                         std::make_move_iterator(qualified_dependencies.begin()),
                                         std::make_move_iterator(qualified_dependencies.end()));
                qualified_dependencies.clear();
            }
        }
    }

    void PackageGraph::upgrade(Span<const PackageSpec> specs)
    {
        std::vector<FeatureSpec> reinstall_reqs;

        for (const PackageSpec& spec : specs)
            mark_for_reinstall(spec, reinstall_reqs);

        Util::sort_unique_erase(reinstall_reqs);

        install(reinstall_reqs);
    }

    ActionPlan create_upgrade_plan(const PortFileProvider::PortFileProvider& port_provider,
                                   const CMakeVars::CMakeVarProvider& var_provider,
                                   const std::vector<PackageSpec>& specs,
                                   const StatusParagraphs& status_db,
                                   const CreateInstallPlanOptions& options)
    {
        PackageGraph pgraph(port_provider, var_provider, status_db);

        pgraph.upgrade(specs);

        return pgraph.serialize(options);
    }

    ActionPlan PackageGraph::serialize(const CreateInstallPlanOptions& options) const
    {
        struct BaseEdgeProvider : Graphs::AdjacencyProvider<PackageSpec, const Cluster*>
        {
            BaseEdgeProvider(const ClusterGraph& parent) : m_parent(parent) {}

            std::string to_string(const PackageSpec& spec) const override { return spec.to_string(); }
            const Cluster* load_vertex_data(const PackageSpec& spec) const override
            {
                return &m_parent.find_or_exit(spec, VCPKG_LINE_INFO);
            }

            const ClusterGraph& m_parent;
        };

        struct RemoveEdgeProvider final : BaseEdgeProvider
        {
            using BaseEdgeProvider::BaseEdgeProvider;

            std::vector<PackageSpec> adjacency_list(const Cluster* const& vertex) const override
            {
                auto&& set = vertex->m_installed.value_or_exit(VCPKG_LINE_INFO).remove_edges;
                return {set.begin(), set.end()};
            }
        } removeedgeprovider(*m_graph);

        struct InstallEdgeProvider final : BaseEdgeProvider
        {
            using BaseEdgeProvider::BaseEdgeProvider;

            std::vector<PackageSpec> adjacency_list(const Cluster* const& vertex) const override
            {
                if (!vertex->m_install_info.has_value()) return {};

                auto& info = vertex->m_install_info.value_or_exit(VCPKG_LINE_INFO);
                std::vector<PackageSpec> deps;
                for (auto&& kv : info.build_edges)
                    for (auto&& e : kv.second)
                    {
                        auto spec = e.spec();
                        if (spec != vertex->m_spec) deps.push_back(std::move(spec));
                    }
                Util::sort_unique_erase(deps);
                return deps;
            }
        } installedgeprovider(*m_graph);

        std::vector<PackageSpec> removed_vertices;
        std::vector<PackageSpec> installed_vertices;
        for (auto&& kv : *m_graph)
        {
            if (kv.second.m_install_info.has_value() && kv.second.m_installed.has_value())
            {
                removed_vertices.push_back(kv.first);
            }
            if (kv.second.m_install_info.has_value() || kv.second.request_type == RequestType::USER_REQUESTED)
            {
                installed_vertices.push_back(kv.first);
            }
        }
        auto remove_toposort = Graphs::topological_sort(removed_vertices, removeedgeprovider, options.randomizer);
        auto insert_toposort = Graphs::topological_sort(installed_vertices, installedgeprovider, options.randomizer);

        ActionPlan plan;

        for (auto&& p_cluster : remove_toposort)
        {
            plan.remove_actions.emplace_back(p_cluster->m_spec, RemovePlanType::REMOVE, p_cluster->request_type);
        }

        for (auto&& p_cluster : insert_toposort)
        {
            // Every cluster that has an install_info needs to be built
            // If a cluster only has an installed object and is marked as user requested we should still report it.
            if (auto info_ptr = p_cluster->m_install_info.get())
            {
                auto&& scfl = p_cluster->m_scfl;

                std::unordered_map<std::string, std::vector<FeatureSpec>> computed_edges;
                for (auto&& kv : info_ptr->build_edges)
                {
                    std::set<FeatureSpec> fspecs;
                    for (auto&& fspec : kv.second)
                    {
                        if (fspec.feature() != "default")
                        {
                            fspecs.insert(fspec);
                            continue;
                        }
                        auto&& dep_clust = m_graph->get(fspec.spec());
                        const auto& default_features = [&] {
                            if (dep_clust.m_install_info.has_value())
                                return dep_clust.m_scfl.source_control_file->core_paragraph->default_features;
                            if (auto p = dep_clust.m_installed.get()) return p->ipv.core->package.default_features;
                            Checks::unreachable(VCPKG_LINE_INFO);
                        }();
                        for (auto&& default_feature : default_features)
                            fspecs.emplace(fspec.spec(), default_feature);
                    }
                    computed_edges[kv.first].assign(fspecs.begin(), fspecs.end());
                }

                plan.install_actions.emplace_back(
                    p_cluster->m_spec, scfl, p_cluster->request_type, std::move(computed_edges));
            }
            else if (p_cluster->request_type == RequestType::USER_REQUESTED && p_cluster->m_installed.has_value())
            {
                auto&& installed = p_cluster->m_installed.value_or_exit(VCPKG_LINE_INFO);
                plan.already_installed.emplace_back(Util::copy(installed.ipv), p_cluster->request_type);
            }
        }

        return plan;
    }

    static std::unique_ptr<ClusterGraph> create_feature_install_graph(
        const PortFileProvider::PortFileProvider& port_provider, const StatusParagraphs& status_db)
    {
        std::unique_ptr<ClusterGraph> graph = std::make_unique<ClusterGraph>(port_provider);

        auto installed_ports = get_installed_ports(status_db);

        for (auto&& ipv : installed_ports)
        {
            graph->get(ipv);
        }

        // Populate the graph with "remove edges", which are the reverse of the Build-Depends edges.
        for (auto&& ipv : installed_ports)
        {
            auto deps = ipv.dependencies();

            for (auto&& dep : deps)
            {
                auto p_installed = graph->get(dep).m_installed.get();
                Checks::check_exit(VCPKG_LINE_INFO,
                                   p_installed,
                                   "Error: database corrupted. Package %s is installed but dependency %s is not.",
                                   ipv.spec(),
                                   dep);
                p_installed->remove_edges.emplace(ipv.spec());
            }
        }
        return graph;
    }

    PackageGraph::PackageGraph(const PortFileProvider::PortFileProvider& port_provider,
                               const CMakeVars::CMakeVarProvider& var_provider,
                               const StatusParagraphs& status_db)
        : m_var_provider(var_provider), m_graph(create_feature_install_graph(port_provider, status_db))
    {
    }

    PackageGraph::~PackageGraph() = default;

    void print_plan(const ActionPlan& action_plan, const bool is_recursive, const fs::path& default_ports_dir)
    {
        std::vector<const RemovePlanAction*> remove_plans;
        std::vector<const InstallPlanAction*> rebuilt_plans;
        std::vector<const InstallPlanAction*> only_install_plans;
        std::vector<const InstallPlanAction*> new_plans;
        std::vector<const InstallPlanAction*> already_installed_plans;
        std::vector<const InstallPlanAction*> excluded;

        const bool has_non_user_requested_packages =
            Util::find_if(action_plan.install_actions, [](const InstallPlanAction& action) -> bool {
                return action.request_type != RequestType::USER_REQUESTED;
            }) != action_plan.install_actions.cend();

        for (auto&& remove_action : action_plan.remove_actions)
        {
            remove_plans.emplace_back(&remove_action);
        }
        for (auto&& install_action : action_plan.install_actions)
        {
            // remove plans are guaranteed to come before install plans, so we know the plan will be contained
            // if at all.
            auto it = Util::find_if(remove_plans,
                                    [&](const RemovePlanAction* plan) { return plan->spec == install_action.spec; });
            if (it != remove_plans.end())
            {
                rebuilt_plans.push_back(&install_action);
            }
            else
            {
                if (install_action.plan_type == InstallPlanType::EXCLUDED)
                    excluded.push_back(&install_action);
                else
                    new_plans.push_back(&install_action);
            }
        }
        for (auto&& action : action_plan.already_installed)
        {
            if (action.request_type == RequestType::USER_REQUESTED) already_installed_plans.emplace_back(&action);
        }
        already_installed_plans = Util::fmap(action_plan.already_installed, [](auto&& action) { return &action; });

        std::sort(remove_plans.begin(), remove_plans.end(), &RemovePlanAction::compare_by_name);
        std::sort(rebuilt_plans.begin(), rebuilt_plans.end(), &InstallPlanAction::compare_by_name);
        std::sort(only_install_plans.begin(), only_install_plans.end(), &InstallPlanAction::compare_by_name);
        std::sort(new_plans.begin(), new_plans.end(), &InstallPlanAction::compare_by_name);
        std::sort(already_installed_plans.begin(), already_installed_plans.end(), &InstallPlanAction::compare_by_name);
        std::sort(excluded.begin(), excluded.end(), &InstallPlanAction::compare_by_name);

        static auto actions_to_output_string = [&](const std::vector<const InstallPlanAction*>& v) {
            return Strings::join("\n", v, [&](const InstallPlanAction* p) {
                if (auto* pscfl = p->source_control_file_location.get())
                {
                    return to_output_string(
                        p->request_type, p->displayname(), p->build_options, pscfl->source_location, default_ports_dir);
                }

                return to_output_string(p->request_type, p->displayname(), p->build_options);
            });
        };

        if (!excluded.empty())
        {
            System::print2("The following packages are excluded:\n", actions_to_output_string(excluded), '\n');
        }

        if (!already_installed_plans.empty())
        {
            System::print2("The following packages are already installed:\n",
                           actions_to_output_string(already_installed_plans),
                           '\n');
        }

        if (!rebuilt_plans.empty())
        {
            System::print2("The following packages will be rebuilt:\n", actions_to_output_string(rebuilt_plans), '\n');
        }

        if (!new_plans.empty())
        {
            System::print2(
                "The following packages will be built and installed:\n", actions_to_output_string(new_plans), '\n');
        }

        if (!only_install_plans.empty())
        {
            System::print2("The following packages will be directly installed:\n",
                           actions_to_output_string(only_install_plans),
                           '\n');
        }

        if (has_non_user_requested_packages)
            System::print2("Additional packages (*) will be modified to complete this operation.\n");

        if (!remove_plans.empty() && !is_recursive)
        {
            System::print2(System::Color::warning,
                           "If you are sure you want to rebuild the above packages, run the command with the "
                           "--recurse option\n");
            Checks::exit_fail(VCPKG_LINE_INFO);
        }
    }
}
