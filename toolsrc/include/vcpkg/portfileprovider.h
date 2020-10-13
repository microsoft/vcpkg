#pragma once

#include <vcpkg/fwd/vcpkgpaths.h>

#include <vcpkg/base/expected.h>
#include <vcpkg/base/util.h>

#include <vcpkg/sourceparagraph.h>

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
        explicit PathsPortFileProvider(const vcpkg::VcpkgPaths& paths, const std::vector<std::string>& overlay_ports);
        ExpectedS<const SourceControlFileLocation&> get_control_file(const std::string& src_name) const override;
        std::vector<const SourceControlFileLocation*> load_all_control_files() const override;

    private:
        const VcpkgPaths& paths;
        std::vector<fs::path> overlay_ports;
        mutable std::unordered_map<std::string, SourceControlFileLocation> cache;
    };
}
