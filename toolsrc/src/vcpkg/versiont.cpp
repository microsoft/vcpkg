#include <vcpkg/base/strings.h>

#include <vcpkg/versiont.h>

namespace vcpkg
{
    VersionT::VersionT() noexcept : value("0.0.0"), port_version(0) { }
    VersionT::VersionT(std::string&& value, int port_version) : value(std::move(value)), port_version(port_version) { }
    VersionT::VersionT(const std::string& value, int port_version) : value(value), port_version(port_version) { }

    std::string VersionT::to_string() const
    {
        return port_version == 0 ? value : Strings::format("%s#%d", value, port_version);
    }

    bool operator==(const VersionT& left, const VersionT& right)
    {
        return left.port_version == right.port_version && left.value == right.value;
    }
    bool operator!=(const VersionT& left, const VersionT& right) { return !(left == right); }

    bool VersionTMapLess::operator()(const VersionT& left, const VersionT& right) const
    {
        auto cmp = left.value.compare(right.value);
        if (cmp < 0)
        {
            return true;
        }
        else if (cmp > 0)
        {
            return false;
        }

        return left.port_version < right.port_version;
    }

    VersionDiff::VersionDiff() noexcept : left(), right() { }
    VersionDiff::VersionDiff(const VersionT& left, const VersionT& right) : left(left), right(right) { }

    std::string VersionDiff::to_string() const
    {
        return Strings::format("%s -> %s", left.to_string(), right.to_string());
    }
}
