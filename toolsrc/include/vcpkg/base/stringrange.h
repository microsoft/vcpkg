#pragma once

#include <vcpkg/base/optional.h>

#include <string>
#include <vector>

namespace vcpkg
{
    struct VcpkgStringRange
    {
        static std::vector<VcpkgStringRange> find_all_enclosed(const VcpkgStringRange& input,
                                                               const std::string& left_delim,
                                                               const std::string& right_delim);

        static VcpkgStringRange find_exactly_one_enclosed(const VcpkgStringRange& input,
                                                          const std::string& left_tag,
                                                          const std::string& right_tag);

        static Optional<VcpkgStringRange> find_at_most_one_enclosed(const VcpkgStringRange& input,
                                                                    const std::string& left_tag,
                                                                    const std::string& right_tag);

        VcpkgStringRange() = default;
        VcpkgStringRange(const std::string& s); // Implicit by design
        VcpkgStringRange(const std::string::const_iterator begin, const std::string::const_iterator end);

        std::string::const_iterator begin;
        std::string::const_iterator end;

        std::string to_string() const;
    };
}
