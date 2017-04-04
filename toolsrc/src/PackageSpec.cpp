#include "pch.h"
#include "PackageSpec.h"

namespace vcpkg
{
    static bool is_valid_package_spec_char(char c)
    {
        return (c == '-') || isdigit(c) || (isalpha(c) && islower(c));
    }

    Expected<PackageSpec> PackageSpec::from_string(const std::string& spec_as_string, const Triplet& default_target_triplet)
    {
        auto pos = spec_as_string.find(':');
        if (pos == std::string::npos)
        {
            return from_name_and_triplet(spec_as_string, default_target_triplet);
        }

        auto pos2 = spec_as_string.find(':', pos + 1);
        if (pos2 != std::string::npos)
        {
            return std::error_code(PackageSpecParseResult::TOO_MANY_COLONS);
        }

        const std::string name = spec_as_string.substr(0, pos);
        const Triplet target_triplet = Triplet::from_canonical_name(spec_as_string.substr(pos + 1));
        return from_name_and_triplet(name, target_triplet);
    }

    Expected<PackageSpec> PackageSpec::from_name_and_triplet(const std::string& name, const Triplet& target_triplet)
    {
        if (std::find_if_not(name.cbegin(), name.cend(), is_valid_package_spec_char) != name.end())
        {
            return std::error_code(PackageSpecParseResult::INVALID_CHARACTERS);
        }

        PackageSpec p;
        p.m_name = name;
        p.m_target_triplet = target_triplet;
        return p;
    }

    const std::string& PackageSpec::name() const
    {
        return this->m_name;
    }

    const Triplet& PackageSpec::target_triplet() const
    {
        return this->m_target_triplet;
    }

    std::string PackageSpec::display_name() const
    {
        return Strings::format("%s:%s", this->name(), this->target_triplet());
    }

    std::string PackageSpec::dir() const
    {
        return Strings::format("%s_%s", this->m_name, this->m_target_triplet);
    }

    std::string PackageSpec::to_string() const
    {
        return this->display_name();
    }

    std::string to_printf_arg(const PackageSpec& spec)
    {
        return spec.to_string();
    }

    bool operator==(const PackageSpec& left, const PackageSpec& right)
    {
        return left.name() == right.name() && left.target_triplet() == right.target_triplet();
    }

    std::ostream& operator<<(std::ostream& os, const PackageSpec& spec)
    {
        return os << spec.to_string();
    }
}
