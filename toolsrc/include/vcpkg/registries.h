#pragma once

#include <vcpkg/fwd/vcpkgpaths.h>

#include <vcpkg/base/files.h>
#include <vcpkg/base/stringview.h>
#include <vcpkg/base/view.h>

#include <vcpkg/versiont.h>

#include <memory>
#include <string>
#include <system_error>
#include <vector>

namespace vcpkg
{
    struct RegistryEntry
    {
        // returns fs::path() if version doesn't exist
        virtual fs::path get_port_directory(const VcpkgPaths& paths, const VersionT& version) const = 0;

        virtual ~RegistryEntry() = default;
    };

    struct RegistryImpl
    {
        // returns nullptr if the port doesn't exist
        virtual std::unique_ptr<RegistryEntry> get_port_entry(const VcpkgPaths& paths, StringView port_name) const = 0;
        // appends the names of the ports to the out parameter
        virtual void get_all_port_names(std::vector<std::string>& port_names, const VcpkgPaths& paths) const = 0;

        virtual Optional<VersionT> get_baseline_version(const VcpkgPaths& paths, StringView port_name) const = 0;

        virtual ~RegistryImpl() = default;
    };

    struct Registry
    {
        // requires: static_cast<bool>(implementation)
        Registry(std::vector<std::string>&& packages, std::unique_ptr<RegistryImpl>&& implementation);

        Registry(std::vector<std::string>&&, std::nullptr_t) = delete;

        // always ordered lexicographically
        View<std::string> packages() const { return packages_; }
        const RegistryImpl& implementation() const { return *implementation_; }

        static std::unique_ptr<RegistryImpl> builtin_registry();

    private:
        std::vector<std::string> packages_;
        std::unique_ptr<RegistryImpl> implementation_;
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
        const RegistryImpl* registry_for_port(StringView port_name) const;

        View<Registry> registries() const { return registries_; }

        const RegistryImpl* default_registry() const { return default_registry_.get(); }

        // TODO: figure out how to get this to return an error (or maybe it should be a warning?)
        void add_registry(Registry&& r);
        void set_default_registry(std::unique_ptr<RegistryImpl>&& r);
        void set_default_registry(std::nullptr_t r);

    private:
        std::unique_ptr<RegistryImpl> default_registry_;
        std::vector<Registry> registries_;
    };

}
