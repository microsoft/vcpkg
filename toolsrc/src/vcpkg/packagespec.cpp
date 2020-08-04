#include "pch.h"

#include <vcpkg/base/checks.h>
#include <vcpkg/base/parse.h>
#include <vcpkg/base/util.h>

#include <vcpkg/packagespec.h>
#include <vcpkg/paragraphparser.h>

namespace vcpkg
{
    std::string FeatureSpec::to_string() const
    {
        std::string ret;
        this->to_string(ret);
        return ret;
    }
    void FeatureSpec::to_string(std::string& out) const
    {
        if (feature().empty()) return spec().to_string(out);
        Strings::append(out, name(), '[', feature(), "]:", triplet());
    }

    std::vector<FeatureSpec> FullPackageSpec::to_feature_specs(const std::vector<std::string>& default_features,
                                                               const std::vector<std::string>& all_features) const
    {
        std::vector<FeatureSpec> feature_specs;

        if (Util::find(features, "*") != features.end())
        {
            feature_specs.emplace_back(package_spec, "core");
            for (const std::string& feature : all_features)
            {
                feature_specs.emplace_back(package_spec, feature);
            }
        }
        else
        {
            bool core = false;
            for (const std::string& feature : features)
            {
                feature_specs.emplace_back(package_spec, feature);

                if (!core)
                {
                    core = feature == "core";
                }
            }

            if (!core)
            {
                feature_specs.emplace_back(package_spec, "core");

                for (const std::string& def : default_features)
                {
                    feature_specs.emplace_back(package_spec, def);
                }
            }
        }

        return feature_specs;
    }

    ExpectedS<FullPackageSpec> FullPackageSpec::from_string(const std::string& spec_as_string, Triplet default_triplet)
    {
        return parse_qualified_specifier(spec_as_string)
            .then([&](ParsedQualifiedSpecifier&& p) -> ExpectedS<FullPackageSpec> {
                if (p.platform)
                    return "Error: platform specifier not allowed in this context: " + spec_as_string + "\n";
                auto triplet = p.triplet ? Triplet::from_canonical_name(std::move(*p.triplet.get())) : default_triplet;
                return FullPackageSpec({p.name, triplet}, p.features.value_or({}));
            });
    }

    std::vector<PackageSpec> PackageSpec::to_package_specs(const std::vector<std::string>& ports, Triplet triplet)
    {
        return Util::fmap(ports, [&](const std::string& spec_as_string) -> PackageSpec {
            return {spec_as_string, triplet};
        });
    }

    const std::string& PackageSpec::name() const { return this->m_name; }

    Triplet PackageSpec::triplet() const { return this->m_triplet; }

    std::string PackageSpec::dir() const { return Strings::format("%s_%s", this->m_name, this->m_triplet); }

    std::string PackageSpec::to_string() const { return Strings::format("%s:%s", this->name(), this->triplet()); }
    void PackageSpec::to_string(std::string& s) const { Strings::append(s, this->name(), ':', this->triplet()); }

    bool operator==(const PackageSpec& left, const PackageSpec& right)
    {
        return left.name() == right.name() && left.triplet() == right.triplet();
    }

    ExpectedS<Features> Features::from_string(const std::string& name)
    {
        return parse_qualified_specifier(name).then([&](ParsedQualifiedSpecifier&& pqs) -> ExpectedS<Features> {
            if (pqs.triplet) return "Error: triplet not allowed in this context: " + name + "\n";
            if (pqs.platform) return "Error: platform specifier not allowed in this context: " + name + "\n";
            return Features{pqs.name, pqs.features.value_or({})};
        });
    }

    static bool is_package_name_char(char32_t ch)
    {
        return Parse::ParserBase::is_lower_alpha(ch) || Parse::ParserBase::is_ascii_digit(ch) || ch == '-';
    }

    static bool is_feature_name_char(char32_t ch)
    {
        // TODO: we do not intend underscores to be valid, however there is currently a feature using them
        // (libwebp[vwebp_sdl]).
        // TODO: we need to rename this feature, then remove underscores from this list.
        return is_package_name_char(ch) || ch == '_';
    }

    ExpectedS<ParsedQualifiedSpecifier> parse_qualified_specifier(StringView input)
    {
        auto parser = Parse::ParserBase(input, "<unknown>");
        auto maybe_pqs = parse_qualified_specifier(parser);
        if (!parser.at_eof()) parser.add_error("expected eof");
        if (auto e = parser.get_error()) return e->format();
        return std::move(maybe_pqs).value_or_exit(VCPKG_LINE_INFO);
    }

    Optional<std::string> parse_feature_name(Parse::ParserBase& parser)
    {
        using Parse::ParserBase;
        auto ret = parser.match_zero_or_more(is_feature_name_char).to_string();
        auto ch = parser.cur();

        // ignores the feature name vwebp_sdl as a back-compat thing
        const bool has_underscore = std::find(ret.begin(), ret.end(), '_') != ret.end() && ret != "vwebp_sdl";
        if (has_underscore || ParserBase::is_upper_alpha(ch))
        {
            parser.add_error("invalid character in feature name (must be lowercase, digits, '-')");
            return nullopt;
        }

        if (ret.empty())
        {
            parser.add_error("expected feature name (must be lowercase, digits, '-')");
            return nullopt;
        }
        return ret;
    }
    Optional<std::string> parse_package_name(Parse::ParserBase& parser)
    {
        using Parse::ParserBase;
        auto ret = parser.match_zero_or_more(is_package_name_char).to_string();
        auto ch = parser.cur();
        if (ParserBase::is_upper_alpha(ch) || ch == '_')
        {
            parser.add_error("invalid character in package name (must be lowercase, digits, '-')");
            return nullopt;
        }
        if (ret.empty())
        {
            parser.add_error("expected package name (must be lowercase, digits, '-')");
            return nullopt;
        }
        return ret;
    }

    Optional<ParsedQualifiedSpecifier> parse_qualified_specifier(Parse::ParserBase& parser)
    {
        using Parse::ParserBase;
        ParsedQualifiedSpecifier ret;
        auto name = parse_package_name(parser);
        if (auto n = name.get())
            ret.name = std::move(*n);
        else
            return nullopt;
        auto ch = parser.cur();
        if (ch == '[')
        {
            std::vector<std::string> features;
            do
            {
                parser.next();
                parser.skip_tabs_spaces();
                if (parser.cur() == '*')
                {
                    features.push_back("*");
                    parser.next();
                }
                else
                {
                    auto feature = parse_feature_name(parser);
                    if (auto f = feature.get())
                        features.push_back(std::move(*f));
                    else
                        return nullopt;
                }
                auto skipped_space = parser.skip_tabs_spaces();
                ch = parser.cur();
                if (ch == ']')
                {
                    ch = parser.next();
                    break;
                }
                else if (ch == ',')
                {
                    continue;
                }
                else
                {
                    if (skipped_space.size() > 0 || Parse::ParserBase::is_lineend(parser.cur()))
                        parser.add_error("expected ',' or ']' in feature list");
                    else
                        parser.add_error("invalid character in feature name (must be lowercase, digits, '-', or '*')");
                    return nullopt;
                }
            } while (true);
            ret.features = std::move(features);
        }
        if (ch == ':')
        {
            parser.next();
            ret.triplet = parser.match_zero_or_more(is_package_name_char).to_string();
            if (ret.triplet.get()->empty())
            {
                parser.add_error("expected triplet name (must be lowercase, digits, '-')");
                return nullopt;
            }
        }
        parser.skip_tabs_spaces();
        ch = parser.cur();
        if (ch == '(')
        {
            auto loc = parser.cur_loc();
            std::string platform_string;
            int depth = 1;
            while (depth > 0 && (ch = parser.next()) != 0)
            {
                if (ch == '(') ++depth;
                if (ch == ')') --depth;
            }
            if (depth > 0)
            {
                parser.add_error("unmatched open braces in platform specifier", loc);
                return nullopt;
            }
            platform_string.append((++loc.it).pointer_to_current(), parser.it().pointer_to_current());
            auto platform_opt = PlatformExpression::parse_platform_expression(
                platform_string, PlatformExpression::MultipleBinaryOperators::Allow);
            if (auto platform = platform_opt.get())
            {
                ret.platform = std::move(*platform);
            }
            else
            {
                parser.add_error(platform_opt.error(), loc);
            }
            parser.next();
        }
        // This makes the behavior of the parser more consistent -- otherwise, it will skip tabs and spaces only if
        // there isn't a qualifier.
        parser.skip_tabs_spaces();
        return ret;
    }

    bool operator==(const Dependency& lhs, const Dependency& rhs)
    {
        if (lhs.name != rhs.name) return false;
        if (lhs.features != rhs.features) return false;
        if (!structurally_equal(lhs.platform, rhs.platform)) return false;
        if (lhs.extra_info != rhs.extra_info) return false;

        return true;
    }
    bool operator!=(const Dependency& lhs, const Dependency& rhs);
}
