#include <vcpkg/base/json.h>
#include <vcpkg/base/system.process.h>

#include <vcpkg/paragraphs.h>
#include <vcpkg/tools.h>
#include <vcpkg/vcpkgpaths.h>
#include <vcpkg/versions.fetch.h>
#include <vcpkg/versions.h>

using namespace vcpkg;
using namespace vcpkg::Versions;

namespace
{
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
}

void Versions::fetch_port_commit_id(const VcpkgPaths& paths, const std::string& port_name, const std::string& commit_id)
{
    const auto working_dir = paths.buildtrees / "versioning_tmp";
    const auto dot_git_dir = paths.root / "versioning_tmp";

    auto& fs = paths.get_filesystem();
    if (!fs.exists(dot_git_dir) && !fs.exists(working_dir))
    {
        // git clone --no-checkout --local {vcpkg_root} versioning_tmp
        System::CmdLineBuilder clone_cmd_builder;
        clone_cmd_builder.string_arg("clone")
            .string_arg("--no-checkout")
            .string_arg("--local")
            .path_arg(paths.root)
            .string_arg("versioning_tmp");
        const auto output = run_git_command(paths, dot_git_dir, working_dir, clone_cmd_builder.extract());
        Checks::check_exit(VCPKG_LINE_INFO, output.exit_code == 0, "Failed to clone temporary vcpkg instance");
    }

    // git checkout {commit_id} -- ./ports/{port_name}
    System::CmdLineBuilder checkout_cmd_builder;
    checkout_cmd_builder.string_arg("checkout")
        .string_arg(commit_id)
        .string_arg("--")
        .string_arg(Strings::concat("./ports/", port_name));
    const auto git_cmd = checkout_cmd_builder.extract();
    const auto checkout_output = run_git_command(paths, dot_git_dir, working_dir, git_cmd);
    Checks::check_exit(
        VCPKG_LINE_INFO, checkout_output.exit_code == 0, "Failed to checkout % at commit %d", port_name, commit_id);
}

void Versions::fetch_port_version(const VcpkgPaths& paths, const std::string& port_name, const Version& version)
{
    const auto commit_id = get_version_commit_id(port_name, version.to_string(), paths);
    fetch_port_commit_id(paths, port_name, commit_id);
}

Optional<Version> Versions::fetch_port_baseline(const VcpkgPaths& paths,
                                                const std::string& port_name,
                                                const std::string& baseline)
{
    fetch_port_commit_id(paths, port_name, baseline);
    const auto port_dir = paths.buildtrees / "versioning_tmp" / "ports" / port_name;

    auto found_scf = Paragraphs::try_load_port(paths.get_filesystem(), port_dir);
    if (auto scf = found_scf.get())
    {
        return VersionString(scf->get()->core_paragraph->version, scf->get()->core_paragraph->port_version);
    }

    return nullopt;
}