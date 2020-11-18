#pragma once

#include <vcpkg/fwd/cmakevars.h>
#include <vcpkg/fwd/dependencies.h>
#include <vcpkg/fwd/portfileprovider.h>

#include <vcpkg/base/cstringview.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/optional.h>
#include <vcpkg/base/system.process.h>

#include <vcpkg/commands.integrate.h>
#include <vcpkg/packagespec.h>
#include <vcpkg/statusparagraphs.h>
#include <vcpkg/triplet.h>
#include <vcpkg/vcpkgcmdarguments.h>
#include <vcpkg/vcpkgpaths.h>

#include <array>
#include <map>
#include <set>
#include <vector>

namespace vcpkg
{
    struct IBinaryProvider;
}

namespace vcpkg::System
{
    struct Environment;
}

namespace vcpkg::Build
{
    enum class BuildResult
    {
        NULLVALUE = 0,
        SUCCEEDED,
        BUILD_FAILED,
        POST_BUILD_CHECKS_FAILED,
        FILE_CONFLICTS,
        CASCADED_DUE_TO_MISSING_DEPENDENCIES,
        EXCLUDED,
        DOWNLOADED
    };

    struct IBuildLogsRecorder
    {
        virtual void record_build_result(const VcpkgPaths& paths,
                                         const PackageSpec& spec,
                                         BuildResult result) const = 0;
    };

    const IBuildLogsRecorder& null_build_logs_recorder() noexcept;

    namespace Command
    {
        int perform_ex(const FullPackageSpec& full_spec,
                       const SourceControlFileLocation& scfl,
                       const PortFileProvider::PathsPortFileProvider& provider,
                       IBinaryProvider& binaryprovider,
                       const IBuildLogsRecorder& build_logs_recorder,
                       const VcpkgPaths& paths);
        void perform_and_exit_ex(const FullPackageSpec& full_spec,
                                 const SourceControlFileLocation& scfl,
                                 const PortFileProvider::PathsPortFileProvider& provider,
                                 IBinaryProvider& binaryprovider,
                                 const IBuildLogsRecorder& build_logs_recorder,
                                 const VcpkgPaths& paths);

        int perform(const VcpkgCmdArguments& args, const VcpkgPaths& paths, Triplet default_triplet);
        void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, Triplet default_triplet);
    }

    enum class UseHeadVersion
    {
        NO = 0,
        YES
    };

    enum class AllowDownloads
    {
        NO = 0,
        YES
    };

    enum class OnlyDownloads
    {
        NO = 0,
        YES
    };

    enum class CleanBuildtrees
    {
        NO = 0,
        YES
    };

    enum class CleanPackages
    {
        NO = 0,
        YES
    };

    enum class CleanDownloads
    {
        NO = 0,
        YES
    };

    enum class ConfigurationType
    {
        DEBUG,
        RELEASE,
    };

    enum class DownloadTool
    {
        BUILT_IN,
        ARIA2,
    };
    const std::string& to_string(DownloadTool tool);
    enum class PurgeDecompressFailure
    {
        NO = 0,
        YES
    };

    enum class Editable
    {
        NO = 0,
        YES
    };

    enum class BackcompatFeatures
    {
        ALLOW = 0,
        PROHIBIT
    };

    struct BuildPackageOptions
    {
        UseHeadVersion use_head_version;
        AllowDownloads allow_downloads;
        OnlyDownloads only_downloads;
        CleanBuildtrees clean_buildtrees;
        CleanPackages clean_packages;
        CleanDownloads clean_downloads;
        DownloadTool download_tool;
        PurgeDecompressFailure purge_decompress_failure;
        Editable editable;
        BackcompatFeatures backcompat_features;
    };

    static constexpr BuildPackageOptions default_build_package_options{
        Build::UseHeadVersion::NO,
        Build::AllowDownloads::YES,
        Build::OnlyDownloads::NO,
        Build::CleanBuildtrees::YES,
        Build::CleanPackages::YES,
        Build::CleanDownloads::NO,
        Build::DownloadTool::BUILT_IN,
        Build::PurgeDecompressFailure::YES,
        Build::Editable::NO,
        Build::BackcompatFeatures::ALLOW,
    };

    static constexpr BuildPackageOptions backcompat_prohibiting_package_options{
        Build::UseHeadVersion::NO,
        Build::AllowDownloads::YES,
        Build::OnlyDownloads::NO,
        Build::CleanBuildtrees::YES,
        Build::CleanPackages::YES,
        Build::CleanDownloads::NO,
        Build::DownloadTool::BUILT_IN,
        Build::PurgeDecompressFailure::YES,
        Build::Editable::NO,
        Build::BackcompatFeatures::PROHIBIT,
    };

    static constexpr std::array<BuildResult, 6> BUILD_RESULT_VALUES = {
        BuildResult::SUCCEEDED,
        BuildResult::BUILD_FAILED,
        BuildResult::POST_BUILD_CHECKS_FAILED,
        BuildResult::FILE_CONFLICTS,
        BuildResult::CASCADED_DUE_TO_MISSING_DEPENDENCIES,
        BuildResult::EXCLUDED};

    const std::string& to_string(const BuildResult build_result);
    std::string create_error_message(const BuildResult build_result, const PackageSpec& spec);
    std::string create_user_troubleshooting_message(const PackageSpec& spec);

    /// <summary>
    /// Settings from the triplet file which impact the build environment and post-build checks
    /// </summary>
    struct PreBuildInfo : Util::ResourceBase
    {
        PreBuildInfo(const VcpkgPaths& paths,
                     Triplet triplet,
                     const std::unordered_map<std::string, std::string>& cmakevars);

        Triplet triplet;
        bool load_vcvars_env = false;
        std::string target_architecture;
        std::string cmake_system_name;
        std::string cmake_system_version;
        Optional<std::string> platform_toolset;
        Optional<fs::path> visual_studio_path;
        Optional<std::string> external_toolchain_file;
        Optional<ConfigurationType> build_type;
        Optional<std::string> public_abi_override;
        std::vector<std::string> passthrough_env_vars;

        fs::path toolchain_file() const;
        bool using_vcvars() const;

    private:
        const VcpkgPaths& m_paths;
    };

    std::string make_build_env_cmd(const PreBuildInfo& pre_build_info, const Toolset& toolset);

    struct ExtendedBuildResult
    {
        ExtendedBuildResult(BuildResult code);
        ExtendedBuildResult(BuildResult code, std::vector<FeatureSpec>&& unmet_deps);
        ExtendedBuildResult(BuildResult code, std::unique_ptr<BinaryControlFile>&& bcf);

        BuildResult code;
        std::vector<FeatureSpec> unmet_dependencies;
        std::unique_ptr<BinaryControlFile> binary_control_file;
    };

    ExtendedBuildResult build_package(const VcpkgPaths& paths,
                                      const Dependencies::InstallPlanAction& config,
                                      IBinaryProvider& binaries_provider,
                                      const IBuildLogsRecorder& build_logs_recorder,
                                      const StatusParagraphs& status_db);

    enum class BuildPolicy
    {
        EMPTY_PACKAGE,
        DLLS_WITHOUT_LIBS,
        DLLS_WITHOUT_EXPORTS,
        DLLS_IN_STATIC_LIBRARY,
        MISMATCHED_NUMBER_OF_BINARIES,
        ONLY_RELEASE_CRT,
        EMPTY_INCLUDE_FOLDER,
        ALLOW_OBSOLETE_MSVCRT,
        ALLOW_RESTRICTED_HEADERS,
        SKIP_DUMPBIN_CHECKS,
        SKIP_ARCHITECTURE_CHECK,
        // Must be last
        COUNT,
    };

    // could be constexpr, but we want to generate this and that's not constexpr in C++14
    extern const std::array<BuildPolicy, size_t(BuildPolicy::COUNT)> ALL_POLICIES;

    const std::string& to_string(BuildPolicy policy);
    CStringView to_cmake_variable(BuildPolicy policy);

    struct BuildPolicies
    {
        BuildPolicies() = default;
        BuildPolicies(std::map<BuildPolicy, bool>&& map) : m_policies(std::move(map)) { }

        bool is_enabled(BuildPolicy policy) const
        {
            const auto it = m_policies.find(policy);
            if (it != m_policies.cend()) return it->second;
            return false;
        }

    private:
        std::map<BuildPolicy, bool> m_policies;
    };

    enum class LinkageType : char
    {
        DYNAMIC,
        STATIC,
    };

    Optional<LinkageType> to_linkage_type(const std::string& str);

    struct BuildInfo
    {
        LinkageType crt_linkage = LinkageType::DYNAMIC;
        LinkageType library_linkage = LinkageType::DYNAMIC;

        Optional<std::string> version;

        BuildPolicies policies;
    };

    BuildInfo read_build_info(const Files::Filesystem& fs, const fs::path& filepath);

    struct AbiEntry
    {
        std::string key;
        std::string value;

        AbiEntry() = default;
        AbiEntry(const std::string& key, const std::string& value) : key(key), value(value) { }

        bool operator<(const AbiEntry& other) const
        {
            return key < other.key || (key == other.key && value < other.value);
        }
    };

    struct CompilerInfo
    {
        std::string id;
        std::string version;
        std::string hash;
    };

    struct AbiInfo
    {
        std::unique_ptr<PreBuildInfo> pre_build_info;
        Optional<const Toolset&> toolset;
        Optional<const std::string&> triplet_abi;
        std::string package_abi;
        Optional<fs::path> abi_tag_file;
        Optional<const CompilerInfo&> compiler_info;
    };

    void compute_all_abis(const VcpkgPaths& paths,
                          Dependencies::ActionPlan& action_plan,
                          const CMakeVars::CMakeVarProvider& var_provider,
                          const StatusParagraphs& status_db);

    struct EnvCache
    {
        explicit EnvCache(bool compiler_tracking) : m_compiler_tracking(compiler_tracking) { }

        const System::Environment& get_action_env(const VcpkgPaths& paths, const AbiInfo& abi_info);
        const std::string& get_triplet_info(const VcpkgPaths& paths, const AbiInfo& abi_info);
        const CompilerInfo& get_compiler_info(const VcpkgPaths& paths, const AbiInfo& abi_info);

    private:
        struct TripletMapEntry
        {
            std::string hash;
            Cache<std::string, std::string> compiler_hashes;
            Cache<std::string, CompilerInfo> compiler_info;
        };
        Cache<fs::path, TripletMapEntry> m_triplet_cache;
        Cache<fs::path, std::string> m_toolchain_cache;

#if defined(_WIN32)
        struct EnvMapEntry
        {
            std::unordered_map<std::string, std::string> env_map;
            Cache<std::string, System::Environment> cmd_cache;
        };

        Cache<std::vector<std::string>, EnvMapEntry> envs;
#endif

        bool m_compiler_tracking;
    };

    struct BuildCommand : Commands::TripletCommand
    {
        virtual void perform_and_exit(const VcpkgCmdArguments& args,
                                      const VcpkgPaths& paths,
                                      Triplet default_triplet) const override;
    };
}
