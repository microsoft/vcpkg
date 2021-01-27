#pragma once

#include <vcpkg/fwd/configuration.h>
#include <vcpkg/fwd/registries.h>
#include <vcpkg/fwd/vcpkgpaths.h>

#include <vcpkg/base/files.h>
#include <vcpkg/base/jsonreader.h>
#include <vcpkg/base/stringview.h>
#include <vcpkg/base/view.h>

#include <vcpkg/versiondeserializers.h>
#include <vcpkg/versiont.h>

#include <map>
#include <memory>
#include <string>
#include <system_error>
#include <vector>

namespace vcpkg
{
    struct RegistryEntry
    {
        virtual View<VersionT> get_port_versions() const = 0;

        virtual ExpectedS<fs::path> get_path_to_version(const VcpkgPaths& paths, const VersionT& version) const = 0;

        virtual ~RegistryEntry() = default;
    };

    struct RegistryImplementation
    {
        // returns nullptr if the port doesn't exist
        virtual std::unique_ptr<RegistryEntry> get_port_entry(const VcpkgPaths& paths, StringView port_name) const = 0;

        // appends the names of the ports to the out parameter
        // may result in duplicated port names; make sure to Util::sort_unique_erase at the end
        virtual void get_all_port_names(std::vector<std::string>& port_names, const VcpkgPaths& paths) const = 0;

        virtual Optional<VersionT> get_baseline_version(const VcpkgPaths& paths, StringView port_name) const = 0;

        virtual ~RegistryImplementation() = default;
    };

    struct Registry
    {
        // requires: static_cast<bool>(implementation)
        Registry(std::vector<std::string>&& packages, std::unique_ptr<RegistryImplementation>&& implementation);

        Registry(std::vector<std::string>&&, std::nullptr_t) = delete;

        // always ordered lexicographically
        View<std::string> packages() const { return packages_; }
        const RegistryImplementation& implementation() const { return *implementation_; }

        friend RegistrySet; // for experimental_set_builtin_registry_baseline

    private:
        std::vector<std::string> packages_;
        std::unique_ptr<RegistryImplementation> implementation_;
    };

    // this type implements the registry fall back logic from the registries RFC:
    // A port name maps to one of the non-default registries if that registry declares
    // that it is the registry for that port name, else it maps to the default registry
    // if that registry exists; else, there is no registry for a port.
    // The way one sets this up is via the `"registries"` and `"default_registry"`
    // configuration fields.
    struct RegistrySet
    {
        RegistrySet();

        // finds the correct registry for the port name
        // Returns the null pointer if there is no registry set up for that name
        const RegistryImplementation* registry_for_port(StringView port_name) const;
        Optional<VersionT> baseline_for_port(const VcpkgPaths& paths, StringView port_name) const;

        View<Registry> registries() const { return registries_; }

        const RegistryImplementation* default_registry() const { return default_registry_.get(); }

        // TODO: figure out how to get this to return an error (or maybe it should be a warning?)
        void add_registry(Registry&& r);
        void set_default_registry(std::unique_ptr<RegistryImplementation>&& r);
        void set_default_registry(std::nullptr_t r);

        // this exists in order to allow versioning and registries to be developed and tested separately
        void experimental_set_builtin_registry_baseline(StringView baseline) const;

        // returns whether the registry set has any modifications to the default
        // (i.e., whether `default_registry` was set, or `registries` had any entries)
        // for checking against the registry feature flag.
        bool has_modifications() const;

    private:
        std::unique_ptr<RegistryImplementation> default_registry_;
        std::vector<Registry> registries_;
    };

    std::unique_ptr<Json::IDeserializer<std::unique_ptr<RegistryImplementation>>>
    get_registry_implementation_deserializer(const fs::path& configuration_directory);

    std::unique_ptr<Json::IDeserializer<std::vector<Registry>>> get_registry_array_deserializer(
        const fs::path& configuration_directory);

    ExpectedS<std::vector<std::pair<SchemedVersion, std::string>>> get_builtin_versions(const VcpkgPaths& paths,
                                                                                        StringView port_name);

    ExpectedS<std::map<std::string, VersionT, std::less<>>> get_builtin_baseline(const VcpkgPaths& paths);
}
