#include "vcpkg_Input.h"
#include "vcpkg_System.h"
#include "metrics.h"
#include "vcpkg_Commands.h"

namespace vcpkg {namespace Input
{
    package_spec check_and_get_package_spec(const std::string& package_spec_as_string, const triplet& default_target_triplet, const char* example_text)
    {
        expected<package_spec> expected_spec = package_spec::from_string(package_spec_as_string, default_target_triplet);
        if (auto spec = expected_spec.get())
        {
            return *spec;
        }

        System::println(System::color::error, "Error: %s: %s", expected_spec.error_code().message(), package_spec_as_string);
        System::print(example_text);
        exit(EXIT_FAILURE);
    }

    std::vector<package_spec> check_and_get_package_specs(const std::vector<std::string>& package_specs_as_strings, const triplet& default_target_triplet, const char* example_text)
    {
        std::vector<package_spec> specs;
        for (const std::string& spec : package_specs_as_strings)
        {
            specs.push_back(check_and_get_package_spec(spec, default_target_triplet, example_text));
        }

        return specs;
    }

    void check_triplet(const triplet& t, const vcpkg_paths& paths)
    {
        if (!paths.is_valid_triplet(t))
        {
            System::println(System::color::error, "Error: invalid triplet: %s", t.value);
            TrackProperty("error", "invalid triplet: " + t.value);
            help_topic_valid_triplet(paths);
            exit(EXIT_FAILURE);
        }
    }
}}
