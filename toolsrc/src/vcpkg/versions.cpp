#include <vcpkg/base/util.h>

#include <vcpkg/versions.h>

#include <regex>

namespace vcpkg::Versions
{
    namespace
    {
        Optional<uint64_t> as_numeric(StringView str)
        {
            uint64_t res = 0;
            size_t digits = 0;
            for (auto&& ch : str)
            {
                uint64_t digit_value = static_cast<unsigned char>(ch) - static_cast<unsigned char>('0');
                if (digit_value > 9) return nullopt;
                if (res > std::numeric_limits<uint64_t>::max() / 10 - digit_value) return nullopt;
                ++digits;
                res = res * 10 + digit_value;
            }
            return res;
        }
    }

    VersionSpec::VersionSpec(const std::string& port_name, const VersionT& version)
        : port_name(port_name), version(version)
    {
    }

    VersionSpec::VersionSpec(const std::string& port_name, const std::string& version_string, int port_version)
        : port_name(port_name), version(version_string, port_version)
    {
    }

    bool operator==(const VersionSpec& lhs, const VersionSpec& rhs)
    {
        return std::tie(lhs.port_name, lhs.version) == std::tie(rhs.port_name, rhs.version);
    }

    bool operator!=(const VersionSpec& lhs, const VersionSpec& rhs) { return !(lhs == rhs); }

    std::size_t VersionSpecHasher::operator()(const VersionSpec& key) const
    {
        using std::hash;
        using std::size_t;
        using std::string;

        return hash<string>()(key.port_name) ^ (hash<string>()(key.version.to_string()) >> 1);
    }

    ExpectedS<RelaxedVersion> RelaxedVersion::from_string(const std::string& str)
    {
        std::regex relaxed_scheme_match("^(0|[1-9][0-9]*)(\\.(0|[1-9][0-9]*))*");

        if (!std::regex_match(str, relaxed_scheme_match))
        {
            return Strings::format(
                "Error: String `%s` must only contain dot-separated numeric values without leading zeroes.", str);
        }

        return RelaxedVersion{str, Util::fmap(Strings::split(str, '.'), [](auto&& strval) -> uint64_t {
                                  return as_numeric(strval).value_or_exit(VCPKG_LINE_INFO);
                              })};
    }

    ExpectedS<SemanticVersion> SemanticVersion::from_string(const std::string& str)
    {
        // Suggested regex by semver.org
        std::regex semver_scheme_match("^(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)"
                                       "(?:-((?:0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*)(?:\\.(?:0|[1-9][0-9]*|[0-9]"
                                       "*[a-zA-Z-][0-9a-zA-Z-]*))*))?"
                                       "(?:\\+([0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?$");

        if (!std::regex_match(str, semver_scheme_match))
        {
            return Strings::format(
                "Error: String `%s` is not a valid Semantic Version string, consult https://semver.org", str);
        }

        SemanticVersion ret;
        ret.original_string = str;
        ret.version_string = str;

        auto build_found = ret.version_string.find('+');
        if (build_found != std::string::npos)
        {
            ret.version_string.resize(build_found);
        }

        auto prerelease_found = ret.version_string.find('-');
        if (prerelease_found != std::string::npos)
        {
            ret.prerelease_string = ret.version_string.substr(prerelease_found + 1);
            ret.identifiers = Strings::split(ret.prerelease_string, '.');
            ret.version_string.resize(prerelease_found);
        }

        std::regex version_match("(0|[1-9][0-9]*)(\\.(0|[1-9][0-9]*)){2}");
        if (!std::regex_match(ret.version_string, version_match))
        {
            return Strings::format("Error: String `%s` does not follow the required MAJOR.MINOR.PATCH format.",
                                   ret.version_string);
        }

        auto parts = Strings::split(ret.version_string, '.');
        ret.version = Util::fmap(
            parts, [](auto&& strval) -> uint64_t { return as_numeric(strval).value_or_exit(VCPKG_LINE_INFO); });

        return ret;
    }

    ExpectedS<DateVersion> DateVersion::from_string(const std::string& str)
    {
        std::regex date_scheme_match("([0-9]{4}-[0-9]{2}-[0-9]{2})(\\.(0|[1-9][0-9]*))*");
        if (!std::regex_match(str, date_scheme_match))
        {
            return Strings::format("Error: String `%s` is not a valid date version."
                                   "Date section must follow the format YYYY-MM-DD and disambiguators must be "
                                   "dot-separated positive integer values without leading zeroes.",
                                   str);
        }

        DateVersion ret;
        ret.original_string = str;
        ret.version_string = str;

        auto identifiers_found = ret.version_string.find('.');
        if (identifiers_found != std::string::npos)
        {
            ret.identifiers_string = ret.version_string.substr(identifiers_found + 1);
            ret.identifiers = Util::fmap(Strings::split(ret.identifiers_string, '.'), [](auto&& strval) -> uint64_t {
                return as_numeric(strval).value_or_exit(VCPKG_LINE_INFO);
            });
            ret.version_string.resize(identifiers_found);
        }

        return ret;
    }

    VerComp compare(const std::string& a, const std::string& b, Scheme scheme)
    {
        if (scheme == Scheme::String)
        {
            return (a == b) ? VerComp::eq : VerComp::unk;
        }
        if (scheme == Scheme::Semver)
        {
            return compare(SemanticVersion::from_string(a).value_or_exit(VCPKG_LINE_INFO),
                           SemanticVersion::from_string(b).value_or_exit(VCPKG_LINE_INFO));
        }
        if (scheme == Scheme::Relaxed)
        {
            return compare(RelaxedVersion::from_string(a).value_or_exit(VCPKG_LINE_INFO),
                           RelaxedVersion::from_string(b).value_or_exit(VCPKG_LINE_INFO));
        }
        if (scheme == Scheme::Date)
        {
            return compare(DateVersion::from_string(a).value_or_exit(VCPKG_LINE_INFO),
                           DateVersion::from_string(b).value_or_exit(VCPKG_LINE_INFO));
        }
        Checks::unreachable(VCPKG_LINE_INFO);
    }

    VerComp compare(const RelaxedVersion& a, const RelaxedVersion& b)
    {
        if (a.original_string == b.original_string) return VerComp::eq;

        if (a.version < b.version) return VerComp::lt;
        if (a.version > b.version) return VerComp::gt;
        Checks::unreachable(VCPKG_LINE_INFO);
    }

    VerComp compare(const SemanticVersion& a, const SemanticVersion& b)
    {
        if (a.version_string == b.version_string)
        {
            if (a.prerelease_string == b.prerelease_string) return VerComp::eq;
            if (a.prerelease_string.empty()) return VerComp::gt;
            if (b.prerelease_string.empty()) return VerComp::lt;
        }

        // Compare version elements left-to-right.
        if (a.version < b.version) return VerComp::lt;
        if (a.version > b.version) return VerComp::gt;

        // Compare identifiers left-to-right.
        auto count = std::min(a.identifiers.size(), b.identifiers.size());
        for (size_t i = 0; i < count; ++i)
        {
            auto&& iden_a = a.identifiers[i];
            auto&& iden_b = b.identifiers[i];

            auto a_numeric = as_numeric(iden_a);
            auto b_numeric = as_numeric(iden_b);

            // Numeric identifiers always have lower precedence than non-numeric identifiers.
            if (a_numeric.has_value() && !b_numeric.has_value()) return VerComp::lt;
            if (!a_numeric.has_value() && b_numeric.has_value()) return VerComp::gt;

            // Identifiers consisting of only digits are compared numerically.
            if (a_numeric.has_value() && b_numeric.has_value())
            {
                auto a_value = a_numeric.value_or_exit(VCPKG_LINE_INFO);
                auto b_value = b_numeric.value_or_exit(VCPKG_LINE_INFO);

                if (a_value < b_value) return VerComp::lt;
                if (a_value > b_value) return VerComp::gt;
                continue;
            }

            // Identifiers with letters or hyphens are compared lexically in ASCII sort order.
            auto strcmp_result = std::strcmp(iden_a.c_str(), iden_b.c_str());
            if (strcmp_result < 0) return VerComp::lt;
            if (strcmp_result > 0) return VerComp::gt;
        }

        // A larger set of pre-release fields has a higher precedence than a smaller set, if all of the preceding
        // identifiers are equal.
        if (a.identifiers.size() < b.identifiers.size()) return VerComp::lt;
        if (a.identifiers.size() > b.identifiers.size()) return VerComp::gt;

        // This should be unreachable since direct string comparisons of version_string and prerelease_string should
        // handle this case. If we ever land here, then there's a bug in the the parsing on
        // SemanticVersion::from_string().
        Checks::unreachable(VCPKG_LINE_INFO);
    }

    VerComp compare(const Versions::DateVersion& a, const Versions::DateVersion& b)
    {
        if (a.version_string == b.version_string)
        {
            if (a.identifiers_string == b.identifiers_string) return VerComp::eq;
            if (a.identifiers_string.empty() && !b.identifiers_string.empty()) return VerComp::lt;
            if (!a.identifiers_string.empty() && b.identifiers_string.empty()) return VerComp::gt;
        }

        // The date parts in our scheme is lexicographically sortable.
        if (a.version_string < b.version_string) return VerComp::lt;
        if (a.version_string > b.version_string) return VerComp::gt;
        if (a.identifiers < b.identifiers) return VerComp::lt;
        if (a.identifiers > b.identifiers) return VerComp::gt;

        Checks::unreachable(VCPKG_LINE_INFO);
    }
}
