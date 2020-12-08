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
    struct VersionErrors
    {
        std::set<std::string> portfiles_errors;
        std::set<std::string> missing_version_file_errors;
        std::set<std::string> unparseable_version_file_errors;
        std::set<std::string> missing_version_errors;
        std::set<std::string> not_top_version_errors;

        bool empty() const
        {
            return portfiles_errors.empty() && missing_version_file_errors.empty() &&
                   unparseable_version_file_errors.empty() && missing_version_errors.empty() &&
                   not_top_version_errors.empty();
        }
    };

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

        PortFileProvider::PathsPortFileProvider paths_provider(paths, {});

        auto& fs = paths.get_filesystem();

        VersionErrors errors;
        for (const auto& dir : fs::directory_iterator(paths.builtin_ports_directory()))
        {
            const auto& port_path = dir.path();

            auto&& port_name = fs::u8string(port_path.stem());
            if (Util::Sets::contains(exclusion_set, port_name)) continue;

            auto control_path = port_path / fs::u8path("CONTROL");
            auto manifest_path = port_path / fs::u8path("vcpkg.json");
            auto manifest_exists = fs.exists(manifest_path);
            auto control_exists = fs.exists(control_path);

            if (manifest_exists && control_exists)
            {
                errors.portfiles_errors.emplace(
                    Strings::format("Error: Both a manifest file and a CONTROL file exist in port directory: %s",
                                    fs::u8string(port_path)));
                continue;
            }
            else if (!manifest_exists && !control_exists)
            {
                errors.portfiles_errors.emplace(Strings::format(
                    "Warning: No manifest file or CONTROL file exist in port directory: %s", fs::u8string(port_path)));
                continue;
            }

            auto versions_file_path =
                paths.version_files / Strings::concat(port_name[0], '-') / Strings::concat(port_name, ".json");

            if (!fs.exists(versions_file_path))
            {
                errors.missing_version_file_errors.emplace(
                    Strings::format("Error: Missing versions file for `%s`. Expected at `%s`.",
                                    port_name,
                                    fs::u8string(versions_file_path)));
                continue;
            }

            auto maybe_versions = vcpkg::parse_versions_file(fs, port_name, versions_file_path);

            if (auto versions = maybe_versions.get())
            {
                if (versions->empty())
                {
                    errors.unparseable_version_file_errors.emplace(
                        Strings::format("Error: Versions file `%s` exists but does not contain versions.",
                                        fs::u8string(versions_file_path)));
                    continue;
                }
                auto top_entry = versions->front();

                auto maybe_scf = paths_provider.get_control_file(port_name);
                if (auto scf = maybe_scf.get())
                {
                    auto found_version = scf->to_versiont();
                    if (top_entry.version == found_version)
                    {
                        System::printf("OK: %s -> %s\n", port_name, found_version);
                    }
                    else
                    {
                        System::printf("FAIL: %s -> %s\n", port_name, found_version);
                        auto it = std::find_if(versions->begin(), versions->end(), [&](auto&& version) {
                            return version.version == found_version;
                        });

                        if (it != versions->end())
                        {
                            errors.not_top_version_errors.emplace(
                                Strings::format("Error: Found version `%s` in `%s` but it is not the top entry.",
                                                found_version,
                                                fs::u8string(versions_file_path)));
                        }
                        else
                        {
                            errors.missing_version_errors.emplace(
                                Strings::format("Error: Versions file `%s` does not contain an entry for version `%s`.",
                                                fs::u8string(versions_file_path),
                                                found_version));
                        }
                    }
                }
                else
                {
                    errors.portfiles_errors.emplace(
                        Strings::format("Error: Couldn't load port `%s`.\n%s", port_name, maybe_scf.error()));
                }
            }
            else
            {
                errors.unparseable_version_file_errors.emplace(
                    Strings::format("Error: Couldn't parse versions file `%s` for port `%s`.\n%s",
                                    fs::u8string(versions_file_path),
                                    port_name,
                                    maybe_versions.error()));
            }
        }

        if (!errors.empty())
        {
            System::print2(System::Color::error, "Found the following errors:\n");
            for (auto&& error : errors.portfiles_errors)
            {
                System::printf(System::Color::error, "\t%s\n", error);
            }
            for (auto&& error : errors.missing_version_file_errors)
            {
                System::printf(System::Color::error, "\t%s\n", error);
            }
            for (auto&& error : errors.unparseable_version_file_errors)
            {
                System::printf(System::Color::error, "\t%s\n", error);
            }
            for (auto&& error : errors.not_top_version_errors)
            {
                System::printf(System::Color::error, "\t%s\n", error);
            }
            for (auto&& error : errors.missing_version_errors)
            {
                System::printf(System::Color::error, "\t%s\n", error);
            }
        }
        Checks::exit_success(VCPKG_LINE_INFO);
    }

    void CIVerifyVersionsCommand::perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const
    {
        CIVerifyVersions::perform_and_exit(args, paths);
    }
}