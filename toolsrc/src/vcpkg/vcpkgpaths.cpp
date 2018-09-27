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
    Expected<VcpkgPaths> VcpkgPaths::create(const fs::path& vcpkg_root_dir, const std::string& default_vs_path)
    {
        std::error_code ec;
        const fs::path canonical_vcpkg_root_dir = fs::stdfs::canonical(vcpkg_root_dir, ec);
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
            if (!fs::stdfs::is_directory(asPath))
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
        paths.scripts = paths.root / "scripts";

        paths.tools = paths.downloads / "tools";
        paths.buildsystems = paths.scripts / "buildsystems";
        paths.buildsystems_msbuild_targets = paths.buildsystems / "msbuild" / "vcpkg.targets";
		paths.buildsystems_msbuild_props = paths.buildsystems / "msbuild" / "vcpkg.props";

        paths.vcpkg_dir = paths.installed / "vcpkg";
        paths.vcpkg_dir_status_file = paths.vcpkg_dir / "status";
        paths.vcpkg_dir_info = paths.vcpkg_dir / "info";
        paths.vcpkg_dir_updates = paths.vcpkg_dir / "updates";

        paths.ports_cmake = paths.scripts / "ports.cmake";

        return paths;
    }

    fs::path VcpkgPaths::package_dir(const PackageSpec& spec) const { return this->packages / spec.dir(); }

    fs::path VcpkgPaths::port_dir(const PackageSpec& spec) const { return this->ports / spec.name(); }
    fs::path VcpkgPaths::port_dir(const std::string& name) const { return this->ports / name; }

    fs::path VcpkgPaths::build_info_file_path(const PackageSpec& spec) const
    {
        return this->package_dir(spec) / "BUILD_INFO";
    }

    fs::path VcpkgPaths::listfile_path(const BinaryParagraph& pgh) const
    {
        return this->vcpkg_dir_info / (pgh.fullstem() + ".list");
    }

    const std::vector<std::string>& VcpkgPaths::get_available_triplets() const
    {
        return this->available_triplets.get_lazy([this]() -> std::vector<std::string> {
            std::vector<std::string> output;
            for (auto&& path : this->get_filesystem().get_files_non_recursive(this->triplets))
            {
                output.push_back(path.stem().filename().string());
            }
            Util::sort(output);

            return output;
        });
    }

    bool VcpkgPaths::is_valid_triplet(const Triplet& t) const
    {
        const auto it = Util::find_if(this->get_available_triplets(), [&](auto&& available_triplet) {
            return t.canonical_name() == available_triplet;
        });
        return it != this->get_available_triplets().cend();
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
        if (prebuildinfo.external_toolchain_file ||
            (!prebuildinfo.cmake_system_name.empty() && prebuildinfo.cmake_system_name != "WindowsStore"))
        {
            static Toolset external_toolset = []() -> Toolset {
                Toolset ret;
                ret.dumpbin = "";
                ret.supported_architectures = {
                    ToolsetArchOption{"", System::get_host_processor(), System::get_host_processor()}};
                ret.vcvarsall = "";
                ret.vcvarsall_options = {};
                ret.version = "external";
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
        if (!vsp && !default_vs_path.empty())
        {
            vsp = &default_vs_path;
        }

        if (tsv && vsp)
        {
            Util::erase_remove_if(
                candidates, [&](const Toolset* t) { return *tsv != t->version || *vsp != t->visual_studio_root_path; });
            Checks::check_exit(VCPKG_LINE_INFO,
                               !candidates.empty(),
                               "Could not find Visual Studio instance at %s with %s toolset.",
                               vsp->u8string(),
                               *tsv);

            Checks::check_exit(VCPKG_LINE_INFO, candidates.size() == 1);
            return *candidates.back();
        }

        if (tsv)
        {
            Util::erase_remove_if(candidates, [&](const Toolset* t) { return *tsv != t->version; });
            Checks::check_exit(
                VCPKG_LINE_INFO, !candidates.empty(), "Could not find Visual Studio instance with %s toolset.", *tsv);
        }

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

        if (prebuildinfo.cmake_system_name == "WindowsStore")
        {
            // For now, cmake does not support VS 2019 when using the MSBuild generator.
            Util::erase_remove_if(candidates, [&](const Toolset* t) { return t->version == "v142"; });
            Checks::check_exit(VCPKG_LINE_INFO,
                               !candidates.empty(),
                               "With the current CMake version, UWP binaries can only be built with toolset version "
                               "v141 or below. Please install the v141 toolset in VS 2019.");
        }

        if (System::get_host_processor() == System::CPUArchitecture::X86)
        {
            // For now, cmake does not support VS 2019 when using the MSBuild generator.
            Util::erase_remove_if(candidates, [&](const Toolset* t) { return t->version == "v142"; });
            Checks::check_exit(VCPKG_LINE_INFO,
                               !candidates.empty(),
                               "With the current CMake version, 32-bit machines can build with toolset version "
                               "v141 or below. Please install the v141 toolset in VS 2019.");
        }

        Checks::check_exit(VCPKG_LINE_INFO, !candidates.empty(), "No suitable Visual Studio instances were found");
        return *candidates.front();

#endif
    }

    Files::Filesystem& VcpkgPaths::get_filesystem() const { return Files::get_real_filesystem(); }
}
