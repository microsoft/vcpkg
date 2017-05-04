#include "pch.h"

#include "Paragraphs.h"
#include "PostBuildLint.h"
#include "metrics.h"
#include "vcpkg_Build.h"
#include "vcpkg_Checks.h"
#include "vcpkg_Chrono.h"
#include "vcpkg_Commands.h"
#include "vcpkg_Enums.h"
#include "vcpkg_System.h"
#include "vcpkg_optional.h"
#include "vcpkglib.h"
#include "vcpkglib_helpers.h"

using vcpkg::PostBuildLint::BuildPolicies;
namespace BuildPoliciesC = vcpkg::PostBuildLint::BuildPoliciesC;
using vcpkg::PostBuildLint::LinkageType;
namespace LinkageTypeC = vcpkg::PostBuildLint::LinkageTypeC;

namespace vcpkg::Build
{
    namespace BuildInfoRequiredField
    {
        static const std::string CRT_LINKAGE = "CRTLinkage";
        static const std::string LIBRARY_LINKAGE = "LibraryLinkage";
    }

    std::wstring make_build_env_cmd(const Triplet& triplet, const Toolset& toolset)
    {
        const wchar_t* tonull = L" >nul";
        if (g_debugging)
        {
            tonull = L"";
        }

        return Strings::wformat(
            LR"("%s" %s %s 2>&1)", toolset.vcvarsall.native(), Strings::to_utf16(triplet.architecture()), tonull);
    }

    static void create_binary_control_file(const VcpkgPaths& paths,
                                           const SourceParagraph& source_paragraph,
                                           const Triplet& triplet,
                                           const BuildInfo& build_info)
    {
        BinaryParagraph bpgh = BinaryParagraph(source_paragraph, triplet);
        if (auto p_ver = build_info.version.get())
        {
            bpgh.version = *p_ver;
        }
        const fs::path binary_control_file = paths.packages / bpgh.dir() / "CONTROL";
        paths.get_filesystem().write_contents(binary_control_file, Strings::serialize(bpgh));
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
        const Toolset& toolset = paths.get_toolset();
        const auto cmd_set_environment = make_build_env_cmd(triplet, toolset);

        const std::wstring cmd_launch_cmake =
            make_cmake_cmd(cmake_exe_path,
                           ports_cmake_script_path,
                           {{L"CMD", L"BUILD"},
                            {L"PORT", config.src.name},
                            {L"CURRENT_PORT_DIR", config.port_dir / "/."},
                            {L"TARGET_TRIPLET", triplet.canonical_name()},
                            {L"VCPKG_PLATFORM_TOOLSET", toolset.version},
                            {L"VCPKG_USE_HEAD_VERSION", config.use_head_version ? L"1" : L"0"},
                            {L"_VCPKG_NO_DOWNLOADS", config.no_downloads ? L"1" : L"0"},
                            {L"GIT", git_exe_path}});

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
        const size_t error_count = PostBuildLint::perform_all_checks(spec, paths, build_info);

        if (error_count != 0)
        {
            return {BuildResult::POST_BUILD_CHECKS_FAILED, {}};
        }

        create_binary_control_file(paths, config.src, triplet, build_info);

        // const fs::path port_buildtrees_dir = paths.buildtrees / spec.name;
        // delete_directory(port_buildtrees_dir);

        return {BuildResult::SUCCEEDED, {}};
    }

    const std::string& to_string(const BuildResult build_result)
    {
        static const std::string NULLVALUE_STRING = Enums::nullvalue_to_string("vcpkg::Commands::Build::BuildResult");
        static const std::string SUCCEEDED_STRING = "SUCCEEDED";
        static const std::string BUILD_FAILED_STRING = "BUILD_FAILED";
        static const std::string POST_BUILD_CHECKS_FAILED_STRING = "POST_BUILD_CHECKS_FAILED";
        static const std::string CASCADED_DUE_TO_MISSING_DEPENDENCIES_STRING = "CASCADED_DUE_TO_MISSING_DEPENDENCIES";

        switch (build_result)
        {
            case BuildResult::NULLVALUE: return NULLVALUE_STRING;
            case BuildResult::SUCCEEDED: return SUCCEEDED_STRING;
            case BuildResult::BUILD_FAILED: return BUILD_FAILED_STRING;
            case BuildResult::POST_BUILD_CHECKS_FAILED: return POST_BUILD_CHECKS_FAILED_STRING;
            case BuildResult::CASCADED_DUE_TO_MISSING_DEPENDENCIES: return CASCADED_DUE_TO_MISSING_DEPENDENCIES_STRING;
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

    BuildInfo BuildInfo::create(std::unordered_map<std::string, std::string> pgh)
    {
        BuildInfo build_info;
        const std::string crt_linkage_as_string =
            details::remove_required_field(&pgh, BuildInfoRequiredField::CRT_LINKAGE);
        build_info.crt_linkage = LinkageType::value_of(crt_linkage_as_string);
        Checks::check_exit(VCPKG_LINE_INFO,
                           build_info.crt_linkage != LinkageTypeC::NULLVALUE,
                           "Invalid crt linkage type: [%s]",
                           crt_linkage_as_string);

        const std::string library_linkage_as_string =
            details::remove_required_field(&pgh, BuildInfoRequiredField::LIBRARY_LINKAGE);
        build_info.library_linkage = LinkageType::value_of(library_linkage_as_string);
        Checks::check_exit(VCPKG_LINE_INFO,
                           build_info.library_linkage != LinkageTypeC::NULLVALUE,
                           "Invalid library linkage type: [%s]",
                           library_linkage_as_string);

        auto it_version = pgh.find("Version");
        if (it_version != pgh.end())
        {
            build_info.version = it_version->second;
            pgh.erase(it_version);
        }

        // The remaining entries are policies
        for (const std::unordered_map<std::string, std::string>::value_type& p : pgh)
        {
            const BuildPolicies policy = BuildPolicies::parse(p.first);
            Checks::check_exit(
                VCPKG_LINE_INFO, policy != BuildPoliciesC::NULLVALUE, "Unknown policy found: %s", p.first);
            if (p.second == "enabled")
                build_info.policies.emplace(policy, true);
            else if (p.second == "disabled")
                build_info.policies.emplace(policy, false);
            else
                Checks::exit_with_message(VCPKG_LINE_INFO, "Unknown setting for policy '%s': %s", p.first, p.second);
        }

        return build_info;
    }

    BuildInfo read_build_info(const Files::Filesystem& fs, const fs::path& filepath)
    {
        const Expected<std::unordered_map<std::string, std::string>> pghs =
            Paragraphs::get_single_paragraph(fs, filepath);
        Checks::check_exit(VCPKG_LINE_INFO, pghs.get() != nullptr, "Invalid BUILD_INFO file for package");
        return BuildInfo::create(*pghs.get());
    }
}
