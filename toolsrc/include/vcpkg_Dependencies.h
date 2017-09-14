#pragma once
#include "PackageSpec.h"
#include "StatusParagraphs.h"
#include "VcpkgPaths.h"
#include "vcpkg_Graphs.h"
#include "vcpkg_Util.h"
#include "vcpkg_optional.h"
#include <vector>

namespace vcpkg::Dependencies
{
    enum class RequestType
    {
        UNKNOWN,
        USER_REQUESTED,
        AUTO_SELECTED
    };

    std::string to_output_string(RequestType request_type, const CStringView s);

    struct AnyParagraph
    {
        std::vector<PackageSpec> dependencies(const Triplet& triplet) const;

        Optional<StatusParagraph> status_paragraph;
        Optional<BinaryControlFile> binary_control_file;
        Optional<SourceParagraph> source_paragraph;
        Optional<const SourceControlFile*> source_control_file;
    };
}

namespace vcpkg::Dependencies
{
    enum class InstallPlanType
    {
        UNKNOWN,
        BUILD_AND_INSTALL,
        INSTALL,
        ALREADY_INSTALLED
    };

    struct InstallPlanAction : Util::MoveOnlyBase
    {
        static bool compare_by_name(const InstallPlanAction* left, const InstallPlanAction* right);

        InstallPlanAction();

        InstallPlanAction(const PackageSpec& spec,
                          const std::unordered_set<std::string>& features,
                          const RequestType& request_type);
        InstallPlanAction(const PackageSpec& spec, const AnyParagraph& any_paragraph, const RequestType& request_type);
        InstallPlanAction(const PackageSpec& spec,
                          const SourceControlFile& any_paragraph,
                          const std::unordered_set<std::string>& features,
                          const RequestType& request_type);

        std::string displayname() const;

        PackageSpec spec;
        AnyParagraph any_paragraph;
        InstallPlanType plan_type;
        RequestType request_type;
        std::unordered_set<std::string> feature_list;
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

        RemovePlanAction();
        RemovePlanAction(const PackageSpec& spec, const RemovePlanType& plan_type, const RequestType& request_type);

        PackageSpec spec;
        RemovePlanType plan_type;
        RequestType request_type;
    };

    struct AnyAction
    {
        AnyAction(InstallPlanAction&& iplan) : install_plan(std::move(iplan)) {}
        AnyAction(RemovePlanAction&& rplan) : remove_plan(std::move(rplan)) {}

        Optional<InstallPlanAction> install_plan;
        Optional<RemovePlanAction> remove_plan;

        const PackageSpec& spec() const;
    };

    enum class ExportPlanType
    {
        UNKNOWN,
        PORT_AVAILABLE_BUT_NOT_BUILT,
        ALREADY_BUILT
    };

    struct ExportPlanAction : Util::MoveOnlyBase
    {
        static bool compare_by_name(const ExportPlanAction* left, const ExportPlanAction* right);

        ExportPlanAction();
        ExportPlanAction(const PackageSpec& spec, const AnyParagraph& any_paragraph, const RequestType& request_type);

        PackageSpec spec;
        AnyParagraph any_paragraph;
        ExportPlanType plan_type;
        RequestType request_type;
    };

    __interface PortFileProvider { virtual const SourceControlFile& get_control_file(const std::string& spec) const; };

    struct MapPortFile : Util::ResourceBase, PortFileProvider
    {
        const std::unordered_map<std::string, SourceControlFile>& ports;
        explicit MapPortFile(const std::unordered_map<std::string, SourceControlFile>& map);
        const SourceControlFile& get_control_file(const std::string& spec) const override;
    };

    struct PathsPortFile : Util::ResourceBase, PortFileProvider
    {
        const VcpkgPaths& ports;
        mutable std::unordered_map<std::string, SourceControlFile> cache;
        explicit PathsPortFile(const VcpkgPaths& paths);
        const SourceControlFile& get_control_file(const std::string& spec) const override;
    };

    std::vector<InstallPlanAction> create_install_plan(const PortFileProvider& port_file_provider,
                                                       const std::vector<PackageSpec>& specs,
                                                       const StatusParagraphs& status_db);

    std::vector<RemovePlanAction> create_remove_plan(const std::vector<PackageSpec>& specs,
                                                     const StatusParagraphs& status_db);

    std::vector<ExportPlanAction> create_export_plan(const VcpkgPaths& paths,
                                                     const std::vector<PackageSpec>& specs,
                                                     const StatusParagraphs& status_db);

    std::vector<AnyAction> create_feature_install_plan(const std::unordered_map<std::string, SourceControlFile>& map,
                                                       const std::vector<FeatureSpec>& specs,
                                                       const StatusParagraphs& status_db);
}
