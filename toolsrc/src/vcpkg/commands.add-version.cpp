
#include <vcpkg/base/checks.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/json.h>

#include <vcpkg/commands.add-version.h>
#include <vcpkg/portfileprovider.h>
#include <vcpkg/vcpkgcmdarguments.h>
#include <vcpkg/vcpkgpaths.h>
#include <vcpkg/versiondeserializers.h>
#include <vcpkg/versions.h>

using namespace vcpkg;

namespace vcpkg::Commands::AddVersion
{
    static constexpr StringLiteral OPTION_OVERWRITE_VERSION = "overwrite-version";

    const CommandSwitch COMMAND_SWITCHES[] = {
        {OPTION_OVERWRITE_VERSION, "Overwrite `git-tree` of an existing version."},
    };

    const CommandStructure COMMAND_STRUCTURE{
        create_example_string(R"###(x-add-version <port name>)###"),
        1,
        1,
        {{COMMAND_SWITCHES}, {}, {}},
        nullptr,
    };

    void insert_schemed_version_to_json_object(Json::Object& obj, const SchemedVersion& version)
    {
        auto scheme = version.scheme;
        if (scheme == Versions::Scheme::String)
        {
            obj.insert("version-string", Json::Value::string(version.versiont.text()));
        }
        else if (scheme == Versions::Scheme::Date)
        {
            obj.insert("version-date", Json::Value::string(version.versiont.text()));
        }
        else if (scheme == Versions::Scheme::Semver)
        {
            obj.insert("version-semver", Json::Value::string(version.versiont.text()));
        }
        else if (scheme == Versions::Scheme::Relaxed)
        {
            obj.insert("version", Json::Value::string(version.versiont.text()));
        }
        else
        {
            Checks::unreachable(VCPKG_LINE_INFO);
        }
        obj.insert("port-version", Json::Value::integer(version.versiont.port_version()));
    }

    Json::Object serialize_baseline(const std::map<std::string, SchemedVersion, std::less<>>& baseline)
    {
        Json::Object port_entries_obj;
        for (auto&& kv_pair : baseline)
        {
            Json::Object baseline_version_obj;
            insert_schemed_version_to_json_object(baseline_version_obj, kv_pair.second);
            port_entries_obj.insert(kv_pair.first, baseline_version_obj);
        }

        Json::Object baseline_obj;
        baseline_obj.insert("default", port_entries_obj);
        return baseline_obj;
    }

    Json::Object serialize_versions(const std::vector<VersionDbEntry>& versions)
    {
        Json::Array versions_array;
        for (auto&& version : versions)
        {
            Json::Object version_obj;
            version_obj.insert("git-tree", Json::Value::string(version.git_tree));
            insert_schemed_version_to_json_object(version_obj, SchemedVersion{version.scheme, version.version});
            versions_array.push_back(std::move(version_obj));
        }

        Json::Object output_object;
        output_object.insert("versions", versions_array);
        return output_object;
    }

    void write_baseline_file(Files::Filesystem& fs,
                             const std::map<std::string, SchemedVersion, std::less<>>& baseline_map,
                             const fs::path& output_path)
    {
        auto backup_path = fs::u8path(Strings::concat(fs::u8string(output_path), ".backup"));
        if (fs.exists(output_path))
        {
            fs.rename(output_path, backup_path, VCPKG_LINE_INFO);
            fs.remove(output_path, VCPKG_LINE_INFO);
        }

        std::error_code ec;
        fs.write_contents(output_path, Json::stringify(serialize_baseline(baseline_map), {}), ec);
        if (ec)
        {
            System::printf(
                System::Color::error, "Error: Couldn't write baseline file to %s.", fs::u8string(output_path));
            if (fs.exists(backup_path))
            {
                fs.rename(backup_path, output_path, VCPKG_LINE_INFO);
            }
            Checks::exit_fail(VCPKG_LINE_INFO);
        }
        if (fs.exists(backup_path))
        {
            fs.remove(backup_path, VCPKG_LINE_INFO);
        }
    }

    void write_versions_file(Files::Filesystem& fs,
                             const std::vector<VersionDbEntry>& versions,
                             const fs::path& output_path)
    {
        auto backup_path = fs::u8path(Strings::concat(fs::u8string(output_path), ".backup"));
        if (fs.exists(output_path))
        {
            fs.rename(output_path, backup_path, VCPKG_LINE_INFO);
            fs.remove(output_path, VCPKG_LINE_INFO);
        }

        std::error_code ec;
        fs.write_contents(output_path, Json::stringify(serialize_versions(versions), {}), ec);
        if (ec)
        {
            System::printf(
                System::Color::error, "Error: Couldn't write versions file to %s.", fs::u8string(output_path));
            if (fs.exists(backup_path))
            {
                fs.rename(backup_path, output_path, VCPKG_LINE_INFO);
            }
            Checks::exit_fail(VCPKG_LINE_INFO);
        }
        if (fs.exists(backup_path))
        {
            fs.remove(backup_path, VCPKG_LINE_INFO);
        }
    }

    void update_baseline_version(Files::Filesystem& fs,
                                 const std::string& port_name,
                                 const SchemedVersion& version,
                                 const fs::path& baseline_path)
    {
        auto maybe_baseline_map = vcpkg::parse_baseline_file(fs, "default", baseline_path);
        if (auto pbaseline = maybe_baseline_map.get())
        {
            auto it = pbaseline->find(port_name);
            if (it != pbaseline->end())
            {
                auto& baseline_version = it->second;
                if (baseline_version.versiont == version.versiont && baseline_version.scheme == version.scheme)
                {
                    System::printf(System::Color::success,
                                   "Version `%s` is already in `%s`\n",
                                   version.versiont,
                                   fs::u8string(baseline_path));
                    return;
                }
                baseline_version = version;
            }
            else
            {
                pbaseline->emplace(port_name, version);
            }
            write_baseline_file(fs, *pbaseline, baseline_path);
            System::printf(
                System::Color::success, "Added version `%s` to `%s`.\n", version.versiont, fs::u8string(baseline_path));
            return;
        }

        System::printf(System::Color::error, "Error: Couldn't parse baseline file.\n%s\n", maybe_baseline_map.error());
        Checks::exit_fail(VCPKG_LINE_INFO);
    }

    void update_version_db_file(Files::Filesystem& fs,
                                const std::string& port_name,
                                const SchemedVersion& version,
                                const std::string& git_tree,
                                const fs::path& version_db_file_path,
                                bool overwrite_version)
    {
        if (!fs.exists(version_db_file_path))
        {
            std::vector<VersionDbEntry> new_entry{VersionDbEntry{version.versiont, version.scheme, git_tree}};
            write_versions_file(fs, new_entry, version_db_file_path);
            System::printf(System::Color::success,
                           "Added version `%s` to `%s` (new file).\n",
                           version.versiont,
                           fs::u8string(version_db_file_path));
            return;
        }

        auto maybe_versions = parse_versions_file(fs, port_name, version_db_file_path);
        if (auto versions = maybe_versions.get())
        {
            const auto& versions_end = versions->end();

            auto found_same_sha =
                std::find_if(versions->begin(), versions_end, [&](const VersionDbEntry& db_entry) -> bool {
                    return db_entry.git_tree == git_tree;
                });
            if (found_same_sha != versions_end)
            {
                if (found_same_sha->version == version.versiont && found_same_sha->scheme == version.scheme)
                {
                    System::printf(System::Color::success,
                                   "Version `%s` is already in `%s`\n",
                                   version.versiont,
                                   fs::u8string(version_db_file_path));
                    return;
                }
                System::printf(System::Color::warning,
                               "Warning: Local port files SHA is the same as version `%s` in `%s`.\n"
                               "-- SHA: %s\n"
                               "-- Did you remember to commit your changes?\n"
                               "No files were updated.\n",
                               found_same_sha->version,
                               fs::u8string(version_db_file_path),
                               git_tree);
                Checks::exit_fail(VCPKG_LINE_INFO);
            }

            auto it = std::find_if(versions->begin(), versions_end, [&](const VersionDbEntry& db_entry) -> bool {
                return db_entry.version == version.versiont;
            });

            if (it != versions_end)
            {
                if (!overwrite_version)
                {
                    System::printf(System::Color::error,
                                   "Error: Local changes detected but no changes to version or port version.\n"
                                   "-- Version: %s\n"
                                   "-- Old SHA: %s\n"
                                   "-- New SHA: %s\n"
                                   "-- Did you remember to update the version or port version?\n"
                                   "No files were updated.\n"
                                   "Pass `--overwrite-version` to bypass this check.\n",
                                   version.versiont,
                                   it->git_tree,
                                   git_tree);
                    Checks::exit_fail(VCPKG_LINE_INFO);
                }

                it->scheme = version.scheme;
                it->version = version.versiont;
                it->git_tree = git_tree;
            }
            else
            {
                versions->insert(versions->begin(), {version.versiont, version.scheme, git_tree});
            }
            write_versions_file(fs, *versions, version_db_file_path);
            System::printf(System::Color::success,
                           "Added version `%s` to `%s`.\n",
                           version.versiont,
                           fs::u8string(version_db_file_path));
            return;
        }

        System::printf(System::Color::error,
                       "Error: Unable to parse versions file %s.\n%s\n",
                       fs::u8string(version_db_file_path),
                       maybe_versions.error());
        Checks::exit_fail(VCPKG_LINE_INFO);
    }

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        auto parsed_args = args.parse_arguments(COMMAND_STRUCTURE);
        const auto port_name = args.command_arguments[0];
        bool overwrite_version = Util::Sets::contains(parsed_args.switches, OPTION_OVERWRITE_VERSION);

        auto baseline_path = paths.version_files / fs::u8path("baseline.json");
        auto& fs = paths.get_filesystem();
        if (!fs.exists(baseline_path))
        {
            System::printf(
                System::Color::error, "Error: Couldn't find required file `%s`", fs::u8string(baseline_path));
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        // Get version information of the local port
        PortFileProvider::PathsPortFileProvider provider(paths, {});
        auto maybe_scf = provider.get_control_file(port_name);
        Checks::check_exit(VCPKG_LINE_INFO, maybe_scf.has_value(), "Error: Couldn't load port `%s`.", port_name);
        const auto& scf = maybe_scf.value_or_exit(VCPKG_LINE_INFO);
        const auto& versiont = scf.source_control_file->to_versiont();
        auto scheme = scf.source_control_file->core_paragraph->version_scheme;

        // Get tree-ish from local repository state.
        auto maybe_git_tree_map = paths.git_get_local_port_treeish_map();
        auto git_tree_map = maybe_git_tree_map.value_or_exit(VCPKG_LINE_INFO);
        auto git_tree_it = git_tree_map.find(port_name);
        if (git_tree_it == git_tree_map.end())
        {
            System::printf(System::Color::warning,
                           "Warning: No local Git SHA was found for port `%s`.\n"
                           "-- Did you remember to commit your changes?\n"
                           "No files were updated.\n",
                           port_name);
            Checks::exit_fail(VCPKG_LINE_INFO);
        }
        const auto& git_tree = git_tree_it->second;

        auto port_versions_path =
            paths.version_files / Strings::concat(port_name[0], '-') / Strings::concat(port_name, ".json");
        update_version_db_file(
            fs, port_name, SchemedVersion{scheme, versiont}, git_tree, port_versions_path, overwrite_version);

        update_baseline_version(fs, port_name, SchemedVersion{scheme, versiont}, baseline_path);

        Checks::exit_success(VCPKG_LINE_INFO);
    }

    void AddVersionCommand::perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const
    {
        AddVersion::perform_and_exit(args, paths);
    }
}