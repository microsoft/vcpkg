#pragma once

#include <vcpkg/base/cstringview.h>
#include <vcpkg/base/expected.h>

namespace vcpkg
{
    enum class PackageSpecParseResult
    {
        SUCCESS = 0,
        TOO_MANY_COLONS,
        INVALID_CHARACTERS
    };

    CStringView to_string(PackageSpecParseResult ev) noexcept;
    inline CStringView to_printf_arg(PackageSpecParseResult ev) noexcept { return to_string(ev); }
}
