#include "pch.h"

#include <vcpkg/base/expected.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/system.h>
#include <vcpkg/base/util.h>
#include <vcpkg/base/system.debug.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/build.h>
#include <vcpkg/commands.h>
#include <vcpkg/metrics.h>
#include <vcpkg/packagespec.h>
#include <vcpkg/vcpkgpaths.h>
#include <vcpkg/visualstudio.h>

namespace
{
    using namespace vcpkg;
    fs::path process_input_directory_impl(
        Files::Filesystem& filesystem, const fs::path& root, std::string* option, StringLiteral name, LineInfo li)
    {
        if (option)
        {
            // input directories must exist, so we use canonical
            return filesystem.canonical(li, fs::u8path(*option));
        }
        else
        {
            return root / fs::u8path(name.begin(), name.end());
        }
    }

    fs::path process_input_directory(
        Files::Filesystem& filesystem, const fs::path& root, std::string* option, StringLiteral name, LineInfo li)
    {
        auto result = process_input_directory_impl(filesystem, root, option, name, li);
        Debug::print("Using ", name, "-root: ", result.u8string(), '\n');
        return result;
    }

    fs::path process_output_directory_impl(
        Files::Filesystem& filesystem, const fs::path& root, std::string* option, StringLiteral name, LineInfo li)
    {
        if (option)
        {
            // output directories might not exist, so we use merely absolute
            return filesystem.absolute(li, fs::u8path(*option));
        }
        else
        {
            return root / fs::u8path(name.begin(), name.end());
        }
    }

    fs::path process_output_directory(
        Files::Filesystem& filesystem, const fs::path& root, std::string* option, StringLiteral name, LineInfo li)
    {
        auto result = process_output_directory_impl(filesystem, root, option, name, li);
        Debug::print("Using ", name, "-root: ", result.u8string(), '\n');
        return result;
    }

} // unnamed namespace

namespace vcpkg
{
    VcpkgPaths::VcpkgPaths(Files::Filesystem& filesystem, const VcpkgCmdArguments& args) : fsPtr(&filesystem)
    {
        original_cwd = filesystem.current_path(VCPKG_LINE_INFO);
        if (args.vcpkg_root_dir)
        {
            root = filesystem.canonical(VCPKG_LINE_INFO, fs::u8path(*args.vcpkg_root_dir));
        }
        else
        {
            root = filesystem.find_file_recursively_up(original_cwd, ".vcpkg-root");
            if (root.empty())
            {
                root = filesystem.find_file_recursively_up(
                    filesystem.canonical(VCPKG_LINE_INFO, System::get_exe_path_of_current_process()), ".vcpkg-root");
            }
        }

        #if defined(_WIN32)
        // fixup Windows drive letter to uppercase
        const auto& nativeRoot = root.native();
        if (nativeRoot.size() > 2 && (nativeRoot[0] >= L'a' && nativeRoot[0] <= L'z') && nativeRoot[1] == L':')
        {
            auto uppercaseFirstLetter = nativeRoot;
            uppercaseFirstLetter[0] = nativeRoot[0] - L'a' + L'A';
            root = uppercaseFirstLetter;
        }
        #endif // defined(_WIN32)

        Checks::check_exit(VCPKG_LINE_INFO, !root.empty(), "Error: Could not detect vcpkg-root.");
        Debug::print("Using vcpkg-root: ", root.u8string(), '\n');

        buildtrees =
            process_output_directory(filesystem, root, args.buildtrees_root_dir.get(), "buildtrees", VCPKG_LINE_INFO);
        downloads =
            process_output_directory(filesystem, root, args.downloads_root_dir.get(), "downloads", VCPKG_LINE_INFO);
        packages =
            process_output_directory(filesystem, root, args.packages_root_dir.get(), "packages", VCPKG_LINE_INFO);
        ports = filesystem.canonical(VCPKG_LINE_INFO, root / fs::u8path("ports"));
        installed =
            process_output_directory(filesystem, root, args.install_root_dir.get(), "installed", VCPKG_LINE_INFO);
        scripts = process_input_directory(filesystem, root, args.scripts_root_dir.get(), "scripts", VCPKG_LINE_INFO);
        prefab = root / fs::u8path("prefab");

        if (args.default_visual_studio_path)
        {
            default_vs_path = filesystem.canonical(VCPKG_LINE_INFO, fs::u8path(*args.default_visual_studio_path));
        }

        triplets = filesystem.canonical(VCPKG_LINE_INFO, root / fs::u8path("triplets"));
        community_triplets = filesystem.canonical(VCPKG_LINE_INFO, triplets / fs::u8path("community"));

        tools = downloads / fs::u8path("tools");
        buildsystems = scripts / fs::u8path("buildsystems");
        buildsystems_msbuild_targets = buildsystems / fs::u8path("msbuild") / fs::u8path("vcpkg.targets");

        vcpkg_dir = installed / fs::u8path("vcpkg");
        vcpkg_dir_status_file = vcpkg_dir / fs::u8path("status");
        vcpkg_dir_info = vcpkg_dir / fs::u8path("info");
        vcpkg_dir_updates = vcpkg_dir / fs::u8path("updates");

        ports_cmake = filesystem.canonical(VCPKG_LINE_INFO, scripts / fs::u8path("ports.cmake"));

        triplets_dirs.emplace_back(triplets);
        triplets_dirs.emplace_back(community_triplets);
        if (args.overlay_triplets)
        {
            for (auto&& overlay_triplets_dir : *args.overlay_triplets)
            {
                triplets_dirs.emplace_back(filesystem.canonical(VCPKG_LINE_INFO, fs::u8path(overlay_triplets_dir)));
            }
        }
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

    bool VcpkgPaths::is_valid_triplet(Triplet t) const
    {
        const auto it = Util::find_if(this->get_available_triplets(), [&](auto&& available_triplet) {
            return t.canonical_name() == available_triplet.name;
        });
        return it != this->get_available_triplets().cend();
    }

    const std::vector<std::string> VcpkgPaths::get_available_triplets_names() const
    {
        return vcpkg::Util::fmap(this->get_available_triplets(),
                                 [](auto&& triplet_file) -> std::string { return triplet_file.name; });
    }

    const std::vector<VcpkgPaths::TripletFile>& VcpkgPaths::get_available_triplets() const
    {
        return this->available_triplets.get_lazy([this]() -> std::vector<TripletFile> {
            std::vector<TripletFile> output;
            Files::Filesystem& fs = this->get_filesystem();
            for (auto&& triplets_dir : triplets_dirs)
            {
                for (auto&& path : fs.get_files_non_recursive(triplets_dir))
                {
                    if (fs::is_regular_file(fs.status(VCPKG_LINE_INFO, path)))
                    {
                        output.emplace_back(TripletFile(path.stem().filename().u8string(), triplets_dir));
                    }
                }
            }
            return output;
        });
    }

    const fs::path VcpkgPaths::get_triplet_file_path(Triplet triplet) const
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
        if ((prebuildinfo.external_toolchain_file && !prebuildinfo.load_vcvars_env) ||
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

        Checks::check_exit(VCPKG_LINE_INFO, !candidates.empty(), "No suitable Visual Studio instances were found");
        return *candidates.front();

#endif
    }

    Files::Filesystem& VcpkgPaths::get_filesystem() const { return *fsPtr; }
}
