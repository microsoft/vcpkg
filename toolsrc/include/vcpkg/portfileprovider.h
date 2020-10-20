#pragma once

#include <vcpkg/fwd/vcpkgpaths.h>

#include <vcpkg/base/expected.h>
#include <vcpkg/base/util.h>

#include <vcpkg/sourceparagraph.h>
#include <vcpkg/versions.h>

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

    struct VersionedPortfileProvider
    {
        explicit VersionedPortfileProvider(const vcpkg::VcpkgPaths& paths);

        const std::vector<vcpkg::Versions::VersionSpec>& get_port_versions(const std::string& port_spec) const;

        // ExpectedS<const SourceControlFileLocation&> get_control_file(
        //    const vcpkg::Versions::VersionSpec& version_spec) const;

    private:
        const vcpkg::VcpkgPaths& paths;
        // mutable std::unordered_map<Versions::VersionSpec, SourceControlFileLocation, Versions::VersionSpecHasher> control_cache;
        mutable std::unordered_map<std::string, std::vector<Versions::VersionSpec>> versions_cache;
        mutable std::unordered_map<Versions::VersionSpec, std::string, Versions::VersionSpecHasher> git_tree_cache;
    };

}
