#include <vcpkg/base/json.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/base/util.h>

#include <vcpkg/tools.h>
#include <vcpkg/vcpkgpaths.h>
#include <vcpkg/versions.h>

using namespace vcpkg;
using namespace vcpkg::Versions;

bool vcpkg::Versions::is_date(const std::string& version_string)
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

bool vcpkg::Versions::is_semver(const std::string& version_string)
{
    // This is the "official" SemVer regex, taken from:
    // https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string
    std::regex re("^(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:-((?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*"
                  ")(?:\\.(?:0|["
                  "1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\\+([0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?$");
    return std::regex_match(version_string, re);
}

bool vcpkg::Versions::is_semver_relaxed(const std::string& version_string)
{
    std::regex re("^(?:[0-9a-zA-Z]+)(?:[\\.|-][0-9a-zA-Z]+)*$");
    return std::regex_match(version_string, re);
}

bool vcpkg::Versions::is_valid_string(const std::string& version_string) { return !version_string.empty(); }

const std::string VersionRequirement::to_string() const
{
    std::string requirement_operator = "?=";
    if (type == VersionRequirement::Type::Exact)
    {
        requirement_operator = "==";
    }
    else if (type == VersionRequirement::Type::Minimum)
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

        if (requirement.type == VersionRequirement::Type::Exact)
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
        else if (requirement.type == VersionRequirement::Type::Minimum)
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

const System::ExitCodeAndOutput run_git_command(const VcpkgPaths& paths,
                                                const fs::path& dot_git_directory,
                                                const fs::path& working_directory,
                                                const std::string& cmd)
{
    const fs::path& git_exe = paths.get_tool_exe(Tools::GIT);

    System::CmdLineBuilder builder;
    builder.path_arg(git_exe)
        .string_arg(Strings::concat("--git-dir=", fs::u8string(dot_git_directory)))
        .string_arg(Strings::concat("--work-tree=", fs::u8string(working_directory)));
    const std::string full_cmd = Strings::concat(builder.extract(), " ", cmd);

    const auto output = System::cmd_execute_and_capture_output(full_cmd);
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
    Checks::check_exit(VCPKG_LINE_INFO, versions.conflicts.empty(), "There are conflicts in the computed versions.");

    auto& fs = paths.get_filesystem();
    const auto working_dir = paths.buildtrees / "versioning_tmp";
    const auto dot_git_dir = paths.root / "versioning_tmp";

    if (fs.exists(working_dir))
    {
        fs.remove_all(working_dir, VCPKG_LINE_INFO);
    }

    System::CmdLineBuilder builder;
    // git clone --no-checkout --local {vcpkg_root} versioning_tmp
    builder.string_arg("clone")
        .string_arg("--no-checkout")
        .string_arg("--local")
        .path_arg(paths.root)
        .string_arg("versioning_tmp");
    const auto output = run_git_command(paths, dot_git_dir, working_dir, builder.extract());
    Checks::check_exit(VCPKG_LINE_INFO, output.exit_code == 0, "Failed to clone temporary vcpkg instance");

    auto checkout_port = [&paths, &dot_git_dir, &working_dir](const std::string& port_name,
                                                              const std::string& commit_id) {
        // git checkout {commit_id} -- ./ports/{port_name}
        System::CmdLineBuilder builder;
        builder.string_arg("checkout")
            .string_arg(commit_id)
            .string_arg("--")
            .string_arg(Strings::concat("./ports/", port_name));

        const auto git_cmd = builder.extract();
        const auto checkout_output = run_git_command(paths, dot_git_dir, working_dir, git_cmd);
        Checks::check_exit(
            VCPKG_LINE_INFO, checkout_output.exit_code == 0, "Failed to checkout % at commit %d", port_name, commit_id);
    };

    for (auto&& versioned_package : versions.computed_versions)
    {
        const auto commit_id =
            get_version_commit_id(versioned_package.package_name, versioned_package.version.to_string(), paths);

        checkout_port(versioned_package.package_name, commit_id);
    }

    for (auto&& baseline_package : versions.baseline_packages)
    {
        checkout_port(baseline_package, baseline);
    }

    if (fs.exists(dot_git_dir))
    {
        fs.remove_all(dot_git_dir, VCPKG_LINE_INFO);
    }

    Checks::exit_success(VCPKG_LINE_INFO);
}

void Versions::test_fetch(const VcpkgPaths& paths)
{
    std::vector<VersionRequirement> reqs{VersionRequirement(VersionRequirement::Type::None, "rapidjson", "0.0.0"),
                                         VersionRequirement(VersionRequirement::Type::Exact, "cpprestsdk", "2.10.16"),
                                         VersionRequirement(VersionRequirement::Type::Minimum, "zlib", "1.2.8"),
                                         VersionRequirement(VersionRequirement::Type::Minimum, "zlib", "1.2.0"),
                                         VersionRequirement(VersionRequirement::Type::Minimum, "zlib", "1.0.0")};
    fetch_port_versions(paths, compute_required_versions(reqs), "e86ff2cc54bda9e9ee322ab69141e7113d5c40a9");
}

VersionRelaxed::VersionRelaxed(const std::string& version_string) : version(version_string), port_version(0)
{
    sections = Strings::split(version_string, '.');
}

VersionRelaxed::VersionRelaxed(const std::string& version_string, int port_version)
    : version(version_string), port_version(port_version)
{
    sections = Strings::split(version_string, '.');
}
