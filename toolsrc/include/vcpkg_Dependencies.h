#pragma once
#include <vector>
#include "PackageSpec.h"
#include "StatusParagraphs.h"
#include "VcpkgPaths.h"
#include "vcpkg_optional.h"

namespace vcpkg::Dependencies
{
    struct AnyParagraph
    {
        std::vector<PackageSpec> dependencies(const Triplet& triplet) const;

        Optional<StatusParagraph> status_paragraph;
        Optional<BinaryParagraph> binary_paragraph;
        Optional<SourceParagraph> source_paragraph;
    };

    enum class RequestType
    {
        UNKNOWN,
        USER_REQUESTED,
        AUTO_SELECTED
    };

    std::string to_output_string(RequestType request_type, const CStringView s);

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
        explicit InstallPlanAction(const PackageSpec& spec, const AnyParagraph& any_paragraph, const RequestType& request_type);
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

    struct SpecAndRemovePlanType
    {
        PackageSpec spec;
        RemovePlanType plan_type;
    };

    struct RemovePlanAction
    {
        RemovePlanAction();
        RemovePlanAction(const RemovePlanType& plan_type, const RequestType& request_type);
        RemovePlanAction(const RemovePlanAction&) = delete;
        RemovePlanAction(RemovePlanAction&&) = default;
        RemovePlanAction& operator=(const RemovePlanAction&) = delete;
        RemovePlanAction& operator=(RemovePlanAction&&) = default;

        RemovePlanType plan_type;
        RequestType request_type;
    };

    struct PackageSpecWithRemovePlan
    {
        static bool compare_by_name(const PackageSpecWithRemovePlan* left, const PackageSpecWithRemovePlan* right);

        PackageSpecWithRemovePlan(const PackageSpec& spec, RemovePlanAction&& plan);

        PackageSpec spec;
        RemovePlanAction plan;
    };

    std::vector<InstallPlanAction> create_install_plan(const VcpkgPaths& paths, const std::vector<PackageSpec>& specs, const StatusParagraphs& status_db);

    std::vector<PackageSpecWithRemovePlan> create_remove_plan(const std::vector<PackageSpec>& specs, const StatusParagraphs& status_db);
}
