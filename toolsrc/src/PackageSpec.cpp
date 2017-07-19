#include "pch.h"

#include "PackageSpec.h"
#include "vcpkg_Util.h"

namespace vcpkg
{
    static bool is_valid_package_spec_char(char c)
    {
        return (c == '-') || isdigit(c) || (isalpha(c) && islower(c)) || (c == '[') || (c == ']');
    }

    ExpectedT<FullPackageSpec, PackageSpecParseResult> FullPackageSpec::from_string(const std::string& spec_as_string,
                                                                                    const Triplet& default_triplet)
    {
        auto pos = spec_as_string.find(':');
        auto pos_l_bracket = spec_as_string.find('[');
        auto pos_r_bracket = spec_as_string.find(']');

        FullPackageSpec f;
        if (pos == std::string::npos && pos_l_bracket == std::string::npos)
        {
            f.package_spec =
                PackageSpec::from_name_and_triplet(spec_as_string, default_triplet).value_or_exit(VCPKG_LINE_INFO);
            return f;
        }
        else if (pos == std::string::npos)
        {
            if (pos_r_bracket == std::string::npos || pos_l_bracket >= pos_r_bracket)
            {
                return PackageSpecParseResult::INVALID_CHARACTERS;
            }
            const std::string name = spec_as_string.substr(0, pos_l_bracket);
            f.package_spec = PackageSpec::from_name_and_triplet(name, default_triplet).value_or_exit(VCPKG_LINE_INFO);
            f.features = parse_comma_list(spec_as_string.substr(pos_l_bracket + 1, pos_r_bracket - pos_l_bracket - 1));
            return f;
        }
        else if (pos_l_bracket == std::string::npos && pos_r_bracket == std::string::npos)
        {
            const std::string name = spec_as_string.substr(0, pos);
            const Triplet triplet = Triplet::from_canonical_name(spec_as_string.substr(pos + 1));
            f.package_spec = PackageSpec::from_name_and_triplet(name, triplet).value_or_exit(VCPKG_LINE_INFO);
        }
        else
        {
            if (pos_r_bracket == std::string::npos || pos_l_bracket >= pos_r_bracket)
            {
                return PackageSpecParseResult::INVALID_CHARACTERS;
            }
            const std::string name = spec_as_string.substr(0, pos_l_bracket);
            f.features = parse_comma_list(spec_as_string.substr(pos_l_bracket + 1, pos_r_bracket - pos_l_bracket - 1));
            const Triplet triplet = Triplet::from_canonical_name(spec_as_string.substr(pos + 1));
            f.package_spec = PackageSpec::from_name_and_triplet(name, triplet).value_or_exit(VCPKG_LINE_INFO);
        }

        auto pos2 = spec_as_string.find(':', pos + 1);
        if (pos2 != std::string::npos)
        {
            return PackageSpecParseResult::TOO_MANY_COLONS;
        }
        return f;
    }

    ExpectedT<PackageSpec, PackageSpecParseResult> PackageSpec::from_name_and_triplet(const std::string& name,
                                                                                      const Triplet& triplet)
    {
        if (Util::find_if_not(name, is_valid_package_spec_char) != name.end())
        {
            return PackageSpecParseResult::INVALID_CHARACTERS;
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
