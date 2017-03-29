#include "pch.h"
#include "version_t.h"
#include "vcpkg_Strings.h"

namespace vcpkg
{
    version_t::version_t() : value("0.0.0") {}
    version_t::version_t(const std::string& value) : value(value) {}
    bool operator==(const version_t& left, const version_t& right) { return left.value == right.value; }
    bool operator!=(const version_t& left, const version_t& right) { return left.value != right.value; }
    std::string to_printf_arg(const version_t& version) { return version.value; }

    version_diff_t::version_diff_t() : left(), right() {}
    version_diff_t::version_diff_t(const version_t& left, const version_t& right) : left(left), right(right) {}

    std::string version_diff_t::toString() const
    {
        return Strings::format("%s -> %s", left.value, right.value);
    }
}
