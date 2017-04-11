#include "pch.h"
#include "Version.h"
#include "vcpkg_Strings.h"

namespace vcpkg
{
    Version::Version() : value("0.0.0") {}
    Version::Version(const std::string& value) : value(value) {}
    bool operator==(const Version& left, const Version& right) { return left.value == right.value; }
    bool operator!=(const Version& left, const Version& right) { return left.value != right.value; }
    std::string to_printf_arg(const Version& version) { return version.value; }

    version_diff_t::version_diff_t() : left(), right() {}
    version_diff_t::version_diff_t(const Version& left, const Version& right) : left(left), right(right) {}

    std::string version_diff_t::toString() const
    {
        return Strings::format("%s -> %s", left.value, right.value);
    }
}
