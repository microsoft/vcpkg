#pragma once

#include <vector>
#include "cstring_view.h"

namespace vcpkg::Strings::details
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

    inline long long to_printf_arg(const long long s)
    {
        return s;
    }

    inline double to_printf_arg(const double s)
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
}

namespace vcpkg::Strings
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

    std::wstring utf8_to_utf16(const cstring_view s);

    std::string utf16_to_utf8(const cwstring_view w);

    std::string::const_iterator case_insensitive_ascii_find(const std::string& s, const std::string& pattern);

    std::string ascii_to_lowercase(const std::string& input);

    template <class T, class Transformer, class CharType>
    std::basic_string<CharType> join(
        const CharType* delimiter,
        const std::vector<T>& v,
        Transformer transformer)
    {
        if (v.empty())
        {
            return std::basic_string<CharType>();
        }

        std::basic_string<CharType> output;
        size_t size = v.size();

        output.append(transformer(v.at(0)));

        for (size_t i = 1; i < size; ++i)
        {
            output.append(delimiter);
            output.append(transformer(v.at(i)));
        }

        return output;
    }
    template <class T, class CharType>
    std::basic_string<CharType> join(
        const CharType* delimiter,
        const std::vector<T>& v)
    {
        return join(delimiter, v, [](const T& x) -> const T&{ return x; });
    }

    void trim(std::string* s);

    std::string trimmed(const std::string& s);

    void trim_all_and_remove_whitespace_strings(std::vector<std::string>* strings);

    std::vector<std::string> split(const std::string& s, const std::string& delimiter);
}
