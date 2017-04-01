#pragma once
#include <string>

namespace vcpkg
{
    template<class CharType>
    struct basic_cstring_view
    {
        constexpr basic_cstring_view() : cstr(nullptr) {}
        constexpr basic_cstring_view(const CharType* cstr) : cstr(cstr) {}
        basic_cstring_view(const std::basic_string<CharType>& str) : cstr(str.c_str()) {}

        constexpr operator const CharType*() const { return cstr; }

        constexpr const CharType* c_str() const { return cstr; }

    private:
        const CharType* cstr;
    };

    using cstring_view = basic_cstring_view<char>;
    using cwstring_view = basic_cstring_view<wchar_t>;

    inline const char* to_printf_arg(const cstring_view spec) { return spec.c_str(); }

    inline const wchar_t* to_wprintf_arg(const cwstring_view spec) { return spec.c_str(); }

    static_assert(sizeof(cstring_view) == sizeof(void*), "cstring_view must be a simple wrapper around char*");
    static_assert(sizeof(cwstring_view) == sizeof(void*), "cwstring_view must be a simple wrapper around wchar_t*");
}
