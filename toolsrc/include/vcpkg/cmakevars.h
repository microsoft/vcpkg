#pragma once

#include <vcpkg/fwd/vcpkgpaths.h>

#include <vcpkg/base/optional.h>

#include <vcpkg/portfileprovider.h>

namespace vcpkg::Dependencies
{
    struct ActionPlan;
}

namespace vcpkg::CMakeVars
{
    struct CMakeVarProvider
    {
        virtual ~CMakeVarProvider() = default;

        virtual Optional<const std::unordered_map<std::string, std::string>&> get_generic_triplet_vars(
            Triplet triplet) const = 0;

        virtual Optional<const std::unordered_map<std::string, std::string>&> get_dep_info_vars(
            const PackageSpec& spec) const = 0;

        virtual Optional<const std::unordered_map<std::string, std::string>&> get_tag_vars(
            const PackageSpec& spec) const = 0;

        virtual void load_generic_triplet_vars(Triplet triplet) const = 0;

        virtual void load_dep_info_vars(Span<const PackageSpec> specs) const = 0;

        virtual void load_tag_vars(Span<const FullPackageSpec> specs,
                                   const PortFileProvider::PortFileProvider& port_provider) const = 0;

        void load_tag_vars(const vcpkg::Dependencies::ActionPlan& action_plan,
                           const PortFileProvider::PortFileProvider& port_provider) const;
    };

    std::unique_ptr<CMakeVarProvider> make_triplet_cmake_var_provider(const vcpkg::VcpkgPaths& paths);
}
