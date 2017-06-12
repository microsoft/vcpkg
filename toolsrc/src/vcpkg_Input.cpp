#include "pch.h"

#include "metrics.h"
#include "vcpkg_Commands.h"
#include "vcpkg_Input.h"
#include "vcpkg_System.h"

namespace vcpkg::Input
{
    FullPackageSpec check_and_get_package_spec(const std::string& package_spec_as_string,
                                               const Triplet& default_triplet,
                                               CStringView example_text)
    {
        const std::string as_lowercase = Strings::ascii_to_lowercase(package_spec_as_string);
        auto expected_spec = PackageSpec::from_string(as_lowercase, default_triplet);
        if (auto spec = expected_spec.get())
        {
            return FullPackageSpec{*spec};
        }

        // Intentionally show the lowercased string
        System::println(System::Color::error, "Error: %s: %s", vcpkg::to_string(expected_spec.error()), as_lowercase);
        System::print(example_text);
        Checks::exit_fail(VCPKG_LINE_INFO);
    }

    void check_triplet(const Triplet& t, const VcpkgPaths& paths)
    {
        if (!paths.is_valid_triplet(t))
        {
            System::println(System::Color::error, "Error: invalid triplet: %s", t);
            Metrics::track_property("error", "invalid triplet: " + t.to_string());
            Commands::Help::help_topic_valid_triplet(paths);
            Checks::exit_fail(VCPKG_LINE_INFO);
        }
    }

    FullPackageSpec check_and_get_full_package_spec(const std::string& full_package_spec_as_string,
                                                    const Triplet& default_triplet,
                                                    CStringView example_text)
    {
        int left_pos = (int)full_package_spec_as_string.find('[');
        if (left_pos == std::string::npos)
        {
            return check_and_get_package_spec(full_package_spec_as_string, default_triplet, example_text);
        }
        int right_pos = (int)full_package_spec_as_string.find(']');
        if (left_pos >= right_pos)
        {
            System::println(System::Color::error, "Error: Argument is not formatted correctly \"%s\"");
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        // parse_comma_list();

        std::string package_spec_as_string = full_package_spec_as_string.substr(0, left_pos);
        const std::string as_lowercase = Strings::ascii_to_lowercase(package_spec_as_string);
        auto expected_spec = PackageSpec::from_string(as_lowercase, default_triplet);
        if (auto&& spec = expected_spec.get())
        {
            return {*spec,
                    parse_comma_list(full_package_spec_as_string.substr(left_pos + 1, right_pos - left_pos - 1))};
        }

        // Intentionally show the lowercased string
        System::println(System::Color::error, "Error: %s: %s", vcpkg::to_string(expected_spec.error()), as_lowercase);
        System::print(example_text);
        Checks::exit_fail(VCPKG_LINE_INFO);
    }
}
