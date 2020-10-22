#pragma once
#include <functional>
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

        friend struct std::less<VersionT>;

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

namespace std
{
    // allows for std::map<VersionT, _>
    template<>
    struct less<::vcpkg::VersionT>
    {
        bool operator()(const ::vcpkg::VersionT& lhs, const ::vcpkg::VersionT& rhs) const;
    };
}
