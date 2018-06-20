#include "pch.h"

#include <vcpkg/base/checks.h>
#include <vcpkg/base/stringrange.h>

namespace vcpkg
{
    std::vector<VcpkgStringRange> VcpkgStringRange::find_all_enclosed(const VcpkgStringRange& input,
                                                                      const std::string& left_delim,
                                                                      const std::string& right_delim)
    {
        std::string::const_iterator it_left = input.begin;
        std::string::const_iterator it_right = input.begin;

        std::vector<VcpkgStringRange> output;

        while (true)
        {
            it_left = std::search(it_right, input.end, left_delim.cbegin(), left_delim.cend());
            if (it_left == input.end) break;

            it_left += left_delim.length();

            it_right = std::search(it_left, input.end, right_delim.cbegin(), right_delim.cend());
            if (it_right == input.end) break;

            output.emplace_back(it_left, it_right);

            ++it_right;
        }

        return output;
    }

    VcpkgStringRange VcpkgStringRange::find_exactly_one_enclosed(const VcpkgStringRange& input,
                                                                 const std::string& left_tag,
                                                                 const std::string& right_tag)
    {
        std::vector<VcpkgStringRange> result = find_all_enclosed(input, left_tag, right_tag);
        Checks::check_exit(VCPKG_LINE_INFO,
                           result.size() == 1,
                           "Found %d sets of %s.*%s but expected exactly 1, in block:\n%s",
                           result.size(),
                           left_tag,
                           right_tag,
                           input);
        return result.front();
    }

    Optional<VcpkgStringRange> VcpkgStringRange::find_at_most_one_enclosed(const VcpkgStringRange& input,
                                                                           const std::string& left_tag,
                                                                           const std::string& right_tag)
    {
        std::vector<VcpkgStringRange> result = find_all_enclosed(input, left_tag, right_tag);
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

    VcpkgStringRange::VcpkgStringRange(const std::string& s) : begin(s.cbegin()), end(s.cend()) {}

    VcpkgStringRange::VcpkgStringRange(const std::string::const_iterator begin, const std::string::const_iterator end)
        : begin(begin), end(end)
    {
    }

    std::string VcpkgStringRange::to_string() const { return std::string(this->begin, this->end); }
}
