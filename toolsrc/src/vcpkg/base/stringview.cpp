#include "pch.h"

#include <vcpkg/base/checks.h>
#include <vcpkg/base/lineinfo.h>
#include <vcpkg/base/stringview.h>

#include <cstring>

namespace vcpkg
{
    std::vector<StringView> StringView::find_all_enclosed(const StringView& input,
                                                          const std::string& left_delim,
                                                          const std::string& right_delim)
    {
        auto it_left = input.begin();
        auto it_right = input.begin();

        std::vector<StringView> output;

        while (true)
        {
            it_left = std::search(it_right, input.end(), left_delim.cbegin(), left_delim.cend());
            if (it_left == input.end()) break;

            it_left += left_delim.length();

            it_right = std::search(it_left, input.end(), right_delim.cbegin(), right_delim.cend());
            if (it_right == input.end()) break;

            output.emplace_back(it_left, it_right);

            ++it_right;
        }

        return output;
    }

    StringView StringView::find_exactly_one_enclosed(const StringView& input,
                                                     const std::string& left_tag,
                                                     const std::string& right_tag)
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

    Optional<StringView> StringView::find_at_most_one_enclosed(const StringView& input,
                                                               const std::string& left_tag,
                                                               const std::string& right_tag)
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

    StringView::StringView(const std::string& s) : m_ptr(s.data()), m_size(s.size()) {}

    std::string StringView::to_string() const { return std::string(m_ptr, m_size); }
    void StringView::to_string(std::string& s) const { s.append(m_ptr, m_size); }

    bool operator==(StringView lhs, StringView rhs) noexcept
    {
        return lhs.size() == rhs.size() && memcmp(lhs.data(), rhs.data(), lhs.size()) == 0;
    }

    bool operator!=(StringView lhs, StringView rhs) noexcept { return !(lhs == rhs); }
}
