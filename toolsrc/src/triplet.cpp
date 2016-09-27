#include "triplet.h"
#include "vcpkg.h"
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
        auto it = std::find(this->value.cbegin(), this->value.cend(), '-');
        Checks::check_exit(it != this->value.end(), "Invalid triplet: %s", this->value);
        return std::string(this->value.cbegin(), it);
    }

    std::string triplet::system() const
    {
        auto it = std::find(this->value.cbegin(), this->value.cend(), '-');
        Checks::check_exit(it != this->value.end(), "Invalid triplet: %s", this->value);
        return std::string(it + 1, this->value.cend());
    }

    bool triplet::validate(const vcpkg_paths& paths) const
    {
        auto it = fs::directory_iterator(paths.triplets);
        for (; it != fs::directory_iterator(); ++it)
        {
            std::string triplet_file_name = it->path().stem().generic_u8string();
            if (this->value == triplet_file_name) // TODO: fuzzy compare
            {
                //this->value = triplet_file_name; // NOTE: uncomment when implementing fuzzy compare
                return true;
            }
        }
        return false;
    }
}
