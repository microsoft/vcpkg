#include "package_spec.h"

namespace vcpkg
{
    expected<package_spec> package_spec::from_string(const std::string& spec, const triplet& default_target_triplet)
    {
        auto pos = spec.find(':');
        if (pos == std::string::npos)
        {
            return package_spec{spec, default_target_triplet};
        }

        auto pos2 = spec.find(':', pos + 1);
        if (pos2 != std::string::npos)
        {
            return std::error_code(package_spec_parse_result::too_many_colons);
        }

        return package_spec{spec.substr(0, pos), triplet::from_canonical_name(spec.substr(pos + 1))};
    }

    std::string package_spec::dir() const
    {
        return Strings::format("%s_%s", this->name, this->target_triplet);
    }

    std::string to_string(const package_spec& spec)
    {
        return Strings::format("%s:%s", spec.name, spec.target_triplet);
    }

    std::string to_printf_arg(const package_spec& spec)
    {
        return to_string(spec);
    }

    bool operator==(const package_spec& left, const package_spec& right)
    {
        return left.name == right.name && left.target_triplet == right.target_triplet;
    }

    std::ostream& operator<<(std::ostream& os, const package_spec& spec)
    {
        return os << to_string(spec);
    }
}
