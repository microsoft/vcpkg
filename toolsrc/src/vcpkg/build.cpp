#include "pch.h"

#include <vcpkg/base/checks.h>
#include <vcpkg/base/chrono.h>
#include <vcpkg/base/enums.h>
#include <vcpkg/base/optional.h>
#include <vcpkg/base/system.h>
#include <vcpkg/build.h>
#include <vcpkg/commands.h>
#include <vcpkg/dependencies.h>
#include <vcpkg/globalstate.h>
#include <vcpkg/help.h>
#include <vcpkg/input.h>
#include <vcpkg/metrics.h>
#include <vcpkg/paragraphs.h>
#include <vcpkg/postbuildlint.h>
#include <vcpkg/statusparagraphs.h>
#include <vcpkg/vcpkglib.h>

using vcpkg::Build::BuildResult;
using vcpkg::Parse::ParseControlErrorInfo;
using vcpkg::Parse::ParseExpected;

namespace vcpkg::Build::Command
{
    using Dependencies::InstallPlanAction;
    using Dependencies::InstallPlanType;

    static const std::string OPTION_CHECKS_ONLY = "--checks-only";

    void perform_and_exit_ex(const FullPackageSpec& full_spec,
                             const fs::path& port_dir,
                             const ParsedArguments& options,
                             const VcpkgPaths& paths)
    {
        const PackageSpec& spec = full_spec.package_spec;
        if (Util::Sets::contains(options.switches, OPTION_CHECKS_ONLY))
        {
            const auto pre_build_info = Build::PreBuildInfo::from_triplet_file(paths, spec.triplet());
            const auto build_info = Build::read_build_info(paths.get_filesystem(), paths.build_info_file_path(spec));
            const size_t error_count = PostBuildLint::perform_all_checks(spec, paths, pre_build_info, build_info);
            Checks::check_exit(VCPKG_LINE_INFO, error_count == 0);
            Checks::exit_success(VCPKG_LINE_INFO);
        }

        const ParseExpected<SourceControlFile> source_control_file =
            Paragraphs::try_load_port(paths.get_filesystem(), port_dir);

        if (!source_control_file.has_value())
        {
            print_error_message(source_control_file.error());
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        const auto& scf = source_control_file.value_or_exit(VCPKG_LINE_INFO);
        Checks::check_exit(VCPKG_LINE_INFO,
                           spec.name() == scf->core_paragraph->name,
                           "The Source field inside the CONTROL file does not match the port directory: '%s' != '%s'",
                           scf->core_paragraph->name,
                           spec.name());

        const StatusParagraphs status_db = database_load_check(paths);
        const Build::BuildPackageOptions build_package_options{Build::UseHeadVersion::NO, Build::AllowDownloads::YES};

        const std::unordered_set<std::string> features_as_set(full_spec.features.begin(), full_spec.features.end());

        const Build::BuildPackageConfig build_config{
            *scf, spec.triplet(), fs::path{port_dir}, build_package_options, features_as_set};

        const auto build_timer = Chrono::ElapsedTime::create_started();
        const auto result = Build::build_package(paths, build_config, status_db);
        System::println("Elapsed time for package %s: %s", spec.to_string(), build_timer.to_string());

        if (result.code == BuildResult::CASCADED_DUE_TO_MISSING_DEPENDENCIES)
        {
            System::println(System::Color::error,
                            "The build command requires all dependencies to be already installed.");
            System::println("The following dependencies are missing:");
            System::println();
            for (const auto& p : result.unmet_dependencies)
            {
                System::println("    %s", p);
            }
            System::println();
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        Checks::check_exit(VCPKG_LINE_INFO, result.code != BuildResult::EXCLUDED);

        if (result.code != BuildResult::SUCCEEDED)
        {
            System::println(System::Color::error, Build::create_error_message(result.code, spec));
            System::println(Build::create_user_troubleshooting_message(spec));
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }

    static const std::array<CommandSwitch, 1> BUILD_SWITCHES = {{
        {OPTION_CHECKS_ONLY, "Only run checks, do not rebuild package"},
    }};

    const CommandStructure COMMAND_STRUCTURE = {
        Help::create_example_string("build zlib:x64-windows"),
        1,
        1,
        {BUILD_SWITCHES, {}},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet)
    {
        // Build only takes a single package and all dependencies must already be installed
        const ParsedArguments options = args.parse_arguments(COMMAND_STRUCTURE);
        const std::string command_argument = args.command_arguments.at(0);
        const FullPackageSpec spec =
            Input::check_and_get_full_package_spec(command_argument, default_triplet, COMMAND_STRUCTURE.example_text);
        Input::check_triplet(spec.package_spec.triplet(), paths);
        if (!spec.features.empty() && !GlobalState::feature_packages)
        {
            Checks::exit_with_message(
                VCPKG_LINE_INFO, "Feature packages are experimentally available under the --featurepackages flag.");
        }
        perform_and_exit_ex(spec, paths.port_dir(spec.package_spec), options, paths);
    }
}

namespace vcpkg::Build
{
    static const std::string NAME_EMPTY_PACKAGE = "PolicyEmptyPackage";
    static const std::string NAME_DLLS_WITHOUT_LIBS = "PolicyDLLsWithoutLIBs";
    static const std::string NAME_ONLY_RELEASE_CRT = "PolicyOnlyReleaseCRT";
    static const std::string NAME_EMPTY_INCLUDE_FOLDER = "PolicyEmptyIncludeFolder";
    static const std::string NAME_ALLOW_OBSOLETE_MSVCRT = "PolicyAllowObsoleteMsvcrt";

    const std::string& to_string(BuildPolicy policy)
    {
        switch (policy)
        {
            case BuildPolicy::EMPTY_PACKAGE: return NAME_EMPTY_PACKAGE;
            case BuildPolicy::DLLS_WITHOUT_LIBS: return NAME_DLLS_WITHOUT_LIBS;
            case BuildPolicy::ONLY_RELEASE_CRT: return NAME_ONLY_RELEASE_CRT;
            case BuildPolicy::EMPTY_INCLUDE_FOLDER: return NAME_EMPTY_INCLUDE_FOLDER;
            case BuildPolicy::ALLOW_OBSOLETE_MSVCRT: return NAME_ALLOW_OBSOLETE_MSVCRT;
            default: Checks::unreachable(VCPKG_LINE_INFO);
        }
    }

    CStringView to_cmake_variable(BuildPolicy policy)
    {
        switch (policy)
        {
            case BuildPolicy::EMPTY_PACKAGE: return "VCPKG_POLICY_EMPTY_PACKAGE";
            case BuildPolicy::DLLS_WITHOUT_LIBS: return "VCPKG_POLICY_DLLS_WITHOUT_LIBS";
            case BuildPolicy::ONLY_RELEASE_CRT: return "VCPKG_POLICY_ONLY_RELEASE_CRT";
            case BuildPolicy::EMPTY_INCLUDE_FOLDER: return "VCPKG_POLICY_EMPTY_INCLUDE_FOLDER";
            case BuildPolicy::ALLOW_OBSOLETE_MSVCRT: return "VCPKG_POLICY_ALLOW_OBSOLETE_MSVCRT";
            default: Checks::unreachable(VCPKG_LINE_INFO);
        }
    }

    Optional<LinkageType> to_linkage_type(const std::string& str)
    {
        if (str == "dynamic") return LinkageType::DYNAMIC;
        if (str == "static") return LinkageType::STATIC;
        return nullopt;
    }

    namespace BuildInfoRequiredField
    {
        static const std::string CRT_LINKAGE = "CRTLinkage";
        static const std::string LIBRARY_LINKAGE = "LibraryLinkage";
    }

    CStringView to_vcvarsall_target(const std::string& cmake_system_name)
    {
        if (cmake_system_name.empty()) return "";
        if (cmake_system_name == "Windows") return "";
        if (cmake_system_name == "WindowsStore") return "store";

        Checks::exit_with_message(VCPKG_LINE_INFO, "Unsupported vcvarsall target %s", cmake_system_name);
    }

    CStringView to_vcvarsall_toolchain(const std::string& target_architecture, const Toolset& toolset)
    {
        auto maybe_target_arch = System::to_cpu_architecture(target_architecture);
        Checks::check_exit(
            VCPKG_LINE_INFO, maybe_target_arch.has_value(), "Invalid architecture string: %s", target_architecture);
        auto target_arch = maybe_target_arch.value_or_exit(VCPKG_LINE_INFO);
        auto host_architectures = System::get_supported_host_architectures();

        for (auto&& host : host_architectures)
        {
            auto it = Util::find_if(toolset.supported_architectures, [&](const ToolsetArchOption& opt) {
                return host == opt.host_arch && target_arch == opt.target_arch;
            });
            if (it != toolset.supported_architectures.end()) return it->name;
        }

        Checks::exit_with_message(VCPKG_LINE_INFO, "Unsupported toolchain combination %s", target_architecture);
    }

    std::string make_build_env_cmd(const PreBuildInfo& pre_build_info, const Toolset& toolset)
    {
        if (pre_build_info.external_toolchain_file)
            return Strings::format(
                R"("%s" %s 2>&1)", toolset.vcvarsall.u8string(), Strings::join(" ", toolset.vcvarsall_options));

        const char* tonull = " >nul";
        if (GlobalState::debugging)
        {
            tonull = "";
        }

        const auto arch = to_vcvarsall_toolchain(pre_build_info.target_architecture, toolset);
        const auto target = to_vcvarsall_target(pre_build_info.cmake_system_name);

        return Strings::format(R"("%s" %s %s %s %s 2>&1)",
                               toolset.vcvarsall.u8string(),
                               Strings::join(" ", toolset.vcvarsall_options),
                               arch,
                               target,
                               tonull);
    }

    static BinaryParagraph create_binary_feature_control_file(const SourceParagraph& source_paragraph,
                                                              const FeatureParagraph& feature_paragraph,
                                                              const Triplet& triplet)
    {
        return BinaryParagraph(source_paragraph, feature_paragraph, triplet);
    }

    static std::unique_ptr<BinaryControlFile> create_binary_control_file(const SourceParagraph& source_paragraph,
                                                                         const Triplet& triplet,
                                                                         const BuildInfo& build_info)
    {
        auto bcf = std::make_unique<BinaryControlFile>();
        BinaryParagraph bpgh(source_paragraph, triplet);
        if (const auto p_ver = build_info.version.get())
        {
            bpgh.version = *p_ver;
        }
        bcf->core_paragraph = std::move(bpgh);
        return bcf;
    }

    static void write_binary_control_file(const VcpkgPaths& paths, BinaryControlFile bcf)
    {
        std::string start = Strings::serialize(bcf.core_paragraph);
        for (auto&& feature : bcf.features)
        {
            start += "\n" + Strings::serialize(feature);
        }
        const fs::path binary_control_file = paths.packages / bcf.core_paragraph.dir() / "CONTROL";
        paths.get_filesystem().write_contents(binary_control_file, start);
    }

    ExtendedBuildResult build_package(const VcpkgPaths& paths,
                                      const BuildPackageConfig& config,
                                      const StatusParagraphs& status_db)
    {
        const PackageSpec spec =
            PackageSpec::from_name_and_triplet(config.src.name, config.triplet).value_or_exit(VCPKG_LINE_INFO);

        const Triplet& triplet = config.triplet;
        {
            std::vector<PackageSpec> missing_specs;
            for (auto&& dep : filter_dependencies(config.src.depends, triplet))
            {
                if (status_db.find_installed(dep, triplet) == status_db.end())
                {
                    missing_specs.push_back(
                        PackageSpec::from_name_and_triplet(dep, triplet).value_or_exit(VCPKG_LINE_INFO));
                }
            }
            // Fail the build if any dependencies were missing
            if (!missing_specs.empty())
            {
                return {BuildResult::CASCADED_DUE_TO_MISSING_DEPENDENCIES, std::move(missing_specs)};
            }
        }

        const fs::path& cmake_exe_path = paths.get_cmake_exe();
        const fs::path& git_exe_path = paths.get_git_exe();

        const fs::path ports_cmake_script_path = paths.ports_cmake;
        const auto pre_build_info = PreBuildInfo::from_triplet_file(paths, triplet);

        std::string features;
        if (GlobalState::feature_packages)
        {
            if (config.feature_list)
            {
                for (auto&& feature : *config.feature_list)
                {
                    features.append(feature + ";");
                }
                if (features.size() > 0)
                {
                    features.pop_back();
                }
            }
        }

        const Toolset& toolset = paths.get_toolset(pre_build_info);
        const std::string cmd_launch_cmake = System::make_cmake_cmd(
            cmake_exe_path,
            ports_cmake_script_path,
            {
                {"CMD", "BUILD"},
                {"PORT", config.src.name},
                {"CURRENT_PORT_DIR", config.port_dir / "/."},
                {"TARGET_TRIPLET", triplet.canonical_name()},
                {"VCPKG_PLATFORM_TOOLSET", toolset.version.c_str()},
                {"VCPKG_USE_HEAD_VERSION",
                 Util::Enum::to_bool(config.build_package_options.use_head_version) ? "1" : "0"},
                {"_VCPKG_NO_DOWNLOADS", !Util::Enum::to_bool(config.build_package_options.allow_downloads) ? "1" : "0"},
                {"GIT", git_exe_path},
                {"FEATURES", features},
            });

        const auto cmd_set_environment = make_build_env_cmd(pre_build_info, toolset);
        const std::string command = Strings::format(R"(%s && %s)", cmd_set_environment, cmd_launch_cmake);

        const auto timer = Chrono::ElapsedTime::create_started();

        const int return_code = System::cmd_execute_clean(command);
        const auto buildtimeus = timer.microseconds();
        const auto spec_string = spec.to_string();

        {
            auto locked_metrics = Metrics::g_metrics.lock();
            locked_metrics->track_metric("buildtimeus-" + spec_string, buildtimeus);
            if (return_code != 0)
            {
                locked_metrics->track_property("error", "build failed");
                locked_metrics->track_property("build_error", spec_string);
                return BuildResult::BUILD_FAILED;
            }
        }

        const BuildInfo build_info = read_build_info(paths.get_filesystem(), paths.build_info_file_path(spec));
        const size_t error_count = PostBuildLint::perform_all_checks(spec, paths, pre_build_info, build_info);

        auto bcf = create_binary_control_file(config.src, triplet, build_info);

        if (error_count != 0)
        {
            return BuildResult::POST_BUILD_CHECKS_FAILED;
        }
        if (GlobalState::feature_packages)
        {
            if (config.feature_list)
            {
                for (auto&& feature : *config.feature_list)
                {
                    for (auto&& f_pgh : config.scf->feature_paragraphs)
                    {
                        if (f_pgh->name == feature)
                            bcf->features.push_back(
                                create_binary_feature_control_file(*config.scf->core_paragraph, *f_pgh, triplet));
                    }
                }
            }
        }

        write_binary_control_file(paths, *bcf);

        if (config.build_package_options.clean_buildtrees == CleanBuildtrees::YES)
        {
            auto& fs = paths.get_filesystem();
            auto buildtrees_dir = paths.buildtrees / spec.name();
            auto buildtree_files = fs.get_files_non_recursive(buildtrees_dir);
            for (auto&& file : buildtree_files)
            {
                if (fs.is_directory(file) && file.filename() != "src")
                {
                    std::error_code ec;
                    fs.remove_all(file, ec);
                }
            }
        }

        return {BuildResult::SUCCEEDED, std::move(bcf)};
    }

    const std::string& to_string(const BuildResult build_result)
    {
        static const std::string NULLVALUE_STRING = Enums::nullvalue_to_string("vcpkg::Commands::Build::BuildResult");
        static const std::string SUCCEEDED_STRING = "SUCCEEDED";
        static const std::string BUILD_FAILED_STRING = "BUILD_FAILED";
        static const std::string FILE_CONFLICTS_STRING = "FILE_CONFLICTS";
        static const std::string POST_BUILD_CHECKS_FAILED_STRING = "POST_BUILD_CHECKS_FAILED";
        static const std::string CASCADED_DUE_TO_MISSING_DEPENDENCIES_STRING = "CASCADED_DUE_TO_MISSING_DEPENDENCIES";
        static const std::string EXCLUDED_STRING = "EXCLUDED";

        switch (build_result)
        {
            case BuildResult::NULLVALUE: return NULLVALUE_STRING;
            case BuildResult::SUCCEEDED: return SUCCEEDED_STRING;
            case BuildResult::BUILD_FAILED: return BUILD_FAILED_STRING;
            case BuildResult::POST_BUILD_CHECKS_FAILED: return POST_BUILD_CHECKS_FAILED_STRING;
            case BuildResult::FILE_CONFLICTS: return FILE_CONFLICTS_STRING;
            case BuildResult::CASCADED_DUE_TO_MISSING_DEPENDENCIES: return CASCADED_DUE_TO_MISSING_DEPENDENCIES_STRING;
            case BuildResult::EXCLUDED: return EXCLUDED_STRING;
            default: Checks::unreachable(VCPKG_LINE_INFO);
        }
    }

    std::string create_error_message(const BuildResult build_result, const PackageSpec& spec)
    {
        return Strings::format("Error: Building package %s failed with: %s", spec, Build::to_string(build_result));
    }

    std::string create_user_troubleshooting_message(const PackageSpec& spec)
    {
        return Strings::format("Please ensure you're using the latest portfiles with `.\\vcpkg update`, then\n"
                               "submit an issue at https://github.com/Microsoft/vcpkg/issues including:\n"
                               "  Package: %s\n"
                               "  Vcpkg version: %s\n"
                               "\n"
                               "Additionally, attach any relevant sections from the log files above.",
                               spec,
                               Commands::Version::version());
    }

    static BuildInfo inner_create_buildinfo(std::unordered_map<std::string, std::string> pgh)
    {
        Parse::ParagraphParser parser(std::move(pgh));

        BuildInfo build_info;

        {
            std::string crt_linkage_as_string;
            parser.required_field(BuildInfoRequiredField::CRT_LINKAGE, crt_linkage_as_string);

            auto crtlinkage = to_linkage_type(crt_linkage_as_string);
            if (const auto p = crtlinkage.get())
                build_info.crt_linkage = *p;
            else
                Checks::exit_with_message(VCPKG_LINE_INFO, "Invalid crt linkage type: [%s]", crt_linkage_as_string);
        }

        {
            std::string library_linkage_as_string;
            parser.required_field(BuildInfoRequiredField::LIBRARY_LINKAGE, library_linkage_as_string);
            auto liblinkage = to_linkage_type(library_linkage_as_string);
            if (const auto p = liblinkage.get())
                build_info.library_linkage = *p;
            else
                Checks::exit_with_message(
                    VCPKG_LINE_INFO, "Invalid library linkage type: [%s]", library_linkage_as_string);
        }
        std::string version = parser.optional_field("Version");
        if (!version.empty()) build_info.version = std::move(version);

        std::map<BuildPolicy, bool> policies;
        for (auto policy : G_ALL_POLICIES)
        {
            const auto setting = parser.optional_field(to_string(policy));
            if (setting.empty()) continue;
            if (setting == "enabled")
                policies.emplace(policy, true);
            else if (setting == "disabled")
                policies.emplace(policy, false);
            else
                Checks::exit_with_message(
                    VCPKG_LINE_INFO, "Unknown setting for policy '%s': %s", to_string(policy), setting);
        }

        if (const auto err = parser.error_info("PostBuildInformation"))
        {
            print_error_message(err);
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        build_info.policies = BuildPolicies(std::move(policies));

        return build_info;
    }

    BuildInfo read_build_info(const Files::Filesystem& fs, const fs::path& filepath)
    {
        const Expected<std::unordered_map<std::string, std::string>> pghs =
            Paragraphs::get_single_paragraph(fs, filepath);
        Checks::check_exit(VCPKG_LINE_INFO, pghs.get() != nullptr, "Invalid BUILD_INFO file for package");
        return inner_create_buildinfo(*pghs.get());
    }

    PreBuildInfo PreBuildInfo::from_triplet_file(const VcpkgPaths& paths, const Triplet& triplet)
    {
        static constexpr CStringView FLAG_GUID = "c35112b6-d1ba-415b-aa5d-81de856ef8eb";

        const fs::path& cmake_exe_path = paths.get_cmake_exe();
        const fs::path ports_cmake_script_path = paths.scripts / "get_triplet_environment.cmake";
        const fs::path triplet_file_path = paths.triplets / (triplet.canonical_name() + ".cmake");

        const auto cmd_launch_cmake = System::make_cmake_cmd(cmake_exe_path,
                                                             ports_cmake_script_path,
                                                             {
                                                                 {"CMAKE_TRIPLET_FILE", triplet_file_path},
                                                             });
        const auto ec_data = System::cmd_execute_and_capture_output(cmd_launch_cmake);
        Checks::check_exit(VCPKG_LINE_INFO, ec_data.exit_code == 0, ec_data.output);

        const std::vector<std::string> lines = Strings::split(ec_data.output, "\n");

        PreBuildInfo pre_build_info;

        const auto e = lines.cend();
        auto cur = std::find(lines.cbegin(), e, FLAG_GUID);
        if (cur != e) ++cur;

        for (; cur != e; ++cur)
        {
            auto&& line = *cur;

            const std::vector<std::string> s = Strings::split(line, "=");
            Checks::check_exit(VCPKG_LINE_INFO,
                               s.size() == 1 || s.size() == 2,
                               "Expected format is [VARIABLE_NAME=VARIABLE_VALUE], but was [%s]",
                               line);

            const bool variable_with_no_value = s.size() == 1;
            const std::string variable_name = s.at(0);
            const std::string variable_value = variable_with_no_value ? "" : s.at(1);

            if (variable_name == "VCPKG_TARGET_ARCHITECTURE")
            {
                pre_build_info.target_architecture = variable_value;
                continue;
            }

            if (variable_name == "VCPKG_CMAKE_SYSTEM_NAME")
            {
                pre_build_info.cmake_system_name = variable_value;
                continue;
            }

            if (variable_name == "VCPKG_CMAKE_SYSTEM_VERSION")
            {
                pre_build_info.cmake_system_version = variable_value;
                continue;
            }

            if (variable_name == "VCPKG_PLATFORM_TOOLSET")
            {
                pre_build_info.platform_toolset =
                    variable_value.empty() ? nullopt : Optional<std::string>{variable_value};
                continue;
            }

            if (variable_name == "VCPKG_VISUAL_STUDIO_PATH")
            {
                pre_build_info.visual_studio_path =
                    variable_value.empty() ? nullopt : Optional<fs::path>{variable_value};
                continue;
            }

            if (variable_name == "VCPKG_CHAINLOAD_TOOLCHAIN_FILE")
            {
                pre_build_info.external_toolchain_file =
                    variable_value.empty() ? nullopt : Optional<std::string>{variable_value};
                continue;
            }

            if (variable_name == "VCPKG_BUILD_TYPE")
            {
                if (variable_value.empty())
                    pre_build_info.build_type = nullopt;
                else if (Strings::case_insensitive_ascii_equals(variable_value, "debug"))
                    pre_build_info.build_type = ConfigurationType::DEBUG;
                else if (Strings::case_insensitive_ascii_equals(variable_value, "release"))
                    pre_build_info.build_type = ConfigurationType::RELEASE;
                else
                    Checks::exit_with_message(
                        VCPKG_LINE_INFO, "Unknown setting for VCPKG_BUILD_TYPE: %s", variable_value);
                continue;
            }

            Checks::exit_with_message(VCPKG_LINE_INFO, "Unknown variable name %s", line);
        }

        return pre_build_info;
    }
    ExtendedBuildResult::ExtendedBuildResult(BuildResult code) : code(code) {}
    ExtendedBuildResult::ExtendedBuildResult(BuildResult code, std::unique_ptr<BinaryControlFile>&& bcf)
        : code(code), binary_control_file(std::move(bcf))
    {
    }
    ExtendedBuildResult::ExtendedBuildResult(BuildResult code, std::vector<PackageSpec>&& unmet_deps)
        : code(code), unmet_dependencies(std::move(unmet_deps))
    {
    }
}
