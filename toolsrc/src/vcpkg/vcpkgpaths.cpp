#include "pch.h"

#include <vcpkg/base/expected.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/system.h>
#include <vcpkg/base/util.h>
#include <vcpkg/build.h>
#include <vcpkg/commands.h>
#include <vcpkg/metrics.h>
#include <vcpkg/packagespec.h>
#include <vcpkg/vcpkgpaths.h>
#include <vcpkg/visualstudio.h>

namespace vcpkg
{
    Expected<VcpkgPaths> VcpkgPaths::create(const fs::path& vcpkg_root_dir,
                                            const Optional<fs::path>& vcpkg_scripts_root_dir,
                                            const std::string& default_vs_path,
                                            const std::vector<std::string>* triplets_dirs)
    {
        auto& fs = Files::get_real_filesystem();
        std::error_code ec;
        const fs::path canonical_vcpkg_root_dir = fs.canonical(vcpkg_root_dir, ec);
        if (ec)
        {
            return ec;
        }

        VcpkgPaths paths;
        paths.root = canonical_vcpkg_root_dir;
        paths.default_vs_path = default_vs_path;

        if (paths.root.empty())
        {
            Metrics::g_metrics.lock()->track_property("error", "Invalid vcpkg root directory");
            Checks::exit_with_message(VCPKG_LINE_INFO, "Invalid vcpkg root directory: %s", paths.root.string());
        }

        paths.packages = paths.root / "packages";
        paths.buildtrees = paths.root / "buildtrees";

        const auto overriddenDownloadsPath = System::get_environment_variable("VCPKG_DOWNLOADS");
        if (auto odp = overriddenDownloadsPath.get())
        {
            auto asPath = fs::u8path(*odp);
            if (!fs::is_directory(fs.status(VCPKG_LINE_INFO, asPath)))
            {
                Metrics::g_metrics.lock()->track_property("error", "Invalid VCPKG_DOWNLOADS override directory.");
                Checks::exit_with_message(
                    VCPKG_LINE_INFO,
                    "Invalid downloads override directory: %s; "
                    "create that directory or unset VCPKG_DOWNLOADS to use the default downloads location.",
                    asPath.u8string());
            }

            paths.downloads = fs::stdfs::canonical(std::move(asPath), ec);
            if (ec)
            {
                return ec;
            }
        }
        else
        {
            paths.downloads = paths.root / "downloads";
        }

        paths.ports = paths.root / "ports";
        paths.installed = paths.root / "installed";
        paths.triplets = paths.root / "triplets";

        if (auto scripts_dir = vcpkg_scripts_root_dir.get())
        {
            if (scripts_dir->empty() || !fs::stdfs::is_directory(*scripts_dir))
            {
                Metrics::g_metrics.lock()->track_property("error", "Invalid scripts override directory.");
                Checks::exit_with_message(
                    VCPKG_LINE_INFO,
                    "Invalid scripts override directory: %s; "
                    "create that directory or unset --x-scripts-root to use the default scripts location.",
                    scripts_dir->u8string());
            }

            paths.scripts = *scripts_dir;
        }
        else
        {
            paths.scripts = paths.root / "scripts";
        }

        paths.tools = paths.downloads / "tools";
        paths.buildsystems = paths.scripts / "buildsystems";
        paths.buildsystems_msbuild_targets = paths.buildsystems / "msbuild" / "vcpkg.targets";

        paths.vcpkg_dir = paths.installed / "vcpkg";
        paths.vcpkg_dir_status_file = paths.vcpkg_dir / "status";
        paths.vcpkg_dir_info = paths.vcpkg_dir / "info";
        paths.vcpkg_dir_updates = paths.vcpkg_dir / "updates";

        paths.ports_cmake = paths.scripts / "ports.cmake";

        if (triplets_dirs)
        {
            for (auto&& triplets_dir : *triplets_dirs)
            {
                auto path = fs::u8path(triplets_dir);
                Checks::check_exit(VCPKG_LINE_INFO,
                                   paths.get_filesystem().exists(path),
                                   "Error: Path does not exist '%s'",
                                   triplets_dir);
                paths.triplets_dirs.emplace_back(fs::stdfs::canonical(path));
            }
        }
        paths.triplets_dirs.emplace_back(fs::stdfs::canonical(paths.root / "triplets"));

        return paths;
    }

    fs::path VcpkgPaths::package_dir(const PackageSpec& spec) const { return this->packages / spec.dir(); }

    fs::path VcpkgPaths::build_info_file_path(const PackageSpec& spec) const
    {
        return this->package_dir(spec) / "BUILD_INFO";
    }

    fs::path VcpkgPaths::listfile_path(const BinaryParagraph& pgh) const
    {
        return this->vcpkg_dir_info / (pgh.fullstem() + ".list");
    }

    bool VcpkgPaths::is_valid_triplet(const Triplet& t) const
    {
        const auto it = Util::find_if(this->get_available_triplets(), [&](auto&& available_triplet) {
            return t.canonical_name() == available_triplet;
        });
        return it != this->get_available_triplets().cend();
    }

    const std::vector<std::string>& VcpkgPaths::get_available_triplets() const
    {
        return this->available_triplets.get_lazy([this]() -> std::vector<std::string> {
            std::vector<std::string> output;
            for (auto&& triplets_dir : triplets_dirs)
            {
                for (auto&& path : this->get_filesystem().get_files_non_recursive(triplets_dir))
                {
                    output.push_back(path.stem().filename().string());
                }
            }
            Util::sort_unique_erase(output);
            return output;
        });
    }

    const fs::path VcpkgPaths::get_triplet_file_path(const Triplet& triplet) const
    {
        return m_triplets_cache.get_lazy(
            triplet, [&]() -> auto {
                for (const auto& triplet_dir : triplets_dirs)
                {
                    auto path = triplet_dir / (triplet.canonical_name() + ".cmake");
                    if (this->get_filesystem().exists(path))
                    {
                        return path;
                    }
                }

                Checks::exit_with_message(
                    VCPKG_LINE_INFO, "Error: Triplet file %s.cmake not found", triplet.canonical_name());
            });
    }

    const fs::path& VcpkgPaths::get_tool_exe(const std::string& tool) const
    {
        if (!m_tool_cache) m_tool_cache = get_tool_cache();
        return m_tool_cache->get_tool_path(*this, tool);
    }
    const std::string& VcpkgPaths::get_tool_version(const std::string& tool) const
    {
        if (!m_tool_cache) m_tool_cache = get_tool_cache();
        return m_tool_cache->get_tool_version(*this, tool);
    }

    const Toolset& VcpkgPaths::get_toolset(const Build::PreBuildInfo& prebuildinfo) const
    {
        const auto host_arch = System::get_host_processor();
        const auto target_arch = System::to_cpu_architecture(prebuildinfo.target_architecture).value_or(host_arch);

        if ((prebuildinfo.external_toolchain_file && !prebuildinfo.force_vcvar_load) ||
            (!prebuildinfo.cmake_system_name.empty() && prebuildinfo.cmake_system_name != "WindowsStore"))
        {
            static Toolset external_toolset = [&]() -> Toolset {
                Toolset ret;
                ret.dumpbin = "";
                ret.arch = {ArchOption{"", host_arch, target_arch}};
                ret.vcvarsall = "";
                ret.vcvarsall_options = {};
                ret.vsversion = "external";
                ret.visual_studio_root_path = "";
                return ret;
            }();
            return external_toolset;
        }

#if !defined(_WIN32)
        Checks::exit_with_message(VCPKG_LINE_INFO, "Cannot build windows triplets from non-windows.");
#else
        const std::vector<Toolset>& vs_toolsets =
            this->toolsets.get_lazy([this]() { return VisualStudio::find_toolset_instances_preferred_first(*this); });

        std::vector<const Toolset*> candidates = Util::fmap(vs_toolsets, [](auto&& x) { return &x; });
        const auto tsv = prebuildinfo.platform_toolset.get();
        auto vsp = prebuildinfo.visual_studio_path.get();

        // Filter by host and target architecture
        Util::erase_remove_if(candidates, [&](const Toolset* t) {
            return t->arch.host_arch != host_arch || t->arch.target_arch != target_arch;
        });

        if (!vsp && !default_vs_path.empty())
        {
            vsp = &default_vs_path;
        }

        // Filter by CMake VS Generator (Allows to overwrite our preferences! -> Makes triplets like: x86-windows-vs2012
        // possible)
        if (const auto cmake_vs_gen = prebuildinfo.cmake_vs_generator.get(); cmake_vs_gen)
        {
            Util::erase_remove_if(candidates, [&](const Toolset* t) { return t->cmake_generator != *cmake_vs_gen; });
            Checks::check_exit(VCPKG_LINE_INFO,
                               !candidates.empty(),
                               "Could not find Visual Studio instance at %s with %s toolset.",
                               vsp->u8string(),
                               *tsv);
        }

        // Filter by toolset and VS path => Should only ever return a single toolset
        if (tsv && vsp)
        {
            Util::erase_remove_if(
                candidates, [&](const Toolset* t) { return *tsv != t->name || *vsp != t->visual_studio_root_path; });
            Checks::check_exit(VCPKG_LINE_INFO,
                               !candidates.empty(),
                               "Could not find Visual Studio instance at %s with %s toolset.",
                               vsp->u8string(),
                               *tsv);

            Checks::check_exit(VCPKG_LINE_INFO, candidates.size() == 1);
            return *candidates.back();
        }

        // Filter by toolset (Allows triplets like x86-windows-llvm or triplets like x86-windows-v141_xp)
        // If used together with cmake_vs_gen x86-windows-vs120_xp should be possible
        if (tsv)
        {
            Util::erase_remove_if(candidates, [&](const Toolset* t) { return *tsv != t->name; });
            Checks::check_exit(
                VCPKG_LINE_INFO, !candidates.empty(), "Could not find Visual Studio instance with %s toolset.", *tsv);
            return *candidates.front();
        }

        // Filter by Path
        if (vsp)
        {
            const fs::path vs_root_path = *vsp;
            Util::erase_remove_if(candidates,
                                  [&](const Toolset* t) { return vs_root_path != t->visual_studio_root_path; });
            Checks::check_exit(VCPKG_LINE_INFO,
                               !candidates.empty(),
                               "Could not find Visual Studio instance at %s.",
                               vs_root_path.generic_string());
        }

        Checks::check_exit(VCPKG_LINE_INFO, !candidates.empty(), "No suitable Visual Studio instances were found");

        // Last but not least: filter by preferred toolset selection.
        // Requires candidates to be sorted in: a) major version b) toolset versions. (newer > older)
        // Maybe candidates should be sorted that way to make sure it is sorted.
        // Currently the code relies on the fact that VisualStudio::find_toolset_instances_preferred_first
        // pushes it back in that way (hoepfully; not fully tested <- please make better)
        auto preferred_pred = [](const Toolset* set, const CStringView prename) noexcept
        {
            return (set->name == prename.c_str());
        };
        const auto preferred = std::find_first_of(candidates.begin(),
                                                  candidates.end(),
                                                  VisualStudio::get_preferred_toolset_names().cbegin(),
                                                  VisualStudio::get_preferred_toolset_names().cend(),
                                                  preferred_pred);
        Checks::check_exit(
            VCPKG_LINE_INFO, preferred != candidates.cend(), "Could not find a preferred Visual Studio toolset!");
        return **preferred;

#endif
    }

    Files::Filesystem& VcpkgPaths::get_filesystem() const { return Files::get_real_filesystem(); }
}
