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
        auto res = ParsedSpecifier::from_string(spec_as_string);
        if (auto p = res.get())
        {
            FullPackageSpec fspec;
            Triplet t = p->triplet.empty() ? default_triplet : Triplet::from_canonical_name(p->triplet);
            fspec.package_spec = PackageSpec::from_name_and_triplet(p->name, t).value_or_exit(VCPKG_LINE_INFO);
            fspec.features = std::move(p->features);
            return fspec;
        }
        return res.error();
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

    ExpectedT<ParsedSpecifier, PackageSpecParseResult> ParsedSpecifier::from_string(const std::string& input)
    {
        auto pos = input.find(':');
        auto pos_l_bracket = input.find('[');
        auto pos_r_bracket = input.find(']');

        ParsedSpecifier f;
        if (pos == std::string::npos && pos_l_bracket == std::string::npos)
        {
            f.name = input;
            return f;
        }
        else if (pos == std::string::npos)
        {
            if (pos_r_bracket == std::string::npos || pos_l_bracket >= pos_r_bracket)
            {
                return PackageSpecParseResult::INVALID_CHARACTERS;
            }
            const std::string name = input.substr(0, pos_l_bracket);
            f.name = name;
            f.features = parse_comma_list(input.substr(pos_l_bracket + 1, pos_r_bracket - pos_l_bracket - 1));
            return f;
        }
        else if (pos_l_bracket == std::string::npos && pos_r_bracket == std::string::npos)
        {
            const std::string name = input.substr(0, pos);
            f.triplet = input.substr(pos + 1);
            f.name = name;
        }
        else
        {
            if (pos_r_bracket == std::string::npos || pos_l_bracket >= pos_r_bracket)
            {
                return PackageSpecParseResult::INVALID_CHARACTERS;
            }
            const std::string name = input.substr(0, pos_l_bracket);
            f.features = parse_comma_list(input.substr(pos_l_bracket + 1, pos_r_bracket - pos_l_bracket - 1));
            f.triplet = input.substr(pos + 1);
            f.name = name;
        }

        auto pos2 = input.find(':', pos + 1);
        if (pos2 != std::string::npos)
        {
            return PackageSpecParseResult::TOO_MANY_COLONS;
        }
        return f;
    }
}
