#pragma once
#include <string>

namespace vcpkg
{
    struct VersionT
    {
        VersionT() noexcept;
        VersionT(std::string&& value);
        VersionT(const std::string& value);

        const std::string& to_string() const;

    private:
        std::string value;
    };

    bool operator==(const VersionT& left, const VersionT& right);
    bool operator!=(const VersionT& left, const VersionT& right);

    struct VersionDiff
    {
        VersionT left;
        VersionT right;

        VersionDiff() noexcept;
        VersionDiff(const VersionT& left, const VersionT& right);

        std::string to_string() const;
    };
}
