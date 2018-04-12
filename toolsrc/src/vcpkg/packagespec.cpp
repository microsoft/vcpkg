#include "pch.h"

#include <vcpkg/base/util.h>
#include <vcpkg/packagespec.h>
#include <vcpkg/packagespecparseresult.h>
#include <vcpkg/parse.h>

using vcpkg::Parse::parse_comma_list;

namespace vcpkg
{
    static bool is_valid_package_spec_char(char c)
    {
        return (c == '-') || isdigit(c) || (isalpha(c) && islower(c)) || (c == '[') || (c == ']');
    }

    std::string FeatureSpec::to_string() const
    {
        if (feature().empty()) return spec().to_string();
        return Strings::format("%s[%s]:%s", name(), feature(), triplet());
    }

    std::vector<FeatureSpec> FeatureSpec::from_strings_and_triplet(const std::vector<std::string>& depends,
                                                                   const Triplet& triplet)
    {
        std::vector<FeatureSpec> f_specs;
        for (auto&& depend : depends)
        {
            auto maybe_spec = ParsedSpecifier::from_string(depend);
            if (auto spec = maybe_spec.get())
            {
                Checks::check_exit(VCPKG_LINE_INFO,
                                   spec->triplet.empty(),
                                   "error: triplets cannot currently be specified in this context: %s",
                                   depend);
                PackageSpec pspec =
                    PackageSpec::from_name_and_triplet(spec->name, triplet).value_or_exit(VCPKG_LINE_INFO);

                for (auto&& feature : spec->features)
                    f_specs.push_back(FeatureSpec{pspec, feature});

                if (spec->features.empty()) f_specs.push_back(FeatureSpec{pspec, ""});
            }
            else
            {
                Checks::exit_with_message(VCPKG_LINE_INFO,
                                          "error while parsing feature list: %s: %s",
                                          vcpkg::to_string(*maybe_spec.get_error()),
                                          depend);
            }
        }
        return f_specs;
    }

    std::vector<FeatureSpec> FullPackageSpec::to_feature_specs(const std::vector<FullPackageSpec>& specs)
    {
        std::vector<FeatureSpec> ret;
        for (auto&& spec : specs)
        {
            ret.emplace_back(spec.package_spec, "");
            for (auto&& feature : spec.features)
                ret.emplace_back(spec.package_spec, feature);
        }
        return ret;
    }

    ExpectedT<FullPackageSpec, PackageSpecParseResult> FullPackageSpec::from_string(const std::string& spec_as_string,
                                                                                    const Triplet& default_triplet)
    {
        return Util::fmap(ParsedSpecifier::from_string(spec_as_string), [&](ParsedSpecifier& spec) {
            FullPackageSpec fspec;
            Triplet t = spec.triplet.empty() ? default_triplet : Triplet::from_canonical_name(spec.triplet);
            fspec.package_spec = PackageSpec::from_name_and_triplet(spec.name, t).value_or_exit(VCPKG_LINE_INFO);
            fspec.features = std::move(spec.features);
            return fspec;
        });
    }

    ExpectedT<PackageSpec, PackageSpecParseResult> PackageSpec::from_name_and_triplet(const std::string& name,
                                                                                      const Triplet& triplet)
    {
        if (Util::find_if_not(name, is_valid_package_spec_char) != name.end())
        {
            return PackageSpecParseResult::INVALID_CHARACTERS;
        }
        else
        {
            PackageSpec p;
            p.m_name = name;
            p.m_triplet = triplet;
            return std::move(p);
        }
    }

    std::vector<PackageSpec> PackageSpec::to_package_specs(const std::vector<std::string>& ports,
                                                           const Triplet& triplet)
    {
        return Util::fmap(ports, [&](const std::string& spec_as_string) -> PackageSpec {
            auto maybe_spec = PackageSpec::from_name_and_triplet(spec_as_string, triplet);
            if (auto spec = maybe_spec.get())
            {
                return std::move(*spec);
            }
            else
            {
                Checks::exit_with_message(VCPKG_LINE_INFO,
                                          "Invalid package: %s\n"
                                          "%s",
                                          spec_as_string,
                                          vcpkg::to_string(*maybe_spec.get_error()));
            }
        });
    }

    const std::string& PackageSpec::name() const { return this->m_name; }

    const Triplet& PackageSpec::triplet() const { return this->m_triplet; }

    std::string PackageSpec::dir() const { return Strings::format("%s_%s", this->m_name, this->m_triplet); }

    std::string PackageSpec::to_string() const { return Strings::format("%s:%s", this->name(), this->triplet()); }

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
            return std::move(f);
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
            return std::move(f);
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
        return std::move(f);
    }

    ExpectedT<Features, PackageSpecParseResult> Features::from_string(const std::string& name)
    {
        return Util::fmap(ParsedSpecifier::from_string(name), [&](ParsedSpecifier& spec) {
            Checks::check_exit(
                VCPKG_LINE_INFO, spec.triplet.empty(), "error: triplet not allowed in specifier: %s", name);

            Features f;
            f.name = std::move(spec.name);
            f.features = std::move(spec.features);
            return f;
        });
    }
}
