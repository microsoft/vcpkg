#include <pch.h>

#include <vcpkg/paragraphs.h>
#include <vcpkg/portfileprovider.h>
#include <vcpkg/sourceparagraph.h>

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

    PathsPortFileProvider::PathsPortFileProvider(const vcpkg::VcpkgPaths& paths,
                                                 const std::vector<std::string>* ports_dirs_paths)
        : filesystem(paths.get_filesystem())
    {
        auto& fs = Files::get_real_filesystem();
        if (ports_dirs_paths)
        {
            for (auto&& overlay_path : *ports_dirs_paths)
            {
                if (!overlay_path.empty())
                {
                    auto overlay = fs.canonical(VCPKG_LINE_INFO, fs::u8path(overlay_path));

                    Checks::check_exit(VCPKG_LINE_INFO,
                                       filesystem.exists(overlay),
                                       "Error: Path \"%s\" does not exist",
                                       overlay.string());

                    Checks::check_exit(VCPKG_LINE_INFO,
                                       fs::is_directory(fs.status(VCPKG_LINE_INFO, overlay)),
                                       "Error: Path \"%s\" must be a directory",
                                       overlay.string());

                    ports_dirs.emplace_back(overlay);
                }
            }
        }
        ports_dirs.emplace_back(paths.ports);
    }

    ExpectedS<const SourceControlFileLocation&> PathsPortFileProvider::get_control_file(const std::string& spec) const
    {
        auto cache_it = cache.find(spec);
        if (cache_it != cache.end())
        {
            return cache_it->second;
        }

        for (auto&& ports_dir : ports_dirs)
        {
            // Try loading individual port
            if (filesystem.exists(ports_dir / "CONTROL"))
            {
                auto maybe_scf = Paragraphs::try_load_port(filesystem, ports_dir);
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
                        VCPKG_LINE_INFO, "Error: Failed to load port from %s", spec, ports_dir.u8string());
                }
            }
            else if (filesystem.exists(ports_dir / spec / "CONTROL"))
            {
                auto found_scf = Paragraphs::try_load_port(filesystem, ports_dir / spec);
                if (auto scf = found_scf.get())
                {
                    if (scf->get()->core_paragraph->name == spec)
                    {
                        auto it = cache.emplace(std::piecewise_construct,
                                                std::forward_as_tuple(spec),
                                                std::forward_as_tuple(std::move(*scf), ports_dir / spec));
                        return it.first->second;
                    }
                    Checks::exit_with_message(VCPKG_LINE_INFO,
                                              "Error: Failed to load port from %s: names did not match: '%s' != '%s'",
                                              (ports_dir / spec).u8string(),
                                              spec,
                                              scf->get()->core_paragraph->name);
                }
                else
                {
                    vcpkg::print_error_message(found_scf.error());
                    Checks::exit_with_message(
                        VCPKG_LINE_INFO, "Error: Failed to load port from %s", spec, ports_dir.u8string());
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
        for (auto&& ports_dir : ports_dirs)
        {
            // Try loading individual port
            if (filesystem.exists(ports_dir / "CONTROL"))
            {
                auto maybe_scf = Paragraphs::try_load_port(filesystem, ports_dir);
                if (auto scf = maybe_scf.get())
                {
                    auto port_name = scf->get()->core_paragraph->name;
                    if (cache.find(port_name) == cache.end())
                    {
                        auto it = cache.emplace(std::piecewise_construct,
                                                std::forward_as_tuple(port_name),
                                                std::forward_as_tuple(std::move(*scf), ports_dir));
                        ret.emplace_back(&it.first->second);
                    }
                }
                else
                {
                    vcpkg::print_error_message(maybe_scf.error());
                    Checks::exit_with_message(
                        VCPKG_LINE_INFO, "Error: Failed to load port from %s", ports_dir.u8string());
                }
                continue;
            }

            // Try loading all ports inside ports_dir
            auto found_scf = Paragraphs::load_all_ports(filesystem, ports_dir);
            for (auto&& scf : found_scf)
            {
                auto port_name = scf->core_paragraph->name;
                if (cache.find(port_name) == cache.end())
                {
                    auto it = cache.emplace(std::piecewise_construct,
                                            std::forward_as_tuple(port_name),
                                            std::forward_as_tuple(std::move(scf), ports_dir / port_name));
                    ret.emplace_back(&it.first->second);
                }
            }
        }
        return ret;
    }
}
