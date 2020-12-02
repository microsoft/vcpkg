#pragma once

#include <vcpkg/base/fwd/json.h>

#include <vcpkg/fwd/configuration.h>
#include <vcpkg/fwd/registries.h>
#include <vcpkg/fwd/vcpkgcmdarguments.h>
#include <vcpkg/fwd/vcpkgpaths.h>

#include <vcpkg/base/cache.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/lazy.h>
#include <vcpkg/base/optional.h>
#include <vcpkg/base/system.h>
#include <vcpkg/base/util.h>

namespace vcpkg
{
    struct ToolsetArchOption
    {
        CStringView name;
        System::CPUArchitecture host_arch;
        System::CPUArchitecture target_arch;
    };

    struct Toolset
    {
        fs::path visual_studio_root_path;
        fs::path dumpbin;
        fs::path vcvarsall;
        std::vector<std::string> vcvarsall_options;
        CStringView version;
        std::vector<ToolsetArchOption> supported_architectures;
    };

    namespace Build
    {
        struct PreBuildInfo;
        struct AbiInfo;
        struct CompilerInfo;
    }

    namespace System
    {
        struct Environment;
    }

    namespace details
    {
        struct VcpkgPathsImpl;
    }

    struct BinaryParagraph;
    struct PackageSpec;
    struct Triplet;

    struct VcpkgPaths : Util::MoveOnlyBase
    {
        struct TripletFile
        {
            std::string name;
            fs::path location;

            TripletFile(const std::string& name, const fs::path& location) : name(name), location(location) { }
        };

        VcpkgPaths(Files::Filesystem& filesystem, const VcpkgCmdArguments& args);
        ~VcpkgPaths();

        fs::path package_dir(const PackageSpec& spec) const;
        fs::path build_dir(const PackageSpec& spec) const;
        fs::path build_dir(const std::string& package_name) const;
        fs::path build_info_file_path(const PackageSpec& spec) const;
        fs::path listfile_path(const BinaryParagraph& pgh) const;

        bool is_valid_triplet(Triplet t) const;
        const std::vector<std::string> get_available_triplets_names() const;
        const std::vector<TripletFile>& get_available_triplets() const;
        const std::map<std::string, std::string>& get_cmake_script_hashes() const;
        const fs::path get_triplet_file_path(Triplet triplet) const;

        fs::path original_cwd;
        fs::path root;
        fs::path manifest_root_dir;
        fs::path config_root_dir;
        fs::path buildtrees;
        fs::path downloads;
        fs::path packages;
        fs::path installed;
        fs::path triplets;
        fs::path community_triplets;
        fs::path scripts;
        fs::path prefab;

        fs::path tools;
        fs::path buildsystems;
        fs::path buildsystems_msbuild_targets;
        fs::path buildsystems_msbuild_props;

        fs::path vcpkg_dir;
        fs::path vcpkg_dir_status_file;
        fs::path vcpkg_dir_info;
        fs::path vcpkg_dir_updates;

        fs::path baselines_dot_git_dir;
        fs::path baselines_work_tree;
        fs::path baselines_output;

        fs::path versions_dot_git_dir;
        fs::path versions_work_tree;
        fs::path versions_output;

        fs::path ports_cmake;

        const fs::path& get_tool_exe(const std::string& tool) const;
        const std::string& get_tool_version(const std::string& tool) const;

        // Git manipulation
        fs::path git_checkout_baseline(Files::Filesystem& filesystem, StringView commit_sha) const;
        fs::path git_checkout_port(Files::Filesystem& filesystem, StringView port_name, StringView git_tree) const;
        ExpectedS<std::string> git_show(const std::string& treeish, const fs::path& dot_git_dir) const;

        Optional<const Json::Object&> get_manifest() const;
        Optional<const fs::path&> get_manifest_path() const;
        const Configuration& get_configuration() const;

        /// <summary>Retrieve a toolset matching a VS version</summary>
        /// <remarks>
        ///   Valid version strings are "v120", "v140", "v141", and "". Empty string gets the latest.
        /// </remarks>
        const Toolset& get_toolset(const Build::PreBuildInfo& prebuildinfo) const;

        Files::Filesystem& get_filesystem() const;

        const System::Environment& get_action_env(const Build::AbiInfo& abi_info) const;
        const std::string& get_triplet_info(const Build::AbiInfo& abi_info) const;
        const Build::CompilerInfo& get_compiler_info(const Build::AbiInfo& abi_info) const;
        bool manifest_mode_enabled() const { return get_manifest().has_value(); }

        const FeatureFlagSettings& get_feature_flags() const;
        void track_feature_flag_metrics() const;

        // the directory of the builtin ports
        // this should be used only for helper commands, not core commands like `install`.
        fs::path builtin_ports_directory() const { return root / fs::u8path("ports"); }

    private:
        std::unique_ptr<details::VcpkgPathsImpl> m_pimpl;

        static void git_checkout_subpath(const VcpkgPaths& paths,
                                         StringView commit_sha,
                                         const fs::path& subpath,
                                         const fs::path& local_repo,
                                         const fs::path& destination,
                                         const fs::path& dot_git_dir,
                                         const fs::path& work_tree);

        static void git_checkout_object(const VcpkgPaths& paths,
                                        StringView git_object,
                                        const fs::path& local_repo,
                                        const fs::path& destination,
                                        const fs::path& dot_git_dir,
                                        const fs::path& work_tree);
    };
}
