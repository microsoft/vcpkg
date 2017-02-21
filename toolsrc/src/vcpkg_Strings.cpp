#include "pch.h"
#include "vcpkg_Strings.h"

namespace vcpkg::Strings::details
{
    // To disambiguate between two overloads
    static const auto isspace = [](const char c)
    {
        return std::isspace(c);
    };

    // Avoids C4244 warnings because of char<->int conversion that occur when using std::tolower()
    static char tolower_char(const char c)
    {
        return static_cast<char>(std::tolower(c));
    }

    std::string format_internal(const char* fmtstr, ...)
    {
        va_list lst;
        va_start(lst, fmtstr);

        const int sz = _vscprintf(fmtstr, lst);
        std::string output(sz, '\0');
        _vsnprintf_s(&output[0], output.size() + 1, output.size() + 1, fmtstr, lst);
        va_end(lst);

        return output;
    }

    std::wstring wformat_internal(const wchar_t* fmtstr, ...)
    {
        va_list lst;
        va_start(lst, fmtstr);

        const int sz = _vscwprintf(fmtstr, lst);
        std::wstring output(sz, '\0');
        _vsnwprintf_s(&output[0], output.size() + 1, output.size() + 1, fmtstr, lst);
        va_end(lst);

        return output;
    }
}

namespace vcpkg::Strings
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

    std::string::const_iterator case_insensitive_ascii_find(const std::string& s, const std::string& pattern)
    {
        const std::string pattern_as_lower_case(ascii_to_lowercase(pattern));
        return search(s.begin(), s.end(), pattern_as_lower_case.begin(), pattern_as_lower_case.end(), [](const char a, const char b)
                      {
                          return details::tolower_char(a) == b;
                      });
    }

    std::string ascii_to_lowercase(const std::string& input)
    {
        std::string output(input);
        std::transform(output.begin(), output.end(), output.begin(), &details::tolower_char);
        return output;
    }

    std::string join(const std::vector<std::string>& v, const std::string& prefix, const std::string& delimiter, const std::string& suffix)
    {
        return join(v, prefix, delimiter, suffix, [](const std::string& i) -> std::string
        {
            return i;
        });
    }

    Joiner Joiner::on(const std::string& delimiter)
    {
        return Joiner(delimiter);
    }

    Joiner& Joiner::prefix(const std::string& prefix)
    {
        this->m_prefix = prefix;
        return *this;
    }

    Joiner& Joiner::suffix(const std::string& suffix)
    {
        this->m_suffix = suffix;
        return *this;
    }

    std::string Joiner::join(const std::vector<std::string>& v) const
    {
        return Strings::join(v, this->m_prefix, this->m_delimiter, this->m_suffix);
    }

    Joiner::Joiner(const std::string& delimiter) : m_prefix(""), m_delimiter(delimiter), m_suffix("")
    {
    }

    void trim(std::string* s)
    {
        s->erase(std::find_if_not(s->rbegin(), s->rend(), details::isspace).base(), s->end());
        s->erase(s->begin(), std::find_if_not(s->begin(), s->end(), details::isspace));
    }

    std::string trimmed(const std::string& s)
    {
        auto whitespace_back = std::find_if_not(s.rbegin(), s.rend(), details::isspace).base();
        auto whitespace_front = std::find_if_not(s.begin(), whitespace_back, details::isspace);
        return std::string(whitespace_front, whitespace_back);
    }

    void trim_all_and_remove_whitespace_strings(std::vector<std::string>* strings)
    {
        for (std::string& s : *strings)
        {
            trim(&s);
        }

        strings->erase(std::remove_if(strings->begin(), strings->end(), [](const std::string& s)-> bool
                                      {
                                          return s == "";
                                      }), strings->end());
    }

    std::vector<std::string> split(const std::string& s, const std::string& delimiter)
    {
        std::vector<std::string> output;

        size_t i = 0;
        for (size_t pos = s.find(delimiter); pos != std::string::npos; pos = s.find(delimiter, pos))
        {
            output.push_back(s.substr(i, pos - i));
            i = ++pos;
        }

        // Add the rest of the string after the last delimiter, unless there is nothing after it
        if (i != s.length())
        {
            output.push_back(s.substr(i, s.length()));
        }

        return output;
    }
}
