#include <vcpkg/base/system.print.h>
#include <vcpkg/base/util.h>

#include <vcpkg/versions.h>

using namespace vcpkg::Versions;

bool VersionString::is_date(const std::string& version_string)
{
    // The date regex is not complete, it matches strings that look like dates,
    // e.g.: 2020-99-99.
    //
    // The regex has two capture groups:
    // * Date: "^([0-9]{4,}[-][0-9]{2}[-][0-9]{2})", it matches strings that resemble YYYY-MM-DD.
    //         It does not validate that MM <= 12, or that DD is possible with the given MM.
    //         YYYY should be AT LEAST 4 digits, for some kind of "future proofing".
    std::regex re("^([0-9]{4,}[-][0-9]{2}[-][0-9]{2})((?:[.|-][0-9a-zA-Z]+)*)$");
    return std::regex_match(version_string, re);
}

bool VersionString::is_semver(const std::string& version_string)
{
    // This is the "official" SemVer regex, taken from:
    // https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string
    std::regex re("^(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:-((?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*"
                  ")(?:\\.(?:0|["
                  "1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\\+([0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?$");
    return std::regex_match(version_string, re);
}

bool VersionString::is_semver_relaxed(const std::string& version_string)
{
    std::regex re("^(?:[0-9a-zA-Z]+)(?:[\\.|-][0-9a-zA-Z]+)*$");
    return std::regex_match(version_string, re);
}

bool VersionString::is_valid_string(const std::string& version_string) { return !version_string.empty(); }

const std::string Version::to_string() const { return vcpkg::Strings::format("%s.%s.%s", major, minor, update); }

const std::string VersionRequirement::to_string() const
{
    std::string requirement_operator = "?=";
    if (type == RequirementType::Exact)
    {
        requirement_operator = "==";
    }
    else if (type == RequirementType::Minimum)
    {
        requirement_operator = ">=";
    }
    return vcpkg::Strings::format("%s (%s %s)", package_name, requirement_operator, version.to_string());
}

const ComputedVersions vcpkg::Versions::compute_required_versions(const std::vector<VersionRequirement>& requirements)
{
    // This implementation is incomplete, as it assumes we have a flattened/final list of requirements.
    // It is missing the recursive step of adding new requirements for each requested dependency.
    //
    // It should be good enough to implement versioning for "only top-level manifest version requirements".
    //
    // To do it correctly, the code that computes the dependency graph needs to include version information.
    using namespace vcpkg::Versions;

    std::set<std::string> package_names;
    std::set<VersionConflict> conflicts;
    std::map<std::string, VersionRequirement> fixed_versions;
    std::map<std::string, VersionRequirement> minimum_versions;

    for (auto&& requirement : requirements)
    {
        package_names.insert(requirement.package_name);

        if (requirement.type == RequirementType::Exact)
        {
            auto conflict = fixed_versions.find(requirement.package_name);
            if (conflict == fixed_versions.end())
            {
                // Add new requirement
                fixed_versions[requirement.package_name] = requirement;
            }
            else if (conflict->second.version != requirement.version)
            {
                // Report conflict
                VersionConflict new_conflict{requirement, conflict->second};
                conflicts.emplace(new_conflict);
            }
        }
        else if (requirement.type == RequirementType::Minimum)
        {
            // Find previous requirements
            auto conflict = minimum_versions.find(requirement.package_name);
            if (conflict == minimum_versions.end())
            {
                // Add new requirement for package
                minimum_versions[requirement.package_name] = requirement;
            }
            else if (conflict->second.version < requirement.version)
            {
                // Upgrade to newest requirement
                conflict->second.version = requirement.version;
            }
        }
    }

    // Merge both lists
    std::set<VersionRequirement> computed_versions;
    std::set<std::string> baseline_packages;

    for (auto&& package_name : package_names)
    {
        auto fixed_version = fixed_versions.find(package_name);
        bool has_fixed_version = fixed_version != fixed_versions.end();

        auto minimum_version = minimum_versions.find(package_name);
        bool has_minimum_version = minimum_version != minimum_versions.end();

        if (has_fixed_version)
        {
            if (!has_minimum_version)
            {
                // No conflicts, use fixed requirement version.
                computed_versions.insert(fixed_version->second);
            }
            else if (minimum_version->second.version < fixed_version->second.version)
            {
                // Upgrade to fixed requirement
                computed_versions.insert(fixed_version->second);
            }
            else
            {
                // Report conflict
                VersionConflict new_conflict{fixed_version->second, minimum_version->second};
                conflicts.emplace(new_conflict);
            }
        }
        else if (has_minimum_version)
        {
            computed_versions.insert(minimum_version->second);
        }
        else
        {
            baseline_packages.insert(package_name);
            /*vcpkg::Checks::exit_with_message(
                VCPKG_LINE_INFO, "Unsatisfied version requirements for package: %s", package_name);*/
        }
    }

    return ComputedVersions{computed_versions, baseline_packages, conflicts};
}

void vcpkg::Versions::test_algorithm()
{
    // Used for debugging, this should be moved to a test.
    std::vector<VersionRequirement> data{// Conflict a=2.0.0 and a=3.0.0 and between a=2.0.0 and a>=4.0.0
                                         VersionRequirement(RequirementType::Exact, "a", "2", "0", "0"),
                                         VersionRequirement(RequirementType::Exact, "a", "3", "0", "0"),
                                         VersionRequirement(RequirementType::Minimum, "a", "1", "0", "0"),
                                         VersionRequirement(RequirementType::Minimum, "a", "4", "0", "0"),

                                         // Use b=2.0.0
                                         VersionRequirement(RequirementType::Exact, "b", "2", "0", "0"),
                                         VersionRequirement(RequirementType::Minimum, "b", "1", "0", "0"),
                                         VersionRequirement(RequirementType::None, "b", "0", "0", "0"),

                                         // Use c>=4.0.0
                                         VersionRequirement(RequirementType::Minimum, "c", "1", "0", "0"),
                                         VersionRequirement(RequirementType::Minimum, "c", "2", "0", "0"),
                                         VersionRequirement(RequirementType::Minimum, "c", "3", "0", "0"),
                                         VersionRequirement(RequirementType::Minimum, "c", "4", "0", "0"),
                                         VersionRequirement(RequirementType::None, "c", "0", "0", "0"),

                                         // Use x=25.0.0
                                         VersionRequirement(RequirementType::Exact, "x", "25", "0", "0"),
                                         VersionRequirement(RequirementType::None, "x", "0", "0", "0"),

                                         // Use y=26.0.0
                                         VersionRequirement(RequirementType::Exact, "y", "26", "0", "0"),
                                         VersionRequirement(RequirementType::Exact, "y", "26", "0", "0"),
                                         VersionRequirement(RequirementType::None, "y", "0", "0", "0"),

                                         // Basesline
                                         VersionRequirement(RequirementType::None, "m", "0", "0", "0"),
                                         VersionRequirement(RequirementType::None, "n", "0", "0", "0"),
                                         VersionRequirement(RequirementType::None, "o", "0", "0", "0")};

    auto output = vcpkg::Versions::compute_required_versions(data);

    vcpkg::System::print2("Solved dependencies:\n");
    for (auto&& version : output.computed_versions)
    {
        vcpkg::System::printf("%s\n", version.to_string());
    }

    vcpkg::System::print2("\nUse baseline versions:\n");
    for (auto&& package : output.baseline_packages)
    {
        vcpkg::System::printf("%s\n", package);
    }

    vcpkg::System::print2("\nConflicts:\n");
    for (auto&& conflict : output.conflicts)
    {
        vcpkg::System::printf("Between %s and %s\n", conflict.a, conflict.b);
    }

    vcpkg::Checks::exit_success(VCPKG_LINE_INFO);
}
