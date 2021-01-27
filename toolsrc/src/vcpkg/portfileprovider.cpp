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

    PathsPortFileProvider::PathsPortFileProvider(const VcpkgPaths& paths, const std::vector<std::string>& overlay_ports)
        : m_baseline(make_baseline_provider(paths))
        , m_versioned(make_versioned_portfile_provider(paths))
        , m_overlay(make_overlay_provider(paths, overlay_ports))
    {
    }

    ExpectedS<const SourceControlFileLocation&> PathsPortFileProvider::get_control_file(const std::string& spec) const
    {
        auto maybe_scfl = m_overlay->get_control_file(spec);
        if (auto scfl = maybe_scfl.get())
        {
            return *scfl;
        }
        auto maybe_baseline = m_baseline->get_baseline_version(spec);
        if (auto baseline = maybe_baseline.get())
        {
            return m_versioned->get_control_file({spec, *baseline});
        }
        else
        {
            return Strings::concat("Error: unable to get baseline for port ", spec);
        }
    }

    std::vector<const SourceControlFileLocation*> PathsPortFileProvider::load_all_control_files() const
    {
        std::map<std::string, const SourceControlFileLocation*> m;
        m_overlay->load_all_control_files(m);
        m_versioned->load_all_control_files(m);
        return Util::fmap(m, [](const auto& p) { return p.second; });
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

            ExpectedS<std::unique_ptr<SourceControlFileLocation>> load_control_file(
                const VersionSpec& version_spec) const
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
                                return std::make_unique<SourceControlFileLocation>(std::move(*scf), std::move(*path));
                            }
                            else
                            {
                                return Strings::format("Error: Failed to load port from %s: names did "
                                                       "not match: '%s' != '%s'",
                                                       fs::u8string(*path),
                                                       version_spec.port_name,
                                                       scf->get()->core_paragraph->name);
                            }
                        }
                        else
                        {
                            // This should change to a soft error when ParseExpected is eliminated.
                            print_error_message(maybe_control_file.error());
                            Checks::exit_maybe_upgrade(VCPKG_LINE_INFO,
                                                       "Error: Failed to load port %s from %s",
                                                       version_spec.port_name,
                                                       fs::u8string(*path));
                        }
                    }
                    else
                    {
                        return maybe_path.error();
                    }
                }
                return maybe_ent.error();
            }

            virtual ExpectedS<const SourceControlFileLocation&> get_control_file(
                const VersionSpec& version_spec) const override
            {
                auto it = m_control_cache.find(version_spec);
                if (it == m_control_cache.end())
                {
                    it = m_control_cache.emplace(version_spec, load_control_file(version_spec)).first;
                }
                return it->second.map([](const auto& x) -> const SourceControlFileLocation& { return *x.get(); });
            }

            virtual void load_all_control_files(
                std::map<std::string, const SourceControlFileLocation*>& out) const override
            {
                auto all_ports = Paragraphs::load_all_registry_ports(paths);
                for (auto&& scfl : all_ports)
                {
                    auto port_name = scfl.source_control_file->core_paragraph->name;
                    auto version = scfl.source_control_file->core_paragraph->to_versiont();
                    auto it = m_control_cache
                                  .emplace(VersionSpec{std::move(port_name), std::move(version)},
                                           std::make_unique<SourceControlFileLocation>(std::move(scfl)))
                                  .first;
                    Checks::check_exit(VCPKG_LINE_INFO, it->second.has_value());
                    out.emplace(it->first.port_name, it->second.get()->get());
                }
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
                : m_fs(paths.get_filesystem())
                , m_overlay_ports(Util::fmap(overlay_ports, [&paths](const std::string& s) -> fs::path {
                    return Files::combine(paths.original_cwd, fs::u8path(s));
                }))
            {
                for (auto&& overlay : m_overlay_ports)
                {
                    auto s_overlay = fs::u8string(overlay);
                    Debug::print("Using overlay: ", s_overlay, "\n");

                    Checks::check_exit(VCPKG_LINE_INFO,
                                       fs::is_directory(m_fs.status(VCPKG_LINE_INFO, overlay)),
                                       "Error: Overlay path \"%s\" must exist and must be a directory",
                                       s_overlay);
                }
            }

            Optional<SourceControlFileLocation> load_port(StringView port_name) const
            {
                auto s_port_name = port_name.to_string();

                for (auto&& ports_dir : m_overlay_ports)
                {
                    // Try loading individual port
                    if (Paragraphs::is_port_directory(m_fs, ports_dir))
                    {
                        auto maybe_scf = Paragraphs::try_load_port(m_fs, ports_dir);
                        if (auto scfp = maybe_scf.get())
                        {
                            auto& scf = *scfp;
                            if (scf->core_paragraph->name == port_name)
                            {
                                return SourceControlFileLocation{std::move(scf), fs::path(ports_dir)};
                            }
                        }
                        else
                        {
                            print_error_message(maybe_scf.error());
                            Checks::exit_maybe_upgrade(VCPKG_LINE_INFO,
                                                       "Error: Failed to load port %s from %s",
                                                       port_name,
                                                       fs::u8string(ports_dir));
                        }

                        continue;
                    }

                    auto ports_spec = ports_dir / fs::u8path(port_name);
                    if (Paragraphs::is_port_directory(m_fs, ports_spec))
                    {
                        auto found_scf = Paragraphs::try_load_port(m_fs, ports_spec);
                        if (auto scfp = found_scf.get())
                        {
                            auto& scf = *scfp;
                            if (scf->core_paragraph->name == port_name)
                            {
                                return SourceControlFileLocation{std::move(scf), std::move(ports_spec)};
                            }
                            Checks::exit_maybe_upgrade(
                                VCPKG_LINE_INFO,
                                "Error: Failed to load port from %s: names did not match: '%s' != '%s'",
                                fs::u8string(ports_spec),
                                port_name,
                                scf->core_paragraph->name);
                        }
                        else
                        {
                            print_error_message(found_scf.error());
                            Checks::exit_maybe_upgrade(VCPKG_LINE_INFO,
                                                       "Error: Failed to load port %s from %s",
                                                       port_name,
                                                       fs::u8string(ports_dir));
                        }
                    }
                }
                return nullopt;
            }

            virtual Optional<const SourceControlFileLocation&> get_control_file(StringView port_name) const override
            {
                auto it = m_overlay_cache.find(port_name);
                if (it == m_overlay_cache.end())
                {
                    it = m_overlay_cache.emplace(port_name.to_string(), load_port(port_name)).first;
                }
                return it->second;
            }

            virtual void load_all_control_files(
                std::map<std::string, const SourceControlFileLocation*>& out) const override
            {
                for (auto&& ports_dir : m_overlay_ports)
                {
                    // Try loading individual port
                    if (Paragraphs::is_port_directory(m_fs, ports_dir))
                    {
                        auto maybe_scf = Paragraphs::try_load_port(m_fs, ports_dir);
                        if (auto scfp = maybe_scf.get())
                        {
                            SourceControlFileLocation scfl{std::move(*scfp), fs::path(ports_dir)};
                            auto name = scfl.source_control_file->core_paragraph->name;
                            auto it = m_overlay_cache.emplace(std::move(name), std::move(scfl)).first;
                            Checks::check_exit(VCPKG_LINE_INFO, it->second.get());
                            out.emplace(it->first, it->second.get());
                        }
                        else
                        {
                            print_error_message(maybe_scf.error());
                            Checks::exit_maybe_upgrade(
                                VCPKG_LINE_INFO, "Error: Failed to load port from %s", fs::u8string(ports_dir));
                        }

                        continue;
                    }

                    // Try loading all ports inside ports_dir
                    auto found_scfls = Paragraphs::load_overlay_ports(m_fs, ports_dir);
                    for (auto&& scfl : found_scfls)
                    {
                        auto name = scfl.source_control_file->core_paragraph->name;
                        auto it = m_overlay_cache.emplace(std::move(name), std::move(scfl)).first;
                        Checks::check_exit(VCPKG_LINE_INFO, it->second.get());
                        out.emplace(it->first, it->second.get());
                    }
                }
            }

        private:
            const Files::Filesystem& m_fs;
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
