#pragma once

#include <vcpkg/base/optional.h>

#include <string>
#include <vector>

namespace vcpkg
{
    struct StringRange
    {
        static std::vector<StringRange> find_all_enclosed(const StringRange& input,
                                                          const std::string& left_delim,
                                                          const std::string& right_delim);

        static StringRange find_exactly_one_enclosed(const StringRange& input,
                                                     const std::string& left_tag,
                                                     const std::string& right_tag);

        static Optional<StringRange> find_at_most_one_enclosed(const StringRange& input,
                                                               const std::string& left_tag,
                                                               const std::string& right_tag);

        StringRange() = default;
        StringRange(const std::string& s); // Implicit by design
        StringRange(const std::string::const_iterator begin, const std::string::const_iterator end);

        std::string::const_iterator begin;
        std::string::const_iterator end;

        std::string to_string() const;
    };
}
