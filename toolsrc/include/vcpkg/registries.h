#pragma once

#include <vcpkg/base/fwd/json.h>

#include <vcpkg/base/files.h>
#include <vcpkg/base/optional.h>

#include <vcpkg/vcpkgpaths.h>

#include <memory>
#include <string>
#include <system_error>
#include <vector>

namespace vcpkg
{
    struct RegistryImpl
    {
        virtual fs::path get_registry_root(const VcpkgPaths& paths) const = 0;

        virtual ~RegistryImpl() = default;
    };

    struct Registry
    {
        // requires: static_cast<bool>(implementation)
        Registry(std::vector<std::string>&& packages, std::unique_ptr<RegistryImpl>&& implementation);

        Registry(std::vector<std::string>&&, std::nullptr_t) = delete;

        // always ordered lexicographically
        Span<const std::string> packages() const { return packages_; }
        const RegistryImpl& implementation() const { return *implementation_; }

        static std::unique_ptr<RegistryImpl> builtin_registry();

    private:
        std::vector<std::string> packages_;
        std::unique_ptr<RegistryImpl> implementation_;
    };

    struct RegistryImplDeserializer : Json::IDeserializer<std::unique_ptr<RegistryImpl>>
    {
        constexpr static StringLiteral KIND = "kind";
        constexpr static StringLiteral PATH = "path";

        constexpr static StringLiteral KIND_BUILTIN = "builtin";
        constexpr static StringLiteral KIND_DIRECTORY = "directory";

        virtual StringView type_name() const override;
        virtual Span<const StringView> valid_fields() const override;

        virtual Optional<std::unique_ptr<RegistryImpl>> visit_null(Json::Reader&) override;
        virtual Optional<std::unique_ptr<RegistryImpl>> visit_object(Json::Reader&, const Json::Object&) override;
    };

    struct RegistryDeserializer final : Json::IDeserializer<Registry>
    {
        constexpr static StringLiteral PACKAGES = "packages";

        virtual StringView type_name() const override;
        virtual Span<const StringView> valid_fields() const override;

        virtual Optional<Registry> visit_object(Json::Reader&, const Json::Object&) override;
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

        Span<const Registry> registries() const { return registries_; }

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
