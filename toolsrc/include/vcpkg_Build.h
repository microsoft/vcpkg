#pragma once

#include "PackageSpec.h"
#include "PostBuildLint_BuildPolicies.h"
#include "PostBuildLint_LinkageType.h"
#include "StatusParagraphs.h"
#include "VcpkgPaths.h"
#include "vcpkg_Files.h"
#include "vcpkg_optional.h"
#include <map>
#include <string>
#include <unordered_map>
#include <vector>

namespace vcpkg::Build
{
    enum class BuildResult
    {
        NULLVALUE = 0,
        SUCCEEDED,
        BUILD_FAILED,
        POST_BUILD_CHECKS_FAILED,
        CASCADED_DUE_TO_MISSING_DEPENDENCIES
    };

    static constexpr std::array<BuildResult, 4> BuildResult_values = {
        BuildResult::SUCCEEDED,
        BuildResult::BUILD_FAILED,
        BuildResult::POST_BUILD_CHECKS_FAILED,
        BuildResult::CASCADED_DUE_TO_MISSING_DEPENDENCIES};

    const std::string& to_string(const BuildResult build_result);
    std::string create_error_message(const BuildResult build_result, const PackageSpec& spec);
    std::string create_user_troubleshooting_message(const PackageSpec& spec);

    std::wstring make_build_env_cmd(const Triplet& triplet, const Toolset& toolset);

    struct ExtendedBuildResult
    {
        BuildResult code;
        std::vector<PackageSpec> unmet_dependencies;
    };

    struct BuildPackageConfig
    {
        BuildPackageConfig(const SourceParagraph& src, const Triplet& triplet, fs::path&& port_dir)
            : src(src), triplet(triplet), port_dir(std::move(port_dir)), use_head_version(false), no_downloads(false)
        {
        }

        const SourceParagraph& src;
        const Triplet& triplet;
        fs::path port_dir;

        bool use_head_version;
        bool no_downloads;
    };

    ExtendedBuildResult build_package(const VcpkgPaths& paths,
                                      const BuildPackageConfig& config,
                                      const StatusParagraphs& status_db);

    struct BuildInfo
    {
        static BuildInfo create(std::unordered_map<std::string, std::string> pgh);

        PostBuildLint::LinkageType crt_linkage;
        PostBuildLint::LinkageType library_linkage;

        Optional<std::string> version;

        std::map<PostBuildLint::BuildPolicies, bool> policies;
    };

    BuildInfo read_build_info(const Files::Filesystem& fs, const fs::path& filepath);
}
