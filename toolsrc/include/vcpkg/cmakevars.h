#pragma once

#include <vcpkg/base/hash.h>
#include <vcpkg/base/system.process.h>

#include <vcpkg/portfileprovider.h>
#include <vcpkg/vcpkgpaths.h>

namespace vcpkg::CMakeVars
{
    struct CMakeVarProvider : Util::ResourceBase
    {
    private:
        fs::path create_tag_extraction_file(
            const Span<const std::pair<const FullPackageSpec*, std::string>>& spec_abi_settings) const;

        fs::path create_dep_info_extraction_file(const Span<const PackageSpec> specs) const;

        void launch_and_split(const fs::path& script_path,
                              std::vector<std::vector<std::pair<std::string, std::string>>>& vars) const;

    public:
        explicit CMakeVarProvider(const vcpkg::VcpkgPaths& paths) : paths(paths) {}

        void load_generic_triplet_vars(const Triplet& triplet) const;

        void load_dep_info_vars(Span<const PackageSpec> specs) const;

        void load_tag_vars(Span<const FullPackageSpec> specs,
                           const PortFileProvider::PortFileProvider& port_provider) const;

        Optional<const std::unordered_map<std::string, std::string>&> get_generic_triplet_vars(
            const Triplet& triplet) const;

        Optional<const std::unordered_map<std::string, std::string>&> get_dep_info_vars(const PackageSpec& spec) const;

        Optional<const std::unordered_map<std::string, std::string>&> get_tag_vars(const PackageSpec& spec) const;

    private:
        const VcpkgPaths& paths;
        const fs::path& cmake_exe_path = paths.get_tool_exe(Tools::CMAKE);
        const fs::path get_tags_path = paths.scripts / "vcpkg_get_tags.cmake";
        const fs::path get_dep_info_path = paths.scripts / "vcpkg_get_dep_info.cmake";
        mutable std::unordered_map<PackageSpec, std::unordered_map<std::string, std::string>> dep_resolution_vars;
        mutable std::unordered_map<PackageSpec, std::unordered_map<std::string, std::string>> tag_vars;
        mutable std::unordered_map<Triplet, std::unordered_map<std::string, std::string>> generic_triplet_vars;
    };
}
