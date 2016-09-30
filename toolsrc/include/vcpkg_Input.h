#pragma once
#include <vector>
#include "package_spec.h"
#include "vcpkg_paths.h"

namespace vcpkg {namespace Input
{
    package_spec check_and_get_package_spec(const std::string& package_spec_as_string, const triplet& default_target_triplet, const char* example_text);

    std::vector<package_spec> check_and_get_package_specs(const std::vector<std::string>& package_specs_as_strings, const triplet& default_target_triplet, const char* example_text);

    void check_triplet(const triplet& t, const vcpkg_paths& paths);
}}
