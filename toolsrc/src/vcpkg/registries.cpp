#include <vcpkg/base/json.h>

#include <vcpkg/registries.h>

namespace
{
    struct BuiltinRegistry final : vcpkg::RegistryImpl
    {
        virtual void update(vcpkg::VcpkgPaths&, std::error_code& ec) const override { ec.clear(); }
        virtual fs::path get_registry_root(const vcpkg::VcpkgPaths& paths) const override { return paths.ports; }
    };

    struct DirectoryRegistry final : vcpkg::RegistryImpl
    {
        virtual void update(vcpkg::VcpkgPaths&, std::error_code& ec) const override { ec.clear(); }
        virtual fs::path get_registry_root(const vcpkg::VcpkgPaths& paths) const override
        {
            return vcpkg::Files::combine(paths.manifest_config_root_dir, path);
        }

        DirectoryRegistry(fs::path&& path_) : path(path_) { }

        fs::path path;
    };
}

namespace vcpkg
{
    std::unique_ptr<RegistryImpl> Registry::builtin_registry() { return std::make_unique<BuiltinRegistry>(); }

    Registry::Registry(std::vector<std::string>&& packages, std::unique_ptr<RegistryImpl>&& impl)
        : packages_(std::move(packages)), implementation_(std::move(impl))
    {
        Checks::check_exit(VCPKG_LINE_INFO, implementation_ != nullptr);
    }

    StringView RegistryImplDeserializer::type_name() const { return "a registry"; }

    Span<const StringView> RegistryImplDeserializer::valid_fields() const
    {
        static const StringView t[] = {KIND, PATH};
        return t;
    }

    Optional<std::unique_ptr<RegistryImpl>> RegistryImplDeserializer::visit_null(Json::Reader&, StringView)
    {
        return nullptr;
    }

    Optional<std::unique_ptr<RegistryImpl>> RegistryImplDeserializer::visit_object(Json::Reader& r,
                                                                                   StringView,
                                                                                   const Json::Object& obj)
    {
        std::string kind;
        r.required_object_field(
            type_name(), obj, KIND, kind, Json::StringDeserializer{"a registry implementation kind"});

        if (kind == KIND_BUILTIN)
        {
            if (obj.contains(PATH))
            {
                r.error().add_extra_fields(type_name().to_string(), {PATH});
            }
            return static_cast<std::unique_ptr<RegistryImpl>>(std::make_unique<BuiltinRegistry>());
        }
        else if (kind == KIND_DIRECTORY)
        {
            fs::path path;
            r.required_object_field(type_name(), obj, PATH, path, Json::PathDeserializer{});

            return static_cast<std::unique_ptr<RegistryImpl>>(std::make_unique<DirectoryRegistry>(std::move(path)));
        }
        else
        {
            return nullopt;
        }
    }

    StringView RegistryDeserializer::type_name() const { return "a registry"; }

    Span<const StringView> RegistryDeserializer::valid_fields() const
    {
        static const StringView t[] = {
            RegistryImplDeserializer::KIND,
            RegistryImplDeserializer::PATH,
            PACKAGES,
        };
        return t;
    }

    Optional<Registry> RegistryDeserializer::visit_object(Json::Reader& r, StringView key, const Json::Object& obj)
    {
        auto impl = RegistryImplDeserializer{}.visit_object(r, key, obj);

        if (!impl.has_value())
        {
            return nullopt;
        }

        std::vector<std::string> packages;
        r.required_object_field(
            type_name(),
            obj,
            PACKAGES,
            packages,
            Json::ArrayDeserializer<Json::PackageNameDeserializer>{"an array of registries", Json::AllowEmpty::Yes});

        return Registry{std::move(packages), std::move(impl).value_or_exit(VCPKG_LINE_INFO)};
    }
}
