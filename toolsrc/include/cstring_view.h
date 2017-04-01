#pragma once
#include <string>

namespace vcpkg
{
    struct cstring_view
    {
        cstring_view(const char* cstr) : cstr(cstr) {}
        cstring_view(const std::string& str) : cstr(str.c_str()) {}

        operator const char*() const { return cstr; }

        const char* c_str() const { return cstr; }

    private:
        const char* cstr;
    };

    inline const char* to_printf_arg(const cstring_view spec) { return spec.c_str(); }

    struct cwstring_view
    {
        cwstring_view(const wchar_t* cstr) : cstr(cstr) {}
        cwstring_view(const std::wstring& str) : cstr(str.c_str()) {}

        operator const wchar_t*() const { return cstr; }

        const wchar_t* c_str() const { return cstr; }

    private:
        const wchar_t* cstr;
    };

    inline const wchar_t* to_wprintf_arg(const cwstring_view spec) { return spec.c_str(); }

    static_assert(sizeof(cstring_view) == sizeof(void*), "cstring_view must be a simple wrapper around char*");
    static_assert(sizeof(cwstring_view) == sizeof(void*), "cwstring_view must be a simple wrapper around wchar_t*");
}
