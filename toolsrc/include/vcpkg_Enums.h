#pragma once
#include "LineInfo.h"
#include <string>

namespace vcpkg::Enums
{
    std::string nullvalue_to_string(const std::string& enum_name);

    [[noreturn]] void nullvalue_used(const LineInfo& line_info, const std::string& enum_name);

    template<class Enum>
    struct enum_range
    {
        static_assert(Enum::COUNT, "Enum must start at 0, be dense, and have a COUNT sentinel");

        struct iterator
        {
            iterator() : e(0) {}
            iterator(Enum u) : e(static_cast<underlying_type>(u)) {}

            void operator++() { ++e; };
            Enum operator*() const { return static_cast<Enum>(e); }
            bool operator!=(const iterator& o) const { return o.e != e; }

        private:
            using underlying_type = int;
            underlying_type e;
        };

        iterator begin() const { return iterator{}; }
        iterator end() const { return iterator{Enum::COUNT}; }
    };

    template<class Enum>
    enum_range<Enum> make_enum_range()
    {
        return {};
    }
}
