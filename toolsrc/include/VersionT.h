#pragma once
#include <string>

namespace vcpkg
{
    struct VersionT
    {
        VersionT();
        VersionT(const std::string& value);

        std::string value;
    };

    bool operator ==(const VersionT& left, const VersionT& right);
    bool operator !=(const VersionT& left, const VersionT& right);
    std::string to_printf_arg(const VersionT& version);

    struct version_diff_t
    {
        VersionT left;
        VersionT right;

        version_diff_t();
        version_diff_t(const VersionT& left, const VersionT& right);

        std::string toString() const;
    };
}
