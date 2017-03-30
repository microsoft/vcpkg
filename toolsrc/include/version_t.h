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

    struct name_and_version_diff_t
    {
        static bool compare_by_name(const name_and_version_diff_t& left, const name_and_version_diff_t& right)
        {
            return left.name < right.name;
        }

        std::string name;
        version_diff_t version_diff;
    };
}
