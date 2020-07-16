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

        friend bool operator==(const VersionT& left, const VersionT& right);
        friend bool operator!=(const VersionT& left, const VersionT& right);

    private:
        std::string value;
        int port_version;
    };

    struct VersionDiff
    {
        VersionT left;
        VersionT right;

        VersionDiff() noexcept;
        VersionDiff(const VersionT& left, const VersionT& right);

        std::string to_string() const;
    };
}
