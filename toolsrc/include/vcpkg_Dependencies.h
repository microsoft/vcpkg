#pragma once
#include <vector>
#include "package_spec.h"
#include "StatusParagraphs.h"
#include <unordered_set>
#include "vcpkg_paths.h"

namespace vcpkg {namespace Dependencies
{
    std::vector<package_spec> create_dependency_ordered_install_plan(const vcpkg_paths& paths, const std::vector<package_spec>& specs, const StatusParagraphs& status_db);

    std::unordered_set<package_spec> find_unmet_dependencies(const vcpkg_paths& paths, const std::vector<package_spec>& specs, const StatusParagraphs& status_db);
}}
