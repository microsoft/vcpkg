#include <vcpkg/base/json.h>
#include <vcpkg/base/jsonreader.h>

#include <vcpkg/configurationdeserializer.h>
#include <vcpkg/registries.h>
#include <vcpkg/vcpkgpaths.h>
#include <vcpkg/versiont.h>

#include <map>

namespace
{
    using namespace vcpkg;

    struct BuiltinEntry final : RegistryEntry
    {
        fs::path port_directory;

        BuiltinEntry(fs::path&& p) : port_directory(std::move(p)) {}

        fs::path get_baseline_version_port_directory(const VcpkgPaths&) const override
        {
            return port_directory;
        }
    };

    struct BuiltinRegistry final : RegistryImpl
    {
        std::unique_ptr<RegistryEntry> get_port_entry(const VcpkgPaths& paths, StringView port_name) const override
        {
            auto p = paths.ports / fs::u8path(port_name);
            if (paths.get_filesystem().exists(p))
            {
                return std::make_unique<BuiltinEntry>(std::move(p));
            }
            else
            {
                return nullptr;
            }
        }

        void get_all_port_names(std::vector<std::string>& names, const VcpkgPaths& paths) const override
        {
            const auto& fs = paths.get_filesystem();
            auto port_dirs = fs.get_files_non_recursive(paths.ports);
            Util::sort(port_dirs);

            Util::erase_remove_if(port_dirs,
                                [&](auto&& port_dir_entry) { return port_dir_entry.filename() == ".DS_Store"; });

            std::transform(port_dirs.begin(), port_dirs.end(), std::back_inserter(names), [](const fs::path& p) { return fs::u8string(p.filename()); });
        }
    };

    struct FilesystemEntry final : RegistryEntry
    {
        VersionT baseline_version;
        std::map<VersionT, fs::path> versions;

        fs::path get_baseline_version_port_directory(const VcpkgPaths&) const override
        {
            return {};
        }
    };

    struct VersionDeserializer final : Json::IDeserializer<VersionT>
    {
        StringView type_name() const
        {
            return "a version object";
        }

        Optional<VersionT> visit_object(Json::Reader&, const Json::Object&) override
        {
            return nullopt;
        }

        static VersionDeserializer instance;
    };
    VersionDeserializer VersionDeserializer::instance{};

    struct RegistryEntryDeserializer final : Json::IDeserializer<FilesystemEntry>
    {
        StringView type_name() const
        {
            return "a registry entry object";
        }

        Optional<FilesystemEntry> visit_object(Json::Reader& r, const Json::Object& obj) override
        {
            FilesystemEntry res;
            r.required_object_field(type_name(), obj, "baseline-version", res.baseline_version, VersionDeserializer::instance);
            return nullopt;
        }

        static RegistryEntryDeserializer instance;
    };
    RegistryEntryDeserializer RegistryEntryDeserializer::instance{};

    struct FilesystemRegistry final : RegistryImpl
    {
        std::unique_ptr<RegistryEntry> get_port_entry(const VcpkgPaths& paths, StringView port_name) const override
        {
            const auto& fs = paths.get_filesystem();
            auto entry_path = this->path_to_port_entry(port_name);
            if (!fs.exists(entry_path))
            {
                return nullptr;
            }
            std::error_code ec;
            auto json_document = Json::parse_file(fs, entry_path, ec);
            (void)json_document;
            return nullptr;
        }

        void get_all_port_names(std::vector<std::string>& names, const VcpkgPaths& paths) const override
        {
            (void)names;
            (void)paths;
        }

        FilesystemRegistry(fs::path&& path_) : path(path_) { }

    private:
        fs::path path_to_port_entry(StringView port_name) const
        {
            Checks::check_exit(VCPKG_LINE_INFO, port_name.size() != 0);
            fs::path path_to_entry = path;
            path_to_entry /= fs::u8path({port_name.byte_at_index(0), '-'});
            path_to_entry /= fs::u8path(port_name);
            path_to_entry += fs::u8path(".json");

            return path_to_entry;
        }

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
    constexpr StringLiteral RegistryImplDeserializer::KIND_FILESYSTEM;

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
        else if (kind == KIND_FILESYSTEM)
        {
            fs::path path;
            r.required_object_field("a filesystem registry", obj, PATH, path, Json::PathDeserializer::instance);

            return static_cast<std::unique_ptr<RegistryImpl>>(std::make_unique<FilesystemRegistry>(std::move(path)));
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
