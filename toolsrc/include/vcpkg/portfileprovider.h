#pragma once

#include <vcpkg/base/optional.h>
#include <vcpkg/base/util.h>
#include <vcpkg/sourceparagraph.h>
#include <vcpkg/vcpkgpaths.h>

namespace vcpkg::PortFileProvider
{
    struct PortFileProvider
    {
        virtual Optional<const SourceControlFileLocation&> get_control_file(const std::string& src_name) const = 0;
        virtual std::vector<const SourceControlFileLocation*> load_all_control_files() const = 0;
    };

    struct MapPortFileProvider : Util::ResourceBase, PortFileProvider
    {
        explicit MapPortFileProvider(const std::unordered_map<std::string, SourceControlFileLocation>& map);
        Optional<const SourceControlFileLocation&> get_control_file(const std::string& src_name) const override;
        std::vector<const SourceControlFileLocation*> load_all_control_files() const override;

    private:
        const std::unordered_map<std::string, SourceControlFileLocation>& ports;
    };

    struct PathsPortFileProvider : Util::ResourceBase, PortFileProvider
    {
        explicit PathsPortFileProvider(const vcpkg::VcpkgPaths& paths,
                                       const std::vector<std::string>* ports_dirs_paths);
        Optional<const SourceControlFileLocation&> get_control_file(const std::string& src_name) const override;
        std::vector<const SourceControlFileLocation*> load_all_control_files() const override;

    private:
        Files::Filesystem& filesystem;
        std::vector<fs::path> ports_dirs;
        mutable std::unordered_map<std::string, SourceControlFileLocation> cache;
    };
}
