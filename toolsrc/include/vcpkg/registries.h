#pragma once

#include <vcpkg/base/files.h>
#include <vcpkg/base/json.h>
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
        virtual void update(VcpkgPaths& paths, std::error_code& ec) const = 0;
        virtual fs::path get_registry_root(StringView port_name, const VcpkgPaths& paths) const = 0;

        virtual ~RegistryImpl() = default;
    protected:
        RegistryImpl() = default;
        RegistryImpl(const RegistryImpl&) = default;
        RegistryImpl& operator=(const RegistryImpl&) = default;
        RegistryImpl(RegistryImpl&&) = default;
        RegistryImpl& operator=(RegistryImpl&&) = default;
    };


    struct Registry
    {
        // requires: static_cast<bool>(implementation)
        Registry(std::vector<std::string>&& packages, std::unique_ptr<RegistryImpl>&& implementation);

        Registry(std::vector<std::string>&&, std::nullptr_t) = delete;

        // always ordered lexicographically
        Span<const std::string> packages() const { return packages_; }
        const RegistryImpl& implementation() const { return *implementation_; }
    private:
        std::vector<std::string> packages_;
        std::unique_ptr<RegistryImpl> implementation_;
    };

    struct RegistryImplDeserializer : Json::IDeserializer<std::unique_ptr<RegistryImpl>>
    {
        virtual StringView type_name() const override;

        virtual Optional<std::unique_ptr<RegistryImpl>> visit_object(Json::Reader&, StringView, const Json::Object&) override;
    };

    struct RegistryDeserializer final : Json::IDeserializer<Registry>
    {
        virtual StringView type_name() const override;

        virtual Optional<Registry> visit_object(Json::Reader&, StringView, const Json::Object&) override;
    };
}
