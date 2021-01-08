#include <vcpkg/base/checks.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/json.h>
#include <vcpkg/base/system.debug.h>

#include <vcpkg/commands.civerifyversions.h>
#include <vcpkg/paragraphs.h>
#include <vcpkg/registries.h>
#include <vcpkg/sourceparagraph.h>
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
    static constexpr StringLiteral OPTION_VERBOSE = "verbose";
    static constexpr StringLiteral OPTION_VERIFY_GIT_TREES = "verify-git-trees";

    static constexpr CommandSwitch VERIFY_VERSIONS_SWITCHES[]{
        {OPTION_VERBOSE, "Print result for each port instead of just errors."},
        {OPTION_VERIFY_GIT_TREES, "Verify that each git tree object matches its declared version (this is very slow)"},
    };

    static constexpr CommandSetting VERIFY_VERSIONS_SETTINGS[] = {
        {OPTION_EXCLUDE, "Comma-separated list of ports to skip"},
    };

    const CommandStructure COMMAND_STRUCTURE{
        create_example_string(R"###(x-ci-verify-versions)###"),
        0,
        SIZE_MAX,
        {{VERIFY_VERSIONS_SWITCHES}, {VERIFY_VERSIONS_SETTINGS}, {}},
        nullptr,
    };

    static ExpectedS<std::string> verify_version_in_db(const VcpkgPaths& paths,
                                                       const std::map<std::string, VersionT, std::less<>> baseline,
                                                       const std::string& port_name,
                                                       const fs::path& port_path,
                                                       const fs::path& versions_file_path,
                                                       const std::string& local_git_tree,
                                                       bool verify_git_trees)
    {
        auto maybe_versions = vcpkg::get_builtin_versions(paths, port_name);
        if (!maybe_versions.has_value())
        {
            return {
                Strings::format(
                    "Error: Cannot parse `%s`.\n\t%s", fs::u8string(versions_file_path), maybe_versions.error()),
                expected_right_tag,
            };
        }

        const auto& versions = maybe_versions.value_or_exit(VCPKG_LINE_INFO);
        if (versions.empty())
        {
            return {
                Strings::format("Error: File `%s` contains no versions.", fs::u8string(versions_file_path)),
                expected_right_tag,
            };
        }

        if (verify_git_trees)
        {
            for (auto&& version_entry : versions)
            {
                bool version_ok = false;
                for (const std::string& control_file : {"CONTROL", "vcpkg.json"})
                {
                    auto treeish = Strings::concat(version_entry.second, ':', control_file);
                    auto maybe_file = paths.git_show(Strings::concat(treeish), paths.root / fs::u8path(".git"));
                    if (!maybe_file.has_value()) continue;

                    const auto& file = maybe_file.value_or_exit(VCPKG_LINE_INFO);
                    auto maybe_scf = Paragraphs::try_load_port_text(file, treeish, control_file == "vcpkg.json");
                    if (!maybe_scf.has_value())
                    {
                        return {
                            Strings::format("Error: Unable to parse `%s` used in version `%s`.\n%s\n",
                                            treeish,
                                            version_entry.first.to_string(),
                                            maybe_scf.error()->error),
                            expected_right_tag,
                        };
                    }

                    const auto& scf = maybe_scf.value_or_exit(VCPKG_LINE_INFO);
                    auto&& git_tree_version = scf.get()->to_versiont();
                    if (version_entry.first != git_tree_version)
                    {
                        return {
                            Strings::format("Error: Version in git-tree `%s` does not match version in file "
                                            "`%s`.\n\tgit-tree version: %s\n\t    file version: %s\n",
                                            version_entry.second,
                                            fs::u8string(versions_file_path),
                                            git_tree_version.to_string(),
                                            version_entry.first.to_string()),
                            expected_right_tag,
                        };
                    }
                    version_ok = true;
                    break;
                }

                if (!version_ok)
                {
                    return {
                        Strings::format("Error: The git-tree `%s` for version `%s` in `%s` does not contain a "
                                        "CONTROL file or vcpkg.json file.",
                                        version_entry.second,
                                        version_entry.first,
                                        fs::u8string(versions_file_path)),
                        expected_right_tag,
                    };
                }
            }
        }

        const auto& top_entry = versions.front();

        auto maybe_scf = Paragraphs::try_load_port(paths.get_filesystem(), port_path);
        if (!maybe_scf.has_value())
        {
            return {
                Strings::format("Error: Cannot load port `%s`.\n\t%s", port_name, maybe_scf.error()->error),
                expected_right_tag,
            };
        }

        const auto found_version = maybe_scf.value_or_exit(VCPKG_LINE_INFO)->to_versiont();
        if (top_entry.first != found_version)
        {
            auto versions_end = versions.end();
            auto it = std::find_if(
                versions.begin(), versions_end, [&](auto&& entry) { return entry.first == found_version; });
            if (it != versions_end)
            {
                return {
                    Strings::format("Error: Version `%s` found but is not the top entry in `%s`.",
                                    found_version,
                                    fs::u8string(versions_file_path)),
                    expected_right_tag,
                };
            }
            else
            {
                return {
                    Strings::format(
                        "Error: Version `%s` not found in `%s`.", found_version, fs::u8string(versions_file_path)),
                    expected_right_tag,
                };
            }
        }

        if (local_git_tree != top_entry.second)
        {
            return {
                Strings::format("Error: Git tree-ish object for version `%s` in `%s` does not match local port files.\n"
                                "\tLocal SHA: %s\n"
                                "\t File SHA: %s",
                                found_version,
                                fs::u8string(versions_file_path),
                                local_git_tree,
                                top_entry.second),
                expected_right_tag,
            };
        }

        auto maybe_baseline = baseline.find(port_name);
        if (maybe_baseline == baseline.end())
        {
            return {
                Strings::format("Error: Couldn't find baseline version for port `%s`.", port_name),
                expected_right_tag,
            };
        }

        auto&& baseline_version = maybe_baseline->second;
        if (baseline_version != top_entry.first)
        {
            return {
                Strings::format("Error: The baseline version for port `%s` doesn't match the latest version.\n"
                                "\tBaseline version: %s\n"
                                "\t  Latest version: %s (%s)",
                                port_name,
                                baseline_version,
                                top_entry.first,
                                fs::u8string(versions_file_path)),
                expected_right_tag,
            };
        }

        if (local_git_tree != top_entry.second)
        {
            return {
                Strings::format("Error: Git tree-ish object for version `%s` in `%s` does not match local port files.\n"
                                "\tLocal SHA: %s\n"
                                "\t File SHA: %s",
                                found_version,
                                fs::u8string(versions_file_path),
                                local_git_tree,
                                top_entry.second),
                expected_right_tag,
            };
        }

        return {
            Strings::format("OK: %s\t%s -> %s\n", top_entry.second, port_name, top_entry.first),
            expected_left_tag,
        };
    }

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        auto parsed_args = args.parse_arguments(COMMAND_STRUCTURE);

        bool verbose = Util::Sets::contains(parsed_args.switches, OPTION_VERBOSE);
        bool verify_git_trees = Util::Sets::contains(parsed_args.switches, OPTION_VERIFY_GIT_TREES);

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

        // Baseline is required.
        auto baseline = get_builtin_baseline(paths).value_or_exit(VCPKG_LINE_INFO);
        auto& fs = paths.get_filesystem();
        std::set<std::string> errors;
        for (const auto& dir : fs::directory_iterator(paths.builtin_ports_directory()))
        {
            const auto& port_path = dir.path();

            auto&& port_name = fs::u8string(port_path.stem());
            if (Util::Sets::contains(exclusion_set, port_name))
            {
                if (verbose) System::printf("SKIP: %s\n", port_name);
                continue;
            }
            auto git_tree_it = port_git_tree_map.find(port_name);
            if (git_tree_it == port_git_tree_map.end())
            {
                System::printf(System::Color::error, "FAIL: %s\n", port_name);
                errors.emplace(Strings::format("Error: Missing local git tree object for port `%s`.", port_name));
                continue;
            }
            auto git_tree = git_tree_it->second;

            auto control_path = port_path / fs::u8path("CONTROL");
            auto manifest_path = port_path / fs::u8path("vcpkg.json");
            auto manifest_exists = fs.exists(manifest_path);
            auto control_exists = fs.exists(control_path);

            if (manifest_exists && control_exists)
            {
                System::printf(System::Color::error, "FAIL: %s\n", port_name);
                errors.emplace(
                    Strings::format("Error: Both a manifest file and a CONTROL file exist in port directory: %s",
                                    fs::u8string(port_path)));
                continue;
            }

            if (!manifest_exists && !control_exists)
            {
                System::printf(System::Color::error, "FAIL: %s\n", port_name);
                errors.emplace(Strings::format("Error: No manifest file or CONTROL file exist in port directory: %s",
                                               fs::u8string(port_path)));
                continue;
            }

            auto versions_file_path =
                paths.builtin_port_versions / Strings::concat(port_name[0], '-') / Strings::concat(port_name, ".json");
            if (!fs.exists(versions_file_path))
            {
                System::printf(System::Color::error, "FAIL: %s\n", port_name);
                errors.emplace(Strings::format("Error: Missing versions file for `%s`. Expected at `%s`.",
                                               port_name,
                                               fs::u8string(versions_file_path)));
                continue;
            }

            auto maybe_ok = verify_version_in_db(
                paths, baseline, port_name, port_path, versions_file_path, git_tree, verify_git_trees);

            if (!maybe_ok.has_value())
            {
                System::printf(System::Color::error, "FAIL: %s\n", port_name);
                errors.emplace(maybe_ok.error());
                continue;
            }

            if (verbose) System::printf("%s", maybe_ok.value_or_exit(VCPKG_LINE_INFO));
        }

        if (!errors.empty())
        {
            System::print2(System::Color::error, "Found the following errors:\n");
            for (auto&& error : errors)
            {
                System::printf(System::Color::error, "%s\n", error);
            }
            Checks::exit_fail(VCPKG_LINE_INFO);
        }
        Checks::exit_success(VCPKG_LINE_INFO);
    }

    void CIVerifyVersionsCommand::perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const
    {
        CIVerifyVersions::perform_and_exit(args, paths);
    }
}