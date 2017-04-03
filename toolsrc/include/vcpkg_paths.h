#pragma once
#include "filesystem_fs.h"
#include "vcpkg_expected.h"
#include "package_spec.h"
#include "BinaryParagraph.h"
#include "lazy.h"

namespace vcpkg
{
    struct toolset_t
    {
        fs::path dumpbin;
        fs::path vcvarsall;
        CWStringView version;
    };

    struct vcpkg_paths
    {
        static expected<vcpkg_paths> create(const fs::path& vcpkg_root_dir);

        fs::path package_dir(const package_spec& spec) const;
        fs::path port_dir(const package_spec& spec) const;
        fs::path build_info_file_path(const package_spec& spec) const;
        fs::path listfile_path(const BinaryParagraph& pgh) const;

        bool is_valid_triplet(const triplet& t) const;

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
        const toolset_t& get_toolset() const;

    private:
        lazy<fs::path> cmake_exe;
        lazy<fs::path> git_exe;
        lazy<fs::path> nuget_exe;
        lazy<toolset_t> toolset;
    };
}
