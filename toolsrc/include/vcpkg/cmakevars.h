#pragma once

#include <vcpkg/base/hash.h>
#include <vcpkg/base/system.process.h>

#include <vcpkg/portfileprovider.h>
#include <vcpkg/vcpkgpaths.h>

namespace vcpkg::CMakeVars
{
    struct CMakeVarProvider
    {
        virtual Optional<const std::unordered_map<std::string, std::string>&> get_generic_triplet_vars(
            const Triplet& triplet) const = 0;

        virtual Optional<const std::unordered_map<std::string, std::string>&> get_dep_info_vars(
            const PackageSpec& spec) const = 0;

        virtual Optional<const std::unordered_map<std::string, std::string>&> get_tag_vars(
            const PackageSpec& spec) const = 0;

        virtual void load_generic_triplet_vars(const Triplet& triplet) const = 0;

        virtual void load_dep_info_vars(Span<const PackageSpec> specs) const = 0;

        virtual void load_tag_vars(Span<const FullPackageSpec> specs,
                                   const PortFileProvider::PortFileProvider& port_provider) const = 0;
    };

    struct TripletCMakeVarProvider : Util::ResourceBase, CMakeVarProvider
    {
    private:
        fs::path create_tag_extraction_file(
            const Span<const std::pair<const FullPackageSpec*, std::string>>& spec_abi_settings) const;

        fs::path create_dep_info_extraction_file(const Span<const PackageSpec> specs) const;

        void launch_and_split(const fs::path& script_path,
                              std::vector<std::vector<std::pair<std::string, std::string>>>& vars) const;

    public:
        explicit TripletCMakeVarProvider(const vcpkg::VcpkgPaths& paths) : paths(paths) {}

        void load_generic_triplet_vars(const Triplet& triplet) const override;

        void load_dep_info_vars(Span<const PackageSpec> specs) const override;

        void load_tag_vars(Span<const FullPackageSpec> specs,
                           const PortFileProvider::PortFileProvider& port_provider) const override;

        Optional<const std::unordered_map<std::string, std::string>&> get_generic_triplet_vars(
            const Triplet& triplet) const override;

        Optional<const std::unordered_map<std::string, std::string>&> get_dep_info_vars(
            const PackageSpec& spec) const override;

        Optional<const std::unordered_map<std::string, std::string>&> get_tag_vars(
            const PackageSpec& spec) const override;

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
