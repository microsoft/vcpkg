#include "pch.h"

#include "PackageSpecParseResult.h"
#include "vcpkg_Checks.h"

namespace vcpkg
{
    CStringView to_string(PackageSpecParseResult ev) noexcept
    {
        switch (ev)
        {
            case PackageSpecParseResult::SUCCESS: return "OK";
            case PackageSpecParseResult::TOO_MANY_COLONS: return "Too many colons";
            case PackageSpecParseResult::INVALID_CHARACTERS:
                return "Contains invalid characters. Only alphanumeric lowercase ASCII characters, dashes and"
                       "underscores are allowed";
            default: Checks::unreachable(VCPKG_LINE_INFO);
        }
    }
}
