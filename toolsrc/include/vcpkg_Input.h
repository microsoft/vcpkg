#pragma once
#include <vector>
#include <string>
#include "package_spec.h"

namespace vcpkg {namespace Input
{
    package_spec check_and_get_package_spec(const std::string& package_spec_as_string, const triplet& default_target_triplet, const char* example_text);

    std::vector<package_spec> check_and_get_package_specs(const std::vector<std::string>& package_specs_as_strings, const triplet& default_target_triplet, const char* example_text);
}}
