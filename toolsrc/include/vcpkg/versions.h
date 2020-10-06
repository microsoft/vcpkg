#pragma once

#include <vcpkg/fwd/vcpkgpaths.h>

#include <set>
#include <string>
#include <tuple>
#include <vector>

namespace vcpkg::Versions
{
    enum class Scheme
    {
        Relaxed,
        Semver,
        Date,
        String
    };

    struct Version
    {
        const Scheme scheme;
        const std::string version;
        const int port_version;

        explicit Version(const std::string& version_string, int port_version, Scheme scheme);

        virtual std::string to_string() const;

        static bool is_semver_relaxed(const std::string& version_string);
        static bool is_semver(const std::string& version_string);
        static bool is_date(const std::string& version_string);
        static bool is_valid_string(const std::string& version_string);
    };

    struct VersionString : Version
    {
        explicit VersionString(const std::string& version_string);
        VersionString(const std::string& version_string, int port_version);

        friend bool operator<(const VersionString& lhs, const VersionString& rhs) { return lhs < rhs; }
        friend bool operator<=(const VersionString& lhs, const VersionString& rhs) { return lhs <= rhs; }
        friend bool operator>(const VersionString& lhs, const VersionString& rhs) { return lhs > rhs; }
        friend bool operator>=(const VersionString& lhs, const VersionString& rhs) { return lhs >= rhs; }
        friend bool operator==(const VersionString& lhs, const VersionString& rhs) { return lhs == rhs; }
        friend bool operator!=(const VersionString& lhs, const VersionString& rhs) { return lhs != rhs; }
    };

    struct VersionRelaxed : Version
    {
        std::vector<std::string> sections;

        explicit VersionRelaxed(const std::string& version_string);
        VersionRelaxed(const std::string& version_string, int port_version);

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
}