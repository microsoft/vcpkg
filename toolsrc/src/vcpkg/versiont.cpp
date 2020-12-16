#include <vcpkg/base/strings.h>

#include <vcpkg/versiont.h>

namespace vcpkg
{
    VersionT::VersionT() noexcept : m_text("0.0.0"), m_port_version(0) { }
    VersionT::VersionT(std::string&& value, int port_version) : m_text(std::move(value)), m_port_version(port_version)
    {
    }
    VersionT::VersionT(const std::string& value, int port_version) : m_text(value), m_port_version(port_version) { }

    std::string VersionT::to_string() const { return Strings::concat(*this); }
    void VersionT::to_string(std::string& out) const
    {
        out.append(m_text);
        if (m_port_version) Strings::append(out, '#', m_port_version);
    }

    bool operator==(const VersionT& left, const VersionT& right)
    {
        return left.m_port_version == right.m_port_version && left.m_text == right.m_text;
    }
    bool operator!=(const VersionT& left, const VersionT& right) { return !(left == right); }

    bool VersionTMapLess::operator()(const VersionT& left, const VersionT& right) const
    {
        auto cmp = left.m_text.compare(right.m_text);
        if (cmp < 0)
        {
            return true;
        }
        else if (cmp > 0)
        {
            return false;
        }

        return left.m_port_version < right.m_port_version;
    }

    VersionDiff::VersionDiff() noexcept : left(), right() { }
    VersionDiff::VersionDiff(const VersionT& left, const VersionT& right) : left(left), right(right) { }

    std::string VersionDiff::to_string() const
    {
        return Strings::format("%s -> %s", left.to_string(), right.to_string());
    }
}
