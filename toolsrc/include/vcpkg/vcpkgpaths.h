#pragma once

#include <vcpkg/binaryparagraph.h>
#include <vcpkg/packagespec.h>
#include <vcpkg/tools.h>

#include <vcpkg/base/cache.h>
#include <vcpkg/base/expected.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/lazy.h>

namespace vcpkg
{
    namespace Tools
    {
        static const std::string SEVEN_ZIP = "7zip";
        static const std::string CMAKE = "cmake";
        static const std::string GIT = "git";
        static const std::string NINJA = "ninja";
        static const std::string NUGET = "nuget";
        static const std::string IFW_INSTALLER_BASE = "ifw_installerbase";
        static const std::string IFW_BINARYCREATOR = "ifw_binarycreator";
        static const std::string IFW_REPOGEN = "ifw_repogen";
    }

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
    }

    struct VcpkgPaths
    {
        struct TripletFile
        {
            std::string name;
            fs::path location;

            TripletFile(const std::string& name, const fs::path& location) : name(name), location(location) {}
        };

        static Expected<VcpkgPaths> create(const fs::path& vcpkg_root_dir,
                                           const Optional<fs::path>& vcpkg_scripts_root_dir,
                                           const std::string& default_vs_path,
                                           const std::vector<std::string>* triplets_dirs);

        fs::path package_dir(const PackageSpec& spec) const;
        fs::path build_info_file_path(const PackageSpec& spec) const;
        fs::path listfile_path(const BinaryParagraph& pgh) const;

        bool is_valid_triplet(Triplet t) const;
        const std::vector<std::string> get_available_triplets_names() const;
        const std::vector<TripletFile>& get_available_triplets() const;
        const fs::path get_triplet_file_path(Triplet triplet) const;

        fs::path root;
        fs::path packages;
        fs::path buildtrees;
        fs::path downloads;
        fs::path ports;
        fs::path installed;
        fs::path triplets;
        fs::path community_triplets;
        fs::path scripts;

        fs::path tools;
        fs::path buildsystems;
        fs::path buildsystems_msbuild_targets;

        fs::path vcpkg_dir;
        fs::path vcpkg_dir_status_file;
        fs::path vcpkg_dir_info;
        fs::path vcpkg_dir_updates;

        fs::path ports_cmake;

        const fs::path& get_tool_exe(const std::string& tool) const;
        const std::string& get_tool_version(const std::string& tool) const;

        /// <summary>Retrieve a toolset matching a VS version</summary>
        /// <remarks>
        ///   Valid version strings are "v120", "v140", "v141", and "". Empty string gets the latest.
        /// </remarks>
        const Toolset& get_toolset(const Build::PreBuildInfo& prebuildinfo) const;

        Files::Filesystem& get_filesystem() const;

    private:
        Lazy<std::vector<TripletFile>> available_triplets;
        Lazy<std::vector<Toolset>> toolsets;
        Lazy<std::vector<Toolset>> toolsets_vs2013;

        fs::path default_vs_path;
        std::vector<fs::path> triplets_dirs;

        mutable std::unique_ptr<ToolCache> m_tool_cache;
        mutable vcpkg::Cache<Triplet, fs::path> m_triplets_cache;
    };
}
