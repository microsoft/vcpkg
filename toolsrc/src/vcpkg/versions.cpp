#include <vcpkg/base/json.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/base/util.h>

#include <vcpkg/tools.h>
#include <vcpkg/vcpkgpaths.h>
#include <vcpkg/versions.h>

using namespace vcpkg::Versions;

bool Version::is_date(const std::string& version_string)
{
    // The date regex is not complete, it matches strings that look like dates,
    // e.g.: 2020-99-99.
    //
    // The regex has two capture groups:
    // * Date: "^([0-9]{4,}[-][0-9]{2}[-][0-9]{2})", it matches strings that resemble YYYY-MM-DD.
    //         It does not validate that MM <= 12, or that DD is possible with the given MM.
    //         YYYY should be AT LEAST 4 digits, for some kind of "future proofing".
    std::regex re("^([0-9]{4,}[-][0-9]{2}[-][0-9]{2})((?:[.|-][0-9a-zA-Z]+)*)$");
    return std::regex_match(version_string, re);
}

bool Version::is_semver(const std::string& version_string)
{
    // This is the "official" SemVer regex, taken from:
    // https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string
    std::regex re("^(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:-((?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*"
                  ")(?:\\.(?:0|["
                  "1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\\+([0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?$");
    return std::regex_match(version_string, re);
}

bool Version::is_semver_relaxed(const std::string& version_string)
{
    std::regex re("^(?:[0-9a-zA-Z]+)\\.(?:[0-9a-zA-Z]+)\\.(?:[0-9a-zA-Z]+)(?:[\\.|-|\\+][0-9a-zA-Z]+)*$");
    return std::regex_match(version_string, re);
}

bool Version::is_valid_string(const std::string& version_string) { return !version_string.empty(); }

Version::Version(const std::string& version_string, int port_version, Scheme scheme)
    : version(version_string), port_version(port_version), scheme(scheme)
{
}

std::string Version::to_string() const { return version; }

VersionString::VersionString(const std::string& version_string) : Version(version_string, 0, Scheme::String) { }

VersionString::VersionString(const std::string& version_string, int port_version)
    : Version(version_string, port_version, Scheme::String)
{
}

VersionRelaxed::VersionRelaxed(const std::string& version_string) : Version(version_string, 0, Scheme::Relaxed)
{
    sections = Strings::split(version_string, '.');
}

VersionRelaxed::VersionRelaxed(const std::string& version_string, int port_version)
    : Version(version_string, port_version, Scheme::Relaxed)
{
    sections = Strings::split(version_string, '.');
}
