#pragma once

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
        std::string text;
        int port_version;
        Scheme scheme;

        bool operator==(const Version& rhs) const
        {
            return text == rhs.text && port_version == rhs.port_version && scheme == rhs.scheme;
        }
        bool operator<(const Version& rhs) const
        {
            if (scheme != rhs.scheme) return scheme < rhs.scheme;
            if (text != rhs.text) return text < rhs.text;
            if (port_version != rhs.port_version) return port_version < rhs.port_version;
            return false;
        }
        bool operator!=(const Version& rhs) const { return !(*this == rhs); }
    };

    struct VersionSpec
    {
        std::string name;
        Version version;

        bool operator==(const VersionSpec& rhs) const { return name == rhs.name && version == rhs.version; }
        bool operator!=(const VersionSpec& rhs) const { return !(*this == rhs); }
    };

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
