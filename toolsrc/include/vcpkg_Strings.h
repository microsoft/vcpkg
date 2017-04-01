#pragma once

#include <vector>

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
}

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

    template <class T, class Transformer>
    std::string join(const std::string& delimiter, const std::vector<T>& v, Transformer transformer)
    {
        if (v.empty())
        {
            return std::string();
        }

        std::string output;
        size_t size = v.size();

        output.append(transformer(v.at(0)));

        for (size_t i = 1; i < size; ++i)
        {
            output.append(delimiter);
            output.append(transformer(v.at(i)));
        }

        return output;
    }

    std::string join(const std::string& delimiter, const std::vector<std::string>& v);

    template <class T, class Transformer>
    std::wstring wjoin(const std::wstring& delimiter, const std::vector<T>& v, Transformer transformer)
    {
        if (v.empty())
        {
            return std::wstring();
        }

        std::wstring output;
        size_t size = v.size();

        output.append(transformer(v.at(0)));

        for (size_t i = 1; i < size; ++i)
        {
            output.append(delimiter);
            output.append(transformer(v.at(i)));
        }

        return output;
    }

    std::wstring wjoin(const std::wstring& delimiter, const std::vector<std::wstring>& v);


    void trim(std::string* s);

    std::string trimmed(const std::string& s);

    void trim_all_and_remove_whitespace_strings(std::vector<std::string>* strings);

    std::vector<std::string> split(const std::string& s, const std::string& delimiter);
}
