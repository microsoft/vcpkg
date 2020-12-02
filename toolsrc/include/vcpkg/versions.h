#pragma once

#include <vcpkg/versiont.h>

namespace vcpkg::Versions
{
    using Version = VersionT;

    enum class VerComp
    {
        unk,
        lt,
        eq,
        gt,
    };

    enum class Scheme
    {
        Relaxed,
        Semver,
        Date,
        String
    };

    struct VersionSpec
    {
        std::string port_name;
        VersionT version;

        VersionSpec(const std::string& port_name, const VersionT& version);

        VersionSpec(const std::string& port_name, const std::string& version_string, int port_version);

        friend bool operator==(const VersionSpec& lhs, const VersionSpec& rhs);
        friend bool operator!=(const VersionSpec& lhs, const VersionSpec& rhs);
    };

    struct VersionSpecHasher
    {
        std::size_t operator()(const VersionSpec& key) const;
    };

    struct SemanticVersion
    {
        std::string original_string;
        std::string version_string;
        std::string prerelease_string;
        std::vector<long> version;
        std::vector<std::string> identifiers;

        static SemanticVersion from_string(const std::string& str);
    };
    VerComp compare(const SemanticVersion& a, const SemanticVersion& b);

    struct Constraint
    {
        enum class Type
        {
            None,
            Minimum,
            Exact
        };
    };
}
