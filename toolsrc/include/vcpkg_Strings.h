#pragma once

#include <string>

namespace vcpkg {namespace Strings {namespace details
{
    inline const char* to_printf_arg(const std::string& s)
    {
        return s.c_str();
    }

    inline const char* to_printf_arg(const char* s)
    {
        return s;
    }

    inline int to_printf_arg(const int s)
    {
        return s;
    }

    inline size_t to_printf_arg(const size_t s)
    {
        return s;
    }

    std::string format_internal(const char* fmtstr, ...);

    inline const wchar_t* to_wprintf_arg(const std::wstring& s)
    {
        return s.c_str();
    }

    inline const wchar_t* to_wprintf_arg(const wchar_t* s)
    {
        return s;
    }

    std::wstring wformat_internal(const wchar_t* fmtstr, ...);
}}}

namespace vcpkg {namespace Strings
{
    template <class...Args>
    std::string format(const char* fmtstr, const Args&...args)
    {
        using vcpkg::Strings::details::to_printf_arg;
        return details::format_internal(fmtstr, to_printf_arg(to_printf_arg(args))...);
    }

    template <class...Args>
    std::wstring wformat(const wchar_t* fmtstr, const Args&...args)
    {
        using vcpkg::Strings::details::to_wprintf_arg;
        return details::wformat_internal(fmtstr, to_wprintf_arg(to_wprintf_arg(args))...);
    }

    std::wstring utf8_to_utf16(const std::string& s);

    std::string utf16_to_utf8(const std::wstring& w);

    std::string::const_iterator case_insensitive_find(const std::string& s, const std::string& pattern);

    std::string ascii_to_lowercase(const std::string& input);
}}
