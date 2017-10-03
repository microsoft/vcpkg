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

        constexpr const CharType* c_str() const { return cstr; }

    private:
        const CharType* cstr;
    };

    namespace details
    {
        inline bool vcpkg_strcmp(const char* l, const char* r) { return strcmp(l, r) == 0; }
        inline bool vcpkg_strcmp(const wchar_t* l, const wchar_t* r) { return wcscmp(l, r) == 0; }
    }

    template<class CharType>
    bool operator==(const BasicCStringView<CharType>& l, const BasicCStringView<CharType>& r)
    {
        return details::vcpkg_strcmp(l.c_str(), r.c_str());
    }

    template<class CharType>
    bool operator==(const CharType* l, const BasicCStringView<CharType>& r)
    {
        return details::vcpkg_strcmp(l, r.c_str());
    }

    template<class CharType>
    bool operator==(const BasicCStringView<CharType>& r, const CharType* l)
    {
        return details::vcpkg_strcmp(l, r.c_str());
    }

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

    // notequals
    template<class CharType>
    bool operator!=(const BasicCStringView<CharType>& l, const BasicCStringView<CharType>& r)
    {
        return !details::vcpkg_strcmp(l.c_str(), r.c_str());
    }

    template<class CharType>
    bool operator!=(const CharType* l, const BasicCStringView<CharType>& r)
    {
        return !details::vcpkg_strcmp(l, r.c_str());
    }

    template<class CharType>
    bool operator!=(const BasicCStringView<CharType>& r, const CharType* l)
    {
        return !details::vcpkg_strcmp(l, r.c_str());
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
