#pragma once

#include <vcpkg/base/cstringview.h>

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

    template<class T, class = std::enable_if_t<std::is_arithmetic<T>::value>>
    T to_printf_arg(T s)
    {
        return s;
    }

    std::string format_internal(const char* fmtstr, ...);
}

namespace vcpkg::Strings
{
    template<class... Args>
    std::string format(const char* fmtstr, const Args&... args)
    {
        using vcpkg::Strings::details::to_printf_arg;
        return details::format_internal(fmtstr, to_printf_arg(to_printf_arg(args))...);
    }

    std::wstring to_utf16(const CStringView& s);

    std::string to_utf8(const CWStringView& w);

    std::string::const_iterator case_insensitive_ascii_find(const std::string& s, const std::string& pattern);

    bool case_insensitive_ascii_contains(const std::string& s, const std::string& pattern);

    bool case_insensitive_ascii_equals(const CStringView left, const CStringView right);

    std::string ascii_to_lowercase(const std::string& input);

    bool case_insensitive_ascii_starts_with(const std::string& s, const std::string& pattern);

    template<class Container, class Transformer>
    std::string join(const char* delimiter, const Container& v, Transformer transformer)
    {
        const auto begin = v.begin();
        const auto end = v.end();

        if (begin == end)
        {
            return std::string();
        }

        std::string output;
        output.append(transformer(*begin));
        for (auto it = std::next(begin); it != end; ++it)
        {
            output.append(delimiter);
            output.append(transformer(*it));
        }

        return output;
    }
    template<class Container>
    std::string join(const char* delimiter, const Container& v)
    {
        using Element = decltype(*v.begin());
        return join(delimiter, v, [](const Element& x) -> const Element& { return x; });
    }

    std::string replace_all(std::string&& s, const std::string& search, const std::string& rep);

    std::string trim(std::string&& s);

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
