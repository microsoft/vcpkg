#pragma once
#include <string>

namespace vcpkg
{
    struct Version
    {
        Version();
        Version(const std::string& value);

        std::string value;
    };

    bool operator ==(const Version& left, const Version& right);
    bool operator !=(const Version& left, const Version& right);
    std::string to_printf_arg(const Version& version);

    struct version_diff_t
    {
        Version left;
        Version right;

        version_diff_t();
        version_diff_t(const Version& left, const Version& right);

        std::string toString() const;
    };
}
