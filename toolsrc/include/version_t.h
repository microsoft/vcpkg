#pragma once
#include <string>

namespace vcpkg
{
    struct version_t
    {
        version_t();
        version_t(const std::string& value);

        std::string value;
    };

    bool operator ==(const version_t& left, const version_t& right);
    bool operator !=(const version_t& left, const version_t& right);
    std::string to_printf_arg(const version_t& version);

    struct version_diff_t
    {
        version_t left;
        version_t right;

        version_diff_t();
        version_diff_t(const version_t& left, const version_t& right);

        std::string toString() const;
    };
}
