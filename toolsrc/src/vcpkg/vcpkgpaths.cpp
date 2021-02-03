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

    System::Command git_cmd_builder(const VcpkgPaths& paths, const fs::path& dot_git_dir, const fs::path& work_tree)
    {
        return System::Command()
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
        auto deserializer = make_configuration_deserializer(filepath.parent_path());

        auto parsed_config_opt = reader.visit(obj, *deserializer);
        if (!reader.errors().empty())
        {
            System::print2(System::Color::error, "Errors occurred while parsing ", fs::u8string(filepath), "\n");
            for (auto&& msg : reader.errors())
                System::print2("    ", msg, '\n');

            System::print2("See https://github.com/Microsoft/vcpkg/tree/master/docs/specifications/registries.md for "
                           "more information.\n");
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        parsed_config_opt.get()->validate_feature_flags(args.feature_flag_settings());

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
            Checks::exit_maybe_upgrade(VCPKG_LINE_INFO,
                                       "Failed to load manifest from directory %s: %s",
                                       fs::u8string(manifest_dir),
                                       ec.message());
        }

        if (!manifest_opt.has_value())
        {
            Checks::exit_maybe_upgrade(VCPKG_LINE_INFO,
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
        if (manifest_dir.empty())
        {
            // classic mode
            config_dir = vcpkg_root;
        }
        else
        {
            // manifest mode
            config_dir = manifest_dir;
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
                const auto& cache_root =
                    System::get_platform_cache_home().value_or_exit(VCPKG_LINE_INFO) / fs::u8path("vcpkg");
                registries_work_tree_dir = cache_root / fs::u8path("registries") / fs::u8path("git");
                registries_dot_git_dir = registries_work_tree_dir / fs::u8path(".git");
                registries_git_trees = cache_root / fs::u8path("registries") / fs::u8path("git-trees");
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

            fs::path registries_work_tree_dir;
            fs::path registries_dot_git_dir;
            fs::path registries_git_trees;
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
        builtin_ports =
            process_output_directory(filesystem, root, args.builtin_ports_root_dir.get(), "ports", VCPKG_LINE_INFO);
        builtin_registry_versions = process_output_directory(
            filesystem, root, args.builtin_registry_versions_dir.get(), "versions", VCPKG_LINE_INFO);
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
        // git clone --no-checkout --local --no-hardlinks {vcpkg_root} {dot_git_dir}
        // note that `--no-hardlinks` is added because otherwise, git fails to clone in some cases
        System::Command clone_cmd_builder = git_cmd_builder(paths, dot_git_dir, work_tree)
                                                .string_arg("clone")
                                                .string_arg("--no-checkout")
                                                .string_arg("--local")
                                                .string_arg("--no-hardlinks")
                                                .path_arg(local_repo)
                                                .path_arg(dot_git_dir);
        const auto clone_output = System::cmd_execute_and_capture_output(clone_cmd_builder);
        Checks::check_exit(VCPKG_LINE_INFO,
                           clone_output.exit_code == 0,
                           "Failed to clone temporary vcpkg instance.\n%s\n",
                           clone_output.output);

        // git checkout {commit-sha} -- {subpath}
        System::Command checkout_cmd_builder = git_cmd_builder(paths, dot_git_dir, work_tree)
                                                   .string_arg("checkout")
                                                   .string_arg(commit_sha)
                                                   .string_arg("--")
                                                   .path_arg(subpath);
        const auto checkout_output = System::cmd_execute_and_capture_output(checkout_cmd_builder);
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

    ExpectedS<std::string> VcpkgPaths::get_current_git_sha() const
    {
        auto cmd = git_cmd_builder(*this, this->root / fs::u8path(".git"), this->root);
        cmd.string_arg("rev-parse").string_arg("HEAD");
        auto output = System::cmd_execute_and_capture_output(cmd);
        if (output.exit_code != 0)
        {
            return {std::move(output.output), expected_right_tag};
        }
        else
        {
            return {Strings::trim(std::move(output.output)), expected_left_tag};
        }
    }
    std::string VcpkgPaths::get_current_git_sha_message() const
    {
        auto maybe_cur_sha = get_current_git_sha();
        if (auto p_sha = maybe_cur_sha.get())
        {
            return Strings::concat("The current commit is \"", *p_sha, '"');
        }
        else
        {
            return Strings::concat("Failed to determine the current commit:\n", maybe_cur_sha.error());
        }
    }

    ExpectedS<std::string> VcpkgPaths::git_show(const std::string& treeish, const fs::path& dot_git_dir) const
    {
        // All git commands are run with: --git-dir={dot_git_dir} --work-tree={work_tree_temp}
        // git clone --no-checkout --local {vcpkg_root} {dot_git_dir}
        System::Command showcmd =
            git_cmd_builder(*this, dot_git_dir, dot_git_dir).string_arg("show").string_arg(treeish);

        auto output = System::cmd_execute_and_capture_output(showcmd);
        if (output.exit_code == 0)
        {
            return {std::move(output.output), expected_left_tag};
        }
        else
        {
            return {std::move(output.output), expected_right_tag};
        }
    }

    ExpectedS<std::map<std::string, std::string, std::less<>>> VcpkgPaths::git_get_local_port_treeish_map() const
    {
        const auto local_repo = this->root / fs::u8path(".git");
        const auto path_with_separator =
            Strings::concat(fs::u8string(this->builtin_ports_directory()), Files::preferred_separator);
        const auto git_cmd = git_cmd_builder(*this, local_repo, this->root)
                                 .string_arg("ls-tree")
                                 .string_arg("-d")
                                 .string_arg("HEAD")
                                 .string_arg("--")
                                 .path_arg(path_with_separator);

        auto output = System::cmd_execute_and_capture_output(git_cmd);
        if (output.exit_code != 0)
            return Strings::format("Error: Couldn't get local treeish objects for ports.\n%s", output.output);

        std::map<std::string, std::string, std::less<>> ret;
        auto lines = Strings::split(output.output, '\n');
        // The first line of the output is always the parent directory itself.
        for (auto line : lines)
        {
            // The default output comes in the format:
            // <mode> SP <type> SP <object> TAB <file>
            auto split_line = Strings::split(line, '\t');
            if (split_line.size() != 2)
                return Strings::format("Error: Unexpected output from command `%s`. Couldn't split by `\\t`.\n%s",
                                       git_cmd.command_line(),
                                       line);

            auto file_info_section = Strings::split(split_line[0], ' ');
            if (file_info_section.size() != 3)
                return Strings::format("Error: Unexepcted output from command `%s`. Couldn't split by ` `.\n%s",
                                       git_cmd.command_line(),
                                       line);

            const auto index = split_line[1].find_last_of('/');
            if (index == std::string::npos)
            {
                return Strings::format("Error: Unexpected output from command `%s`. Couldn't split by `/`.\n%s",
                                       git_cmd.command_line(),
                                       line);
            }

            ret.emplace(split_line[1].substr(index + 1), file_info_section.back());
        }
        return ret;
    }

    ExpectedS<fs::path> VcpkgPaths::git_checkout_baseline(StringView commit_sha) const
    {
        Files::Filesystem& fs = get_filesystem();
        const fs::path destination_parent = this->baselines_output / fs::u8path(commit_sha);
        fs::path destination = destination_parent / fs::u8path("baseline.json");

        if (!fs.exists(destination))
        {
            const fs::path destination_tmp = destination_parent / fs::u8path("baseline.json.tmp");
            auto treeish = Strings::concat(commit_sha, ":versions/baseline.json");
            auto maybe_contents = git_show(treeish, this->root / fs::u8path(".git"));
            if (auto contents = maybe_contents.get())
            {
                std::error_code ec;
                fs.create_directories(destination_parent, ec);
                if (ec)
                {
                    return {Strings::format(
                                "Error: while checking out baseline %s\nError: while creating directories %s: %s",
                                commit_sha,
                                fs::u8string(destination_parent),
                                ec.message()),
                            expected_right_tag};
                }
                fs.write_contents(destination_tmp, *contents, ec);
                if (ec)
                {
                    return {Strings::format("Error: while checking out baseline %s\nError: while writing %s: %s",
                                            commit_sha,
                                            fs::u8string(destination_tmp),
                                            ec.message()),
                            expected_right_tag};
                }
                fs.rename(destination_tmp, destination, ec);
                if (ec)
                {
                    return {Strings::format("Error: while checking out baseline %s\nError: while renaming %s to %s: %s",
                                            commit_sha,
                                            fs::u8string(destination_tmp),
                                            fs::u8string(destination),
                                            ec.message()),
                            expected_right_tag};
                }
            }
            else
            {
                return {Strings::format("Error: while checking out baseline '%s':\n%s\nThis may be fixed by updating "
                                        "vcpkg to the latest master via `git pull`.",
                                        treeish,
                                        maybe_contents.error()),
                        expected_right_tag};
            }
        }
        return destination;
    }

    ExpectedS<fs::path> VcpkgPaths::git_checkout_port(StringView port_name,
                                                      StringView git_tree,
                                                      const fs::path& dot_git_dir) const
    {
        /* Check out a git tree into the versioned port recipes folder
         *
         * Since we are checking a git tree object, all files will be checked out to the root of `work-tree`.
         * Because of that, it makes sense to use the git hash as the name for the directory.
         */
        Files::Filesystem& fs = get_filesystem();
        fs::path destination = this->versions_output / fs::u8path(port_name) / fs::u8path(git_tree);
        if (fs.exists(destination))
        {
            return destination;
        }

        const fs::path destination_tmp =
            this->versions_output / fs::u8path(port_name) / fs::u8path(Strings::concat(git_tree, ".tmp"));
        const fs::path destination_tar =
            this->versions_output / fs::u8path(port_name) / fs::u8path(Strings::concat(git_tree, ".tar"));
#define PRELUDE "Error: while checking out port ", port_name, " with git tree ", git_tree, "\n"
        std::error_code ec;
        fs::path failure_point;
        fs.remove_all(destination_tmp, ec, failure_point);
        if (ec)
        {
            return {Strings::concat(PRELUDE, "Error: while removing ", fs::u8string(failure_point), ": ", ec.message()),
                    expected_right_tag};
        }
        fs.create_directories(destination_tmp, ec);
        if (ec)
        {
            return {
                Strings::concat(
                    PRELUDE, "Error: while creating directories ", fs::u8string(destination_tmp), ": ", ec.message()),
                expected_right_tag};
        }

        auto tar_cmd_builder = git_cmd_builder(*this, dot_git_dir, dot_git_dir)
                                   .string_arg("archive")
                                   .string_arg(git_tree)
                                   .string_arg("-o")
                                   .path_arg(destination_tar);
        const auto tar_output = System::cmd_execute_and_capture_output(tar_cmd_builder);
        if (tar_output.exit_code != 0)
        {
            return {Strings::concat(PRELUDE, "Error: Failed to tar port directory\n", tar_output.output),
                    expected_right_tag};
        }

        auto extract_cmd_builder = System::Command{this->get_tool_exe(Tools::CMAKE)}
                                       .string_arg("-E")
                                       .string_arg("tar")
                                       .string_arg("xf")
                                       .path_arg(destination_tar);

        const auto extract_output =
            System::cmd_execute_and_capture_output(extract_cmd_builder, System::InWorkingDirectory{destination_tmp});
        if (extract_output.exit_code != 0)
        {
            return {Strings::concat(PRELUDE, "Error: Failed to extract port directory\n", extract_output.output),
                    expected_right_tag};
        }
        fs.remove(destination_tar, ec);
        if (ec)
        {
            return {
                Strings::concat(PRELUDE, "Error: while removing ", fs::u8string(destination_tar), ": ", ec.message()),
                expected_right_tag};
        }
        fs.rename(destination_tmp, destination, ec);
        if (ec)
        {
            return {Strings::concat(PRELUDE,
                                    "Error: while renaming ",
                                    fs::u8string(destination_tmp),
                                    " to ",
                                    fs::u8string(destination),
                                    ": ",
                                    ec.message()),
                    expected_right_tag};
        }

        return destination;
#undef PRELUDE
    }

    ExpectedS<std::string> VcpkgPaths::git_fetch_from_remote_registry(StringView repo, StringView treeish) const
    {
        auto& fs = get_filesystem();

        auto work_tree = m_pimpl->registries_work_tree_dir;
        fs.create_directories(work_tree, VCPKG_LINE_INFO);
        auto dot_git_dir = m_pimpl->registries_dot_git_dir;

        System::Command init_registries_git_dir = git_cmd_builder(*this, dot_git_dir, work_tree).string_arg("init");
        auto init_output = System::cmd_execute_and_capture_output(init_registries_git_dir);
        if (init_output.exit_code != 0)
        {
            return {Strings::format("Error: Failed to initialize local repository %s.\n%s\n",
                                    fs::u8string(work_tree),
                                    init_output.output),
                    expected_right_tag};
        }

        auto lock_file = work_tree / fs::u8path(".vcpkg-lock");

        std::error_code ec;
        Files::ExclusiveFileLock guard(Files::ExclusiveFileLock::Wait::Yes, fs, lock_file, ec);

        System::Command fetch_git_ref =
            git_cmd_builder(*this, dot_git_dir, work_tree).string_arg("fetch").string_arg("--").string_arg(repo);
        if (treeish.size() != 0)
        {
            fetch_git_ref.string_arg(treeish);
        }

        auto fetch_output = System::cmd_execute_and_capture_output(fetch_git_ref);
        if (fetch_output.exit_code != 0)
        {
            return {Strings::format("Error: Failed to fetch %s%s from repository %s.\n%s\n",
                                    treeish.size() != 0 ? "ref " : "",
                                    treeish,
                                    repo,
                                    fetch_output.output),
                    expected_right_tag};
        }

        System::Command get_fetch_head =
            git_cmd_builder(*this, dot_git_dir, work_tree).string_arg("rev-parse").string_arg("FETCH_HEAD");
        auto fetch_head_output = System::cmd_execute_and_capture_output(get_fetch_head);
        if (fetch_head_output.exit_code != 0)
        {
            return {Strings::format("Error: Failed to rev-parse FETCH_HEAD.\n%s\n", fetch_head_output.output),
                    expected_right_tag};
        }
        return {Strings::trim(fetch_head_output.output).to_string(), expected_left_tag};
    }
    // returns an error if there was an unexpected error; returns nullopt if the file doesn't exist at the specified
    // hash
    ExpectedS<std::string> VcpkgPaths::git_show_from_remote_registry(StringView hash,
                                                                     const fs::path& relative_path) const
    {
        auto revision = Strings::format("%s:%s", hash, fs::generic_u8string(relative_path));
        System::Command git_show =
            git_cmd_builder(*this, m_pimpl->registries_dot_git_dir, m_pimpl->registries_work_tree_dir)
                .string_arg("show")
                .string_arg(revision);

        auto git_show_output = System::cmd_execute_and_capture_output(git_show);
        if (git_show_output.exit_code != 0)
        {
            return {git_show_output.output, expected_right_tag};
        }
        return {git_show_output.output, expected_left_tag};
    }
    ExpectedS<std::string> VcpkgPaths::git_find_object_id_for_remote_registry_path(StringView hash,
                                                                                   const fs::path& relative_path) const
    {
        auto revision = Strings::format("%s:%s", hash, fs::generic_u8string(relative_path));
        System::Command git_rev_parse =
            git_cmd_builder(*this, m_pimpl->registries_dot_git_dir, m_pimpl->registries_work_tree_dir)
                .string_arg("rev-parse")
                .string_arg(revision);

        auto git_rev_parse_output = System::cmd_execute_and_capture_output(git_rev_parse);
        if (git_rev_parse_output.exit_code != 0)
        {
            return {git_rev_parse_output.output, expected_right_tag};
        }
        return {Strings::trim(git_rev_parse_output.output).to_string(), expected_left_tag};
    }
    ExpectedS<fs::path> VcpkgPaths::git_checkout_object_from_remote_registry(StringView object) const
    {
        auto& fs = get_filesystem();
        fs.create_directories(m_pimpl->registries_git_trees, VCPKG_LINE_INFO);

        auto git_tree_final = m_pimpl->registries_git_trees / fs::u8path(object);
        if (fs.exists(git_tree_final))
        {
            return std::move(git_tree_final);
        }

        auto pid = System::get_process_id();

        fs::path git_tree_temp = fs::u8path(Strings::format("%s.tmp%ld", fs::u8string(git_tree_final), pid));
        fs::path git_tree_temp_tar = fs::u8path(Strings::format("%s.tmp%ld.tar", fs::u8string(git_tree_final), pid));
        fs.remove_all(git_tree_temp, VCPKG_LINE_INFO);
        fs.create_directory(git_tree_temp, VCPKG_LINE_INFO);

        auto dot_git_dir = m_pimpl->registries_dot_git_dir;
        System::Command git_archive = git_cmd_builder(*this, dot_git_dir, m_pimpl->registries_work_tree_dir)
                                          .string_arg("archive")
                                          .string_arg("--format")
                                          .string_arg("tar")
                                          .string_arg(object)
                                          .string_arg("--output")
                                          .path_arg(git_tree_temp_tar);
        auto git_archive_output = System::cmd_execute_and_capture_output(git_archive);
        if (git_archive_output.exit_code != 0)
        {
            return {Strings::format("git archive failed with message:\n%s", git_archive_output.output),
                    expected_right_tag};
        }

        auto untar =
            System::Command{get_tool_exe(Tools::CMAKE)}.string_arg("-E").string_arg("tar").string_arg("xf").path_arg(
                git_tree_temp_tar);

        auto untar_output = System::cmd_execute_and_capture_output(untar, System::InWorkingDirectory{git_tree_temp});
        if (untar_output.exit_code != 0)
        {
            return {Strings::format("cmake's untar failed with message:\n%s", untar_output.output), expected_right_tag};
        }

        std::error_code ec;
        fs.rename(git_tree_temp, git_tree_final, ec);

        if (fs.exists(git_tree_final))
        {
            return git_tree_final;
        }
        if (ec)
        {
            return {
                Strings::format("rename to %s failed with message:\n%s", fs::u8string(git_tree_final), ec.message()),
                expected_right_tag};
        }
        else
        {
            return {"Unknown error", expected_right_tag};
        }
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
        Checks::exit_maybe_upgrade(VCPKG_LINE_INFO, "Cannot build windows triplets from non-windows.");
#else
        View<Toolset> vs_toolsets = get_all_toolsets();

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

    View<Toolset> VcpkgPaths::get_all_toolsets() const
    {
#if defined(_WIN32)
        return m_pimpl->toolsets.get_lazy(
            [this]() { return VisualStudio::find_toolset_instances_preferred_first(*this); });
#else
        return {};
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
