#include <vcpkg/base/json.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/base/util.h>

#include <vcpkg/tools.h>
#include <vcpkg/vcpkgpaths.h>
#include <vcpkg/versions.h>

using namespace vcpkg;
using namespace vcpkg::Versions;

bool VersionString::is_date(const std::string& version_string)
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

bool VersionString::is_semver(const std::string& version_string)
{
    // This is the "official" SemVer regex, taken from:
    // https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string
    std::regex re("^(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:-((?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*"
                  ")(?:\\.(?:0|["
                  "1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\\+([0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?$");
    return std::regex_match(version_string, re);
}

bool VersionString::is_semver_relaxed(const std::string& version_string)
{
    std::regex re("^(?:[0-9a-zA-Z]+)(?:[\\.|-][0-9a-zA-Z]+)*$");
    return std::regex_match(version_string, re);
}

bool VersionString::is_valid_string(const std::string& version_string) { return !version_string.empty(); }

const std::string Version::to_string() const { return vcpkg::Strings::format("%s.%s.%s", major, minor, update); }

const std::string VersionRequirement::to_string() const
{
    std::string requirement_operator = "?=";
    if (type == RequirementType::Exact)
    {
        requirement_operator = "==";
    }
    else if (type == RequirementType::Minimum)
    {
        requirement_operator = ">=";
    }
    return vcpkg::Strings::format("%s (%s %s)", package_name, requirement_operator, version.to_string());
}

const ComputedVersions Versions::compute_required_versions(const std::vector<VersionRequirement>& requirements)
{
    // This implementation is incomplete, as it assumes we have a flattened/final list of requirements.
    // It is missing the recursive step of adding new requirements for each requested dependency.
    //
    // It should be good enough to implement versioning for "only top-level manifest version requirements".
    //
    // To do it correctly, the code that computes the dependency graph needs to include version information.
    std::set<std::string> package_names;
    std::set<VersionConflict> conflicts;
    std::map<std::string, VersionRequirement> fixed_versions;
    std::map<std::string, VersionRequirement> minimum_versions;

    for (auto&& requirement : requirements)
    {
        package_names.insert(requirement.package_name);

        if (requirement.type == RequirementType::Exact)
        {
            auto conflict = fixed_versions.find(requirement.package_name);
            if (conflict == fixed_versions.end())
            {
                // Add new requirement
                fixed_versions[requirement.package_name] = requirement;
            }
            else if (conflict->second.version != requirement.version)
            {
                // Report conflict
                VersionConflict new_conflict{requirement, conflict->second};
                conflicts.emplace(new_conflict);
            }
        }
        else if (requirement.type == RequirementType::Minimum)
        {
            // Find previous requirements
            auto conflict = minimum_versions.find(requirement.package_name);
            if (conflict == minimum_versions.end())
            {
                // Add new requirement for package
                minimum_versions[requirement.package_name] = requirement;
            }
            else if (conflict->second.version < requirement.version)
            {
                // Upgrade to newest requirement
                conflict->second.version = requirement.version;
            }
        }
    }

    // Merge both lists
    std::set<VersionRequirement> computed_versions;
    std::set<std::string> baseline_packages;

    for (auto&& package_name : package_names)
    {
        auto fixed_version = fixed_versions.find(package_name);
        bool has_fixed_version = fixed_version != fixed_versions.end();

        auto minimum_version = minimum_versions.find(package_name);
        bool has_minimum_version = minimum_version != minimum_versions.end();

        if (has_fixed_version)
        {
            if (!has_minimum_version)
            {
                // No conflicts, use fixed requirement version.
                computed_versions.insert(fixed_version->second);
            }
            else if (minimum_version->second.version < fixed_version->second.version)
            {
                // Upgrade to fixed requirement
                computed_versions.insert(fixed_version->second);
            }
            else
            {
                // Report conflict
                VersionConflict new_conflict{fixed_version->second, minimum_version->second};
                conflicts.emplace(new_conflict);
            }
        }
        else if (has_minimum_version)
        {
            computed_versions.insert(minimum_version->second);
        }
        else
        {
            baseline_packages.insert(package_name);
            /*vcpkg::Checks::exit_with_message(
                VCPKG_LINE_INFO, "Unsatisfied version requirements for package: %s", package_name);*/
        }
    }

    return ComputedVersions{computed_versions, baseline_packages, conflicts};
}

static System::ExitCodeAndOutput run_git_command(const VcpkgPaths& paths,
                                                 const fs::path& working_directory,
                                                 const std::string& cmd)
{
    const fs::path& git_exe = paths.get_tool_exe(Tools::GIT);
    const fs::path dot_git_dir = working_directory / ".git";

    const std::string full_cmd =
        Strings::format(R"("%s" --work-tree="%s" %s)", fs::u8string(git_exe), fs::u8string(working_directory), cmd);

    auto output = System::cmd_execute_and_capture_output(full_cmd);
    return output;
}

const std::string get_version_commit_id(const std::string& package_name,
                                        const std::string& requested_version,
                                        const VcpkgPaths& paths)
{
    const auto database_filename = Strings::format("%s.db.json", package_name);
    const auto database_file_path = paths.scripts / "port_versions_db" / database_filename;
    Checks::check_exit(VCPKG_LINE_INFO,
                       paths.get_filesystem().exists(database_file_path),
                       "Version database file does not exist for package %s",
                       package_name);

    auto pair = Json::parse_file(VCPKG_LINE_INFO, paths.get_filesystem(), database_file_path);
    Checks::check_exit(VCPKG_LINE_INFO, pair.first.is_object(), "Failed to parse %", database_filename);

    auto& db_object = pair.first.object();

    auto maybe_versions = db_object.get("versions");
    Checks::check_exit(VCPKG_LINE_INFO,
                       maybe_versions && maybe_versions->is_array(),
                       "Database file %s contains no versions",
                       database_filename);

    auto& versions = maybe_versions->array();
    for (auto&& version : versions)
    {
        auto version_string = version.object().get("version_string")->string().to_string();
        if (version_string == requested_version)
        {
            return version.object().get("commit_id")->string().to_string();
        }
    }

    Checks::exit_with_message(VCPKG_LINE_INFO, "Couldn't find version '%s' of %s", requested_version, package_name);
}

void Versions::fetch_port_versions(const VcpkgPaths& paths,
                                   const ComputedVersions& versions,
                                   const std::string& baseline)
{
    (void)baseline;
    (void)versions;

    Checks::check_exit(VCPKG_LINE_INFO, versions.conflicts.empty(), "There are conflicts in the computed versions.");

    auto& fs = paths.get_filesystem();
    const auto working_dir = paths.root / "vcpkg-temp";

    if (fs.exists(working_dir))
    {
        fs.remove_all(working_dir, VCPKG_LINE_INFO);
    }

    auto output = run_git_command(paths, working_dir, "clone https://github.com/microsoft/vcpkg vcpkg-temp");
    Checks::check_exit(VCPKG_LINE_INFO, output.exit_code == 0, "Failed to clone temporary vcpkg instance");

    fs.remove_all(working_dir / "ports", VCPKG_LINE_INFO);

    for (auto&& versioned_package : versions.computed_versions)
    {
        auto commit_id =
            get_version_commit_id(versioned_package.package_name, versioned_package.version.to_string(), paths);

        auto port_path = working_dir / "ports" / versioned_package.package_name;
        auto cmd = Strings::format("checkout %s -- ./ports/%s", commit_id, versioned_package.package_name);
        run_git_command(paths, working_dir, cmd);
    }

    for (auto&& baseline_package : versions.baseline_packages)
    {
        auto port_path = working_dir / "ports" / baseline_package;
        auto cmd = Strings::format("checkout %s -- ./ports/%s", baseline, baseline_package);
        run_git_command(paths, working_dir, cmd);
    }

    Checks::exit_success(VCPKG_LINE_INFO);
}

void Versions::test_fetch(const VcpkgPaths& paths)
{
    std::vector<VersionRequirement> reqs{VersionRequirement(RequirementType::None, "rapidjson", "0", "0", "0"),
                                         VersionRequirement(RequirementType::Exact, "cpprestsdk", "2", "10", "16"),
                                         VersionRequirement(RequirementType::Minimum, "zlib", "1", "2", "8")};
    fetch_port_versions(paths, compute_required_versions(reqs), "e86ff2cc54bda9e9ee322ab69141e7113d5c40a9");
}