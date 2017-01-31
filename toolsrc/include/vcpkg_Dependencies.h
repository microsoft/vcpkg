#pragma once
#include <vector>
#include "package_spec.h"
#include "StatusParagraphs.h"
#include "vcpkg_paths.h"
#include "vcpkg_optional.h"

namespace vcpkg::Dependencies
{
    enum class request_type
    {
        USER_REQUESTED,
        AUTO_SELECTED
    };

    enum class install_plan_type
    {
        BUILD_AND_INSTALL,
        INSTALL,
        ALREADY_INSTALLED
    };

    struct install_plan_action
    {
        install_plan_type plan_type;
        optional<BinaryParagraph> binary_pgh;
        optional<SourceParagraph> source_pgh;
    };

    struct package_spec_with_install_plan
    {
        package_spec spec;
        install_plan_action plan;
    };

    enum class remove_plan_type
    {
        NOT_INSTALLED,
        REMOVE
    };

    struct remove_plan_action
    {
        remove_plan_type plan_type;
        request_type request_type;
    };

    struct package_spec_with_remove_plan
    {
        package_spec spec;
        remove_plan_action plan;
    };

    std::vector<package_spec_with_install_plan> create_install_plan(const vcpkg_paths& paths, const std::vector<package_spec>& specs, const StatusParagraphs& status_db);

    std::vector<package_spec_with_remove_plan> create_remove_plan(const vcpkg_paths& paths, const std::vector<package_spec>& specs, const StatusParagraphs& status_db);
}
