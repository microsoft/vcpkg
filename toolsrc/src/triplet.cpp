#include "triplet.h"
#include "vcpkg_Checks.h"
#include <algorithm>

namespace vcpkg
{
    const triplet triplet::X86_WINDOWS = from_canonical_name("x86-windows");
    const triplet triplet::X64_WINDOWS = from_canonical_name("x64-windows");
    const triplet triplet::X86_UWP = from_canonical_name("x86-uwp");
    const triplet triplet::X64_UWP = from_canonical_name("x64-uwp");
    const triplet triplet::ARM_UWP = from_canonical_name("arm-uwp");

    std::string to_string(const triplet& t)
    {
        return t.canonical_name();
    }

    std::string to_printf_arg(const triplet& t)
    {
        return to_string(t);
    }

    bool operator==(const triplet& left, const triplet& right)
    {
        return left.canonical_name() == right.canonical_name();
    }

    bool operator!=(const triplet& left, const triplet& right)
    {
        return !(left == right);
    }

    std::ostream& operator<<(std::ostream& os, const triplet& t)
    {
        return os << to_string(t);
    }

    triplet triplet::from_canonical_name(const std::string& triplet_as_string)
    {
        std::string s(triplet_as_string);
        std::transform(s.begin(), s.end(), s.begin(), ::tolower);

        auto it = std::find(s.cbegin(), s.cend(), '-');
        Checks::check_exit(it != s.cend(), "Invalid triplet: %s", triplet_as_string);

        triplet t;
        t.m_canonical_name = s;
        return t;
    }

    const std::string& triplet::canonical_name() const
    {
        return this->m_canonical_name;
    }

    std::string triplet::architecture() const
    {
        auto it = std::find(this->m_canonical_name.cbegin(), this->m_canonical_name.cend(), '-');
        return std::string(this->m_canonical_name.cbegin(), it);
    }

    std::string triplet::system() const
    {
        auto it = std::find(this->m_canonical_name.cbegin(), this->m_canonical_name.cend(), '-');
        return std::string(it + 1, this->m_canonical_name.cend());
    }
}
