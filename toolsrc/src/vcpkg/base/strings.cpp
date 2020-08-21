#include <vcpkg/base/checks.h>
#include <vcpkg/base/strings.h>
#include <vcpkg/base/util.h>

namespace vcpkg::Strings::details
{
    // To disambiguate between two overloads
    static bool is_space(const char c) { return std::isspace(static_cast<unsigned char>(c)) != 0; }

    // Avoids C4244 warnings because of char<->int conversion that occur when using std::tolower()
    static char toupper_char(const char c) { return (c < 'a' || c > 'z') ? c : c - 'a' + 'A'; }

    static bool icase_eq(char a, char b) { return tolower_char{}(a) == tolower_char{}(b); }

#if defined(_WIN32)
    static _locale_t& c_locale()
    {
        static _locale_t c_locale_impl = _create_locale(LC_ALL, "C");
        return c_locale_impl;
    }
#endif

    std::string format_internal(const char* fmtstr, ...)
    {
        va_list args;
        va_start(args, fmtstr);

#if defined(_WIN32)
        const int sz = _vscprintf_l(fmtstr, c_locale(), args);
#else
        const int sz = vsnprintf(nullptr, 0, fmtstr, args);
#endif
        Checks::check_exit(VCPKG_LINE_INFO, sz > 0);

        std::string output(sz, '\0');

#if defined(_WIN32)
        _vsnprintf_s_l(&output.at(0), output.size() + 1, output.size(), fmtstr, c_locale(), args);
#else
        va_start(args, fmtstr);
        vsnprintf(&output.at(0), output.size() + 1, fmtstr, args);
#endif
        va_end(args);

        return output;
    }
}

using namespace vcpkg;

#if defined(_WIN32)
std::wstring Strings::to_utf16(StringView s)
{
    std::wstring output;
    if (s.size() == 0) return output;
    Checks::check_exit(VCPKG_LINE_INFO, s.size() < size_t(INT_MAX));
    int size = MultiByteToWideChar(CP_UTF8, 0, s.data(), static_cast<int>(s.size()), nullptr, 0);
    output.resize(static_cast<size_t>(size));
    MultiByteToWideChar(CP_UTF8, 0, s.data(), static_cast<int>(s.size()), output.data(), size);
    return output;
}
#endif

#if defined(_WIN32)
std::string Strings::to_utf8(const wchar_t* w)
{
    std::string output;
    const size_t size = WideCharToMultiByte(CP_UTF8, 0, w, -1, nullptr, 0, nullptr, nullptr);
    if (size == 0) return output;
    output.resize(size - 1);
    WideCharToMultiByte(CP_UTF8, 0, w, -1, output.data(), static_cast<int>(size) - 1, nullptr, nullptr);
    return output;
}
#endif

std::string Strings::escape_string(std::string&& s, char char_to_escape, char escape_char)
{
    // Replace '\' with '\\' or '`' with '``'
    auto ret = Strings::replace_all(std::move(s), {&escape_char, 1}, std::string{escape_char, escape_char});
    // Replace '"' with '\"' or '`"'
    ret = Strings::replace_all(std::move(ret), {&char_to_escape, 1}, std::string{escape_char, char_to_escape});
    return ret;
}

static const char* case_insensitive_ascii_find(StringView s, StringView pattern)
{
    return std::search(s.begin(), s.end(), pattern.begin(), pattern.end(), &Strings::details::icase_eq);
}

bool Strings::case_insensitive_ascii_contains(StringView s, StringView pattern)
{
    return case_insensitive_ascii_find(s, pattern) != s.end();
}

bool Strings::case_insensitive_ascii_equals(StringView left, StringView right)
{
    return std::equal(left.begin(), left.end(), right.begin(), right.end(), &details::icase_eq);
}

std::string Strings::ascii_to_lowercase(std::string&& s)
{
    Strings::ascii_to_lowercase(s.begin(), s.end());
    return std::move(s);
}

std::string Strings::ascii_to_uppercase(std::string&& s)
{
    std::transform(s.begin(), s.end(), s.begin(), &details::toupper_char);
    return std::move(s);
}

bool Strings::case_insensitive_ascii_starts_with(StringView s, StringView pattern)
{
    if (s.size() < pattern.size()) return false;
    return std::equal(s.begin(), s.begin() + pattern.size(), pattern.begin(), pattern.end(), &details::icase_eq);
}

bool Strings::ends_with(StringView s, StringView pattern)
{
    if (s.size() < pattern.size()) return false;
    return std::equal(s.end() - pattern.size(), s.end(), pattern.begin(), pattern.end());
}
bool Strings::starts_with(StringView s, StringView pattern)
{
    if (s.size() < pattern.size()) return false;
    return std::equal(s.begin(), s.begin() + pattern.size(), pattern.begin(), pattern.end());
}

std::string Strings::replace_all(std::string&& s, const std::string& search, StringView rep)
{
    size_t pos = 0;
    while ((pos = s.find(search, pos)) != std::string::npos)
    {
        s.replace(pos, search.size(), rep.data(), rep.size());
        pos += rep.size();
    }
    return std::move(s);
}

std::string Strings::trim(std::string&& s)
{
    s.erase(std::find_if_not(s.rbegin(), s.rend(), details::is_space).base(), s.end());
    s.erase(s.begin(), std::find_if_not(s.begin(), s.end(), details::is_space));
    return std::move(s);
}

StringView Strings::trim(StringView sv)
{
    auto last = std::find_if_not(sv.rbegin(), sv.rend(), details::is_space).base();
    auto first = std::find_if_not(sv.begin(), sv.end(), details::is_space);
    return StringView(first, last);
}

void Strings::trim_all_and_remove_whitespace_strings(std::vector<std::string>* strings)
{
    for (std::string& s : *strings)
    {
        s = trim(std::move(s));
    }

    Util::erase_remove_if(*strings, [](const std::string& s) { return s.empty(); });
}

std::vector<std::string> Strings::split(StringView s, const char delimiter)
{
    std::vector<std::string> output;
    auto first = s.begin();
    const auto last = s.end();
    for (;;)
    {
        first = std::find_if(first, last, [=](const char c) { return c != delimiter; });
        if (first == last)
        {
            return output;
        }

        auto next = std::find(first, last, delimiter);
        output.emplace_back(first, next);
        first = next;
    }
}

const char* Strings::find_first_of(StringView input, StringView chars)
{
    return std::find_first_of(input.begin(), input.end(), chars.begin(), chars.end());
}

std::vector<StringView> Strings::find_all_enclosed(StringView input, StringView left_delim, StringView right_delim)
{
    auto it_left = input.begin();
    auto it_right = input.begin();

    std::vector<StringView> output;

    for (;;)
    {
        it_left = std::search(it_right, input.end(), left_delim.begin(), left_delim.end());
        if (it_left == input.end()) break;

        it_left += left_delim.size();

        it_right = std::search(it_left, input.end(), right_delim.begin(), right_delim.end());
        if (it_right == input.end()) break;

        output.emplace_back(it_left, it_right);

        ++it_right;
    }

    return output;
}

StringView Strings::find_exactly_one_enclosed(StringView input, StringView left_tag, StringView right_tag)
{
    std::vector<StringView> result = find_all_enclosed(input, left_tag, right_tag);
    Checks::check_exit(VCPKG_LINE_INFO,
                       result.size() == 1,
                       "Found %d sets of %s.*%s but expected exactly 1, in block:\n%s",
                       result.size(),
                       left_tag,
                       right_tag,
                       input);
    return result.front();
}

Optional<StringView> Strings::find_at_most_one_enclosed(StringView input, StringView left_tag, StringView right_tag)
{
    std::vector<StringView> result = find_all_enclosed(input, left_tag, right_tag);
    Checks::check_exit(VCPKG_LINE_INFO,
                       result.size() <= 1,
                       "Found %d sets of %s.*%s but expected at most 1, in block:\n%s",
                       result.size(),
                       left_tag,
                       right_tag,
                       input);

    if (result.empty())
    {
        return nullopt;
    }

    return result.front();
}

bool Strings::equals(StringView a, StringView b)
{
    if (a.size() != b.size()) return false;
    return std::equal(a.begin(), a.end(), b.begin(), b.end());
}

const char* Strings::search(StringView haystack, StringView needle)
{
    return std::search(haystack.begin(), haystack.end(), needle.begin(), needle.end());
}

bool Strings::contains(StringView haystack, StringView needle)
{
    return Strings::search(haystack, needle) != haystack.end();
}

namespace vcpkg::Strings
{
    namespace
    {
        template<class Integral>
        std::string b32_encode_implementation(Integral x)
        {
            static_assert(std::is_integral<Integral>::value, "b64url_encode must take an integer type");
            using Unsigned = std::make_unsigned_t<Integral>;
            auto value = static_cast<Unsigned>(x);

            // 32 values, plus the implicit \0
            constexpr static char map[33] = "ABCDEFGHIJKLMNOP"
                                            "QRSTUVWXYZ234567";

            // log2(32)
            constexpr static int shift = 5;
            // 32 - 1
            constexpr static auto mask = 31;

            // ceiling(bitsize(Integral) / log2(32))
            constexpr static auto result_size = (sizeof(value) * 8 + shift - 1) / shift;

            std::string result;
            result.reserve(result_size);

            for (std::size_t i = 0; i < result_size; ++i)
            {
                result.push_back(map[value & mask]);
                value >>= shift;
            }

            return result;
        }
    }

    std::string b32_encode(std::uint64_t x) noexcept { return b32_encode_implementation(x); }

}
