#include "triplet.h"
#include "vcpkg_System.h"
#include "vcpkg_Checks.h"

namespace vcpkg
{
    const triplet triplet::X86_WINDOWS = {"x86-windows"};
    const triplet triplet::X64_WINDOWS = {"x64-windows"};
    const triplet triplet::X86_UWP = {"x86-uwp"};
    const triplet triplet::X64_UWP = {"x64-uwp"};
    const triplet triplet::ARM_UWP = {"arm-uwp"};

    std::string to_string(const triplet& t)
    {
        return t.value;
    }

    std::string to_printf_arg(const triplet& t)
    {
        return to_string(t);
    }

    bool operator==(const triplet& left, const triplet& right)
    {
        return left.value == right.value;
    }

    bool operator!=(const triplet& left, const triplet& right)
    {
        return !(left == right);
    }

    std::ostream& operator<<(std::ostream& os, const triplet& t)
    {
        return os << to_string(t);
    }

    std::string triplet::architecture() const
    {
        if (*this == X86_WINDOWS || *this == X86_UWP)
            return "x86";
        if (*this == X64_WINDOWS || *this == X64_UWP)
            return "x64";
        if (*this == ARM_UWP)
            return "arm";

        Checks::exit_with_message("Unknown architecture: %s", value);
    }

    std::string triplet::system() const
    {
        if (*this == X86_WINDOWS || *this == X64_WINDOWS)
            return "windows";
        if (*this == X86_UWP || *this == X64_UWP || *this == ARM_UWP)
            return "uwp";

        Checks::exit_with_message("Unknown system: %s", value);
    }
}
