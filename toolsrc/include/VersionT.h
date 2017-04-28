#pragma once
#include <string>

namespace vcpkg
{
    struct VersionT
    {
        VersionT();
        VersionT(const std::string& value);

        std::string to_string() const;

        std::string value;
    };

    bool operator==(const VersionT& left, const VersionT& right);
    bool operator!=(const VersionT& left, const VersionT& right);

    struct VersionDiff
    {
        VersionT left;
        VersionT right;

        VersionDiff();
        VersionDiff(const VersionT& left, const VersionT& right);

        std::string to_string() const;
    };
}
