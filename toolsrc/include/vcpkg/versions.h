#pragma once

#include <vcpkg/fwd/vcpkgpaths.h>

#include <set>
#include <string>
#include <tuple>
#include <vector>

namespace vcpkg::Versions
{
    bool is_date(const std::string& version_string);
    bool is_semver(const std::string& version_string);
    bool is_semver_relaxed(const std::string& version_string);
    bool is_valid_string(const std::string& version_string);

    struct Version
    {
        virtual const std::string to_string() const = 0;
    };

    struct VersionString : Version
    {
        std::string version;
        int port_version;

        explicit VersionString(const std::string& version_string) : version(version_string), port_version(0) { }
        VersionString(const std::string& version_string, int port_version)
            : version(version_string), port_version(port_version)
        {
        }

        const std::string to_string() const override { return version; }

        friend bool operator<(const VersionString& lhs, const VersionString& rhs) { return lhs < rhs; }
        friend bool operator<=(const VersionString& lhs, const VersionString& rhs) { return lhs <= rhs; }
        friend bool operator>(const VersionString& lhs, const VersionString& rhs) { return lhs > rhs; }
        friend bool operator>=(const VersionString& lhs, const VersionString& rhs) { return lhs >= rhs; }
        friend bool operator==(const VersionString& lhs, const VersionString& rhs) { return lhs == rhs; }
        friend bool operator!=(const VersionString& lhs, const VersionString& rhs) { return lhs != rhs; }
    };

    struct VersionRelaxed : Version
    {
        std::string version;
        int port_version;
        std::vector<std::string> sections;

        explicit VersionRelaxed(const std::string& version_string);
        VersionRelaxed(const std::string& version_string, int port_version);

        const std::string to_string() const override { return version; }

        friend bool operator<(const VersionRelaxed& lhs, const VersionRelaxed& rhs)
        {
            return lhs.sections < rhs.sections;
        }
        friend bool operator<=(const VersionRelaxed& lhs, const VersionRelaxed& rhs)
        {
            return lhs.sections <= rhs.sections;
        }
        friend bool operator>(const VersionRelaxed& lhs, const VersionRelaxed& rhs)
        {
            return lhs.sections > rhs.sections;
        }
        friend bool operator>=(const VersionRelaxed& lhs, const VersionRelaxed& rhs)
        {
            return lhs.sections >= rhs.sections;
        }
        friend bool operator==(const VersionRelaxed& lhs, const VersionRelaxed& rhs)
        {
            return lhs.sections == rhs.sections;
        }
        friend bool operator!=(const VersionRelaxed& lhs, const VersionRelaxed& rhs)
        {
            return lhs.sections != rhs.sections;
        }
    };

    struct VersionRequirement
    {
        enum class Type
        {
            None,
            Baseline,
            Exact,
            Minimum
        };

        Type type;
        std::string package_name;
        VersionRelaxed version;

        VersionRequirement() : type(Type::None), package_name(), version("") { }
        VersionRequirement(Type type, std::string package_name, VersionRelaxed version)
            : type(type), package_name(package_name), version(version)
        {
        }
        VersionRequirement(Type type, std::string package_name, std::string version_string)
            : type(type), package_name(package_name), version(version_string)
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

    void fetch_port_versions(const vcpkg::VcpkgPaths& paths,
                             const ComputedVersions& versions,
                             const std::string& baseline);

    void test_fetch(const vcpkg::VcpkgPaths& paths);
}