#include <vcpkg/base/json.h>
#include <vcpkg/base/system.debug.h>

#include <vcpkg/configuration.h>
#include <vcpkg/paragraphs.h>
#include <vcpkg/portfileprovider.h>
#include <vcpkg/registries.h>
#include <vcpkg/sourceparagraph.h>
#include <vcpkg/vcpkgcmdarguments.h>
#include <vcpkg/vcpkgpaths.h>
#include <vcpkg/versiondeserializers.h>

#include <regex>

using namespace vcpkg;
using namespace Versions;

namespace
{
    using namespace vcpkg;

    struct OverlayRegistryEntry final : RegistryEntry
    {
        OverlayRegistryEntry(fs::path&& p, VersionT&& v) : path(p), version(v) { }

        View<VersionT> get_port_versions() const override { return {&version, 1}; }
        ExpectedS<fs::path> get_path_to_version(const VcpkgPaths&, const VersionT& v) const override
        {
            if (v == version)
            {
                return path;
            }
            return Strings::format("Version %s not found; only %s is available.", v.to_string(), version.to_string());
        }

        fs::path path;
        VersionT version;
    };
}

namespace vcpkg::PortFileProvider
{
    MapPortFileProvider::MapPortFileProvider(const std::unordered_map<std::string, SourceControlFileLocation>& map)
        : ports(map)
    {
    }

    ExpectedS<const SourceControlFileLocation&> MapPortFileProvider::get_control_file(const std::string& spec) const
    {
        auto scf = ports.find(spec);
        if (scf == ports.end()) return std::string("does not exist in map");
        return scf->second;
    }

    std::vector<const SourceControlFileLocation*> MapPortFileProvider::load_all_control_files() const
    {
        return Util::fmap(ports, [](auto&& kvpair) -> const SourceControlFileLocation* { return &kvpair.second; });
    }

    PathsPortFileProvider::PathsPortFileProvider(const VcpkgPaths& paths_,
                                                 const std::vector<std::string>& overlay_ports_)
        : paths(paths_)
    {
        auto& fs = paths.get_filesystem();
        for (auto&& overlay_path : overlay_ports_)
        {
            if (!overlay_path.empty())
            {
                auto overlay = fs::u8path(overlay_path);
                if (overlay.is_absolute())
                {
                    overlay = fs.canonical(VCPKG_LINE_INFO, overlay);
                }
                else
                {
                    overlay = fs.canonical(VCPKG_LINE_INFO, paths.original_cwd / overlay);
                }

                Debug::print("Using overlay: ", fs::u8string(overlay), "\n");

                Checks::check_exit(
                    VCPKG_LINE_INFO, fs.exists(overlay), "Error: Path \"%s\" does not exist", fs::u8string(overlay));

                Checks::check_exit(VCPKG_LINE_INFO,
                                   fs::is_directory(fs.status(VCPKG_LINE_INFO, overlay)),
                                   "Error: Path \"%s\" must be a directory",
                                   overlay.string());

                overlay_ports.emplace_back(overlay);
            }
        }
    }

    static Optional<std::unique_ptr<SourceControlFileLocation>> try_load_overlay_port(const Files::Filesystem& fs,
                                                                                      View<fs::path> overlay_ports,
                                                                                      const std::string& spec)
    {
        for (auto&& ports_dir : overlay_ports)
        {
            // Try loading individual port
            if (Paragraphs::is_port_directory(fs, ports_dir))
            {
                auto maybe_scf = Paragraphs::try_load_port(fs, ports_dir);
                if (auto scfp = maybe_scf.get())
                {
                    auto& scf = *scfp;
                    if (scf->core_paragraph->name == spec)
                    {
                        return std::make_unique<SourceControlFileLocation>(std::move(scf), fs::path(ports_dir));
                    }
                }
                else
                {
                    print_error_message(maybe_scf.error());
                    Checks::exit_with_message(
                        VCPKG_LINE_INFO, "Error: Failed to load port %s from %s", spec, fs::u8string(ports_dir));
                }

                continue;
            }

            auto ports_spec = ports_dir / fs::u8path(spec);
            if (Paragraphs::is_port_directory(fs, ports_spec))
            {
                auto found_scf = Paragraphs::try_load_port(fs, ports_spec);
                if (auto scfp = found_scf.get())
                {
                    auto& scf = *scfp;
                    if (scf->core_paragraph->name == spec)
                    {
                        return std::make_unique<SourceControlFileLocation>(std::move(scf), std::move(ports_spec));
                    }
                    Checks::exit_with_message(VCPKG_LINE_INFO,
                                              "Error: Failed to load port from %s: names did not match: '%s' != '%s'",
                                              fs::u8string(ports_spec),
                                              spec,
                                              scf->core_paragraph->name);
                }
                else
                {
                    print_error_message(found_scf.error());
                    Checks::exit_with_message(
                        VCPKG_LINE_INFO, "Error: Failed to load port %s from %s", spec, fs::u8string(ports_dir));
                }
            }
        }
        return nullopt;
    }

    static std::pair<std::unique_ptr<RegistryEntry>, Optional<VersionT>> try_load_registry_port_and_baseline(
        const VcpkgPaths& paths, const std::string& spec)
    {
        if (auto registry = paths.get_configuration().registry_set.registry_for_port(spec))
        {
            auto entry = registry->get_port_entry(paths, spec);
            auto maybe_baseline = registry->get_baseline_version(paths, spec);
            if (entry)
            {
                if (!maybe_baseline)
                {
                    if (entry->get_port_versions().size() == 1)
                    {
                        maybe_baseline = entry->get_port_versions()[0];
                    }
                }
                return {std::move(entry), std::move(maybe_baseline)};
            }
            else
            {
                Debug::print("Failed to find port `", spec, "` in registry: no entry found.\n");
            }
        }
        else
        {
            Debug::print("Failed to find registry for port: `", spec, "`.\n");
        }

        return {nullptr, nullopt};
    }

    ExpectedS<const SourceControlFileLocation&> PathsPortFileProvider::get_control_file(const std::string& spec) const
    {
        auto cache_it = cache.find(spec);
        if (cache_it == cache.end())
        {
            const auto& fs = paths.get_filesystem();

            auto maybe_overlay_port = try_load_overlay_port(fs, overlay_ports, spec);
            if (auto overlay_port = maybe_overlay_port.get())
            {
                cache_it = cache.emplace(spec, std::move(**overlay_port)).first;
            }
            else
            {
                auto entry_and_baseline = try_load_registry_port_and_baseline(paths, spec);
                auto& entry = entry_and_baseline.first;
                if (!entry)
                {
                    return Strings::concat("Error: could not find definition for port ", spec);
                }
                if (!entry_and_baseline.second.has_value())
                {
                    return Strings::concat("Error: no baseline version available for port ", spec);
                }
                const auto& version = *entry_and_baseline.second.get();

                auto maybe_port_path = entry->get_path_to_version(paths, version);
                if (!maybe_port_path.has_value())
                {
                    return std::move(maybe_port_path.error());
                }
                const auto& port_path = *maybe_port_path.get();

                auto maybe_scfl = Paragraphs::try_load_port(fs, port_path);
                if (auto p = maybe_scfl.get())
                {
                    auto maybe_error = (*p)->check_against_feature_flags(port_path, paths.get_feature_flags());
                    if (maybe_error) return std::move(*maybe_error.get());

                    cache_it =
                        cache.emplace(spec, SourceControlFileLocation{std::move(*p), std::move(port_path)}).first;
                }
                else
                {
                    return Strings::format("Error: when loading port `%s` from directory `%s`:\n%s\n",
                                           spec,
                                           fs::u8string(port_path),
                                           maybe_scfl.error()->error);
                }
            }
        }

        Checks::check_exit(VCPKG_LINE_INFO, cache_it != cache.end());
        return cache_it->second;
    }

    std::vector<const SourceControlFileLocation*> PathsPortFileProvider::load_all_control_files() const
    {
        // Reload cache with ports contained in all ports_dirs
        cache.clear();
        std::vector<const SourceControlFileLocation*> ret;

        for (const fs::path& ports_dir : overlay_ports)
        {
            // Try loading individual port
            if (Paragraphs::is_port_directory(paths.get_filesystem(), ports_dir))
            {
                auto maybe_scf = Paragraphs::try_load_port(paths.get_filesystem(), ports_dir);
                if (auto scf = maybe_scf.get())
                {
                    auto port_name = scf->get()->core_paragraph->name;
                    if (cache.find(port_name) == cache.end())
                    {
                        auto scfl = SourceControlFileLocation{std::move(*scf), ports_dir};
                        auto it = cache.emplace(std::move(port_name), std::move(scfl));
                        ret.emplace_back(&it.first->second);
                    }
                }
                else
                {
                    print_error_message(maybe_scf.error());
                    Checks::exit_with_message(
                        VCPKG_LINE_INFO, "Error: Failed to load port from %s", fs::u8string(ports_dir));
                }
                continue;
            }

            // Try loading all ports inside ports_dir
            auto found_scfls = Paragraphs::load_overlay_ports(paths, ports_dir);
            for (auto&& scfl : found_scfls)
            {
                auto port_name = scfl.source_control_file->core_paragraph->name;
                if (cache.find(port_name) == cache.end())
                {
                    auto it = cache.emplace(std::move(port_name), std::move(scfl));
                    ret.emplace_back(&it.first->second);
                }
            }
        }

        auto all_ports = Paragraphs::load_all_registry_ports(paths);
        for (auto&& scfl : all_ports)
        {
            auto port_name = scfl.source_control_file->core_paragraph->name;
            if (cache.find(port_name) == cache.end())
            {
                auto it = cache.emplace(port_name, std::move(scfl));
                ret.emplace_back(&it.first->second);
            }
        }

        return ret;
    }

    namespace
    {
        struct BaselineProviderImpl : IBaselineProvider, Util::ResourceBase
        {
            BaselineProviderImpl(const VcpkgPaths& paths_) : paths(paths_) { }

            virtual Optional<VersionT> get_baseline_version(StringView port_name) const override
            {
                auto it = m_baseline_cache.find(port_name);
                if (it != m_baseline_cache.end())
                {
                    return it->second;
                }
                else
                {
                    auto version = paths.get_configuration().registry_set.baseline_for_port(paths, port_name);
                    m_baseline_cache.emplace(port_name.to_string(), version);
                    return version;
                }
            }

        private:
            const VcpkgPaths& paths; // TODO: remove this data member
            mutable std::map<std::string, Optional<VersionT>, std::less<>> m_baseline_cache;
        };

        struct VersionedPortfileProviderImpl : IVersionedPortfileProvider, Util::ResourceBase
        {
            VersionedPortfileProviderImpl(const VcpkgPaths& paths_) : paths(paths_) { }

            const ExpectedS<std::unique_ptr<RegistryEntry>>& entry(StringView name) const
            {
                auto entry_it = m_entry_cache.find(name);
                if (entry_it == m_entry_cache.end())
                {
                    if (auto reg = paths.get_configuration().registry_set.registry_for_port(name))
                    {
                        if (auto entry = reg->get_port_entry(paths, name))
                        {
                            entry_it = m_entry_cache.emplace(name.to_string(), std::move(entry)).first;
                        }
                        else
                        {
                            entry_it =
                                m_entry_cache
                                    .emplace(name.to_string(),
                                             Strings::concat("Error: Could not find a definition for port ", name))
                                    .first;
                        }
                    }
                    else
                    {
                        entry_it = m_entry_cache
                                       .emplace(name.to_string(),
                                                Strings::concat("Error: no registry configured for port ", name))
                                       .first;
                    }
                }
                return entry_it->second;
            }

            virtual View<VersionT> get_port_versions(StringView port_name) const override
            {
                return entry(port_name).value_or_exit(VCPKG_LINE_INFO)->get_port_versions();
            }

            ExpectedS<const SourceControlFileLocation&> get_control_file(const VersionSpec& version_spec) const override
            {
                auto it = m_control_cache.find(version_spec);
                if (it == m_control_cache.end())
                {
                    const auto& maybe_ent = entry(version_spec.port_name);
                    if (auto ent = maybe_ent.get())
                    {
                        auto maybe_path = ent->get()->get_path_to_version(paths, version_spec.version);
                        if (auto path = maybe_path.get())
                        {
                            auto maybe_control_file = Paragraphs::try_load_port(paths.get_filesystem(), *path);
                            if (auto scf = maybe_control_file.get())
                            {
                                if (scf->get()->core_paragraph->name == version_spec.port_name)
                                {
                                    it = m_control_cache
                                             .emplace(version_spec,
                                                      std::make_unique<SourceControlFileLocation>(std::move(*scf),
                                                                                                  std::move(*path)))
                                             .first;
                                }
                                it =
                                    m_control_cache
                                        .emplace(
                                            version_spec,
                                            Strings::format(
                                                "Error: Failed to load port from %s: names did not match: '%s' != '%s'",
                                                fs::u8string(*path),
                                                version_spec.port_name,
                                                scf->get()->core_paragraph->name))
                                        .first;
                            }
                            // This should change to a soft error when ParseExpected is eliminated.
                            print_error_message(maybe_control_file.error());
                            Checks::exit_with_message(VCPKG_LINE_INFO,
                                                      "Error: Failed to load port %s from %s",
                                                      version_spec.port_name,
                                                      fs::u8string(*path));
                        }
                        else
                        {
                            it = m_control_cache.emplace(version_spec, maybe_path.error()).first;
                        }
                    }
                    else
                    {
                        it = m_control_cache.emplace(version_spec, maybe_ent.error()).first;
                    }
                }
                return it->second.map([](const auto& x) -> const SourceControlFileLocation& { return *x.get(); });
            }

        private:
            const VcpkgPaths& paths; // TODO: remove this data member
            mutable std::
                unordered_map<VersionSpec, ExpectedS<std::unique_ptr<SourceControlFileLocation>>, VersionSpecHasher>
                    m_control_cache;
            mutable std::map<std::string, ExpectedS<std::unique_ptr<RegistryEntry>>, std::less<>> m_entry_cache;
        };

        struct OverlayProviderImpl : IOverlayProvider, Util::ResourceBase
        {
            OverlayProviderImpl(const VcpkgPaths& paths, View<std::string> overlay_ports)
                : paths(paths), m_overlay_ports(Util::fmap(overlay_ports, [&paths](const std::string& s) -> fs::path {
                    return Files::combine(paths.original_cwd, fs::u8path(s));
                }))
            {
            }

            virtual Optional<const SourceControlFileLocation&> get_control_file(StringView port_name) const override
            {
                auto it = m_overlay_cache.find(port_name);
                if (it == m_overlay_cache.end())
                {
                    auto s_port_name = port_name.to_string();
                    auto maybe_overlay = try_load_overlay_port(paths.get_filesystem(), m_overlay_ports, s_port_name);
                    if (auto overlay = maybe_overlay.get())
                    {
                        it = m_overlay_cache.emplace(std::move(s_port_name), std::move(**overlay)).first;
                    }
                    else
                    {
                        it = m_overlay_cache.emplace(std::move(s_port_name), nullopt).first;
                    }
                }
                return it->second;
            }

        private:
            const VcpkgPaths& paths;
            const std::vector<fs::path> m_overlay_ports;
            mutable std::map<std::string, Optional<SourceControlFileLocation>, std::less<>> m_overlay_cache;
        };
    }

    std::unique_ptr<IBaselineProvider> make_baseline_provider(const vcpkg::VcpkgPaths& paths)
    {
        return std::make_unique<BaselineProviderImpl>(paths);
    }

    std::unique_ptr<IVersionedPortfileProvider> make_versioned_portfile_provider(const vcpkg::VcpkgPaths& paths)
    {
        return std::make_unique<VersionedPortfileProviderImpl>(paths);
    }

    std::unique_ptr<IOverlayProvider> make_overlay_provider(const vcpkg::VcpkgPaths& paths,
                                                            View<std::string> overlay_ports)
    {
        return std::make_unique<OverlayProviderImpl>(paths, std::move(overlay_ports));
    }
}
