#include "pch.h"

#include "PackageSpec.h"
#include "vcpkg_Util.h"

namespace vcpkg
{
    static bool is_valid_package_spec_char(char c) { return (c == '-') || isdigit(c) || (isalpha(c) && islower(c)); }

    Expected<PackageSpec> PackageSpec::from_string(const std::string& spec_as_string, const Triplet& default_triplet)
    {
        auto pos = spec_as_string.find(':');
        if (pos == std::string::npos)
        {
            return from_name_and_triplet(spec_as_string, default_triplet);
        }

        auto pos2 = spec_as_string.find(':', pos + 1);
        if (pos2 != std::string::npos)
        {
            return std::error_code(PackageSpecParseResult::TOO_MANY_COLONS);
        }

        const std::string name = spec_as_string.substr(0, pos);
        const Triplet triplet = Triplet::from_canonical_name(spec_as_string.substr(pos + 1));
        return from_name_and_triplet(name, triplet);
    }

    Expected<PackageSpec> PackageSpec::from_name_and_triplet(const std::string& name, const Triplet& triplet)
    {
        if (Util::find_if_not(name, is_valid_package_spec_char) != name.end())
        {
            return std::error_code(PackageSpecParseResult::INVALID_CHARACTERS);
        }

        PackageSpec p;
        p.m_name = name;
        p.m_triplet = triplet;
        return p;
    }

    const std::string& PackageSpec::name() const { return this->m_name; }

    const Triplet& PackageSpec::triplet() const { return this->m_triplet; }

    std::string PackageSpec::dir() const { return Strings::format("%s_%s", this->m_name, this->m_triplet); }

    std::string PackageSpec::to_string(const std::string& name, const Triplet& triplet)
    {
        return Strings::format("%s:%s", name, triplet);
    }
    std::string PackageSpec::to_string() const { return to_string(this->name(), this->triplet()); }

    bool operator==(const PackageSpec& left, const PackageSpec& right)
    {
        return left.name() == right.name() && left.triplet() == right.triplet();
    }

    bool operator!=(const PackageSpec& left, const PackageSpec& right) { return !(left == right); }
}
