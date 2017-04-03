#include "pch.h"
#include "vcpkg_Input.h"
#include "vcpkg_System.h"
#include "metrics.h"
#include "vcpkg_Commands.h"

namespace vcpkg::Input
{
    PackageSpec check_and_get_package_spec(const std::string& package_spec_as_string, const Triplet& default_target_triplet, CStringView example_text)
    {
        const std::string as_lowercase = Strings::ascii_to_lowercase(package_spec_as_string);
        Expected<PackageSpec> expected_spec = PackageSpec::from_string(as_lowercase, default_target_triplet);
        if (auto spec = expected_spec.get())
        {
            return *spec;
        }

        // Intentionally show the lowercased string
        System::println(System::Color::error, "Error: %s: %s", expected_spec.error_code().message(), as_lowercase);
        System::print(example_text);
        Checks::exit_fail(VCPKG_LINE_INFO);
    }

    void check_triplet(const Triplet& t, const VcpkgPaths& paths)
    {
        if (!paths.is_valid_triplet(t))
        {
            System::println(System::Color::error, "Error: invalid triplet: %s", t.canonical_name());
            Metrics::track_property("error", "invalid triplet: " + t.canonical_name());
            Commands::Help::help_topic_valid_triplet(paths);
            Checks::exit_fail(VCPKG_LINE_INFO);
        }
    }
}
