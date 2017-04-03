#include "pch.h"
#include "VersionT.h"
#include "vcpkg_Strings.h"

namespace vcpkg
{
    VersionT::VersionT() : value("0.0.0") {}
    VersionT::VersionT(const std::string& value) : value(value) {}
    bool operator==(const VersionT& left, const VersionT& right) { return left.value == right.value; }
    bool operator!=(const VersionT& left, const VersionT& right) { return left.value != right.value; }
    std::string to_printf_arg(const VersionT& version) { return version.value; }

    version_diff_t::version_diff_t() : left(), right() {}
    version_diff_t::version_diff_t(const VersionT& left, const VersionT& right) : left(left), right(right) {}

    std::string version_diff_t::toString() const
    {
        return Strings::format("%s -> %s", left.value, right.value);
    }
}
