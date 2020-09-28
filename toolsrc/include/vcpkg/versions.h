#pragma once

#include <set>
#include <string>
#include <tuple>
#include <vector>

namespace vcpkg::Versions
{
    namespace VersionString
    {
        bool is_date(const std::string& version_string);
        bool is_semver(const std::string& version_string);
        bool is_semver_relaxed(const std::string& version_string);
        bool is_valid_string(const std::string& version_string);
    }

    struct Version
    {
        std::string major;
        std::string minor;
        std::string update;

        Version() : major("0"), minor("0"), update("0") { }
        Version(std::string major, std::string minor, std::string update) : major(major), minor(minor), update(update)
        {
        }

        const std::string to_string() const;

        

        friend bool operator<(const Version& lhs, const Version& rhs)
        {
            return std::tie(lhs.major, lhs.minor, lhs.update) < std::tie(rhs.major, rhs.minor, rhs.update);
        }

        friend bool operator<=(const Version& lhs, const Version& rhs)
        {
            return std::tie(lhs.major, lhs.minor, lhs.update) <= std::tie(rhs.major, rhs.minor, rhs.update);
        }

        friend bool operator>(const Version& lhs, const Version& rhs)
        {
            return std::tie(lhs.major, lhs.minor, lhs.update) > std::tie(rhs.major, rhs.minor, rhs.update);
        }

        friend bool operator>=(const Version& lhs, const Version& rhs)
        {
            return std::tie(lhs.major, lhs.minor, lhs.update) >= std::tie(rhs.major, rhs.minor, rhs.update);
        }

        friend bool operator==(const Version& lhs, const Version& rhs)
        {
            return std::tie(lhs.major, lhs.minor, lhs.update) == std::tie(rhs.major, rhs.minor, rhs.update);
        }

        friend bool operator!=(const Version& lhs, const Version& rhs) { return !(lhs == rhs); }
    };

    enum class RequirementType
    {
        None,
        Baseline,
        Exact,
        Minimum
    };

    struct VersionRequirement
    {
        RequirementType type;
        std::string package_name;
        Version version;

        VersionRequirement() : type(RequirementType::None), package_name(), version() { }
        VersionRequirement(RequirementType type, std::string package_name, Version version)
            : type(type), package_name(package_name), version(version)
        {
        }
        VersionRequirement(
            RequirementType type, std::string package_name, std::string major, std::string minor, std::string update)
            : type(type), package_name(package_name), version(major, minor, update)
        {
        }

        const std::string to_string() const;

        friend bool operator<(const VersionRequirement& lhs, const VersionRequirement& rhs)
        {
            return std::tie(lhs.type, lhs.package_name, lhs.version) <
                   std::tie(rhs.type, rhs.package_name, rhs.version);
        }
    };

    struct VersionConflict
    {
        VersionRequirement a;
        VersionRequirement b;

        friend bool operator<(const VersionConflict& lhs, const VersionConflict& rhs)
        {
            return std::tie(lhs.a, lhs.b) < std::tie(rhs.a, rhs.b);
        }
    };

    struct ComputedVersions
    {
        std::set<VersionRequirement> computed_versions;
        std::set<std::string> baseline_packages;
        std::set<VersionConflict> conflicts;
    };

    const ComputedVersions compute_required_versions(const std::vector<VersionRequirement>& requirements);

    void test_algorithm();
}