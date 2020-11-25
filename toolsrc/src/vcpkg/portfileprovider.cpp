

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
    Optional<fs::path> get_versions_json_path(const VcpkgPaths& paths, StringView port_name)
    {
        const auto port_versions_dir_path = paths.root / fs::u8path("port_versions");
        const auto subpath = Strings::concat(port_name.substr(0, 1), "-/", port_name, ".json");
        const auto json_path = port_versions_dir_path / subpath;
        if (paths.get_filesystem().exists(json_path))
        {
            return json_path;
        }
        return nullopt;
    }

    Optional<fs::path> get_baseline_json_path(const VcpkgPaths& paths, StringView baseline_commit_sha)
    {
        const auto baseline_json = paths.git_checkout_baseline(paths.get_filesystem(), baseline_commit_sha);
        return paths.get_filesystem().exists(baseline_json) ? make_optional(baseline_json) : nullopt;
    }
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

    static Optional<SourceControlFileLocation> try_load_overlay_port(const Files::Filesystem& fs,
                                                                     View<fs::path> overlay_ports,
                                                                     const std::string& spec)
    {
        for (auto&& ports_dir : overlay_ports)
        {
            // Try loading individual port
            if (Paragraphs::is_port_directory(fs, ports_dir))
            {
                auto maybe_scf = Paragraphs::try_load_port(fs, ports_dir);
                if (auto scf = maybe_scf.get())
                {
                    if (scf->get()->core_paragraph->name == spec)
                    {
                        return SourceControlFileLocation{std::move(*scf), ports_dir};
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
                if (auto scf = found_scf.get())
                {
                    if (scf->get()->core_paragraph->name == spec)
                    {
                        return SourceControlFileLocation{std::move(*scf), std::move(ports_spec)};
                    }
                    Checks::exit_with_message(VCPKG_LINE_INFO,
                                              "Error: Failed to load port from %s: names did not match: '%s' != '%s'",
                                              fs::u8string(ports_spec),
                                              spec,
                                              scf->get()->core_paragraph->name);
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

    static Optional<SourceControlFileLocation> try_load_registry_port(const VcpkgPaths& paths, const std::string& spec)
    {
        const auto& fs = paths.get_filesystem();
        if (auto registry = paths.get_configuration().registry_set.registry_for_port(spec))
        {
            auto baseline_version = registry->get_baseline_version(paths, spec);
            auto entry = registry->get_port_entry(paths, spec);
            if (entry && baseline_version)
            {
                auto port_directory = entry->get_port_directory(paths, *baseline_version.get());
                if (port_directory.empty())
                {
                    Checks::exit_with_message(VCPKG_LINE_INFO,
                                              "Error: registry is incorrect. Baseline version for port `%s` is `%s`, "
                                              "but that version is not in the registry.\n",
                                              spec,
                                              baseline_version.get()->to_string());
                }
                auto found_scf = Paragraphs::try_load_port(fs, port_directory);
                if (auto scf = found_scf.get())
                {
                    if (scf->get()->core_paragraph->name == spec)
                    {
                        return SourceControlFileLocation{std::move(*scf), std::move(port_directory)};
                    }
                    Checks::exit_with_message(VCPKG_LINE_INFO,
                                              "Error: Failed to load port from %s: names did not match: '%s' != '%s'",
                                              fs::u8string(port_directory),
                                              spec,
                                              scf->get()->core_paragraph->name);
                }
                else
                {
                    print_error_message(found_scf.error());
                    Checks::exit_with_message(
                        VCPKG_LINE_INFO, "Error: Failed to load port %s from %s", spec, fs::u8string(port_directory));
                }
            }
            else
            {
                Debug::print("Failed to find port `",
                             spec,
                             "` in registry:",
                             entry ? " entry found;" : " no entry found;",
                             baseline_version ? " baseline version found\n" : " no baseline version found\n");
            }
        }
        else
        {
            Debug::print("Failed to find registry for port: `", spec, "`.\n");
        }
        return nullopt;
    }

    ExpectedS<const SourceControlFileLocation&> PathsPortFileProvider::get_control_file(const std::string& spec) const
    {
        auto cache_it = cache.find(spec);
        if (cache_it == cache.end())
        {
            const auto& fs = paths.get_filesystem();
            auto maybe_port = try_load_overlay_port(fs, overlay_ports, spec);
            if (!maybe_port)
            {
                maybe_port = try_load_registry_port(paths, spec);
            }
            if (auto p = maybe_port.get())
            {
                auto maybe_error =
                    p->source_control_file->check_against_feature_flags(p->source_location, paths.get_feature_flags());
                if (maybe_error) return std::move(*maybe_error.get());

                cache_it = cache.emplace(spec, std::move(*p)).first;
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

    namespace details
    {
        struct BaselineProviderImpl
        {
            BaselineProviderImpl(const VcpkgPaths& paths, const std::string& baseline)
                : paths(paths), baseline(baseline)
            {
            }
            ~BaselineProviderImpl() { }

            const std::map<std::string, VersionT, std::less<>>& get_baseline_cache() const
            {
                return baseline_cache.get_lazy([&]() -> auto {
                    auto maybe_baseline_file = get_baseline_json_path(paths, baseline);
                    Checks::check_exit(VCPKG_LINE_INFO, maybe_baseline_file.has_value(), "Couldn't find baseline.json");
                    auto baseline_file = maybe_baseline_file.value_or_exit(VCPKG_LINE_INFO);

                    auto maybe_baselines_map = parse_baseline_file(paths.get_filesystem(), "default", baseline_file);
                    Checks::check_exit(VCPKG_LINE_INFO,
                                       maybe_baselines_map.has_value(),
                                       "Error: Couldn't parse baseline `%s` from `%s`",
                                       "default",
                                       fs::u8string(baseline_file));
                    auto baselines_map = *maybe_baselines_map.get();
                    return std::move(baselines_map);
                });
            }

        private:
            const VcpkgPaths& paths;
            const std::string baseline;
            Lazy<std::map<std::string, VersionT, std::less<>>> baseline_cache;
        };

        struct VersionedPortfileProviderImpl
        {
            std::map<std::string, std::vector<VersionSpec>> versions_cache;
            std::unordered_map<VersionSpec, std::string, VersionSpecHasher> git_tree_cache;
            std::unordered_map<VersionSpec, SourceControlFileLocation, VersionSpecHasher> control_cache;

            VersionedPortfileProviderImpl(const VcpkgPaths& paths) : paths(paths) { }
            ~VersionedPortfileProviderImpl() { }

            const VcpkgPaths& get_paths() const { return paths; }
            Files::Filesystem& get_filesystem() const { return paths.get_filesystem(); }

        private:
            const VcpkgPaths& paths;
        };
    }

    VersionedPortfileProvider::VersionedPortfileProvider(const VcpkgPaths& paths)
        : m_impl(std::make_unique<details::VersionedPortfileProviderImpl>(paths))
    {
    }
    VersionedPortfileProvider::~VersionedPortfileProvider() { }

    const std::vector<VersionSpec>& VersionedPortfileProvider::get_port_versions(StringView port_name) const
    {
        auto cache_it = m_impl->versions_cache.find(port_name.to_string());
        if (cache_it != m_impl->versions_cache.end())
        {
            return cache_it->second;
        }

        auto maybe_versions_file_path = get_versions_json_path(m_impl->get_paths(), port_name);
        Checks::check_exit(VCPKG_LINE_INFO,
                           maybe_versions_file_path.has_value(),
                           "Error: Couldn't find a versions database file: %s.json.",
                           port_name);
        auto versions_file_path = maybe_versions_file_path.value_or_exit(VCPKG_LINE_INFO);

        auto maybe_version_entries = parse_versions_file(m_impl->get_filesystem(), port_name, versions_file_path);
        Checks::check_exit(VCPKG_LINE_INFO,
                           maybe_version_entries.has_value(),
                           "Error: Couldn't parse versions from file: %s",
                           fs::u8string(versions_file_path));
        auto version_entries = maybe_version_entries.value_or_exit(VCPKG_LINE_INFO);

        auto port = port_name.to_string();
        for (auto&& version_entry : version_entries)
        {
            VersionSpec spec(port, version_entry.version, version_entry.scheme);
            m_impl->versions_cache[port].push_back(spec);
            m_impl->git_tree_cache.emplace(std::move(spec), std::move(version_entry.git_tree));
        }
        return m_impl->versions_cache.at(port);
    }

    ExpectedS<const SourceControlFileLocation&> VersionedPortfileProvider::get_control_file(
        const VersionSpec& version_spec) const
    {
        auto cache_it = m_impl->control_cache.find(version_spec);
        if (cache_it != m_impl->control_cache.end())
        {
            return cache_it->second;
        }

        // Pre-populate versions cache.
        get_port_versions(version_spec.port_name);

        auto git_tree_cache_it = m_impl->git_tree_cache.find(version_spec);
        if (git_tree_cache_it == m_impl->git_tree_cache.end())
        {
            return Strings::concat("No git object SHA for entry %s at version %s.",
                                   version_spec.port_name,
                                   version_spec.version.to_string());
        }

        const std::string git_tree = git_tree_cache_it->second;
        auto port_directory =
            m_impl->get_paths().git_checkout_port(m_impl->get_filesystem(), version_spec.port_name, git_tree);

        auto maybe_control_file = Paragraphs::try_load_port(m_impl->get_filesystem(), port_directory);
        if (auto scf = maybe_control_file.get())
        {
            if (scf->get()->core_paragraph->name == version_spec.port_name)
            {
                return m_impl->control_cache
                    .emplace(version_spec, SourceControlFileLocation{std::move(*scf), std::move(port_directory)})
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

    BaselineProvider::BaselineProvider(const VcpkgPaths& paths, const std::string& baseline)
        : m_impl(std::make_unique<details::BaselineProviderImpl>(paths, baseline))
    {
    }
    BaselineProvider::~BaselineProvider() { }

    Optional<VersionT> BaselineProvider::get_baseline_version(StringView port_name) const
    {
        const auto& cache = m_impl->get_baseline_cache();
        auto it = cache.find(port_name.to_string());
        if (it != cache.end())
        {
            return it->second;
        }
        return nullopt;
    }
}
