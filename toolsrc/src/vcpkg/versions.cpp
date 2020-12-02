#include <vcpkg/base/util.h>

#include <vcpkg/versions.h>

#include <regex>

namespace vcpkg::Versions
{
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
        ret.version = std::move(Util::fmap(parts, [](auto&& str) -> long {
            try
            {
                return std::stol(str);
            }
            catch (std::exception&)
            {
                Checks::exit_fail(VCPKG_LINE_INFO);
            }
        }));

        return std::move(ret);
    }
}