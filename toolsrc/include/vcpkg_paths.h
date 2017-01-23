#pragma once
#include "filesystem_fs.h"
#include "expected.h"
#include "package_spec.h"
#include "BinaryParagraph.h"

namespace vcpkg
{
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
    };
}
