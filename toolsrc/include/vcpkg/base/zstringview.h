#pragma once

#include <vcpkg/base/stringview.h>

#include <algorithm>
#include <cstddef>
#include <cstring>
#include <string>

namespace vcpkg
{
    // A counted view of a null-terminated string
    struct ZStringView
    {
        using value_type = char;

        constexpr ZStringView() : m_size(0), m_cstr("") { }

        template<int N>
        constexpr ZStringView(const char (&str)[N])
            : m_size(N - 1) /* -1 here accounts for the null byte at the end*/, m_cstr(str)
        {
        }

        ZStringView(const std::string& s) : m_size(s.size()), m_cstr(s.c_str()) { }
        constexpr ZStringView(const char* str, size_t sz) : m_size(sz), m_cstr(str) { }

        constexpr const char* data() const { return m_cstr; }
        constexpr size_t size() const { return m_size; }
        constexpr char operator[](ptrdiff_t off) const { return m_cstr[off]; }

        constexpr const char* c_str() const { return m_cstr; }

        constexpr const char* begin() const { return m_cstr; }
        constexpr const char* end() const { return m_cstr + m_size; }

        std::string to_string() const { return std::string(m_cstr, m_size); }
        void to_string(std::string& out) const { out.append(m_cstr, m_size); }

        constexpr operator StringView() const { return StringView(m_cstr, m_size); }

    private:
        size_t m_size;
        const char* m_cstr;
    };

    inline bool operator==(ZStringView l, ZStringView r) { return std::equal(l.begin(), l.end(), r.begin(), r.end()); }
    inline bool operator!=(ZStringView l, ZStringView r) { return !std::equal(l.begin(), l.end(), r.begin(), r.end()); }

    inline bool operator==(const char* l, ZStringView r) { return strcmp(l, r.c_str()) == 0; }
    inline bool operator==(ZStringView l, const char* r) { return strcmp(l.c_str(), r) == 0; }
}
