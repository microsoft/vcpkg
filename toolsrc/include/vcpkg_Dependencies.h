#pragma once
#include <vector>
#include "package_spec.h"
#include "StatusParagraphs.h"
#include "vcpkg_paths.h"

namespace vcpkg {namespace Dependencies
{
    enum class install_plan_kind
    {
        BUILD_AND_INSTALL,
        INSTALL,
        ALREADY_INSTALLED
    };

    struct install_plan_action
    {
        install_plan_kind plan;
        std::unique_ptr<BinaryParagraph> bpgh;
        std::unique_ptr<SourceParagraph> spgh;
    };

    struct package_spec_with_install_plan
    {
        package_spec spec;
        install_plan_action install_plan;
    };

    std::vector<package_spec_with_install_plan> create_install_plan(const vcpkg_paths& paths, const std::vector<package_spec>& specs, const StatusParagraphs& status_db);
}}
