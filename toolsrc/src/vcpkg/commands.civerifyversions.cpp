#include <vcpkg/base/checks.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/json.h>
#include <vcpkg/base/system.debug.h>

#include <vcpkg/commands.civerifyversions.h>
#include <vcpkg/portfileprovider.h>
#include <vcpkg/vcpkgcmdarguments.h>
#include <vcpkg/vcpkgpaths.h>
#include <vcpkg/versiondeserializers.h>

namespace
{
    using namespace vcpkg;

}

namespace vcpkg::Commands::CIVerifyVersions
{
    static constexpr StringLiteral OPTION_EXCLUDE = "exclude";

    static constexpr CommandSetting VERIFY_VERSIONS_SETTINGS[] = {
        {OPTION_EXCLUDE, "Comma-separated list of ports to skip"},
    };

    const CommandStructure COMMAND_STRUCTURE{
        create_example_string(R"###(x-ci-verify-versions)###"),
        0,
        SIZE_MAX,
        {{}, {VERIFY_VERSIONS_SETTINGS}, {}},
        nullptr,
    };

    ExpectedS<std::string> verify_version_in_db(Files::Filesystem& fs,
                                                const PortFileProvider::PathsPortFileProvider& paths_provider,
                                                const PortFileProvider::BaselineProvider& baseline_provider,
                                                const std::string& port_name,
                                                const fs::path& versions_file_path,
                                                const std::string& local_git_tree)
    {
        auto maybe_versions = vcpkg::parse_versions_file(fs, port_name, versions_file_path);
        if (!maybe_versions.has_value())
        {
            return {std::move(Strings::format("Error: Cannot parse `%s`.\n\t%s",
                                              fs::u8string(versions_file_path),
                                              port_name,
                                              maybe_versions.error())),
                    expected_right_tag};
        }

        auto versions = maybe_versions.value_or_exit(VCPKG_LINE_INFO);
        auto top_entry = versions.front();

        auto maybe_scf = paths_provider.get_control_file(port_name);
        if (!maybe_scf.has_value())
        {
            return {std::move(Strings::format("Error: Cannot load port `%s`.\n\t%s", port_name, maybe_scf.error())),
                    expected_right_tag};
        }
        auto& scf = maybe_scf.value_or_exit(VCPKG_LINE_INFO);
        auto found_version = scf.to_versiont();

        if (top_entry.version != found_version)
        {
            auto versions_end = versions.end();
            auto it = std::find_if(
                versions.begin(), versions_end, [&](auto&& version) { return version.version == found_version; });
            if (it != versions_end)
            {
                return {std::move(Strings::format("Error: Version `%s` found but is not the top entry in `%s`.",
                                                  found_version,
                                                  fs::u8string(versions_file_path))),
                        expected_right_tag};
            }
            else
            {
                return {std::move(Strings::format(
                            "Error: Version `%s` not found in `%s`.", found_version, fs::u8string(versions_file_path))),
                        expected_right_tag};
            }
        }

        auto maybe_baseline_version = baseline_provider.get_baseline_version(port_name);
        if (!maybe_baseline_version.has_value())
        {
            return {std::move(Strings::format("Error: Couldn't find baseline version for port `%s`.", port_name)),
                    expected_right_tag};
        }

        const auto& baseline_version = maybe_baseline_version.value_or_exit(VCPKG_LINE_INFO);
        if (baseline_version != top_entry.version)
        {
            return {std::move(
                        Strings::format("Error: The baseline version for port `%s` doesn't match the latest version.\n"
                                        "\tBaseline version: %s\n"
                                        "\t  Latest version: %s (%s)",
                                        port_name,
                                        baseline_version,
                                        top_entry.version,
                                        fs::u8string(versions_file_path))),
                    expected_right_tag};
        }

        if (local_git_tree != top_entry.git_tree)
        {
            return {std::move(Strings::format(
                        "Error: Git tree-ish object for version `%s` in `%s` does not match local port files.\n"
                        "\tLocal SHA: %s\n"
                        "\t File SHA: %s",
                        found_version,
                        fs::u8string(versions_file_path),
                        local_git_tree,
                        top_entry.git_tree)),
                    expected_right_tag};
        }

        return {std::move(Strings::format("OK: %s\t%s -> %s\n", top_entry.git_tree, port_name, top_entry.version)),
                expected_left_tag};
    }

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        auto parsed_args = args.parse_arguments(COMMAND_STRUCTURE);

        std::set<std::string> exclusion_set;
        auto settings = parsed_args.settings;
        auto it_exclusions = settings.find(OPTION_EXCLUDE);
        if (it_exclusions != settings.end())
        {
            auto exclusions = Strings::split(it_exclusions->second, ',');
            exclusion_set.insert(exclusions.begin(), exclusions.end());
        }

        auto maybe_port_git_tree_map = paths.git_get_local_port_treeish_map();
        Checks::check_exit(VCPKG_LINE_INFO,
                           maybe_port_git_tree_map.has_value(),
                           "Error: Failed to obtain git treeish objects for local ports.\n%s",
                           maybe_port_git_tree_map.error());

        auto port_git_tree_map = maybe_port_git_tree_map.value_or_exit(VCPKG_LINE_INFO);
        auto& fs = paths.get_filesystem();

        // Without a revision, baseline will use local baseline.json file.
        auto baseline_file_path = paths.version_files / fs::u8path("baseline.json");
        Checks::check_exit(VCPKG_LINE_INFO,
                           fs.exists(baseline_file_path),
                           "Error: Couldn't find required file `%s`.",
                           fs::u8string(baseline_file_path));
        PortFileProvider::BaselineProvider baseline_provider(paths);
        PortFileProvider::PathsPortFileProvider paths_provider(paths, {});

        std::set<std::string> errors;
        for (const auto& dir : fs::directory_iterator(paths.builtin_ports_directory()))
        {
            const auto& port_path = dir.path();

            auto&& port_name = fs::u8string(port_path.stem());
            if (Util::Sets::contains(exclusion_set, port_name))
            {
                System::printf("SKIP: %s\n", port_name);
                continue;
            }

            auto control_path = port_path / fs::u8path("CONTROL");
            auto manifest_path = port_path / fs::u8path("vcpkg.json");
            auto manifest_exists = fs.exists(manifest_path);
            auto control_exists = fs.exists(control_path);

            if (manifest_exists && control_exists)
            {
                errors.emplace(
                    Strings::format("Error: Both a manifest file and a CONTROL file exist in port directory: %s",
                                    fs::u8string(port_path)));
                continue;
            }

            if (!manifest_exists && !control_exists)
            {
                errors.emplace(Strings::format("Error: No manifest file or CONTROL file exist in port directory: %s",
                                               fs::u8string(port_path)));
                continue;
            }

            auto versions_file_path =
                paths.version_files / Strings::concat(port_name[0], '-') / Strings::concat(port_name, ".json");
            if (!fs.exists(versions_file_path))
            {
                errors.emplace(Strings::format("Error: Missing versions file for `%s`. Expected at `%s`.",
                                               port_name,
                                               fs::u8string(versions_file_path)));
                continue;
            }

            auto maybe_ok = verify_version_in_db(
                fs, paths_provider, baseline_provider, port_name, versions_file_path, port_git_tree_map[port_name]);

            if (!maybe_ok.has_value())
            {
                System::printf(System::Color::error, "FAIL: %s\n", port_name);
                errors.emplace(maybe_ok.error());
                continue;
            }

            System::printf("%s", maybe_ok.value_or_exit(VCPKG_LINE_INFO));
        }

        if (!errors.empty())
        {
            System::print2(System::Color::error, "Found the following errors:\n");
            for (auto&& error : errors)
            {
                System::printf(System::Color::error, "%s\n", error);
            }
        }
        Checks::exit_success(VCPKG_LINE_INFO);
    }

    void CIVerifyVersionsCommand::perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const
    {
        CIVerifyVersions::perform_and_exit(args, paths);
    }
}