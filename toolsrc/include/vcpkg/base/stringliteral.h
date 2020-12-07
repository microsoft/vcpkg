#pragma once

#include <vcpkg/base/zstringview.h>

#include <string>

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
