#pragma once

#include "CStringView.h"
#include "PackageSpec.h"
#include "PostBuildLint_LinkageType.h"
#include "StatusParagraphs.h"
#include "VcpkgPaths.h"
#include "vcpkg_Files.h"
#include "vcpkg_optional.h"

#include <map>
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

    /// <summary>
    /// Settings from the triplet file which impact the build environment and post-build checks
    /// </summary>
    struct PreBuildInfo
    {
        /// <summary>
        /// Runs the triplet file in a "capture" mode to create a PreBuildInfo
        /// </summary>
        static PreBuildInfo from_triplet_file(const VcpkgPaths& paths, const Triplet& triplet);

        std::string target_architecture;
        std::string cmake_system_name;
        std::string cmake_system_version;
        std::string platform_toolset;
    };

    std::wstring make_build_env_cmd(const PreBuildInfo& pre_build_info, const Toolset& toolset);

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

    enum class BuildPolicy
    {
        EMPTY_PACKAGE,
        DLLS_WITHOUT_LIBS,
        ONLY_RELEASE_CRT,
        EMPTY_INCLUDE_FOLDER,
        ALLOW_OBSOLETE_MSVCRT,
        // Must be last
        COUNT,
    };

    Optional<BuildPolicy> to_build_policy(const std::string& str);

    const std::string& to_string(BuildPolicy policy);
    CStringView to_cmake_variable(BuildPolicy policy);

    struct BuildPolicies
    {
        BuildPolicies() {}
        BuildPolicies(std::map<BuildPolicy, bool>&& map) : m_policies(std::move(map)) {}

        inline bool is_enabled(BuildPolicy policy) const
        {
            auto it = m_policies.find(policy);
            if (it != m_policies.cend()) return it->second;
            return false;
        }

    private:
        std::map<BuildPolicy, bool> m_policies;
    };

    struct BuildInfo
    {
        PostBuildLint::LinkageType crt_linkage;
        PostBuildLint::LinkageType library_linkage;

        Optional<std::string> version;

        BuildPolicies policies;
    };

    BuildInfo read_build_info(const Files::Filesystem& fs, const fs::path& filepath);
}
