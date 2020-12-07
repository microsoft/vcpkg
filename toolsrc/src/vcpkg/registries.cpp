#include <vcpkg/base/delayed_init.h>
#include <vcpkg/base/json.h>
#include <vcpkg/base/jsonreader.h>
#include <vcpkg/base/system.debug.h>

#include <vcpkg/configurationdeserializer.h>
#include <vcpkg/registries.h>
#include <vcpkg/vcpkgcmdarguments.h>
#include <vcpkg/vcpkgpaths.h>
#include <vcpkg/versiondeserializers.h>
#include <vcpkg/versiont.h>

#include <map>

namespace
{
    using namespace vcpkg;

    struct BuiltinEntry final : RegistryEntry
    {
        fs::path port_directory;

        BuiltinEntry(fs::path&& p) : port_directory(std::move(p)) { }

        fs::path get_port_directory(const VcpkgPaths&, const VersionT&) const override { return port_directory; }
    };

    struct BuiltinRegistry final : RegistryImpl
    {
        std::unique_ptr<RegistryEntry> get_port_entry(const VcpkgPaths& paths, StringView port_name) const override
        {
            auto p = paths.builtin_ports_directory() / fs::u8path(port_name);
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
            auto port_dirs = fs.get_files_non_recursive(paths.builtin_ports_directory());
            Util::sort(port_dirs);

            Util::erase_remove_if(port_dirs,
                                  [&](auto&& port_dir_entry) { return port_dir_entry.filename() == ".DS_Store"; });

            std::transform(port_dirs.begin(), port_dirs.end(), std::back_inserter(names), [](const fs::path& p) {
                return fs::u8string(p.filename());
            });
        }

        Optional<VersionT> get_baseline_version(const VcpkgPaths&, StringView) const override { return VersionT{}; }
    };

    struct FilesystemEntry final : RegistryEntry
    {
        std::map<VersionT, fs::path, VersionTMapLess> versions;

        fs::path get_port_directory(const VcpkgPaths&, const VersionT& version) const override
        {
            auto it = versions.find(version);
            if (it != versions.end())
            {
                return it->second;
            }
            return {};
        }
    };

    struct FilesystemVersionEntryDeserializer final : Json::IDeserializer<std::pair<VersionT, fs::path>>
    {
        StringView type_name() const override { return "a version entry object"; }
        View<StringView> valid_fields() const override
        {
            static const StringView t[] = {"version-string", "port-version", "registry-path"};
            return t;
        }

        Optional<std::pair<VersionT, fs::path>> visit_object(Json::Reader& r, const Json::Object& obj) override
        {
            fs::path registry_path;

            auto version = get_versiont_deserializer_instance().visit_object(r, obj);

            r.required_object_field(
                "version entry", obj, "registry-path", registry_path, Json::PathDeserializer::instance);
            // registry_path should look like `/blah/foo`
            if (registry_path.has_root_name() || !registry_path.has_root_directory())
            {
                r.add_generic_error(type_name(), "must be an absolute path without a drive name");
                registry_path.clear();
            }

            return std::pair<VersionT, fs::path>{std::move(version).value_or(VersionT{}), std::move(registry_path)};
        }

        static FilesystemVersionEntryDeserializer instance;
    };
    FilesystemVersionEntryDeserializer FilesystemVersionEntryDeserializer::instance;

    struct FilesystemEntryDeserializer final : Json::IDeserializer<FilesystemEntry>
    {
        StringView type_name() const override { return "a registry entry object"; }

        Optional<FilesystemEntry> visit_array(Json::Reader& r, const Json::Array& arr) override
        {
            FilesystemEntry res;

            std::pair<VersionT, fs::path> buffer;
            for (std::size_t idx = 0; idx < arr.size(); ++idx)
            {
                r.visit_at_index(
                    arr[idx], static_cast<int64_t>(idx), buffer, FilesystemVersionEntryDeserializer::instance);

                auto it = res.versions.lower_bound(buffer.first);
                if (it == res.versions.end() || it->first != buffer.first)
                {
                    buffer.second = registry_root / fs::lexically_normal(buffer.second).relative_path();
                    res.versions.insert(it, std::move(buffer));
                }
                else if (buffer.first != VersionT{})
                {
                    r.add_generic_error(
                        type_name(), "Gave multiple definitions for version: ", buffer.first.to_string());
                }
            }

            return res;
        }

        FilesystemEntryDeserializer(const fs::path& p) : registry_root(p) { }

        const fs::path& registry_root;
    };

    struct FilesystemRegistry final : RegistryImpl
    {
        std::unique_ptr<RegistryEntry> get_port_entry(const VcpkgPaths& paths, StringView port_name) const override
        {
            const auto& fs = paths.get_filesystem();
            auto entry_path = this->path_to_port_entry(paths, port_name);
            if (!fs.exists(entry_path))
            {
                Debug::print(
                    "Failed to find entry for port `", port_name, "` in file: ", fs::u8string(entry_path), "\n");
                return nullptr;
            }
            std::error_code ec;
            auto json_document = Json::parse_file(fs, entry_path, ec);

            if (auto p = json_document.get())
            {
                Json::Reader r;
                auto real_path = paths.config_root_dir / path;
                FilesystemEntryDeserializer deserializer{real_path};
                auto entry = r.visit(p->first, deserializer);
                auto pentry = entry.get();
                if (pentry && r.errors().empty())
                {
                    return std::make_unique<FilesystemEntry>(std::move(*pentry));
                }
                else
                {
                    vcpkg::Checks::exit_with_message(VCPKG_LINE_INFO,
                                                     "Failed to parse the port entry for port `%s` at `%s`.\n%s",
                                                     port_name,
                                                     fs::u8string(entry_path),
                                                     Strings::join("\n", r.errors()));
                }
            }
            else
            {
                Debug::print("Failed to parse json document: ", json_document.error()->format(), "\n");
            }

            return nullptr;
        }

        void get_all_port_names(std::vector<std::string>& port_names, const VcpkgPaths& paths) const override
        {
            std::error_code ec;
            for (const auto& super_dir : fs::directory_iterator(path))
            {
                if (!fs::is_directory(paths.get_filesystem().status(super_dir, ec)))
                {
                    continue;
                }

                auto super_dir_filename = fs::u8string(super_dir.path().filename());
                if (!Strings::ends_with(super_dir_filename, "-"))
                {
                    continue;
                }

                super_dir_filename.pop_back();
                for (const auto& database_entry : fs::directory_iterator(super_dir))
                {
                    auto database_entry_filename = database_entry.path().filename();
                    auto database_entry_filename_str = fs::u8string(database_entry_filename);

                    if (!Strings::starts_with(database_entry_filename_str, super_dir_filename) ||
                        !Strings::ends_with(database_entry_filename_str, ".json"))
                    {
                        Debug::print("Unexpected file in database (this is not an error): ",
                                     fs::u8string(database_entry.path()),
                                     "\n");
                        continue;
                    }

                    port_names.push_back(fs::u8string(database_entry_filename.replace_extension()));
                }
            }
        }

        Optional<VersionT> get_baseline_version(const VcpkgPaths& paths, StringView port_name) const override
        {
            if (!paths.get_feature_flags().versions)
            {
                Checks::check_exit(VCPKG_LINE_INFO,
                                   "This invocation failed because the `versions` feature flag is not enabled.");
            }

            const auto& baseline_cache = baseline.get([this, &paths] { return load_baseline_versions(paths); });
            auto it = baseline_cache.find(port_name);
            if (it != baseline_cache.end())
            {
                return it->second;
            }
            else
            {
                return nullopt;
            }
        }

        FilesystemRegistry(fs::path&& path_) : path(path_) { }

    private:
        fs::path path_to_registry_database(const VcpkgPaths& paths) const
        {
            fs::path path_to_db = paths.config_root_dir / path;
            path_to_db /= fs::u8path({'\xF0', '\x9F', '\x98', '\x87'}); // utf-8 for 😇
            return path_to_db;
        }

        fs::path path_to_port_entry(const VcpkgPaths& paths, StringView port_name) const
        {
            Checks::check_exit(VCPKG_LINE_INFO, port_name.size() != 0);
            fs::path path_to_entry = path_to_registry_database(paths);
            path_to_entry /= fs::u8path({port_name.byte_at_index(0), '-'});
            path_to_entry /= fs::u8path(port_name);
            path_to_entry += fs::u8path(".json");

            return path_to_entry;
        }

        std::map<std::string, VersionT, std::less<>> load_baseline_versions(const VcpkgPaths& paths) const
        {
            auto baseline_file = path_to_registry_database(paths) / fs::u8path("baseline.json");

            auto value = Json::parse_file(VCPKG_LINE_INFO, paths.get_filesystem(), baseline_file);
            if (!value.first.is_object())
            {
                Checks::exit_with_message(VCPKG_LINE_INFO, "Error: `baseline.json` does not have a top-level object.");
            }

            auto maybe_baseline_versions = parse_baseline_file(paths.get_filesystem(), "default", baseline_file);
            if (auto baseline_versions = maybe_baseline_versions.get())
            {
                return std::move(*baseline_versions);
            }
            else
            {
                Checks::exit_with_message(VCPKG_LINE_INFO,
                                          "Error: failed to parse `%s`:\n%s",
                                          fs::u8string(baseline_file),
                                          maybe_baseline_versions.error());
            }
        }

        fs::path path;
        DelayedInit<std::map<std::string, VersionT, std::less<>>> baseline;
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

    RegistryImplDeserializer RegistryImplDeserializer::instance;

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
        auto impl = RegistryImplDeserializer::instance.visit_object(r, obj);

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
