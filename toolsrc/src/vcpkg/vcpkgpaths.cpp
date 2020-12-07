#include <vcpkg/base/expected.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/hash.h>
#include <vcpkg/base/jsonreader.h>
#include <vcpkg/base/system.debug.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/base/util.h>

#include <vcpkg/binaryparagraph.h>
#include <vcpkg/build.h>
#include <vcpkg/commands.h>
#include <vcpkg/configuration.h>
#include <vcpkg/configurationdeserializer.h>
#include <vcpkg/globalstate.h>
#include <vcpkg/metrics.h>
#include <vcpkg/packagespec.h>
#include <vcpkg/registries.h>
#include <vcpkg/sourceparagraph.h>
#include <vcpkg/tools.h>
#include <vcpkg/vcpkgcmdarguments.h>
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
        Debug::print("Using ", name, "-root: ", fs::u8string(result), '\n');
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
#if defined(_WIN32)
        result = vcpkg::Files::win32_fix_path_case(result);
#endif // _WIN32
        Debug::print("Using ", name, "-root: ", fs::u8string(result), '\n');
        return result;
    }

    System::CmdLineBuilder git_cmd_builder(const VcpkgPaths& paths,
                                           const fs::path& dot_git_dir,
                                           const fs::path& work_tree)
    {
        return System::CmdLineBuilder()
            .path_arg(paths.get_tool_exe(Tools::GIT))
            .string_arg(Strings::concat("--git-dir=", fs::u8string(dot_git_dir)))
            .string_arg(Strings::concat("--work-tree=", fs::u8string(work_tree)));
    }
} // unnamed namespace

namespace vcpkg
{
    static Configuration deserialize_configuration(const Json::Object& obj,
                                                   const VcpkgCmdArguments& args,
                                                   const fs::path& filepath)
    {
        Json::Reader reader;
        ConfigurationDeserializer deserializer(args);

        auto parsed_config_opt = reader.visit(obj, deserializer);
        if (!reader.errors().empty())
        {
            System::print2(System::Color::error, "Errors occurred while parsing ", fs::u8string(filepath), "\n");
            for (auto&& msg : reader.errors())
                System::print2("    ", msg, '\n');

            System::print2("See https://github.com/Microsoft/vcpkg/tree/master/docs/specifications/registries.md for "
                           "more information.\n");
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        return std::move(parsed_config_opt).value_or_exit(VCPKG_LINE_INFO);
    }

    struct ManifestAndConfig
    {
        fs::path config_directory;
        Configuration config;
    };

    static std::pair<Json::Object, Json::JsonStyle> load_manifest(const Files::Filesystem& fs,
                                                                  const fs::path& manifest_dir)
    {
        std::error_code ec;
        auto manifest_path = manifest_dir / fs::u8path("vcpkg.json");
        auto manifest_opt = Json::parse_file(fs, manifest_path, ec);
        if (ec)
        {
            Checks::exit_with_message(VCPKG_LINE_INFO,
                                      "Failed to load manifest from directory %s: %s",
                                      fs::u8string(manifest_dir),
                                      ec.message());
        }

        if (!manifest_opt.has_value())
        {
            Checks::exit_with_message(VCPKG_LINE_INFO,
                                      "Failed to parse manifest at %s:\n%s",
                                      fs::u8string(manifest_path),
                                      manifest_opt.error()->format());
        }
        auto manifest_value = std::move(manifest_opt).value_or_exit(VCPKG_LINE_INFO);

        if (!manifest_value.first.is_object())
        {
            System::print2(System::Color::error,
                           "Failed to parse manifest at ",
                           fs::u8string(manifest_path),
                           ": Manifest files must have a top-level object\n");
            Checks::exit_fail(VCPKG_LINE_INFO);
        }
        return {std::move(manifest_value.first.object()), std::move(manifest_value.second)};
    }

    struct ConfigAndPath
    {
        fs::path config_directory;
        Configuration config;
    };

    // doesn't yet implement searching upwards for configurations, nor inheritance of configurations
    static ConfigAndPath load_configuration(const Files::Filesystem& fs,
                                            const VcpkgCmdArguments& args,
                                            const fs::path& vcpkg_root,
                                            const fs::path& manifest_dir)
    {
        fs::path config_dir;

        if (!manifest_dir.empty())
        {
            // manifest mode
            config_dir = manifest_dir;
        }
        else
        {
            // classic mode
            config_dir = vcpkg_root;
        }

        auto path_to_config = config_dir / fs::u8path("vcpkg-configuration.json");
        if (!fs.exists(path_to_config))
        {
            return {};
        }

        auto parsed_config = Json::parse_file(VCPKG_LINE_INFO, fs, path_to_config);
        if (!parsed_config.first.is_object())
        {
            System::print2(System::Color::error,
                           "Failed to parse ",
                           fs::u8string(path_to_config),
                           ": configuration files must have a top-level object\n");
            Checks::exit_fail(VCPKG_LINE_INFO);
        }
        auto config_obj = std::move(parsed_config.first.object());

        return {std::move(config_dir), deserialize_configuration(config_obj, args, path_to_config)};
    }

    namespace details
    {
        struct VcpkgPathsImpl
        {
            VcpkgPathsImpl(Files::Filesystem& fs, FeatureFlagSettings ff_settings)
                : fs_ptr(&fs)
                , m_tool_cache(get_tool_cache())
                , m_env_cache(ff_settings.compiler_tracking)
                , m_ff_settings(ff_settings)
            {
            }

            Lazy<std::vector<VcpkgPaths::TripletFile>> available_triplets;
            Lazy<std::vector<Toolset>> toolsets;
            Lazy<std::map<std::string, std::string>> cmake_script_hashes;

            Files::Filesystem* fs_ptr;

            fs::path default_vs_path;
            std::vector<fs::path> triplets_dirs;

            std::unique_ptr<ToolCache> m_tool_cache;
            Cache<Triplet, fs::path> m_triplets_cache;
            Build::EnvCache m_env_cache;

            fs::SystemHandle file_lock_handle;

            Optional<std::pair<Json::Object, Json::JsonStyle>> m_manifest_doc;
            fs::path m_manifest_path;
            Configuration m_config;

            FeatureFlagSettings m_ff_settings;
        };
    }

    VcpkgPaths::VcpkgPaths(Files::Filesystem& filesystem, const VcpkgCmdArguments& args)
        : m_pimpl(std::make_unique<details::VcpkgPathsImpl>(filesystem, args.feature_flag_settings()))
    {
        original_cwd = filesystem.current_path(VCPKG_LINE_INFO);
#if defined(_WIN32)
        original_cwd = vcpkg::Files::win32_fix_path_case(original_cwd);
#endif // _WIN32

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

        Checks::check_exit(VCPKG_LINE_INFO, !root.empty(), "Error: Could not detect vcpkg-root.");
        Debug::print("Using vcpkg-root: ", fs::u8string(root), '\n');

        std::error_code ec;
        bool manifest_mode_on = args.manifest_mode.value_or(args.manifest_root_dir != nullptr);
        if (args.manifest_root_dir)
        {
            manifest_root_dir = filesystem.canonical(VCPKG_LINE_INFO, fs::u8path(*args.manifest_root_dir));
        }
        else
        {
            manifest_root_dir = filesystem.find_file_recursively_up(original_cwd, fs::u8path("vcpkg.json"));
        }

        if (!manifest_root_dir.empty() && manifest_mode_on)
        {
            Debug::print("Using manifest-root: ", fs::u8string(manifest_root_dir), '\n');

            installed = process_output_directory(
                filesystem, manifest_root_dir, args.install_root_dir.get(), "vcpkg_installed", VCPKG_LINE_INFO);

            const auto vcpkg_lock = root / ".vcpkg-root";
            if (args.wait_for_lock.value_or(false))
            {
                m_pimpl->file_lock_handle = filesystem.take_exclusive_file_lock(vcpkg_lock, ec);
            }
            else
            {
                m_pimpl->file_lock_handle = filesystem.try_take_exclusive_file_lock(vcpkg_lock, ec);
            }

            if (ec)
            {
                if (ec == std::errc::device_or_resource_busy || args.ignore_lock_failures.value_or(false))
                {
                    System::printf(
                        System::Color::error, "Failed to take the filesystem lock on %s:\n", fs::u8string(vcpkg_lock));
                    System::printf(System::Color::error, "    %s\n", ec.message());
                    Checks::exit_fail(VCPKG_LINE_INFO);
                }
            }

            m_pimpl->m_manifest_doc = load_manifest(filesystem, manifest_root_dir);
            m_pimpl->m_manifest_path = manifest_root_dir / fs::u8path("vcpkg.json");
        }
        else
        {
            // we ignore the manifest root dir if the user requests -manifest
            if (!manifest_root_dir.empty() && !args.manifest_mode.has_value() && !args.output_json())
            {
                System::print2(System::Color::warning,
                               "Warning: manifest-root detected at ",
                               fs::generic_u8string(manifest_root_dir),
                               ", but manifests are not enabled.\n");
                System::printf(System::Color::warning,
                               R"(If you wish to use manifest mode, you may do one of the following:
    * Add the `%s` feature flag to the comma-separated environment
      variable `%s`.
    * Add the `%s` feature flag to the `--%s` option.
    * Pass your manifest directory to the `--%s` option.
If you wish to silence this error and use classic mode, you can:
    * Add the `-%s` feature flag to `%s`.
    * Add the `-%s` feature flag to `--%s`.
)",
                               VcpkgCmdArguments::MANIFEST_MODE_FEATURE,
                               VcpkgCmdArguments::FEATURE_FLAGS_ENV,
                               VcpkgCmdArguments::MANIFEST_MODE_FEATURE,
                               VcpkgCmdArguments::FEATURE_FLAGS_ARG,
                               VcpkgCmdArguments::MANIFEST_ROOT_DIR_ARG,
                               VcpkgCmdArguments::MANIFEST_MODE_FEATURE,
                               VcpkgCmdArguments::FEATURE_FLAGS_ENV,
                               VcpkgCmdArguments::MANIFEST_MODE_FEATURE,
                               VcpkgCmdArguments::FEATURE_FLAGS_ARG);
            }

            manifest_root_dir.clear();
            installed =
                process_output_directory(filesystem, root, args.install_root_dir.get(), "installed", VCPKG_LINE_INFO);
        }

        auto config_file = load_configuration(filesystem, args, root, manifest_root_dir);

        config_root_dir = std::move(config_file.config_directory);
        m_pimpl->m_config = std::move(config_file.config);

        buildtrees =
            process_output_directory(filesystem, root, args.buildtrees_root_dir.get(), "buildtrees", VCPKG_LINE_INFO);
        downloads =
            process_output_directory(filesystem, root, args.downloads_root_dir.get(), "downloads", VCPKG_LINE_INFO);
        packages =
            process_output_directory(filesystem, root, args.packages_root_dir.get(), "packages", VCPKG_LINE_INFO);
        scripts = process_input_directory(filesystem, root, args.scripts_root_dir.get(), "scripts", VCPKG_LINE_INFO);
        prefab = root / fs::u8path("prefab");

        if (args.default_visual_studio_path)
        {
            m_pimpl->default_vs_path =
                filesystem.canonical(VCPKG_LINE_INFO, fs::u8path(*args.default_visual_studio_path));
        }

        triplets = filesystem.canonical(VCPKG_LINE_INFO, root / fs::u8path("triplets"));
        community_triplets = filesystem.canonical(VCPKG_LINE_INFO, triplets / fs::u8path("community"));

        tools = downloads / fs::u8path("tools");
        buildsystems = scripts / fs::u8path("buildsystems");
        const auto msbuildDirectory = buildsystems / fs::u8path("msbuild");
        buildsystems_msbuild_targets = msbuildDirectory / fs::u8path("vcpkg.targets");
        buildsystems_msbuild_props = msbuildDirectory / fs::u8path("vcpkg.props");

        vcpkg_dir = installed / fs::u8path("vcpkg");
        vcpkg_dir_status_file = vcpkg_dir / fs::u8path("status");
        vcpkg_dir_info = vcpkg_dir / fs::u8path("info");
        vcpkg_dir_updates = vcpkg_dir / fs::u8path("updates");

        // Versioning paths
        const auto versioning_tmp = buildtrees / fs::u8path("versioning_tmp");
        const auto versioning_output = buildtrees / fs::u8path("versioning");

        baselines_dot_git_dir = versioning_tmp / fs::u8path(".baselines.git");
        baselines_work_tree = versioning_tmp / fs::u8path("baselines-worktree");
        baselines_output = versioning_output / fs::u8path("baselines");

        versions_dot_git_dir = versioning_tmp / fs::u8path(".versions.git");
        versions_work_tree = versioning_tmp / fs::u8path("versions-worktree");
        versions_output = versioning_output / fs::u8path("versions");

        ports_cmake = filesystem.canonical(VCPKG_LINE_INFO, scripts / fs::u8path("ports.cmake"));

        for (auto&& overlay_triplets_dir : args.overlay_triplets)
        {
            m_pimpl->triplets_dirs.emplace_back(
                filesystem.canonical(VCPKG_LINE_INFO, fs::u8path(overlay_triplets_dir)));
        }
        m_pimpl->triplets_dirs.emplace_back(triplets);
        m_pimpl->triplets_dirs.emplace_back(community_triplets);
    }

    fs::path VcpkgPaths::package_dir(const PackageSpec& spec) const { return this->packages / fs::u8path(spec.dir()); }
    fs::path VcpkgPaths::build_dir(const PackageSpec& spec) const { return this->buildtrees / fs::u8path(spec.name()); }
    fs::path VcpkgPaths::build_dir(const std::string& package_name) const
    {
        return this->buildtrees / fs::u8path(package_name);
    }

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
        return m_pimpl->available_triplets.get_lazy([this]() -> std::vector<TripletFile> {
            std::vector<TripletFile> output;
            Files::Filesystem& fs = this->get_filesystem();
            for (auto&& triplets_dir : m_pimpl->triplets_dirs)
            {
                for (auto&& path : fs.get_files_non_recursive(triplets_dir))
                {
                    if (fs::is_regular_file(fs.status(VCPKG_LINE_INFO, path)))
                    {
                        output.emplace_back(TripletFile(fs::u8string(path.stem().filename()), triplets_dir));
                    }
                }
            }
            return output;
        });
    }

    const std::map<std::string, std::string>& VcpkgPaths::get_cmake_script_hashes() const
    {
        return m_pimpl->cmake_script_hashes.get_lazy([this]() -> std::map<std::string, std::string> {
            auto& fs = this->get_filesystem();
            std::map<std::string, std::string> helpers;
            auto files = fs.get_files_non_recursive(this->scripts / fs::u8path("cmake"));
            for (auto&& file : files)
            {
                helpers.emplace(fs::u8string(file.stem()),
                                Hash::get_file_hash(VCPKG_LINE_INFO, fs, file, Hash::Algorithm::Sha1));
            }
            return helpers;
        });
    }

    const fs::path VcpkgPaths::get_triplet_file_path(Triplet triplet) const
    {
        return m_pimpl->m_triplets_cache.get_lazy(
            triplet, [&]() -> auto {
                for (const auto& triplet_dir : m_pimpl->triplets_dirs)
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
        return m_pimpl->m_tool_cache->get_tool_path(*this, tool);
    }
    const std::string& VcpkgPaths::get_tool_version(const std::string& tool) const
    {
        return m_pimpl->m_tool_cache->get_tool_version(*this, tool);
    }

    void VcpkgPaths::git_checkout_subpath(const VcpkgPaths& paths,
                                          StringView commit_sha,
                                          const fs::path& subpath,
                                          const fs::path& local_repo,
                                          const fs::path& destination,
                                          const fs::path& dot_git_dir,
                                          const fs::path& work_tree)
    {
        Files::Filesystem& fs = paths.get_filesystem();
        fs.remove_all(work_tree, VCPKG_LINE_INFO);
        fs.remove_all(destination, VCPKG_LINE_INFO);
        fs.remove_all(dot_git_dir, VCPKG_LINE_INFO);

        // All git commands are run with: --git-dir={dot_git_dir} --work-tree={work_tree_temp}
        // git clone --no-checkout --local {vcpkg_root} {dot_git_dir}
        System::CmdLineBuilder clone_cmd_builder = git_cmd_builder(paths, dot_git_dir, work_tree)
                                                       .string_arg("clone")
                                                       .string_arg("--no-checkout")
                                                       .string_arg("--local")
                                                       .path_arg(local_repo)
                                                       .path_arg(dot_git_dir);
        const auto clone_output = System::cmd_execute_and_capture_output(clone_cmd_builder.extract());
        Checks::check_exit(VCPKG_LINE_INFO,
                           clone_output.exit_code == 0,
                           "Failed to clone temporary vcpkg instance.\n%s\n",
                           clone_output.output);

        // git checkout {commit-sha} -- {subpath}
        System::CmdLineBuilder checkout_cmd_builder = git_cmd_builder(paths, dot_git_dir, work_tree)
                                                          .string_arg("checkout")
                                                          .string_arg(commit_sha)
                                                          .string_arg("--")
                                                          .path_arg(subpath);
        const auto checkout_output = System::cmd_execute_and_capture_output(checkout_cmd_builder.extract());
        Checks::check_exit(VCPKG_LINE_INFO,
                           checkout_output.exit_code == 0,
                           "Error: Failed to checkout %s:%s\n%s\n",
                           commit_sha,
                           fs::u8string(subpath),
                           checkout_output.output);

        const fs::path checked_out_path = work_tree / subpath;
        const auto& containing_folder = destination.parent_path();
        if (!fs.exists(containing_folder))
        {
            fs.create_directories(containing_folder, VCPKG_LINE_INFO);
        }

        std::error_code ec;
        fs.rename_or_copy(checked_out_path, destination, ".tmp", ec);
        fs.remove_all(work_tree, VCPKG_LINE_INFO);
        fs.remove_all(dot_git_dir, VCPKG_LINE_INFO);
        if (ec)
        {
            System::printf(System::Color::error,
                           "Error: Couldn't move checked out files from %s to destination %s",
                           fs::u8string(checked_out_path),
                           fs::u8string(destination));
            Checks::exit_fail(VCPKG_LINE_INFO);
        }
    }

    ExpectedS<std::string> VcpkgPaths::git_show(const std::string& treeish, const fs::path& dot_git_dir) const
    {
        // All git commands are run with: --git-dir={dot_git_dir} --work-tree={work_tree_temp}
        // git clone --no-checkout --local {vcpkg_root} {dot_git_dir}
        System::CmdLineBuilder showcmd =
            git_cmd_builder(*this, dot_git_dir, dot_git_dir).string_arg("show").string_arg(treeish);

        auto output = System::cmd_execute_and_capture_output(showcmd.extract());
        if (output.exit_code == 0)
        {
            return {std::move(output.output), expected_left_tag};
        }
        else
        {
            return {std::move(output.output), expected_right_tag};
        }
    }

    void VcpkgPaths::git_checkout_object(const VcpkgPaths& paths,
                                         StringView git_object,
                                         const fs::path& local_repo,
                                         const fs::path& destination,
                                         const fs::path& dot_git_dir,
                                         const fs::path& work_tree)
    {
        Files::Filesystem& fs = paths.get_filesystem();
        fs.remove_all(work_tree, VCPKG_LINE_INFO);
        fs.remove_all(destination, VCPKG_LINE_INFO);

        if (!fs.exists(dot_git_dir))
        {
            // All git commands are run with: --git-dir={dot_git_dir} --work-tree={work_tree_temp}
            // git clone --no-checkout --local {vcpkg_root} {dot_git_dir}
            System::CmdLineBuilder clone_cmd_builder = git_cmd_builder(paths, dot_git_dir, work_tree)
                                                           .string_arg("clone")
                                                           .string_arg("--no-checkout")
                                                           .string_arg("--local")
                                                           .path_arg(local_repo)
                                                           .path_arg(dot_git_dir);
            const auto clone_output = System::cmd_execute_and_capture_output(clone_cmd_builder.extract());
            Checks::check_exit(VCPKG_LINE_INFO,
                               clone_output.exit_code == 0,
                               "Failed to clone temporary vcpkg instance.\n%s\n",
                               clone_output.output);
        }
        else
        {
            System::CmdLineBuilder fetch_cmd_builder =
                git_cmd_builder(paths, dot_git_dir, work_tree).string_arg("fetch");
            const auto fetch_output = System::cmd_execute_and_capture_output(fetch_cmd_builder.extract());
            Checks::check_exit(VCPKG_LINE_INFO,
                               fetch_output.exit_code == 0,
                               "Failed to update refs on temporary vcpkg repository.\n%s\n",
                               fetch_output.output);
        }

        if (!fs.exists(work_tree))
        {
            fs.create_directories(work_tree, VCPKG_LINE_INFO);
        }

        // git checkout {tree_object} .
        System::CmdLineBuilder checkout_cmd_builder = git_cmd_builder(paths, dot_git_dir, work_tree)
                                                          .string_arg("checkout")
                                                          .string_arg(git_object)
                                                          .string_arg(".");
        const auto checkout_output = System::cmd_execute_and_capture_output(checkout_cmd_builder.extract());
        Checks::check_exit(VCPKG_LINE_INFO, checkout_output.exit_code == 0, "Failed to checkout %s", git_object);

        const auto& containing_folder = destination.parent_path();
        if (!fs.exists(containing_folder))
        {
            fs.create_directories(containing_folder, VCPKG_LINE_INFO);
        }

        std::error_code ec;
        fs.rename_or_copy(work_tree, destination, ".tmp", ec);
        fs.remove_all(work_tree, VCPKG_LINE_INFO);
        if (ec)
        {
            System::printf(System::Color::error,
                           "Error: Couldn't move checked out files from %s to destination %s",
                           fs::u8string(work_tree),
                           fs::u8string(destination));
            Checks::exit_fail(VCPKG_LINE_INFO);
        }
    }

    fs::path VcpkgPaths::git_checkout_baseline(Files::Filesystem& fs, StringView commit_sha) const
    {
        const fs::path destination_parent = this->baselines_output / fs::u8path(commit_sha);
        const fs::path destination = destination_parent / fs::u8path("baseline.json");

        if (!fs.exists(destination))
        {
            auto treeish = Strings::concat(commit_sha, ":port_versions/baseline.json");
            auto maybe_contents = git_show(treeish, this->root / fs::u8path(".git"));
            if (auto contents = maybe_contents.get())
            {
                fs.create_directories(destination_parent, VCPKG_LINE_INFO);
                fs.write_contents(destination, *contents, VCPKG_LINE_INFO);
            }
            else
            {
                Checks::exit_with_message(
                    VCPKG_LINE_INFO, "Error: while checking out baseline '%s':\n%s", treeish, maybe_contents.error());
            }
        }
        return destination;
    }

    fs::path VcpkgPaths::git_checkout_port(Files::Filesystem& fs, StringView port_name, StringView git_tree) const
    {
        /* Clone a new vcpkg repository instance using the local instance as base.
         *
         * The `--git-dir` directory will store all the Git metadata files,
         * and the  `--work-tree` is the directory where files will be checked out.
         *
         * Since we are checking a git tree object, all files will be checked out to the root of `work-tree`.
         * Because of that, it makes sense to use the git hash as the name for the directory.
         */
        const fs::path local_repo = this->root;
        const fs::path destination = this->versions_output / fs::u8path(git_tree) / fs::u8path(port_name);

        if (!fs.exists(destination / "CONTROL") && !fs.exists(destination / "vcpkg.json"))
        {
            git_checkout_object(
                *this, git_tree, local_repo, destination, this->versions_dot_git_dir, this->versions_work_tree);
        }
        return destination;
    }

    Optional<const Json::Object&> VcpkgPaths::get_manifest() const
    {
        if (auto p = m_pimpl->m_manifest_doc.get())
        {
            return p->first;
        }
        else
        {
            return nullopt;
        }
    }
    Optional<const fs::path&> VcpkgPaths::get_manifest_path() const
    {
        if (m_pimpl->m_manifest_doc)
        {
            return m_pimpl->m_manifest_path;
        }
        else
        {
            return nullopt;
        }
    }

    const Configuration& VcpkgPaths::get_configuration() const { return m_pimpl->m_config; }

    const Toolset& VcpkgPaths::get_toolset(const Build::PreBuildInfo& prebuildinfo) const
    {
        if (!prebuildinfo.using_vcvars())
        {
            static Toolset external_toolset = []() -> Toolset {
                Toolset ret;
                ret.dumpbin.clear();
                ret.supported_architectures = {
                    ToolsetArchOption{"", System::get_host_processor(), System::get_host_processor()}};
                ret.vcvarsall.clear();
                ret.vcvarsall_options = {};
                ret.version = "external";
                ret.visual_studio_root_path.clear();
                return ret;
            }();
            return external_toolset;
        }

#if !defined(_WIN32)
        Checks::exit_with_message(VCPKG_LINE_INFO, "Cannot build windows triplets from non-windows.");
#else
        const std::vector<Toolset>& vs_toolsets = m_pimpl->toolsets.get_lazy(
            [this]() { return VisualStudio::find_toolset_instances_preferred_first(*this); });

        std::vector<const Toolset*> candidates = Util::fmap(vs_toolsets, [](auto&& x) { return &x; });
        const auto tsv = prebuildinfo.platform_toolset.get();
        auto vsp = prebuildinfo.visual_studio_path.get();
        if (!vsp && !m_pimpl->default_vs_path.empty())
        {
            vsp = &m_pimpl->default_vs_path;
        }

        if (tsv && vsp)
        {
            Util::erase_remove_if(
                candidates, [&](const Toolset* t) { return *tsv != t->version || *vsp != t->visual_studio_root_path; });
            Checks::check_exit(VCPKG_LINE_INFO,
                               !candidates.empty(),
                               "Could not find Visual Studio instance at %s with %s toolset.",
                               fs::u8string(*vsp),
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

    const System::Environment& VcpkgPaths::get_action_env(const Build::AbiInfo& abi_info) const
    {
        return m_pimpl->m_env_cache.get_action_env(*this, abi_info);
    }

    const std::string& VcpkgPaths::get_triplet_info(const Build::AbiInfo& abi_info) const
    {
        return m_pimpl->m_env_cache.get_triplet_info(*this, abi_info);
    }

    const Build::CompilerInfo& VcpkgPaths::get_compiler_info(const Build::AbiInfo& abi_info) const
    {
        return m_pimpl->m_env_cache.get_compiler_info(*this, abi_info);
    }

    Files::Filesystem& VcpkgPaths::get_filesystem() const { return *m_pimpl->fs_ptr; }

    const FeatureFlagSettings& VcpkgPaths::get_feature_flags() const { return m_pimpl->m_ff_settings; }

    void VcpkgPaths::track_feature_flag_metrics() const
    {
        struct
        {
            StringView flag;
            bool enabled;
        } flags[] = {{VcpkgCmdArguments::MANIFEST_MODE_FEATURE, manifest_mode_enabled()}};

        for (const auto& flag : flags)
        {
            Metrics::g_metrics.lock()->track_feature(flag.flag.to_string(), flag.enabled);
        }
    }

    VcpkgPaths::~VcpkgPaths()
    {
        std::error_code ec;
        if (m_pimpl->file_lock_handle.is_valid())
        {
            m_pimpl->fs_ptr->unlock_file_lock(m_pimpl->file_lock_handle, ec);
            if (ec)
            {
                Debug::print("Failed to unlock filesystem lock: ", ec.message(), '\n');
            }
        }
    }
}
