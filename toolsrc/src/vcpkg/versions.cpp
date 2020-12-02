#include <vcpkg/base/util.h>

#include <vcpkg/versions.h>

#include <regex>

namespace vcpkg::Versions
{
    namespace
    {
        Optional<long> as_numeric(const std::string& str)
        {
            try
            {
                return std::stol(str);
            }
            catch (std::exception&)
            {
                return nullopt;
            }
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

    SemanticVersion SemanticVersion::from_string(const std::string& str)
    {
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
            ret.identifiers = std::move(Strings::split(ret.prerelease_string, '.'));
            ret.version_string.resize(prerelease_found);
        }

        std::regex version_match("(0|[1-9][0-9]*)(\\.(0|[1-9][0-9]*)){2}");
        Checks::check_exit(VCPKG_LINE_INFO,
                           std::regex_match(ret.version_string, version_match),
                           "Error: String `%s` is not a valid Semantic Version string.",
                           str);

        auto parts = Strings::split(ret.version_string, '.');
        ret.version = std::move(
            Util::fmap(parts, [](auto&& strval) -> long { return as_numeric(strval).value_or_exit(VCPKG_LINE_INFO); }));

        return std::move(ret);
    }

    VerComp compare(const Versions::SemanticVersion& a, const Versions::SemanticVersion& b)
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
        /// return VerComp::eq;
    }
}