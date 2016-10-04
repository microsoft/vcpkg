#include "package_spec.h"
#include <algorithm>

namespace vcpkg
{
    expected<package_spec> package_spec::from_string(const std::string& spec_as_string, const triplet& default_target_triplet)
    {
        std::string s(spec_as_string);
        std::transform(s.begin(), s.end(), s.begin(), ::tolower);

        auto pos = s.find(':');
        if (pos == std::string::npos)
        {
            return from_name_and_triplet(s, default_target_triplet);
        }

        auto pos2 = s.find(':', pos + 1);
        if (pos2 != std::string::npos)
        {
            return std::error_code(package_spec_parse_result::too_many_colons);
        }

        const std::string name = s.substr(0, pos);
        const triplet target_triplet = triplet::from_canonical_name(s.substr(pos + 1));
        return from_name_and_triplet(name, target_triplet);
    }

    package_spec package_spec::from_name_and_triplet(const std::string& name, const triplet& target_triplet)
    {
        std::string n(name);
        std::transform(n.begin(), n.end(), n.begin(), ::tolower);

        package_spec p;
        p.m_name = n;
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

    std::string package_spec::dir() const
    {
        return Strings::format("%s_%s", this->m_name, this->m_target_triplet);
    }

    std::string to_string(const package_spec& spec)
    {
        return Strings::format("%s:%s", spec.name(), spec.target_triplet());
    }

    std::string to_printf_arg(const package_spec& spec)
    {
        return to_string(spec);
    }

    bool operator==(const package_spec& left, const package_spec& right)
    {
        return left.name() == right.name() && left.target_triplet() == right.target_triplet();
    }

    std::ostream& operator<<(std::ostream& os, const package_spec& spec)
    {
        return os << to_string(spec);
    }
}
