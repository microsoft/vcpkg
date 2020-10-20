#include <vcpkg/versions.h>

namespace vcpkg::Versions
{
    VersionSpec::VersionSpec(const std::string& package_spec, const VersionT& version, Scheme scheme)
        : package_spec(package_spec), version(version), scheme(scheme)
    {
    }

    VersionSpec::VersionSpec(const std::string& package_spec,
                             const std::string& version_string,
                             int port_version,
                             Scheme scheme)
        : package_spec(package_spec), version(version_string, port_version), scheme(scheme)
    {
    }

    bool operator==(const VersionSpec& lhs, const VersionSpec& rhs)
    {
        return std::tie(lhs.package_spec, lhs.version, lhs.scheme) ==
               std::tie(rhs.package_spec, rhs.version, rhs.scheme);
    }

    bool operator!=(const VersionSpec& lhs, const VersionSpec& rhs) { return !(lhs == rhs); }

    std::size_t VersionSpecHasher::operator()(const VersionSpec& key) const
    {
        using std::hash;
        using std::size_t;
        using std::string;

        return ((hash<string>()(key.package_spec) ^ (hash<string>()(key.version.to_string()) << 1)) >> 1) ^
               (hash<int>()(static_cast<int>(key.scheme)) << 1);
    }

    Constraint::Constraint(const std::string& package_spec, const VersionT& version, Scheme scheme, Type type)
        : version_spec(package_spec, version, scheme), type(type)
    {
    }

    Constraint::Constraint(const VersionSpec& version_spec, Type type) : version_spec(version_spec), type(type) { }
}