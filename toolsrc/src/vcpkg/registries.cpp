#include <vcpkg/base/json.h>
#include <vcpkg/base/jsonreader.h>

#include <vcpkg/configurationdeserializer.h>
#include <vcpkg/registries.h>
#include <vcpkg/vcpkgpaths.h>

namespace
{
    struct BuiltinRegistry final : vcpkg::RegistryImpl
    {
        virtual fs::path get_registry_root(const vcpkg::VcpkgPaths& paths) const override { return paths.ports; }
    };

    struct DirectoryRegistry final : vcpkg::RegistryImpl
    {
        virtual fs::path get_registry_root(const vcpkg::VcpkgPaths& paths) const override
        {
            return vcpkg::Files::combine(paths.config_root_dir, path);
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

    constexpr StringLiteral RegistryImplDeserializer::KIND;
    constexpr StringLiteral RegistryImplDeserializer::PATH;
    constexpr StringLiteral RegistryImplDeserializer::KIND_BUILTIN;
    constexpr StringLiteral RegistryImplDeserializer::KIND_DIRECTORY;

    View<StringView> RegistryImplDeserializer::valid_fields() const
    {
        static const StringView t[] = {KIND, PATH};
        return t;
    }

    Optional<std::unique_ptr<RegistryImpl>> RegistryImplDeserializer::visit_null(Json::Reader&) { return nullptr; }

    Optional<std::unique_ptr<RegistryImpl>> RegistryImplDeserializer::visit_object(Json::Reader& r,
                                                                                   const Json::Object& obj)
    {
        static Json::StringDeserializer kind_deserializer{"a registry implementation kind"};
        std::string kind;
        r.required_object_field(type_name(), obj, KIND, kind, kind_deserializer);

        if (kind == KIND_BUILTIN)
        {
            if (obj.contains(PATH))
            {
                r.add_extra_field_error("a builtin registry", PATH);
            }
            return static_cast<std::unique_ptr<RegistryImpl>>(std::make_unique<BuiltinRegistry>());
        }
        else if (kind == KIND_DIRECTORY)
        {
            fs::path path;
            r.required_object_field("a directory registry", obj, PATH, path, Json::PathDeserializer::instance);

            return static_cast<std::unique_ptr<RegistryImpl>>(std::make_unique<DirectoryRegistry>(std::move(path)));
        }
        else
        {
            return nullopt;
        }
    }
    RegistryImplDeserializer RegistryImplDeserializer::instance;

    StringView RegistryDeserializer::type_name() const { return "a registry"; }

    constexpr StringLiteral RegistryDeserializer::PACKAGES;

    View<StringView> RegistryDeserializer::valid_fields() const
    {
        static const StringView t[] = {
            RegistryImplDeserializer::KIND,
            RegistryImplDeserializer::PATH,
            PACKAGES,
        };
        return t;
    }

    Optional<Registry> RegistryDeserializer::visit_object(Json::Reader& r, const Json::Object& obj)
    {
        auto impl = RegistryImplDeserializer{}.visit_object(r, obj);

        if (!impl.has_value())
        {
            return nullopt;
        }

        static Json::ArrayDeserializer<Json::PackageNameDeserializer> package_names_deserializer{
            "an array of package names"};

        std::vector<std::string> packages;
        r.required_object_field(type_name(), obj, PACKAGES, packages, package_names_deserializer);

        return Registry{std::move(packages), std::move(impl).value_or_exit(VCPKG_LINE_INFO)};
    }

    RegistrySet::RegistrySet() : default_registry_(Registry::builtin_registry()), registries_() { }

    const RegistryImpl* RegistrySet::registry_for_port(StringView name) const
    {
        for (const auto& registry : registries())
        {
            const auto& packages = registry.packages();
            if (std::find(packages.begin(), packages.end(), name) != packages.end())
            {
                return &registry.implementation();
            }
        }
        return default_registry();
    }

    void RegistrySet::add_registry(Registry&& r) { registries_.push_back(std::move(r)); }

    void RegistrySet::set_default_registry(std::unique_ptr<RegistryImpl>&& r) { default_registry_ = std::move(r); }
    void RegistrySet::set_default_registry(std::nullptr_t) { default_registry_.reset(); }
}
