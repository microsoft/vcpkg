#pragma once
#include <string>

namespace vcpkg
{
    template<class CharType>
    struct BasicCStringView
    {
        constexpr BasicCStringView() : cstr(nullptr) {}
        constexpr BasicCStringView(const CharType* cstr) : cstr(cstr) {}
        constexpr BasicCStringView(const BasicCStringView&) = default;
        BasicCStringView(const std::basic_string<CharType>& str) : cstr(str.c_str()) {}

        constexpr operator const CharType*() const { return cstr; }
        constexpr const CharType* c_str() const { return cstr; }

    private:
        const CharType* cstr;
    };

    template<class CharType>
    bool operator==(const std::basic_string<CharType>& l, const BasicCStringView<CharType>& r)
    {
        return l == r.c_str();
    }

    template<class CharType>
    bool operator==(const BasicCStringView<CharType>& r, const std::basic_string<CharType>& l)
    {
        return l == r.c_str();
    }

    template<class CharType>
    bool operator!=(const BasicCStringView<CharType>& r, const std::basic_string<CharType>& l)
    {
        return l != r.c_str();
    }

    template<class CharType>
    bool operator!=(const std::basic_string<CharType>& l, const BasicCStringView<CharType>& r)
    {
        return l != r.c_str();
    }

    using CStringView = BasicCStringView<char>;
    using CWStringView = BasicCStringView<wchar_t>;

    inline const char* to_printf_arg(const CStringView string_view) { return string_view.c_str(); }

    inline const wchar_t* to_wprintf_arg(const CWStringView string_view) { return string_view.c_str(); }

    static_assert(sizeof(CStringView) == sizeof(void*), "CStringView must be a simple wrapper around char*");
    static_assert(sizeof(CWStringView) == sizeof(void*), "CWStringView must be a simple wrapper around wchar_t*");
}
