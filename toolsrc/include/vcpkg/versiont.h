#pragma once

#include <string>

namespace vcpkg
{
    struct VersionT
    {
        VersionT() noexcept;
        VersionT(std::string&& value, int port_version);
        VersionT(const std::string& value, int port_version);

        std::string to_string() const;
        void to_string(std::string& out) const;

        friend bool operator==(const VersionT& left, const VersionT& right);
        friend bool operator!=(const VersionT& left, const VersionT& right);

        friend struct VersionTMapLess;

        const std::string text() const { return m_text; }
        int port_version() const { return m_port_version; }

    private:
        std::string m_text;
        int m_port_version;
    };

    struct VersionDiff
    {
        VersionT left;
        VersionT right;

        VersionDiff() noexcept;
        VersionDiff(const VersionT& left, const VersionT& right);

        std::string to_string() const;
    };

    struct VersionTMapLess
    {
        bool operator()(const VersionT& left, const VersionT& right) const;
    };
}
