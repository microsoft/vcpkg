#pragma once
#include "PackageSpec.h"
#include "StatusParagraphs.h"
#include "VcpkgPaths.h"
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
        Optional<BinaryParagraph> binary_paragraph;
        Optional<SourceParagraph> source_paragraph;
    };

    enum class InstallPlanType
    {
        UNKNOWN,
        BUILD_AND_INSTALL,
        INSTALL,
        ALREADY_INSTALLED
    };

    struct InstallPlanAction
    {
        static bool compare_by_name(const InstallPlanAction* left, const InstallPlanAction* right);

        InstallPlanAction();
        InstallPlanAction(const PackageSpec& spec, const AnyParagraph& any_paragraph, const RequestType& request_type);
        InstallPlanAction(const InstallPlanAction&) = delete;
        InstallPlanAction(InstallPlanAction&&) = default;
        InstallPlanAction& operator=(const InstallPlanAction&) = delete;
        InstallPlanAction& operator=(InstallPlanAction&&) = default;

        PackageSpec spec;
        AnyParagraph any_paragraph;
        InstallPlanType plan_type;
        RequestType request_type;
    };

    enum class RemovePlanType
    {
        UNKNOWN,
        NOT_INSTALLED,
        REMOVE
    };

    struct RemovePlanAction
    {
        static bool compare_by_name(const RemovePlanAction* left, const RemovePlanAction* right);

        RemovePlanAction();
        RemovePlanAction(const PackageSpec& spec, const RemovePlanType& plan_type, const RequestType& request_type);
        RemovePlanAction(const RemovePlanAction&) = delete;
        RemovePlanAction(RemovePlanAction&&) = default;
        RemovePlanAction& operator=(const RemovePlanAction&) = delete;
        RemovePlanAction& operator=(RemovePlanAction&&) = default;

        PackageSpec spec;
        RemovePlanType plan_type;
        RequestType request_type;
    };

    enum class ExportPlanType
    {
        UNKNOWN,
        PORT_AVAILABLE_BUT_NOT_BUILT,
        ALREADY_BUILT
    };

    struct ExportPlanAction
    {
        static bool compare_by_name(const ExportPlanAction* left, const ExportPlanAction* right);

        ExportPlanAction();
        ExportPlanAction(const PackageSpec& spec, const AnyParagraph& any_paragraph, const RequestType& request_type);
        ExportPlanAction(const ExportPlanAction&) = delete;
        ExportPlanAction(ExportPlanAction&&) = default;
        ExportPlanAction& operator=(const ExportPlanAction&) = delete;
        ExportPlanAction& operator=(ExportPlanAction&&) = default;

        PackageSpec spec;
        AnyParagraph any_paragraph;
        ExportPlanType plan_type;
        RequestType request_type;
    };

    __interface PortFileProvider { virtual const SourceControlFile* get_control_file(const PackageSpec& spec) const; };

    struct MapPortFile : PortFileProvider
    {
        const std::unordered_map<PackageSpec, SourceControlFile>& ports;
        explicit MapPortFile(const std::unordered_map<PackageSpec, SourceControlFile>& map);
        const SourceControlFile* get_control_file(const PackageSpec& spec) const override;
    };

    struct PathsPortFile : PortFileProvider
    {
        const VcpkgPaths& ports;
        mutable std::unordered_map<PackageSpec, SourceControlFile> cache;
        explicit PathsPortFile(const VcpkgPaths& paths);
        const SourceControlFile* get_control_file(const PackageSpec& spec) const override;
    };

    std::vector<InstallPlanAction> create_install_plan(const PortFileProvider& port_file_provider,
                                                       const std::vector<PackageSpec>& specs,
                                                       const StatusParagraphs& status_db);

    std::vector<RemovePlanAction> create_remove_plan(const std::vector<PackageSpec>& specs,
                                                     const StatusParagraphs& status_db);

    std::vector<ExportPlanAction> create_export_plan(const VcpkgPaths& paths,
                                                     const std::vector<PackageSpec>& specs,
                                                     const StatusParagraphs& status_db);
}
