#pragma once

#include "CStringView.h"
#include <vector>

namespace vcpkg::Strings::details
{
    template<class T>
    auto to_printf_arg(const T& t) -> decltype(t.to_string())
    {
        return t.to_string();
    }

    inline const char* to_printf_arg(const std::string& s) { return s.c_str(); }

    inline const char* to_printf_arg(const char* s) { return s; }

    inline int to_printf_arg(const int s) { return s; }

    inline long long to_printf_arg(const long long s) { return s; }

    inline unsigned long to_printf_arg(const unsigned long s) { return s; }

    inline size_t to_printf_arg(const size_t s) { return s; }

    inline double to_printf_arg(const double s) { return s; }

    std::string format_internal(const char* fmtstr, ...);

    inline const wchar_t* to_wprintf_arg(const std::wstring& s) { return s.c_str(); }

    inline const wchar_t* to_wprintf_arg(const wchar_t* s) { return s; }

    std::wstring wformat_internal(const wchar_t* fmtstr, ...);
}

namespace vcpkg::Strings
{
    static constexpr const char* EMPTY = "";
    static constexpr const wchar_t* WEMPTY = L"";

    template<class... Args>
    std::string format(const char* fmtstr, const Args&... args)
    {
        using vcpkg::Strings::details::to_printf_arg;
        return details::format_internal(fmtstr, to_printf_arg(to_printf_arg(args))...);
    }

    template<class... Args>
    std::wstring wformat(const wchar_t* fmtstr, const Args&... args)
    {
        using vcpkg::Strings::details::to_wprintf_arg;
        return details::wformat_internal(fmtstr, to_wprintf_arg(to_wprintf_arg(args))...);
    }

    std::wstring to_utf16(const CStringView s);

    std::string to_utf8(const CWStringView w);

    std::string::const_iterator case_insensitive_ascii_find(const std::string& s, const std::string& pattern);

    bool case_insensitive_ascii_contains(const std::string& s, const std::string& pattern);

    int case_insensitive_ascii_compare(const CStringView left, const CStringView right);

    std::string ascii_to_lowercase(const std::string& input);

    template<class Container, class Transformer, class CharType>
    std::basic_string<CharType> join(const CharType* delimiter, const Container& v, Transformer transformer)
    {
        const auto begin = v.begin();
        const auto end = v.end();

        if (begin == end)
        {
            return std::basic_string<CharType>();
        }

        std::basic_string<CharType> output;
        output.append(transformer(*begin));
        for (auto it = std::next(begin); it != end; ++it)
        {
            output.append(delimiter);
            output.append(transformer(*it));
        }

        return output;
    }
    template<class Container, class CharType>
    std::basic_string<CharType> join(const CharType* delimiter, const Container& v)
    {
        using Element = decltype(*v.begin());
        return join(delimiter, v, [](const Element& x) -> const Element& { return x; });
    }

    void trim(std::string* s);

    std::string trimmed(const std::string& s);

    void trim_all_and_remove_whitespace_strings(std::vector<std::string>* strings);

    std::vector<std::string> split(const std::string& s, const std::string& delimiter);

    template<class T>
    std::string serialize(const T& t)
    {
        std::string ret;
        serialize(t, ret);
        return ret;
    }
}
