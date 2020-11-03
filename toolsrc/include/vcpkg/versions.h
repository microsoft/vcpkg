#pragma once

#include <vcpkg/versiont.h>

namespace vcpkg::Versions
{
    enum class Scheme
    {
        Relaxed,
        Semver,
        Date,
        String
    };

    struct VersionSpec
    {
        const std::string package_spec;
        const VersionT version;
        const Scheme scheme;

        VersionSpec(const std::string& package_spec, const VersionT& version, Scheme scheme);

        VersionSpec(const std::string& package_spec,
                    const std::string& version_string,
                    int port_version,
                    Scheme scheme);

        friend bool operator==(const VersionSpec& lhs, const VersionSpec& rhs);
        friend bool operator!=(const VersionSpec& lhs, const VersionSpec& rhs);
    };

    struct VersionSpecHasher
    {
        std::size_t operator()(const VersionSpec& key) const;
    };

    struct Constraint
    {
        enum class Type
        {
            None,
            Minimum,
            Exact
        };

        const VersionSpec version_spec;
        const Type type;

        Constraint(const VersionSpec& version_spec, Type type);
        Constraint(const std::string& package_spec, const VersionT& version, Scheme scheme, Type type);
    };
}