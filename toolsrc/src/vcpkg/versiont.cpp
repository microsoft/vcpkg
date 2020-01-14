#include "pch.h"

#include <vcpkg/base/strings.h>
#include <vcpkg/versiont.h>

namespace vcpkg
{
    VersionT::VersionT() noexcept : value("0.0.0") {}
    VersionT::VersionT(std::string&& value) : value(std::move(value)) {}
    VersionT::VersionT(const std::string& value) : value(value) {}
    const std::string& VersionT::to_string() const { return value; }
    bool operator==(const VersionT& left, const VersionT& right) { return left.to_string() == right.to_string(); }
    bool operator!=(const VersionT& left, const VersionT& right) { return left.to_string() != right.to_string(); }

    VersionDiff::VersionDiff() noexcept : left(), right() {}
    VersionDiff::VersionDiff(const VersionT& left, const VersionT& right) : left(left), right(right) {}

    std::string VersionDiff::to_string() const
    {
        return Strings::format("%s -> %s", left.to_string(), right.to_string());
    }
}
