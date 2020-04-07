#include "pch.h"

#include <vcpkg/commands.h>
#include <vcpkg/dependencies.h>
#include <vcpkg/export.chocolatey.h>
#include <vcpkg/export.prefab.h>
#include <vcpkg/export.h>
#include <vcpkg/export.ifw.h>
#include <vcpkg/help.h>
#include <vcpkg/input.h>
#include <vcpkg/install.h>
#include <vcpkg/paragraphs.h>
#include <vcpkg/vcpkglib.h>

#include <vcpkg/base/stringliteral.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/base/util.h>

namespace vcpkg::Export
{
    using Dependencies::ExportPlanAction;
    using Dependencies::ExportPlanType;
    using Dependencies::RequestType;
    using Install::InstallDir;

    static std::string create_nuspec_file_contents(const std::string& raw_exported_dir,
                                                   const std::string& targets_redirect_path,
                                                   const std::string& nuget_id,
                                                   const std::string& nupkg_version)
    {
        static constexpr auto CONTENT_TEMPLATE = R"(
<package>
    <metadata>
        <id>@NUGET_ID@</id>
        <version>@VERSION@</version>
        <authors>vcpkg</authors>
        <description>
            Vcpkg NuGet export
        </description>
    </metadata>
    <files>
        <file src="@RAW_EXPORTED_DIR@\installed\**" target="installed" />
        <file src="@RAW_EXPORTED_DIR@\scripts\**" target="scripts" />
        <file src="@RAW_EXPORTED_DIR@\.vcpkg-root" target="" />
        <file src="@TARGETS_REDIRECT_PATH@" target="build\native\@NUGET_ID@.targets" />
    </files>
</package>
)";

        std::string nuspec_file_content = Strings::replace_all(CONTENT_TEMPLATE, "@NUGET_ID@", nuget_id);
        nuspec_file_content = Strings::replace_all(std::move(nuspec_file_content), "@VERSION@", nupkg_version);
        nuspec_file_content =
            Strings::replace_all(std::move(nuspec_file_content), "@RAW_EXPORTED_DIR@", raw_exported_dir);
        nuspec_file_content =
            Strings::replace_all(std::move(nuspec_file_content), "@TARGETS_REDIRECT_PATH@", targets_redirect_path);
        return nuspec_file_content;
    }

    static std::string create_targets_redirect(const std::string& target_path) noexcept
    {
        return Strings::format(R"###(
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <VcpkgRoot>$([MSBuild]::GetDirectoryNameOfFileAbove($(MSBuildThisFileDirectory), .vcpkg-root))\installed\$(VcpkgTriplet)\</VcpkgRoot>
  </PropertyGroup>
  <Import Condition="Exists('%s')" Project="%s" />
</Project>
)###",
                               target_path,
                               target_path);
    }

    static void print_plan(const std::map<ExportPlanType, std::vector<const ExportPlanAction*>>& group_by_plan_type)
    {
        static constexpr std::array<ExportPlanType, 2> ORDER = {ExportPlanType::ALREADY_BUILT,
                                                                ExportPlanType::NOT_BUILT};
        static constexpr Build::BuildPackageOptions BUILD_OPTIONS = {
            Build::UseHeadVersion::NO,
            Build::AllowDownloads::YES,
            Build::OnlyDownloads::NO,
            Build::CleanBuildtrees::NO,
            Build::CleanPackages::NO,
            Build::CleanDownloads::NO,
            Build::DownloadTool::BUILT_IN,
            Build::BinaryCaching::NO,
            Build::FailOnTombstone::NO,
        };

        for (const ExportPlanType plan_type : ORDER)
        {
            const auto it = group_by_plan_type.find(plan_type);
            if (it == group_by_plan_type.cend())
            {
                continue;
            }

            std::vector<const ExportPlanAction*> cont = it->second;
            std::sort(cont.begin(), cont.end(), &ExportPlanAction::compare_by_name);
            const std::string as_string = Strings::join("\n", cont, [](const ExportPlanAction* p) {
                return Dependencies::to_output_string(p->request_type, p->spec.to_string(), BUILD_OPTIONS);
            });

            switch (plan_type)
            {
                case ExportPlanType::ALREADY_BUILT:
                    System::print2("The following packages are already built and will be exported:\n", as_string, '\n');
                    continue;
                case ExportPlanType::NOT_BUILT:
                    System::print2("The following packages need to be built:\n", as_string, '\n');
                    continue;
                default: Checks::unreachable(VCPKG_LINE_INFO);
            }
        }
    }

    static std::string create_export_id()
    {
        const tm date_time = Chrono::get_current_date_time_local();

        // Format is: YYYYmmdd-HHMMSS
        // 15 characters + 1 null terminating character will be written for a total of 16 chars
        char mbstr[16];
        const size_t bytes_written = std::strftime(mbstr, sizeof(mbstr), "%Y%m%d-%H%M%S", &date_time);
        Checks::check_exit(VCPKG_LINE_INFO,
                           bytes_written == 15,
                           "Expected 15 bytes to be written, but %u were written",
                           bytes_written);
        const std::string date_time_as_string(mbstr);
        return ("vcpkg-export-" + date_time_as_string);
    }

    static fs::path do_nuget_export(const VcpkgPaths& paths,
                                    const std::string& nuget_id,
                                    const std::string& nuget_version,
                                    const fs::path& raw_exported_dir,
                                    const fs::path& output_dir)
    {
        Files::Filesystem& fs = paths.get_filesystem();
        const fs::path& nuget_exe = paths.get_tool_exe(Tools::NUGET);

        // This file will be placed in "build\native" in the nuget package. Therefore, go up two dirs.
        const std::string targets_redirect_content =
            create_targets_redirect("$(MSBuildThisFileDirectory)../../scripts/buildsystems/msbuild/vcpkg.targets");
        const fs::path targets_redirect = paths.buildsystems / "tmp" / "vcpkg.export.nuget.targets";

        std::error_code ec;
        fs.create_directories(paths.buildsystems / "tmp", ec);

        fs.write_contents(targets_redirect, targets_redirect_content, VCPKG_LINE_INFO);

        const std::string nuspec_file_content =
            create_nuspec_file_contents(raw_exported_dir.string(), targets_redirect.string(), nuget_id, nuget_version);
        const fs::path nuspec_file_path = paths.buildsystems / "tmp" / "vcpkg.export.nuspec";
        fs.write_contents(nuspec_file_path, nuspec_file_content, VCPKG_LINE_INFO);

        // -NoDefaultExcludes is needed for ".vcpkg-root"
        const auto cmd_line = Strings::format(R"("%s" pack -OutputDirectory "%s" "%s" -NoDefaultExcludes)",
                                              nuget_exe.u8string(),
                                              output_dir.u8string(),
                                              nuspec_file_path.u8string());

        const int exit_code =
            System::cmd_execute_and_capture_output(cmd_line, System::get_clean_environment()).exit_code;
        Checks::check_exit(VCPKG_LINE_INFO, exit_code == 0, "Error: NuGet package creation failed");

        const fs::path output_path = output_dir / (nuget_id + "." + nuget_version + ".nupkg");
        return output_path;
    }

    struct ArchiveFormat final
    {
        enum class BackingEnum
        {
            ZIP = 1,
            SEVEN_ZIP,
        };

        constexpr ArchiveFormat() = delete;

        constexpr ArchiveFormat(BackingEnum backing_enum, const char* extension, const char* cmake_option)
            : backing_enum(backing_enum), m_extension(extension), m_cmake_option(cmake_option)
        {
        }

        constexpr operator BackingEnum() const { return backing_enum; }
        constexpr CStringView extension() const { return this->m_extension; }
        constexpr CStringView cmake_option() const { return this->m_cmake_option; }

    private:
        BackingEnum backing_enum;
        const char* m_extension;
        const char* m_cmake_option;
    };

    namespace ArchiveFormatC
    {
        constexpr const ArchiveFormat ZIP(ArchiveFormat::BackingEnum::ZIP, "zip", "zip");
        constexpr const ArchiveFormat SEVEN_ZIP(ArchiveFormat::BackingEnum::SEVEN_ZIP, "7z", "7zip");
        constexpr const ArchiveFormat AAR(ArchiveFormat::BackingEnum::ZIP, "aar", "zip");
    }

    static fs::path do_archive_export(const VcpkgPaths& paths,
                                      const fs::path& raw_exported_dir,
                                      const fs::path& output_dir,
                                      const ArchiveFormat& format)
    {
        const fs::path& cmake_exe = paths.get_tool_exe(Tools::CMAKE);

        const std::string exported_dir_filename = raw_exported_dir.filename().u8string();
        const std::string exported_archive_filename =
            Strings::format("%s.%s", exported_dir_filename, format.extension());
        const fs::path exported_archive_path = (output_dir / exported_archive_filename);

        // -NoDefaultExcludes is needed for ".vcpkg-root"
        const auto cmd_line = Strings::format(R"("%s" -E tar "cf" "%s" --format=%s -- "%s")",
                                              cmake_exe.u8string(),
                                              exported_archive_path.u8string(),
                                              format.cmake_option(),
                                              raw_exported_dir.u8string());

        const int exit_code = System::cmd_execute_clean(cmd_line);
        Checks::check_exit(
            VCPKG_LINE_INFO, exit_code == 0, "Error: %s creation failed", exported_archive_path.generic_string());
        return exported_archive_path;
    }

    static Optional<std::string> maybe_lookup(std::unordered_map<std::string, std::string> const& m,
                                              std::string const& key)
    {
        const auto it = m.find(key);
        if (it != m.end()) return it->second;
        return nullopt;
    }

    void export_integration_files(const fs::path& raw_exported_dir_path, const VcpkgPaths& paths)
    {
        const std::vector<fs::path> integration_files_relative_to_root = {
            {".vcpkg-root"},
            {fs::path{"scripts"} / "buildsystems" / "msbuild" / "applocal.ps1"},
            {fs::path{"scripts"} / "buildsystems" / "msbuild" / "vcpkg.targets"},
            {fs::path{"scripts"} / "buildsystems" / "vcpkg.cmake"},
            {fs::path{"scripts"} / "cmake" / "vcpkg_get_windows_sdk.cmake"},
        };

        for (const fs::path& file : integration_files_relative_to_root)
        {
            const fs::path source = paths.root / file;
            fs::path destination = raw_exported_dir_path / file;
            Files::Filesystem& fs = paths.get_filesystem();
            std::error_code ec;
            fs.create_directories(destination.parent_path(), ec);
            Checks::check_exit(VCPKG_LINE_INFO, !ec);
            fs.copy_file(source, destination, fs::copy_options::overwrite_existing, ec);
            Checks::check_exit(VCPKG_LINE_INFO, !ec);
        }
    }

    struct ExportArguments
    {
        bool dry_run = false;
        bool raw = false;
        bool nuget = false;
        bool ifw = false;
        bool zip = false;
        bool seven_zip = false;
        bool chocolatey = false;
        bool prefab = false;
        bool all_installed = false;

        Optional<std::string> maybe_output;

        Optional<std::string> maybe_nuget_id;
        Optional<std::string> maybe_nuget_version;

        IFW::Options ifw_options;
        Prefab::Options prefab_options;
        Chocolatey::Options chocolatey_options;
        std::vector<PackageSpec> specs;
    };

    static constexpr StringLiteral OPTION_OUTPUT = "--output";
    static constexpr StringLiteral OPTION_DRY_RUN = "--dry-run";
    static constexpr StringLiteral OPTION_RAW = "--raw";
    static constexpr StringLiteral OPTION_NUGET = "--nuget";
    static constexpr StringLiteral OPTION_IFW = "--ifw";
    static constexpr StringLiteral OPTION_ZIP = "--zip";
    static constexpr StringLiteral OPTION_SEVEN_ZIP = "--7zip";
    static constexpr StringLiteral OPTION_NUGET_ID = "--nuget-id";
    static constexpr StringLiteral OPTION_NUGET_VERSION = "--nuget-version";
    static constexpr StringLiteral OPTION_IFW_REPOSITORY_URL = "--ifw-repository-url";
    static constexpr StringLiteral OPTION_IFW_PACKAGES_DIR_PATH = "--ifw-packages-directory-path";
    static constexpr StringLiteral OPTION_IFW_REPOSITORY_DIR_PATH = "--ifw-repository-directory-path";
    static constexpr StringLiteral OPTION_IFW_CONFIG_FILE_PATH = "--ifw-configuration-file-path";
    static constexpr StringLiteral OPTION_IFW_INSTALLER_FILE_PATH = "--ifw-installer-file-path";
    static constexpr StringLiteral OPTION_CHOCOLATEY = "--x-chocolatey";
    static constexpr StringLiteral OPTION_CHOCOLATEY_MAINTAINER = "--x-maintainer";
    static constexpr StringLiteral OPTION_CHOCOLATEY_VERSION_SUFFIX = "--x-version-suffix";
    static constexpr StringLiteral OPTION_ALL_INSTALLED = "--x-all-installed";
    
    static constexpr StringLiteral OPTION_PREFAB = "--prefab";
    static constexpr StringLiteral OPTION_PREFAB_GROUP_ID = "--prefab-group-id";
    static constexpr StringLiteral OPTION_PREFAB_ARTIFACT_ID = "--prefab-artifact-id";
    static constexpr StringLiteral OPTION_PREFAB_VERSION = "--prefab-version";
    static constexpr StringLiteral OPTION_PREFAB_SDK_MIN_VERSION = "--prefab-min-sdk";
    static constexpr StringLiteral OPTION_PREFAB_SDK_TARGET_VERSION = "--prefab-target-sdk";
    static constexpr StringLiteral OPTION_PREFAB_ENABLE_MAVEN = "--prefab-maven";
    static constexpr StringLiteral OPTION_PREFAB_ENABLE_DEBUG = "--prefab-debug";
    



    static constexpr std::array<CommandSwitch, 11> EXPORT_SWITCHES = {{
        {OPTION_DRY_RUN, "Do not actually export"},
        {OPTION_RAW, "Export to an uncompressed directory"},
        {OPTION_NUGET, "Export a NuGet package"},
        {OPTION_IFW, "Export to an IFW-based installer"},
        {OPTION_ZIP, "Export to a zip file"},
        {OPTION_SEVEN_ZIP, "Export to a 7zip (.7z) file"},
        {OPTION_CHOCOLATEY, "Export a Chocolatey package (experimental feature)"},
        {OPTION_PREFAB, "Export to Prefab format"},
        {OPTION_PREFAB_ENABLE_MAVEN, "Enable maven"},
        {OPTION_PREFAB_ENABLE_DEBUG, "Enable prefab debug"},
        {OPTION_ALL_INSTALLED, "Export all installed packages"},
    }};

    static constexpr std::array<CommandSetting, 15> EXPORT_SETTINGS = {{
        {OPTION_OUTPUT, "Specify the output name (used to construct filename)"},
        {OPTION_NUGET_ID, "Specify the id for the exported NuGet package (overrides --output)"},
        {OPTION_NUGET_VERSION, "Specify the version for the exported NuGet package"},
        {OPTION_IFW_REPOSITORY_URL, "Specify the remote repository URL for the online installer"},
        {OPTION_IFW_PACKAGES_DIR_PATH, "Specify the temporary directory path for the repacked packages"},
        {OPTION_IFW_REPOSITORY_DIR_PATH, "Specify the directory path for the exported repository"},
        {OPTION_IFW_CONFIG_FILE_PATH, "Specify the temporary file path for the installer configuration"},
        {OPTION_IFW_INSTALLER_FILE_PATH, "Specify the file path for the exported installer"},
        {OPTION_CHOCOLATEY_MAINTAINER,
         "Specify the maintainer for the exported Chocolatey package (experimental feature)"},
        {OPTION_CHOCOLATEY_VERSION_SUFFIX,
         "Specify the version suffix to add for the exported Chocolatey package (experimental feature)"},
        {OPTION_PREFAB_GROUP_ID,  "GroupId uniquely identifies your project according maven specifications"},
        {OPTION_PREFAB_ARTIFACT_ID, "Artifact Id is the name of the project according maven specifications"},
        {OPTION_PREFAB_VERSION, "Version is the name of the project according maven specifications"},
        {OPTION_PREFAB_SDK_MIN_VERSION, "Android minimum supported sdk version"},
        {OPTION_PREFAB_SDK_TARGET_VERSION, "Android target sdk version"},
    }};

    const CommandStructure COMMAND_STRUCTURE = {
        Help::create_example_string("export zlib zlib:x64-windows boost --nuget"),
        0,
        SIZE_MAX,
        {EXPORT_SWITCHES, EXPORT_SETTINGS},
        nullptr,
    };

    static ExportArguments handle_export_command_arguments(const VcpkgCmdArguments& args,
                                                           Triplet default_triplet,
                                                           const StatusParagraphs& status_db)
    {
        ExportArguments ret;

        const auto options = args.parse_arguments(COMMAND_STRUCTURE);

        ret.dry_run = options.switches.find(OPTION_DRY_RUN) != options.switches.cend();
        ret.raw = options.switches.find(OPTION_RAW) != options.switches.cend();
        ret.nuget = options.switches.find(OPTION_NUGET) != options.switches.cend();
        ret.ifw = options.switches.find(OPTION_IFW) != options.switches.cend();
        ret.zip = options.switches.find(OPTION_ZIP) != options.switches.cend();
        ret.seven_zip = options.switches.find(OPTION_SEVEN_ZIP) != options.switches.cend();
        ret.chocolatey = options.switches.find(OPTION_CHOCOLATEY) != options.switches.cend();
        ret.prefab = options.switches.find(OPTION_PREFAB) != options.switches.cend();
        ret.prefab_options.enable_maven = options.switches.find(OPTION_PREFAB_ENABLE_MAVEN) != options.switches.cend();
        ret.prefab_options.enable_debug = options.switches.find(OPTION_PREFAB_ENABLE_DEBUG) != options.switches.cend();
        ret.maybe_output = maybe_lookup(options.settings, OPTION_OUTPUT);
        ret.all_installed = options.switches.find(OPTION_ALL_INSTALLED) != options.switches.end();

        if (ret.all_installed)
        {
            auto installed_ipv = get_installed_ports(status_db);
            std::transform(installed_ipv.begin(),
                           installed_ipv.end(),
                           std::back_inserter(ret.specs),
                           [](const auto& ipv) { return ipv.spec(); });
        }
        else
        {
            // input sanitization
            ret.specs = Util::fmap(args.command_arguments, [&](auto&& arg) {
                return Input::check_and_get_package_spec(
                    std::string(arg), default_triplet, COMMAND_STRUCTURE.example_text);
            });
        }

        if (!ret.raw && !ret.nuget && !ret.ifw && !ret.zip && !ret.seven_zip && !ret.dry_run && !ret.chocolatey && !ret.prefab)
        {
            System::print2(System::Color::error,
                           "Must provide at least one export type: --raw --nuget --ifw --zip --7zip --chocolatey --prefab\n");
            System::print2(COMMAND_STRUCTURE.example_text);
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        struct OptionPair
        {
            const StringLiteral& name;
            Optional<std::string>& out_opt;
        };
        const auto options_implies = [&](const StringLiteral& main_opt_name,
                                         bool is_main_opt,
                                         const std::initializer_list<OptionPair>& implying_opts) {
            if (is_main_opt)
            {
                for (auto&& opt : implying_opts)
                    opt.out_opt = maybe_lookup(options.settings, opt.name);
            }
            else
            {
                for (auto&& opt : implying_opts)
                    Checks::check_exit(VCPKG_LINE_INFO,
                                       !maybe_lookup(options.settings, opt.name),
                                       "%s is only valid with %s",
                                       opt.name,
                                       main_opt_name);
            }
        };

#if defined(_MSC_VER) && _MSC_VER <= 1900
// there's a bug in VS 2015 that causes a bunch of "unreferenced local variable" warnings
#pragma warning(push)
#pragma warning(disable : 4189)
#endif

        options_implies(OPTION_NUGET,
                        ret.nuget,
                        {
                            {OPTION_NUGET_ID, ret.maybe_nuget_id},
                            {OPTION_NUGET_VERSION, ret.maybe_nuget_version},
                        });

        options_implies(OPTION_IFW,
                        ret.ifw,
                        {
                            {OPTION_IFW_REPOSITORY_URL, ret.ifw_options.maybe_repository_url},
                            {OPTION_IFW_PACKAGES_DIR_PATH, ret.ifw_options.maybe_packages_dir_path},
                            {OPTION_IFW_REPOSITORY_DIR_PATH, ret.ifw_options.maybe_repository_dir_path},
                            {OPTION_IFW_CONFIG_FILE_PATH, ret.ifw_options.maybe_config_file_path},
                            {OPTION_IFW_INSTALLER_FILE_PATH, ret.ifw_options.maybe_installer_file_path},
                        });
        
        options_implies(OPTION_PREFAB,
                        ret.prefab,
                        {
                            {OPTION_PREFAB_ARTIFACT_ID, ret.prefab_options.maybe_artifact_id},
                            {OPTION_PREFAB_GROUP_ID, ret.prefab_options.maybe_group_id},
                            {OPTION_PREFAB_SDK_MIN_VERSION, ret.prefab_options.maybe_min_sdk},
                            {OPTION_PREFAB_SDK_TARGET_VERSION, ret.prefab_options.maybe_target_sdk},
                            {OPTION_PREFAB_VERSION, ret.prefab_options.maybe_version},
                        });

        options_implies(OPTION_CHOCOLATEY,
                        ret.chocolatey,
                        {
                            {OPTION_CHOCOLATEY_MAINTAINER, ret.chocolatey_options.maybe_maintainer},
                            {OPTION_CHOCOLATEY_VERSION_SUFFIX, ret.chocolatey_options.maybe_version_suffix},
                        });

#if defined(_MSC_VER) && _MSC_VER <= 1900
#pragma warning(pop)
#endif
        return ret;
    }

    static void print_next_step_info(const fs::path& prefix)
    {
        const fs::path cmake_toolchain = prefix / "scripts" / "buildsystems" / "vcpkg.cmake";
        const System::CMakeVariable cmake_variable =
            System::CMakeVariable("CMAKE_TOOLCHAIN_FILE", cmake_toolchain.generic_string());
        System::print2("\n"
                       "To use the exported libraries in CMake projects use:"
                       "\n"
                       "    ",
                       cmake_variable.s,
                       "\n\n");
    }

    static void handle_raw_based_export(Span<const ExportPlanAction> export_plan,
                                        const ExportArguments& opts,
                                        const std::string& export_id,
                                        const VcpkgPaths& paths)
    {
        Files::Filesystem& fs = paths.get_filesystem();
        const fs::path export_to_path = paths.root;
        const fs::path raw_exported_dir_path = export_to_path / export_id;
        fs.remove_all(raw_exported_dir_path, VCPKG_LINE_INFO);

        // TODO: error handling
        std::error_code ec;
        fs.create_directory(raw_exported_dir_path, ec);

        // execute the plan
        for (const ExportPlanAction& action : export_plan)
        {
            if (action.plan_type != ExportPlanType::ALREADY_BUILT)
            {
                Checks::unreachable(VCPKG_LINE_INFO);
            }

            const std::string display_name = action.spec.to_string();
            System::print2("Exporting package ", display_name, "...\n");

            const BinaryParagraph& binary_paragraph = action.core_paragraph().value_or_exit(VCPKG_LINE_INFO);

            const InstallDir dirs = InstallDir::from_destination_root(
                raw_exported_dir_path / "installed",
                action.spec.triplet().to_string(),
                raw_exported_dir_path / "installed" / "vcpkg" / "info" / (binary_paragraph.fullstem() + ".list"));

            Install::install_files_and_write_listfile(paths.get_filesystem(), paths.package_dir(action.spec), dirs);
        }

        // Copy files needed for integration
        export_integration_files(raw_exported_dir_path, paths);

        if (opts.raw)
        {
            System::printf(System::Color::success,
                           R"(Files exported at: "%s")"
                           "\n",
                           raw_exported_dir_path.u8string());
            print_next_step_info(raw_exported_dir_path);
        }

        if (opts.nuget)
        {
            System::print2("Packing nuget package...\n");

            const std::string nuget_id = opts.maybe_nuget_id.value_or(raw_exported_dir_path.filename().string());
            const std::string nuget_version = opts.maybe_nuget_version.value_or("1.0.0");
            const fs::path output_path =
                do_nuget_export(paths, nuget_id, nuget_version, raw_exported_dir_path, export_to_path);
            System::print2(System::Color::success, "NuGet package exported at: ", output_path.u8string(), "\n");

            System::printf(R"(
With a project open, go to Tools->NuGet Package Manager->Package Manager Console and paste:
    Install-Package %s -Source "%s"
)"
                           "\n\n",
                           nuget_id,
                           output_path.parent_path().u8string());
        }

        if (opts.zip)
        {
            System::print2("Creating zip archive...\n");
            const fs::path output_path =
                do_archive_export(paths, raw_exported_dir_path, export_to_path, ArchiveFormatC::ZIP);
            System::print2(System::Color::success, "Zip archive exported at: ", output_path.u8string(), "\n");
            print_next_step_info("[...]");
        }

        if (opts.seven_zip)
        {
            System::print2("Creating 7zip archive...\n");
            const fs::path output_path =
                do_archive_export(paths, raw_exported_dir_path, export_to_path, ArchiveFormatC::SEVEN_ZIP);
            System::print2(System::Color::success, "7zip archive exported at: ", output_path.u8string(), "\n");
            print_next_step_info("[...]");
        }

        if (!opts.raw)
        {
            fs.remove_all(raw_exported_dir_path, VCPKG_LINE_INFO);
        }
    }

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, Triplet default_triplet)
    {
        const StatusParagraphs status_db = database_load_check(paths);
        const auto opts = handle_export_command_arguments(args, default_triplet, status_db);
        for (auto&& spec : opts.specs)
            Input::check_triplet(spec.triplet(), paths);

        // Load ports from ports dirs
        PortFileProvider::PathsPortFileProvider provider(paths, args.overlay_ports.get());

        // create the plan
        std::vector<ExportPlanAction> export_plan = Dependencies::create_export_plan(opts.specs, status_db);
        Checks::check_exit(VCPKG_LINE_INFO, !export_plan.empty(), "Export plan cannot be empty");

        std::map<ExportPlanType, std::vector<const ExportPlanAction*>> group_by_plan_type;
        Util::group_by(export_plan, &group_by_plan_type, [](const ExportPlanAction& p) { return p.plan_type; });
        print_plan(group_by_plan_type);

        const bool has_non_user_requested_packages =
            Util::find_if(export_plan, [](const ExportPlanAction& package) -> bool {
                return package.request_type != RequestType::USER_REQUESTED;
            }) != export_plan.cend();

        if (has_non_user_requested_packages)
        {
            System::print2(System::Color::warning,
                           "Additional packages (*) need to be exported to complete this operation.\n");
        }

        const auto it = group_by_plan_type.find(ExportPlanType::NOT_BUILT);
        if (it != group_by_plan_type.cend() && !it->second.empty())
        {
            System::print2(System::Color::error, "There are packages that have not been built.\n");

            // No need to show all of them, just the user-requested ones. Dependency resolution will handle the rest.
            std::vector<const ExportPlanAction*> unbuilt = it->second;
            Util::erase_remove_if(
                unbuilt, [](const ExportPlanAction* a) { return a->request_type != RequestType::USER_REQUESTED; });

            const auto s = Strings::join(" ", unbuilt, [](const ExportPlanAction* a) { return a->spec.to_string(); });
            System::print2("To build them, run:\n"
                           "    vcpkg install ",
                           s,
                           "\n");
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        if (opts.dry_run)
        {
            Checks::exit_success(VCPKG_LINE_INFO);
        }

        std::string export_id = opts.maybe_output.value_or(create_export_id());

        if (opts.raw || opts.nuget || opts.zip || opts.seven_zip)
        {
            handle_raw_based_export(export_plan, opts, export_id, paths);
        }

        if (opts.ifw)
        {
            IFW::do_export(export_plan, export_id, opts.ifw_options, paths);

            print_next_step_info("@RootDir@/src/vcpkg");
        }

        if (opts.chocolatey)
        {
            Chocolatey::do_export(export_plan, paths, opts.chocolatey_options);
        }

        if(opts.prefab){
            Prefab::do_export(export_plan, paths, opts.prefab_options, default_triplet);
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
