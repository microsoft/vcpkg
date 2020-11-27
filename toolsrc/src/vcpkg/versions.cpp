#include <vcpkg/versions.h>

namespace vcpkg::Versions
{
    VersionSpec::VersionSpec(const std::string& port_name, const VersionT& version, Scheme scheme)
        : port_name(port_name), version(version), scheme(scheme)
    {
    }

    VersionSpec::VersionSpec(const std::string& port_name,
                             const std::string& version_string,
                             int port_version,
                             Scheme scheme)
        : port_name(port_name), version(version_string, port_version), scheme(scheme)
    {
    }

    bool operator==(const VersionSpec& lhs, const VersionSpec& rhs)
    {
        return std::tie(lhs.port_name, lhs.version, lhs.scheme) == std::tie(rhs.port_name, rhs.version, rhs.scheme);
    }

    bool operator!=(const VersionSpec& lhs, const VersionSpec& rhs) { return !(lhs == rhs); }

    std::size_t VersionSpecHasher::operator()(const VersionSpec& key) const
    {
        using std::hash;
        using std::size_t;
        using std::string;

        return ((hash<string>()(key.port_name) ^ (hash<string>()(key.version.to_string()) << 1)) >> 1) ^
               (hash<int>()(static_cast<int>(key.scheme)) << 1);
    }
}