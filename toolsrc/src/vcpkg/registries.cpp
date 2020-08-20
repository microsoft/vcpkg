#include <vcpkg/registries.h>

namespace
{
    struct BuiltinRegistry final : vcpkg::RegistryImpl
    {
        BuiltinRegistry() = default;
        BuiltinRegistry(const BuiltinRegistry&) = default;
        BuiltinRegistry& operator=(const BuiltinRegistry&) = default;

        virtual void update(vcpkg::VcpkgPaths&, std::error_code& ec) const override { ec.clear(); }
        virtual fs::path get_registry_root(const vcpkg::VcpkgPaths& paths) const override { return paths.ports; }
    };
}

namespace vcpkg
{
    std::unique_ptr<RegistryImpl> Registry::builtin_registry() { return std::make_unique<BuiltinRegistry>(); }

#if 0
    struct RegistryImplDeserializer final : Json::IDeserializer<std::unique_ptr<RegistryImpl>>
    {
        virtual Optional<std::unique_ptr<RegistryImpl>> visit_object(Json::Reader&, StringView, const Json::Object&) override;
    };
#endif

    StringView RegistryImplDeserializer::type_name() const { return "a registry"; }

    Span<const StringView> RegistryImplDeserializer::valid_fields() const
    {
        static const StringView t[] = {KIND, PATH};
        return t;
    }

    static Span<const StringView> builtin_valid_fields()
    {
        static const StringView t[] = {RegistryImplDeserializer::KIND};
        return t;
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
            r.check_for_unexpected_fields(obj, builtin_valid_fields(), type_name());
            return static_cast<std::unique_ptr<RegistryImpl>>(std::make_unique<BuiltinRegistry>());
        }
        else if (kind == KIND_DIRECTORY)
        {
            Checks::exit_with_message(VCPKG_LINE_INFO, "not yet implemented");
        }
        else
        {
            return nullopt;
        }
    }

#if 0
    struct RegistryDeserializer final : Json::IDeserializer<Registry>
    {
        virtual Optional<Registry> visit_object(Json::Reader&, StringView, const Json::Object&) override;
    };
#endif

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
}
