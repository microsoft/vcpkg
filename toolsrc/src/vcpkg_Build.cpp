#include "pch.h"

#include "Paragraphs.h"
#include "PostBuildLint.h"
#include "metrics.h"
#include "vcpkg_Build.h"
#include "vcpkg_Checks.h"
#include "vcpkg_Chrono.h"
#include "vcpkg_Commands.h"
#include "vcpkg_Enums.h"
#include "vcpkg_GlobalState.h"
#include "vcpkg_System.h"
#include "vcpkg_optional.h"
#include "vcpkglib.h"

namespace vcpkg::Build
{
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

    CWStringView to_vcvarsall_target(const std::string& cmake_system_name)
    {
        if (cmake_system_name == "") return L"";
        if (cmake_system_name == "Windows") return L"";
        if (cmake_system_name == "WindowsStore") return L"store";

        Checks::exit_with_message(VCPKG_LINE_INFO, "Unsupported vcvarsall target %s", cmake_system_name);
    }

    CWStringView to_vcvarsall_toolchain(const std::string& target_architecture)
    {
        using CPU = System::CPUArchitecture;

        struct ArchOption
        {
            CWStringView name;
            CPU host_arch;
            CPU target_arch;
        };

        static constexpr ArchOption X86 = {L"x86", CPU::X86, CPU::X86};
        static constexpr ArchOption X86_X64 = {L"x86_x64", CPU::X86, CPU::X64};
        static constexpr ArchOption X86_ARM = {L"x86_arm", CPU::X86, CPU::ARM};
        static constexpr ArchOption X86_ARM64 = {L"x86_arm64", CPU::X86, CPU::ARM64};

        static constexpr ArchOption X64 = {L"amd64", CPU::X64, CPU::X64};
        static constexpr ArchOption X64_X86 = {L"amd64_x86", CPU::X64, CPU::X86};
        static constexpr ArchOption X64_ARM = {L"amd64_arm", CPU::X64, CPU::ARM};
        static constexpr ArchOption X64_ARM64 = {L"amd64_arm64", CPU::X64, CPU::ARM64};

        static constexpr std::array<ArchOption, 8> VALUES = {
            X86, X86_X64, X86_ARM, X86_ARM64, X64, X64_X86, X64_ARM, X64_ARM64};

        auto target_arch = System::to_cpu_architecture(target_architecture);
        auto host_arch = System::get_host_processor();

        for (auto&& value : VALUES)
        {
            if (target_arch == value.target_arch && host_arch == value.host_arch)
            {
                return value.name;
            }
        }

        Checks::exit_with_message(VCPKG_LINE_INFO, "Unsupported toolchain combination %s", target_architecture);
    }

    std::wstring make_build_env_cmd(const PreBuildInfo& pre_build_info, const Toolset& toolset)
    {
        const wchar_t* tonull = L" >nul";
        if (GlobalState::debugging)
        {
            tonull = L"";
        }

        auto arch = to_vcvarsall_toolchain(pre_build_info.target_architecture);
        auto target = to_vcvarsall_target(pre_build_info.cmake_system_name);

        return Strings::wformat(LR"("%s" %s %s %s 2>&1)", toolset.vcvarsall.native(), arch, target, tonull);
    }

    static void create_binary_feature_control_file(const SourceParagraph& source_paragraph,
                                                   const FeatureParagraph& feature_paragraph,
                                                   const Triplet& triplet,
                                                   BinaryControlFile& bcf)
    {
        BinaryParagraph bpgh(source_paragraph, feature_paragraph, triplet);
        bcf.features.emplace_back(std::move(bpgh));
    }

    static void create_binary_control_file(const SourceParagraph& source_paragraph,
                                           const Triplet& triplet,
                                           const BuildInfo& build_info,
                                           BinaryControlFile& bcf)
    {
        BinaryParagraph bpgh(source_paragraph, triplet);
        if (auto p_ver = build_info.version.get())
        {
            bpgh.version = *p_ver;
        }
        bcf.core_paragraph = std::move(bpgh);
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
        auto pre_build_info = PreBuildInfo::from_triplet_file(paths, triplet);
        const Toolset& toolset = paths.get_toolset(pre_build_info.platform_toolset);
        const auto cmd_set_environment = make_build_env_cmd(pre_build_info, toolset);

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

        const std::wstring cmd_launch_cmake = make_cmake_cmd(
            cmake_exe_path,
            ports_cmake_script_path,
            {
                {L"CMD", L"BUILD"},
                {L"PORT", config.src.name},
                {L"CURRENT_PORT_DIR", config.port_dir / "/."},
                {L"TARGET_TRIPLET", triplet.canonical_name()},
                {L"VCPKG_PLATFORM_TOOLSET", toolset.version},
                {L"VCPKG_USE_HEAD_VERSION", to_bool(config.build_package_options.use_head_version) ? L"1" : L"0"},
                {L"_VCPKG_NO_DOWNLOADS", !to_bool(config.build_package_options.allow_downloads) ? L"1" : L"0"},
                {L"GIT", git_exe_path},
                {L"FEATURES", features},
            });

        const std::wstring command = Strings::wformat(LR"(%s && %s)", cmd_set_environment, cmd_launch_cmake);

        const ElapsedTime timer = ElapsedTime::create_started();

        int return_code = System::cmd_execute_clean(command);
        auto buildtimeus = timer.microseconds();
        const auto spec_string = spec.to_string();
        Metrics::track_metric("buildtimeus-" + spec_string, buildtimeus);

        if (return_code != 0)
        {
            Metrics::track_property("error", "build failed");
            Metrics::track_property("build_error", spec_string);
            return {BuildResult::BUILD_FAILED, {}};
        }

        auto build_info = read_build_info(paths.get_filesystem(), paths.build_info_file_path(spec));
        const size_t error_count = PostBuildLint::perform_all_checks(spec, paths, pre_build_info, build_info);

        BinaryControlFile bcf;

        create_binary_control_file(config.src, triplet, build_info, bcf);

        if (error_count != 0)
        {
            return {BuildResult::POST_BUILD_CHECKS_FAILED, {}};
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
                            create_binary_feature_control_file(*config.scf->core_paragraph, *f_pgh, triplet, bcf);
                    }
                }
            }
        }

        write_binary_control_file(paths, bcf);

        // const fs::path port_buildtrees_dir = paths.buildtrees / spec.name;
        // delete_directory(port_buildtrees_dir);

        return {BuildResult::SUCCEEDED, {}};
    }

    const std::string& to_string(const BuildResult build_result)
    {
        static const std::string NULLVALUE_STRING = Enums::nullvalue_to_string("vcpkg::Commands::Build::BuildResult");
        static const std::string SUCCEEDED_STRING = "SUCCEEDED";
        static const std::string BUILD_FAILED_STRING = "BUILD_FAILED";
        static const std::string FILE_CONFLICTS_STRING = "FILE_CONFLICTS";
        static const std::string POST_BUILD_CHECKS_FAILED_STRING = "POST_BUILD_CHECKS_FAILED";
        static const std::string CASCADED_DUE_TO_MISSING_DEPENDENCIES_STRING = "CASCADED_DUE_TO_MISSING_DEPENDENCIES";

        switch (build_result)
        {
            case BuildResult::NULLVALUE: return NULLVALUE_STRING;
            case BuildResult::SUCCEEDED: return SUCCEEDED_STRING;
            case BuildResult::BUILD_FAILED: return BUILD_FAILED_STRING;
            case BuildResult::POST_BUILD_CHECKS_FAILED: return POST_BUILD_CHECKS_FAILED_STRING;
            case BuildResult::CASCADED_DUE_TO_MISSING_DEPENDENCIES: return CASCADED_DUE_TO_MISSING_DEPENDENCIES_STRING;
            case BuildResult::FILE_CONFLICTS: return FILE_CONFLICTS_STRING;
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
            if (auto p = crtlinkage.get())
                build_info.crt_linkage = *p;
            else
                Checks::exit_with_message(VCPKG_LINE_INFO, "Invalid crt linkage type: [%s]", crt_linkage_as_string);
        }

        {
            std::string library_linkage_as_string;
            parser.required_field(BuildInfoRequiredField::LIBRARY_LINKAGE, library_linkage_as_string);
            auto liblinkage = to_linkage_type(library_linkage_as_string);
            if (auto p = liblinkage.get())
                build_info.library_linkage = *p;
            else
                Checks::exit_with_message(
                    VCPKG_LINE_INFO, "Invalid library linkage type: [%s]", library_linkage_as_string);
        }
        std::string version = parser.optional_field("Version");
        if (!version.empty()) build_info.version = std::move(version);

        std::map<BuildPolicy, bool> policies;
        for (auto policy : g_all_policies)
        {
            const auto setting = parser.optional_field(to_string(policy));
            if (setting.empty())
                continue;
            else if (setting == "enabled")
                policies.emplace(policy, true);
            else if (setting == "disabled")
                policies.emplace(policy, false);
            else
                Checks::exit_with_message(
                    VCPKG_LINE_INFO, "Unknown setting for policy '%s': %s", to_string(policy), setting);
        }

        if (auto err = parser.error_info("PostBuildInformation"))
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

        const std::wstring cmd_launch_cmake = make_cmake_cmd(cmake_exe_path,
                                                             ports_cmake_script_path,
                                                             {
                                                                 {L"CMAKE_TRIPLET_FILE", triplet_file_path},
                                                             });

        const std::wstring command = Strings::wformat(LR"(%s)", cmd_launch_cmake);
        auto ec_data = System::cmd_execute_and_capture_output(command);
        Checks::check_exit(VCPKG_LINE_INFO, ec_data.exit_code == 0);

        const std::vector<std::string> lines = Strings::split(ec_data.output, "\n");

        PreBuildInfo pre_build_info;

        auto e = lines.cend();
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
                pre_build_info.platform_toolset = variable_value;
                continue;
            }

            Checks::exit_with_message(VCPKG_LINE_INFO, "Unknown variable name %s", line);
        }

        return pre_build_info;
    }
}
