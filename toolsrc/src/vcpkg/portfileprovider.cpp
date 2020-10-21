#include <vcpkg/base/system.debug.h>

#include <vcpkg/configuration.h>
#include <vcpkg/paragraphs.h>
#include <vcpkg/portfileprovider.h>
#include <vcpkg/registries.h>
#include <vcpkg/sourceparagraph.h>
#include <vcpkg/versions.h>

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

    PathsPortFileProvider::PathsPortFileProvider(const vcpkg::VcpkgPaths& paths_,
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

    ExpectedS<const SourceControlFileLocation&> PathsPortFileProvider::get_control_file(const std::string& spec) const
    {
        auto cache_it = cache.find(spec);
        if (cache_it != cache.end())
        {
            return cache_it->second;
        }

        const auto& fs = paths.get_filesystem();

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
                        auto it = cache.emplace(std::piecewise_construct,
                                                std::forward_as_tuple(spec),
                                                std::forward_as_tuple(std::move(*scf), ports_dir));
                        return it.first->second;
                    }
                }
                else
                {
                    vcpkg::print_error_message(maybe_scf.error());
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
                        auto it = cache.emplace(std::piecewise_construct,
                                                std::forward_as_tuple(std::move(spec)),
                                                std::forward_as_tuple(std::move(*scf), std::move(ports_spec)));
                        return it.first->second;
                    }
                    Checks::exit_with_message(VCPKG_LINE_INFO,
                                              "Error: Failed to load port from %s: names did not match: '%s' != '%s'",
                                              fs::u8string(ports_spec),
                                              spec,
                                              scf->get()->core_paragraph->name);
                }
                else
                {
                    vcpkg::print_error_message(found_scf.error());
                    Checks::exit_with_message(
                        VCPKG_LINE_INFO, "Error: Failed to load port %s from %s", spec, fs::u8string(ports_dir));
                }
            }
        }

        if (auto registry = paths.get_configuration().registry_set.registry_for_port(spec))
        {
            auto registry_root = registry->get_registry_root(paths);
            auto port_directory = registry_root / fs::u8path(spec);

            if (fs.exists(port_directory))
            {
                auto found_scf = Paragraphs::try_load_port(fs, port_directory);
                if (auto scf = found_scf.get())
                {
                    if (scf->get()->core_paragraph->name == spec)
                    {
                        auto it = cache.emplace(std::piecewise_construct,
                                                std::forward_as_tuple(spec),
                                                std::forward_as_tuple(std::move(*scf), std::move(port_directory)));
                        return it.first->second;
                    }
                    Checks::exit_with_message(VCPKG_LINE_INFO,
                                              "Error: Failed to load port from %s: names did not match: '%s' != '%s'",
                                              fs::u8string(port_directory),
                                              spec,
                                              scf->get()->core_paragraph->name);
                }
                else
                {
                    vcpkg::print_error_message(found_scf.error());
                    Checks::exit_with_message(
                        VCPKG_LINE_INFO, "Error: Failed to load port %s from %s", spec, fs::u8string(port_directory));
                }
            }
        }

        return std::string("Port definition not found");
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
                    vcpkg::print_error_message(maybe_scf.error());
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

    VersionedPortfileProvider::VersionedPortfileProvider(const vcpkg::VcpkgPaths& paths) : paths(paths) { }

    vcpkg::Versions::VersionSpec extract_version_spec(const std::string& package_spec, const Json::Object& version_obj)
    {
        static const std::map<vcpkg::Versions::Scheme, std::string> version_schemes{
            {Versions::Scheme::Relaxed, "version"},
            {Versions::Scheme::Semver, "version-semver"},
            {Versions::Scheme::Date, "version-date"},
            {Versions::Scheme::String, "version-string"}};

        const auto port_version = static_cast<int>(version_obj.get("port-version")->integer());

        for (auto&& kv_pair : version_schemes)
        {
            if (const auto version_string = version_obj.get(kv_pair.second))
            {
                return Versions::VersionSpec(
                    package_spec, version_string->string().to_string(), port_version, kv_pair.first);
            }
        }

        Checks::unreachable(VCPKG_LINE_INFO);
    }

    const std::vector<vcpkg::Versions::VersionSpec>& VersionedPortfileProvider::get_port_versions(
        const std::string& package_spec) const
    {
        auto cache_it = versions_cache.find(package_spec);
        if (cache_it != versions_cache.end())
        {
            return cache_it->second;
        }

        auto db_path =
            paths.root / "port_versions" / package_spec.substr(0, 1) / Strings::concat(package_spec, ".json");
        auto& fs = paths.get_filesystem();
        if (!fs.exists(db_path))
        {
            // TODO: Handle db version not existing
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        auto versions_json = Json::parse_file(VCPKG_LINE_INFO, paths.get_filesystem(), db_path);

        // NOTE: A dictionary would be the best way to store this, for now we use a vector
        if (versions_json.first.is_object())
        {
            auto versions_object = std::move(versions_json.first.object());
            auto maybe_versions_array = versions_object.get("versions");

            if (maybe_versions_array && maybe_versions_array->is_array())
            {
                auto versions_array = std::move(maybe_versions_array->array());
                for (auto&& version : versions_array)
                {
                    auto version_obj = std::move(version.object());
                    Versions::VersionSpec spec = extract_version_spec(package_spec, version_obj);

                    auto& package_versions = versions_cache[spec.package_spec];
                    package_versions.push_back(spec);

                    auto&& git_tree = version_obj.get("git-tree")->string().to_string();
                    git_tree_cache.emplace(std::move(spec), git_tree);
                }
            }
        }

        return versions_cache.at(package_spec);
    }

    // ExpectedS<const SourceControlFileLocation&> VersionedPortfileProvider::get_control_file(
    //    const vcpkg::Versions::VersionSpec& version_spec) const
    //{
    //    auto cache_it = control_cache.find(version_spec);
    //    if (cache_it != control_cache.end())
    //    {
    //        return cache_it->second;
    //    }

    //    // 1. Load database for port
    //    auto git_tree_cache_it = git_tree_cache.find(version_spec);
    //    if (git_tree_cache_it == git_tree_cache.end())
    //    {
    //        // TODO: Try to load port from database
    //        Checks::exit_fail(VCPKG_LINE_INFO);
    //    }

    //    const std::string git_tree = git_tree_cache_it->second;

    //    // 2. Checkout port version
    //    // paths.checkout_port_object(version_spec.package_spec, git_tree);
    //    // 3. Try load port
    //    // 4. Return

    //    return std::string("Not yet implemented");
    //}
}
