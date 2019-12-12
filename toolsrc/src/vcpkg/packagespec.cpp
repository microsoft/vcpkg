#include "pch.h"

#include <vcpkg/base/checks.h>
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

    std::string FeatureSpec::to_string(bool omitTriplet) const
    {
        std::string ret;
        this->to_string(ret, omitTriplet);
        return ret;
    }
    void FeatureSpec::to_string(std::string& out, bool omitTriplet) const
    {
        if (feature().empty()) return spec().to_string(out, omitTriplet);
        if (omitTriplet)
            Strings::append(out, name(), '[', feature(), "]");
        else
            Strings::append(out, name(), '[', feature(), "]:", triplet());
    }

    std::string FullPackageSpec::to_string(bool omitTriplet) const
    {
        std::string ret;
        this->to_string(ret, omitTriplet);
        return ret;
    }
    void FullPackageSpec::to_string(std::string& out, bool omitTriplet) const
    {
        // Strip out the "core" feature, as this is always present
        auto print_features = features;
        Util::erase_remove_if(print_features, [](const std::string& feature) { return feature == "core"; });
        if (print_features.empty()) return spec().to_string(out, omitTriplet);

        if (omitTriplet)
            Strings::append(out, name(), '[', Strings::join(",", print_features), "]");
        else
            Strings::append(out, name(), '[', Strings::join(",", print_features), "]:", triplet());
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
                                          vcpkg::to_string(maybe_spec.error()),
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
        auto res = ParsedSpecifier::from_string(spec_as_string);
        if (auto p = res.get())
        {
            FullPackageSpec fspec;
            Triplet t = p->triplet.empty() ? default_triplet : Triplet::from_canonical_name(std::move(p->triplet));
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

    std::vector<PackageSpec> PackageSpec::to_package_specs(const std::vector<std::string>& ports,
                                                           const Triplet& triplet)
    {
        return Util::fmap(ports, [&](const std::string& spec_as_string) -> PackageSpec {
            auto maybe_spec = PackageSpec::from_name_and_triplet(spec_as_string, triplet);
            if (auto spec = maybe_spec.get())
            {
                return std::move(*spec);
            }

            const PackageSpecParseResult error_type = maybe_spec.error();
            Checks::exit_with_message(VCPKG_LINE_INFO,
                                      "Invalid package: %s\n"
                                      "%s",
                                      spec_as_string,
                                      vcpkg::to_string(error_type));
        });
    }

    const std::string& PackageSpec::name() const { return this->m_name; }

    const Triplet& PackageSpec::triplet() const { return this->m_triplet; }

    std::string PackageSpec::dir() const { return Strings::format("%s_%s", this->m_name, this->m_triplet); }

    std::string PackageSpec::to_string(bool omitTriplet) const { return omitTriplet ? this->name() : Strings::format("%s:%s", this->name(), this->triplet()); }
    void PackageSpec::to_string(std::string& s, bool omitTriplet) const
    {
        if (omitTriplet)
            s = this->name();
        else
            Strings::append(s, this->name(), ':', this->triplet());
    }

    bool operator==(const PackageSpec& left, const PackageSpec& right)
    {
        return left.name() == right.name() && left.triplet() == right.triplet();
    }

    bool operator!=(const PackageSpec& left, const PackageSpec& right) { return !(left == right); }

    bool operator< (const FullPackageSpec& left, const FullPackageSpec& right)
    {
        if (left.package_spec < right.package_spec) return true;
        if (right.package_spec < left.package_spec) return false;

        std::vector<std::string> leftFeatures;
        for (auto&& f : left.features)
            if (f != "core")
                Util::Vectors::insert_sorted(leftFeatures, f);

        std::vector<std::string> rightFeatures;
        for (auto&& f : right.features)
            if (f != "core")
                Util::Vectors::insert_sorted(rightFeatures, f);

        if (leftFeatures.size() < rightFeatures.size()) return true;
        if (rightFeatures.size() < leftFeatures.size()) return false;

        for (size_t i = 0; i < leftFeatures.size(); ++i)
        {
            int cmp = leftFeatures[i].compare(rightFeatures[i]);
            if (cmp < 0)
                return true;
            else if (cmp > 0)
                return false;
        }

        return false;   // equal
    }

    bool operator==(const FullPackageSpec& left, const FullPackageSpec& right)
    {
        if (left.package_spec != right.package_spec)
            return false;

        std::vector<std::string> leftFeatures;
        for (auto&& f : left.features)
            if (f != "core")
                Util::Vectors::insert_sorted(leftFeatures, f);

        std::vector<std::string> rightFeatures;
        for (auto&& f : right.features)
            if (f != "core")
                Util::Vectors::insert_sorted(rightFeatures, f);

        return leftFeatures == rightFeatures;
    }

    bool operator!=(const FullPackageSpec& left, const FullPackageSpec& right) { return !(left == right); }

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

    ExpectedT<Features, PackageSpecParseResult> Features::from_string(const std::string& name)
    {
        auto maybe_spec = ParsedSpecifier::from_string(name);
        if (auto spec = maybe_spec.get())
        {
            Checks::check_exit(
                VCPKG_LINE_INFO, spec->triplet.empty(), "error: triplet not allowed in specifier: %s", name);

            Features f;
            f.name = spec->name;
            f.features = spec->features;
            return f;
        }

        return maybe_spec.error();
    }
}
