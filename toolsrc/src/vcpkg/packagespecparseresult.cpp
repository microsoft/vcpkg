#include "pch.h"

#include <vcpkg/packagespecparseresult.h>

#include <vcpkg/base/checks.h>

namespace vcpkg
{
    CStringView to_string(PackageSpecParseResult ev) noexcept
    {
        switch (ev)
        {
            case PackageSpecParseResult::SUCCESS: return "OK";
            case PackageSpecParseResult::TOO_MANY_COLONS: return "Too many colons";
            case PackageSpecParseResult::INVALID_CHARACTERS:
                return "Contains invalid characters. Only alphanumeric lowercase ASCII characters and dashes are "
                       "allowed";
            default: Checks::unreachable(VCPKG_LINE_INFO);
        }
    }

    void to_string(std::string& out, PackageSpecParseResult p) { out.append(vcpkg::to_string(p).c_str()); }
}
