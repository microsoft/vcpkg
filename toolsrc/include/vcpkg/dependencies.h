#pragma once

#include <vcpkg/base/optional.h>
#include <vcpkg/base/util.h>
#include <vcpkg/build.h>
#include <vcpkg/cmakevars.h>
#include <vcpkg/packagespec.h>
#include <vcpkg/portfileprovider.h>
#include <vcpkg/statusparagraphs.h>
#include <vcpkg/vcpkgpaths.h>

#include <functional>
#include <vector>

namespace vcpkg::Graphs
{
    struct Randomizer;
}

namespace vcpkg::Dependencies
{
    enum class RequestType
    {
        UNKNOWN,
        USER_REQUESTED,
        AUTO_SELECTED
    };

    std::string to_output_string(RequestType request_type,
                                 const CStringView s,
                                 const Build::BuildPackageOptions& options);
    std::string to_output_string(RequestType request_type, const CStringView s);

    enum class InstallPlanType
    {
        UNKNOWN,
        BUILD_AND_INSTALL,
        ALREADY_INSTALLED,
        EXCLUDED
    };

    struct InstallPlanAction : Util::MoveOnlyBase
    {
        static bool compare_by_name(const InstallPlanAction* left, const InstallPlanAction* right);

        InstallPlanAction() noexcept;

        InstallPlanAction(InstalledPackageView&& spghs, const RequestType& request_type);

        InstallPlanAction(const PackageSpec& spec,
                          const SourceControlFileLocation& scfl,
                          const RequestType& request_type,
                          std::unordered_map<std::string, std::vector<FeatureSpec>>&& dependencies);

        std::string displayname() const;

        PackageSpec spec;

        Optional<const SourceControlFileLocation&> source_control_file_location;
        Optional<InstalledPackageView> installed_package;

        InstallPlanType plan_type;
        RequestType request_type;
        Build::BuildPackageOptions build_options;

        std::unordered_map<std::string, std::vector<FeatureSpec>> feature_dependencies;
        std::vector<PackageSpec> package_dependencies;

        std::vector<std::string> feature_list;
    };

    enum class RemovePlanType
    {
        UNKNOWN,
        NOT_INSTALLED,
        REMOVE
    };

    struct RemovePlanAction : Util::MoveOnlyBase
    {
        static bool compare_by_name(const RemovePlanAction* left, const RemovePlanAction* right);

        RemovePlanAction() noexcept;
        RemovePlanAction(const PackageSpec& spec, const RemovePlanType& plan_type, const RequestType& request_type);

        PackageSpec spec;
        RemovePlanType plan_type;
        RequestType request_type;
    };

    struct AnyAction
    {
        AnyAction(InstallPlanAction&& iplan) : install_action(std::move(iplan)) {}
        AnyAction(RemovePlanAction&& rplan) : remove_action(std::move(rplan)) {}

        Optional<InstallPlanAction> install_action;
        Optional<RemovePlanAction> remove_action;

        const PackageSpec& spec() const;
    };

    enum class ExportPlanType
    {
        UNKNOWN,
        NOT_BUILT,
        ALREADY_BUILT
    };

    struct ExportPlanAction : Util::MoveOnlyBase
    {
        static bool compare_by_name(const ExportPlanAction* left, const ExportPlanAction* right);

        ExportPlanAction() noexcept;
        ExportPlanAction(const PackageSpec& spec,
                         InstalledPackageView&& installed_package,
                         const RequestType& request_type);

        ExportPlanAction(const PackageSpec& spec, const RequestType& request_type);

        PackageSpec spec;
        ExportPlanType plan_type;
        RequestType request_type;

        Optional<const BinaryParagraph&> core_paragraph() const;
        std::vector<PackageSpec> dependencies(const Triplet& triplet) const;

    private:
        Optional<InstalledPackageView> m_installed_package;
    };

    struct ClusterGraph;
    struct GraphPlan;

    struct CreateInstallPlanOptions
    {
        Graphs::Randomizer* randomizer = nullptr;
    };

    struct PackageGraph
    {
        static std::vector<RemovePlanAction> create_remove_plan(const std::vector<PackageSpec>& specs,
                                                                const StatusParagraphs& status_db);

        static std::vector<ExportPlanAction> create_export_plan(const std::vector<PackageSpec>& specs,
                                                                const StatusParagraphs& status_db);

        /// <summary>Figure out which actions are required to install features specifications in `specs`.</summary>
        /// <param name="provider">Contains the ports of the current environment.</param>
        /// <param name="specs">Feature specifications to resolve dependencies for.</param>
        /// <param name="status_db">Status of installed packages in the current environment.</param>
        static std::vector<AnyAction> create_feature_install_plan(const PortFileProvider::PortFileProvider& provider,
                                                                  const CMakeVars::CMakeVarProvider& var_provider,
                                                                  const std::vector<FullPackageSpec>& specs,
                                                                  const StatusParagraphs& status_db,
                                                                  const CreateInstallPlanOptions& options = {});

        static std::vector<AnyAction> create_upgrade_plan(const PortFileProvider::PortFileProvider& provider,
                                                          const CMakeVars::CMakeVarProvider& var_provider,
                                                          const std::vector<PackageSpec>& specs,
                                                          const StatusParagraphs& status_db,
                                                          const CreateInstallPlanOptions& options = {});

    private:
        PackageGraph(const PortFileProvider::PortFileProvider& provider,
                     const CMakeVars::CMakeVarProvider& var_provider,
                     const StatusParagraphs& status_db);
        ~PackageGraph();

        void install(Span<const FeatureSpec> specs);
        void upgrade(Span<const PackageSpec> specs);
        void mark_user_requested(const PackageSpec& spec);

        std::vector<AnyAction> serialize(const CreateInstallPlanOptions& options = {}) const;

        void graph_removals(const PackageSpec& spec, std::vector<FeatureSpec>& out_reinstall_requirements);
        std::vector<FeatureSpec> graph_installs(const PackageSpec& spec,
                                                const std::vector<FeatureSpec>& new_dependencies);

        const CMakeVars::CMakeVarProvider& m_var_provider;

        std::unique_ptr<GraphPlan> m_graph_plan;
        std::unique_ptr<ClusterGraph> m_graph;
    };

    void print_plan(const std::vector<AnyAction>& action_plan,
                    const bool is_recursive = true,
                    const fs::path& default_ports_dir = "");
}
