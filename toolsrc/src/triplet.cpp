#include "pch.h"
#include "Triplet.h"
#include "vcpkg_Checks.h"
#include "vcpkg_Strings.h"

namespace vcpkg
{
    const Triplet Triplet::X86_WINDOWS = from_canonical_name("x86-windows");
    const Triplet Triplet::X64_WINDOWS = from_canonical_name("x64-windows");
    const Triplet Triplet::X86_UWP = from_canonical_name("x86-uwp");
    const Triplet Triplet::X64_UWP = from_canonical_name("x64-uwp");
    const Triplet Triplet::ARM_UWP = from_canonical_name("arm-uwp");

    std::string to_string(const Triplet& t)
    {
        return t.canonical_name();
    }

    std::string to_printf_arg(const Triplet& t)
    {
        return to_string(t);
    }

    bool operator==(const Triplet& left, const Triplet& right)
    {
        return left.canonical_name() == right.canonical_name();
    }

    bool operator!=(const Triplet& left, const Triplet& right)
    {
        return !(left == right);
    }

    std::ostream& operator<<(std::ostream& os, const Triplet& t)
    {
        return os << to_string(t);
    }

    Triplet Triplet::from_canonical_name(const std::string& triplet_as_string)
    {
        const std::string s(Strings::ascii_to_lowercase(triplet_as_string));
        auto it = std::find(s.cbegin(), s.cend(), '-');
        Checks::check_exit(VCPKG_LINE_INFO, it != s.cend(), "Invalid triplet: %s", triplet_as_string);

        Triplet t;
        t.m_canonical_name = s;
        return t;
    }

    const std::string& Triplet::canonical_name() const
    {
        return this->m_canonical_name;
    }

    std::string Triplet::architecture() const
    {
        auto it = std::find(this->m_canonical_name.cbegin(), this->m_canonical_name.cend(), '-');
        return std::string(this->m_canonical_name.cbegin(), it);
    }

    std::string Triplet::system() const
    {
        auto it = std::find(this->m_canonical_name.cbegin(), this->m_canonical_name.cend(), '-');
        return std::string(it + 1, this->m_canonical_name.cend());
    }
}
