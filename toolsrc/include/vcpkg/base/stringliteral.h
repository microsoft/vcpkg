#pragma once

#include <string>
#include <vcpkg/base/zstringview.h>

namespace vcpkg
{
    struct StringLiteral : ZStringView
    {
        template<int N>
        constexpr StringLiteral(const char (&str)[N]) : ZStringView(str)
        {
        }

        operator std::string() const { return std::string(data(), size()); }
    };
}
