#pragma once

#include <vcpkg/base/cstringview.h>

namespace vcpkg
{
    struct StringLiteral
    {
        template<int N>
        constexpr StringLiteral(const char (&str)[N])
            : m_size(N - 1) /* -1 here accounts for the null byte at the end*/, m_cstr(str)
        {
        }

        constexpr const char* c_str() const { return m_cstr; }
        constexpr size_t size() const { return m_size; }

        operator CStringView() const { return m_cstr; }
        operator std::string() const { return m_cstr; }

    private:
        size_t m_size;
        const char* m_cstr;
    };

    inline const char* to_printf_arg(const StringLiteral str) { return str.c_str(); }
}
