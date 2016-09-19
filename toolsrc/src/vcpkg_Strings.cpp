#include "vcpkg_Strings.h"

#include <cstdarg>
#include <algorithm>
#include <codecvt>
#include <iterator>

namespace vcpkg {namespace Strings {namespace details
{
    std::string format_internal(const char* fmtstr, ...)
    {
        va_list lst;
        va_start(lst, fmtstr);

        auto sz = _vscprintf(fmtstr, lst);
        std::string output(sz, '\0');
        _vsnprintf_s(&output[0], output.size() + 1, output.size() + 1, fmtstr, lst);
        va_end(lst);

        return output;
    }

    std::wstring format_internal(const wchar_t* fmtstr, ...)
    {
        va_list lst;
        va_start(lst, fmtstr);

        auto sz = _vscwprintf(fmtstr, lst);
        std::wstring output(sz, '\0');
        _vsnwprintf_s(&output[0], output.size() + 1, output.size() + 1, fmtstr, lst);
        va_end(lst);

        return output;
    }
}}}

namespace vcpkg {namespace Strings
{
    std::wstring utf8_to_utf16(const std::string& s)
    {
        std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>, wchar_t> conversion;
        return conversion.from_bytes(s);
    }

    std::string utf16_to_utf8(const std::wstring& w)
    {
        std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>, wchar_t> conversion;
        return conversion.to_bytes(w);
    }

    std::string::const_iterator case_insensitive_find(const std::string& s, const std::string& pattern)
    {
        std::string patter_as_lower_case;
        std::transform(pattern.begin(), pattern.end(), back_inserter(patter_as_lower_case), tolower);
        return search(s.begin(), s.end(), patter_as_lower_case.begin(), patter_as_lower_case.end(), [](const char a, const char b)
                      {
                          return (tolower(a) == b);
                      });
    }
}}
