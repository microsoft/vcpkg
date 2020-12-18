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

    static std::unique_ptr<OverlayRegistryEntry> try_load_overlay_port(const Files::Filesystem& fs,
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
                        return std::make_unique<OverlayRegistryEntry>(fs::path(ports_dir), scf->to_versiont());
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
                        return std::make_unique<OverlayRegistryEntry>(std::move(ports_spec), scf->to_versiont());
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
        return nullptr;
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

            std::unique_ptr<RegistryEntry> port;
            VersionT port_version;

            auto maybe_overlay_port = try_load_overlay_port(fs, overlay_ports, spec);
            if (maybe_overlay_port)
            {
                port_version = maybe_overlay_port->version;
                port = std::move(maybe_overlay_port);
            }
            else
            {
                auto maybe_registry_port = try_load_registry_port_and_baseline(paths, spec);
                port = std::move(maybe_registry_port.first);
                if (auto version = maybe_registry_port.second.get())
                {
                    port_version = std::move(*version);
                }
                else if (port)
                {
                    return std::string("No baseline version available.");
                }
            }

            if (port)
            {
                auto port_path = port->get_path_to_version(paths, port_version).value_or_exit(VCPKG_LINE_INFO);
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

        if (cache_it == cache.end())
        {
            return std::string("Port definition not found");
        }
        else
        {
            return cache_it->second;
        }
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

            virtual View<VersionT> get_port_versions(StringView port_name) const override
            {
                auto entry_it = m_entry_cache.find(port_name.to_string());
                if (entry_it != m_entry_cache.end())
                {
                    return entry_it->second->get_port_versions();
                }

                auto entry = try_load_registry_port_and_baseline(paths, port_name.to_string());
                if (!entry.first)
                {
                    Checks::exit_with_message(
                        VCPKG_LINE_INFO, "Error: Could not find a definition for port %s", port_name);
                }
                auto it = m_entry_cache.emplace(port_name.to_string(), std::move(entry.first));
                return it.first->second->get_port_versions();
            }

            ExpectedS<const SourceControlFileLocation&> get_control_file(const VersionSpec& version_spec) const override
            {
                auto cache_it = m_control_cache.find(version_spec);
                if (cache_it != m_control_cache.end())
                {
                    return cache_it->second;
                }

                auto entry_it = m_entry_cache.find(version_spec.port_name);
                if (entry_it == m_entry_cache.end())
                {
                    auto reg_for_port =
                        paths.get_configuration().registry_set.registry_for_port(version_spec.port_name);

                    if (!reg_for_port)
                    {
                        return Strings::format("Error: no registry set up for port %s", version_spec.port_name);
                    }

                    auto entry = reg_for_port->get_port_entry(paths, version_spec.port_name);
                    entry_it = m_entry_cache.emplace(version_spec.port_name, std::move(entry)).first;
                }

                auto maybe_path = entry_it->second->get_path_to_version(paths, version_spec.version);
                if (!maybe_path.has_value())
                {
                    return std::move(maybe_path).error();
                }
                auto& port_directory = *maybe_path.get();

                auto maybe_control_file = Paragraphs::try_load_port(paths.get_filesystem(), port_directory);
                if (auto scf = maybe_control_file.get())
                {
                    if (scf->get()->core_paragraph->name == version_spec.port_name)
                    {
                        return m_control_cache
                            .emplace(version_spec,
                                     SourceControlFileLocation{std::move(*scf), std::move(port_directory)})
                            .first->second;
                    }
                    return Strings::format("Error: Failed to load port from %s: names did not match: '%s' != '%s'",
                                           fs::u8string(port_directory),
                                           version_spec.port_name,
                                           scf->get()->core_paragraph->name);
                }

                print_error_message(maybe_control_file.error());
                return Strings::format(
                    "Error: Failed to load port %s from %s", version_spec.port_name, fs::u8string(port_directory));
            }

        private:
            const VcpkgPaths& paths; // TODO: remove this data member
            mutable std::unordered_map<VersionSpec, SourceControlFileLocation, VersionSpecHasher> m_control_cache;
            mutable std::map<std::string, std::unique_ptr<RegistryEntry>, std::less<>> m_entry_cache;
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
}
