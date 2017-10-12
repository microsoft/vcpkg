#pragma once
#include "BinaryParagraph.h"
#include "Lazy.h"
#include "PackageSpec.h"
#include "filesystem_fs.h"
#include "vcpkg_Files.h"
#include "vcpkg_expected.h"

namespace vcpkg
{
    struct ToolsetArchOption
    {
        CWStringView name;
        System::CPUArchitecture host_arch;
        System::CPUArchitecture target_arch;
    };

    struct Toolset
    {
        fs::path visual_studio_root_path;
        fs::path dumpbin;
        fs::path vcvarsall;
        std::vector<std::wstring> vcvarsall_options;
        CWStringView version;
        std::vector<ToolsetArchOption> supported_architectures;
    };

    struct VcpkgPaths
    {
        static Expected<VcpkgPaths> create(const fs::path& vcpkg_root_dir);

        fs::path package_dir(const PackageSpec& spec) const;
        fs::path port_dir(const PackageSpec& spec) const;
        fs::path port_dir(const std::string& name) const;
        fs::path build_info_file_path(const PackageSpec& spec) const;
        fs::path listfile_path(const BinaryParagraph& pgh) const;

        bool is_valid_triplet(const Triplet& t) const;

        fs::path root;
        fs::path packages;
        fs::path buildtrees;
        fs::path downloads;
        fs::path ports;
        fs::path installed;
        fs::path triplets;
        fs::path scripts;

        fs::path buildsystems;
        fs::path buildsystems_msbuild_targets;

        fs::path vcpkg_dir;
        fs::path vcpkg_dir_status_file;
        fs::path vcpkg_dir_info;
        fs::path vcpkg_dir_updates;

        fs::path ports_cmake;

        const fs::path& get_cmake_exe() const;
        const fs::path& get_git_exe() const;
        const fs::path& get_nuget_exe() const;
        const fs::path& get_ifw_installerbase_exe() const;
        const fs::path& get_ifw_binarycreator_exe() const;
        const fs::path& get_ifw_repogen_exe() const;

        /// <summary>Retrieve a toolset matching a VS version</summary>
        /// <remarks>
        ///   Valid version strings are "v140", "v141", and "". Empty string gets the latest.
        /// </remarks>
        const Toolset& VcpkgPaths::get_toolset(const Optional<std::string>& toolset_version,
                                               const Optional<fs::path>& visual_studio_path) const;

        Files::Filesystem& get_filesystem() const;

    private:
        Lazy<fs::path> cmake_exe;
        Lazy<fs::path> git_exe;
        Lazy<fs::path> nuget_exe;
        Lazy<fs::path> ifw_installerbase_exe;
        Lazy<fs::path> ifw_binarycreator_exe;
        Lazy<fs::path> ifw_repogen_exe;
        Lazy<std::vector<Toolset>> toolsets;
    };
}
