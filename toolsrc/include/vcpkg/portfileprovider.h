#pragma once

#include <vcpkg/base/expected.h>
#include <vcpkg/base/util.h>

#include <vcpkg/sourceparagraph.h>
#include <vcpkg/vcpkgpaths.h>

namespace vcpkg::PortFileProvider
{
    struct PortFileProvider
    {
        virtual ExpectedS<const SourceControlFileLocation&> get_control_file(const std::string& src_name) const = 0;
        virtual std::vector<const SourceControlFileLocation*> load_all_control_files() const = 0;
    };

    struct MapPortFileProvider : Util::ResourceBase, PortFileProvider
    {
        explicit MapPortFileProvider(const std::unordered_map<std::string, SourceControlFileLocation>& map);
        ExpectedS<const SourceControlFileLocation&> get_control_file(const std::string& src_name) const override;
        std::vector<const SourceControlFileLocation*> load_all_control_files() const override;

    private:
        const std::unordered_map<std::string, SourceControlFileLocation>& ports;
    };

    struct PathsPortFileProvider : Util::ResourceBase, PortFileProvider
    {
        explicit PathsPortFileProvider(const vcpkg::VcpkgPaths& paths,
                                       const std::vector<std::string>& ports_dirs_paths);
        ExpectedS<const SourceControlFileLocation&> get_control_file(const std::string& src_name) const override;
        std::vector<const SourceControlFileLocation*> load_all_control_files() const override;

    private:
        const SourceControlFileLocation* load_manifest_file() const;

        Files::Filesystem& filesystem;
        fs::path manifest;
        std::vector<fs::path> ports_dirs;
        mutable std::unordered_map<std::string, SourceControlFileLocation> cache;
    };
}
