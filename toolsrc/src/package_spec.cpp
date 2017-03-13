#include "pch.h"
#include "package_spec.h"

namespace vcpkg
{
    static bool is_valid_package_spec_char(char c)
    {
        return (c == '-') || isdigit(c) || (isalpha(c) && islower(c));
    }

    expected<package_spec> package_spec::from_string(const std::string& spec_as_string, const triplet& default_target_triplet)
    {
        auto pos = spec_as_string.find(':');
        if (pos == std::string::npos)
        {
            return from_name_and_triplet(spec_as_string, default_target_triplet);
        }

        auto pos2 = spec_as_string.find(':', pos + 1);
        if (pos2 != std::string::npos)
        {
            return std::error_code(package_spec_parse_result::TOO_MANY_COLONS);
        }

        const std::string name = spec_as_string.substr(0, pos);
        const triplet target_triplet = triplet::from_canonical_name(spec_as_string.substr(pos + 1));
        return from_name_and_triplet(name, target_triplet);
    }

    expected<package_spec> package_spec::from_name_and_triplet(const std::string& name, const triplet& target_triplet)
    {
        if (std::find_if_not(name.cbegin(), name.cend(), is_valid_package_spec_char) != name.end())
        {
            return std::error_code(package_spec_parse_result::INVALID_CHARACTERS);
        }

        package_spec p;
        p.m_name = name;
        p.m_target_triplet = target_triplet;
        return p;
    }

    const std::string& package_spec::name() const
    {
        return this->m_name;
    }

    const triplet& package_spec::target_triplet() const
    {
        return this->m_target_triplet;
    }

    std::string package_spec::display_name() const
    {
        return Strings::format("%s:%s", this->name(), this->target_triplet());
    }

    std::string package_spec::dir() const
    {
        return Strings::format("%s_%s", this->m_name, this->m_target_triplet);
    }

    std::string package_spec::toString() const
    {
        return this->display_name();
    }

    std::string to_printf_arg(const package_spec& spec)
    {
        return spec.toString();
    }

    bool operator==(const package_spec& left, const package_spec& right)
    {
        return left.name() == right.name() && left.target_triplet() == right.target_triplet();
    }

    std::ostream& operator<<(std::ostream& os, const package_spec& spec)
    {
        return os << spec.toString();
    }
}
