#pragma once
#include <vector>
#include "PackageSpec.h"
#include "StatusParagraphs.h"
#include "vcpkg_paths.h"
#include "vcpkg_optional.h"

namespace vcpkg::Dependencies
{
    enum class request_type
    {
        UNKNOWN,
        USER_REQUESTED,
        AUTO_SELECTED
    };

    enum class install_plan_type
    {
        UNKNOWN,
        BUILD_AND_INSTALL,
        INSTALL,
        ALREADY_INSTALLED
    };

    struct install_plan_action
    {
        install_plan_action();
        install_plan_action(const install_plan_type& plan_type, optional<BinaryParagraph> binary_pgh, optional<SourceParagraph> source_pgh);
        install_plan_action(const install_plan_action&) = delete;
        install_plan_action(install_plan_action&&) = default;
        install_plan_action& operator=(const install_plan_action&) = delete;
        install_plan_action& operator=(install_plan_action&&) = default;

        install_plan_type plan_type;
        optional<BinaryParagraph> binary_pgh;
        optional<SourceParagraph> source_pgh;
    };

    struct package_spec_with_install_plan
    {
        package_spec_with_install_plan(const PackageSpec& spec, install_plan_action&& plan);

        PackageSpec spec;
        install_plan_action plan;
    };

    enum class remove_plan_type
    {
        UNKNOWN,
        NOT_INSTALLED,
        REMOVE
    };

    struct remove_plan_action
    {
        remove_plan_action();
        remove_plan_action(const remove_plan_type& plan_type, const request_type& request_type);
        remove_plan_action(const remove_plan_action&) = delete;
        remove_plan_action(remove_plan_action&&) = default;
        remove_plan_action& operator=(const remove_plan_action&) = delete;
        remove_plan_action& operator=(remove_plan_action&&) = default;


        remove_plan_type plan_type;
        request_type request_type;
    };

    struct package_spec_with_remove_plan
    {
        package_spec_with_remove_plan(const PackageSpec& spec, remove_plan_action&& plan);

        PackageSpec spec;
        remove_plan_action plan;
    };

    std::vector<package_spec_with_install_plan> create_install_plan(const vcpkg_paths& paths, const std::vector<PackageSpec>& specs, const StatusParagraphs& status_db);

    std::vector<package_spec_with_remove_plan> create_remove_plan(const std::vector<PackageSpec>& specs, const StatusParagraphs& status_db);
}
