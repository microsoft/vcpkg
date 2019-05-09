#pragma once

#include <cstring>
#include <string>

namespace vcpkg
{
    struct CStringView
    {
        constexpr CStringView() noexcept : cstr(nullptr) {}
        constexpr CStringView(const char* cstr) : cstr(cstr) {}
        constexpr CStringView(const CStringView&) = default;
        CStringView(const std::string& str) : cstr(str.c_str()) {}

        constexpr const char* c_str() const { return cstr; }

        void to_string(std::string& str) const { str.append(cstr); }

    private:
        const char* cstr;
    };

    namespace details
    {
        inline bool vcpkg_strcmp(const char* l, const char* r) { return strcmp(l, r) == 0; }
    }

    inline bool operator==(const CStringView& l, const CStringView& r)
    {
        return details::vcpkg_strcmp(l.c_str(), r.c_str());
    }

    inline bool operator==(const char* l, const CStringView& r) { return details::vcpkg_strcmp(l, r.c_str()); }

    inline bool operator==(const CStringView& r, const char* l) { return details::vcpkg_strcmp(l, r.c_str()); }

    inline bool operator==(const std::string& l, const CStringView& r) { return l == r.c_str(); }

    inline bool operator==(const CStringView& r, const std::string& l) { return l == r.c_str(); }

    // notequals
    inline bool operator!=(const CStringView& l, const CStringView& r)
    {
        return !details::vcpkg_strcmp(l.c_str(), r.c_str());
    }

    inline bool operator!=(const char* l, const CStringView& r) { return !details::vcpkg_strcmp(l, r.c_str()); }

    inline bool operator!=(const CStringView& r, const char* l) { return !details::vcpkg_strcmp(l, r.c_str()); }

    inline bool operator!=(const CStringView& r, const std::string& l) { return l != r.c_str(); }

    inline bool operator!=(const std::string& l, const CStringView& r) { return l != r.c_str(); }

    inline std::string operator+(std::string&& l, const CStringView& r) { return std::move(l) + r.c_str(); }

    inline const char* to_printf_arg(const CStringView string_view) { return string_view.c_str(); }

    static_assert(sizeof(CStringView) == sizeof(void*), "CStringView must be a simple wrapper around char*");
}
