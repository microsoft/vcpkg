#pragma once

#include <vcpkg/base/cstringview.h>
#include <vcpkg/base/optional.h>
#include <vcpkg/base/stringliteral.h>
#include <vcpkg/base/stringview.h>
#include <vcpkg/base/view.h>

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

    inline void append_internal(std::string& into, char c) { into += c; }
    template<class T, class = decltype(std::to_string(std::declval<T>()))>
    inline void append_internal(std::string& into, T x)
    {
        into += std::to_string(x);
    }
    inline void append_internal(std::string& into, const char* v) { into.append(v); }
    inline void append_internal(std::string& into, const std::string& s) { into.append(s); }

    template<class T, class = decltype(std::declval<const T&>().to_string(std::declval<std::string&>()))>
    void append_internal(std::string& into, const T& t)
    {
        t.to_string(into);
    }

    template<class T, class = void, class = decltype(to_string(std::declval<std::string&>(), std::declval<const T&>()))>
    void append_internal(std::string& into, const T& t)
    {
        to_string(into, t);
    }
}

namespace vcpkg::Strings
{
    template<class Arg>
    std::string& append(std::string& into, const Arg& a)
    {
        details::append_internal(into, a);
        return into;
    }
    template<class Arg, class... Args>
    std::string& append(std::string& into, const Arg& a, const Args&... args)
    {
        append(into, a);
        return append(into, args...);
    }

    template<class... Args>
    [[nodiscard]] std::string concat(const Args&... args)
    {
        std::string ret;
        append(ret, args...);
        return ret;
    }

    template<class... Args, class = void>
    std::string concat_or_view(const Args&... args)
    {
        return Strings::concat(args...);
    }

    template<class T, class = std::enable_if_t<std::is_convertible<T, StringView>::value>>
    StringView concat_or_view(const T& v)
    {
        return v;
    }

    template<class... Args>
    std::string format(const char* fmtstr, const Args&... args)
    {
        using vcpkg::Strings::details::to_printf_arg;
        return details::format_internal(fmtstr, to_printf_arg(to_printf_arg(args))...);
    }

#if defined(_WIN32)
    std::wstring to_utf16(StringView s);

    std::string to_utf8(const wchar_t* w);
    inline std::string to_utf8(const std::wstring& ws) { return to_utf8(ws.c_str()); }
#endif

    std::string escape_string(std::string&& s, char char_to_escape, char escape_char);

    bool case_insensitive_ascii_contains(StringView s, StringView pattern);

    bool case_insensitive_ascii_equals(StringView left, StringView right);

    std::string ascii_to_lowercase(std::string&& s);

    std::string ascii_to_uppercase(std::string&& s);

    bool case_insensitive_ascii_starts_with(StringView s, StringView pattern);
    bool ends_with(StringView s, StringView pattern);
    bool starts_with(StringView s, StringView pattern);

    template<class InputIterator, class Transformer>
    std::string join(const char* delimiter, InputIterator begin, InputIterator end, Transformer transformer)
    {
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

    template<class Container, class Transformer>
    std::string join(const char* delimiter, const Container& v, Transformer transformer)
    {
        const auto begin = v.begin();
        const auto end = v.end();

        return join(delimiter, begin, end, transformer);
    }

    template<class InputIterator>
    std::string join(const char* delimiter, InputIterator begin, InputIterator end)
    {
        using Element = decltype(*begin);
        return join(delimiter, begin, end, [](const Element& x) -> const Element& { return x; });
    }

    template<class Container>
    std::string join(const char* delimiter, const Container& v)
    {
        using Element = decltype(*v.begin());
        return join(delimiter, v, [](const Element& x) -> const Element& { return x; });
    }

    std::string replace_all(std::string&& s, const std::string& search, StringView rep);

    std::string trim(std::string&& s);

    void trim_all_and_remove_whitespace_strings(std::vector<std::string>* strings);

    std::vector<std::string> split(const std::string& s, const std::string& delimiter);

    std::vector<std::string> split(const std::string& s, const std::string& delimiter, size_t max_count);

    std::vector<StringView> find_all_enclosed(StringView input, StringView left_delim, StringView right_delim);

    StringView find_exactly_one_enclosed(StringView input, StringView left_tag, StringView right_tag);

    Optional<StringView> find_at_most_one_enclosed(StringView input, StringView left_tag, StringView right_tag);

    bool equals(StringView a, StringView b);

    template<class T>
    std::string serialize(const T& t)
    {
        std::string ret;
        serialize(t, ret);
        return ret;
    }

    const char* search(StringView haystack, StringView needle);

    bool contains(StringView haystack, StringView needle);
}
