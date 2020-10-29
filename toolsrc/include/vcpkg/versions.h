#pragma once

#include <vcpkg/base/strings.h>

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

        void to_string(std::string& out) const
        {
            Strings::append(out, text);
            if (port_version != 0) Strings::append(out, '#', port_version);
        }

        bool operator==(const Version& rhs) const { return text == rhs.text && port_version == rhs.port_version; }
        bool operator<(const Version& rhs) const
        {
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
