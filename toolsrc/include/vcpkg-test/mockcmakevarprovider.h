#pragma once

#include <vcpkg/cmakevars.h>

namespace vcpkg::Test
{
    struct MockCMakeVarProvider : CMakeVars::CMakeVarProvider
    {
        using SMap = std::unordered_map<std::string, std::string>;
        void load_generic_triplet_vars(Triplet triplet) const override
        {
            generic_triplet_vars.emplace(triplet, SMap{});
        }

        void load_dep_info_vars(Span<const PackageSpec> specs) const override
        {
            for (auto&& spec : specs)
                dep_info_vars.emplace(spec, SMap{});
        }

        void load_tag_vars(Span<const FullPackageSpec> specs,
                           const PortFileProvider::PortFileProvider& port_provider) const override
        {
            for (auto&& spec : specs)
                tag_vars.emplace(spec.package_spec, SMap{});
            (void)(port_provider);
        }

        Optional<const std::unordered_map<std::string, std::string>&> get_generic_triplet_vars(
            Triplet triplet) const override;

        Optional<const std::unordered_map<std::string, std::string>&> get_dep_info_vars(
            const PackageSpec& spec) const override;

        Optional<const std::unordered_map<std::string, std::string>&> get_tag_vars(
            const PackageSpec& spec) const override;

        mutable std::unordered_map<PackageSpec, std::unordered_map<std::string, std::string>> dep_info_vars;
        mutable std::unordered_map<PackageSpec, std::unordered_map<std::string, std::string>> tag_vars;
        mutable std::unordered_map<Triplet, std::unordered_map<std::string, std::string>> generic_triplet_vars;
    };
}
