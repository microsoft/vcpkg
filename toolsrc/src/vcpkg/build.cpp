#include "pch.h"

#include <vcpkg/base/checks.h>
#include <vcpkg/base/chrono.h>
#include <vcpkg/base/enums.h>
#include <vcpkg/base/hash.h>
#include <vcpkg/base/optional.h>
#include <vcpkg/base/stringliteral.h>
#include <vcpkg/base/system.debug.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/base/util.h>

#include <vcpkg/build.h>
#include <vcpkg/commands.h>
#include <vcpkg/dependencies.h>
#include <vcpkg/globalstate.h>
#include <vcpkg/help.h>
#include <vcpkg/input.h>
#include <vcpkg/metrics.h>
#include <vcpkg/paragraphs.h>
#include <vcpkg/postbuildlint.h>
#include <vcpkg/statusparagraphs.h>
#include <vcpkg/vcpkglib.h>

using vcpkg::Build::BuildResult;
using vcpkg::Dependencies::PathsPortFileProvider;
using vcpkg::Parse::ParseControlErrorInfo;
using vcpkg::Parse::ParseExpected;

namespace vcpkg::Build::Command
{
    using Dependencies::InstallPlanAction;
    using Dependencies::InstallPlanType;

    void perform_and_exit_ex(const FullPackageSpec& full_spec,
                             const SourceControlFileLocation& scfl,
                             const ParsedArguments& options,
                             const VcpkgPaths& paths)
    {
        vcpkg::Util::unused(options);

        const StatusParagraphs status_db = database_load_check(paths);
        const PackageSpec& spec = full_spec.package_spec;
        const SourceControlFile& scf = *scfl.source_control_file;

        Checks::check_exit(VCPKG_LINE_INFO,
                           spec.name() == scf.core_paragraph->name,
                           "The Source field inside the CONTROL file does not match the port directory: '%s' != '%s'",
                           scf.core_paragraph->name,
                           spec.name());

        const Build::BuildPackageOptions build_package_options{
            Build::UseHeadVersion::NO,
            Build::AllowDownloads::YES,
            Build::OnlyDownloads::NO,
            Build::CleanBuildtrees::NO,
            Build::CleanPackages::NO,
            Build::CleanDownloads::NO,
            Build::DownloadTool::BUILT_IN,
            GlobalState::g_binary_caching ? Build::BinaryCaching::YES : Build::BinaryCaching::NO,
            Build::FailOnTombstone::NO,
        };

        std::set<std::string> features_as_set(full_spec.features.begin(), full_spec.features.end());
        features_as_set.emplace("core");

        const Build::BuildPackageConfig build_config{scfl, spec.triplet(), build_package_options, features_as_set};

        const auto build_timer = Chrono::ElapsedTimer::create_started();
        const auto result = Build::build_package(paths, build_config, status_db);
        System::print2("Elapsed time for package ", spec, ": ", build_timer, '\n');

        if (result.code == BuildResult::CASCADED_DUE_TO_MISSING_DEPENDENCIES)
        {
            System::print2(System::Color::error,
                           "The build command requires all dependencies to be already installed.\n");
            System::print2("The following dependencies are missing:\n\n");
            for (const auto& p : result.unmet_dependencies)
            {
                System::print2("    ", p, '\n');
            }
            System::print2('\n');
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        Checks::check_exit(VCPKG_LINE_INFO, result.code != BuildResult::EXCLUDED);

        if (result.code != BuildResult::SUCCEEDED)
        {
            System::print2(System::Color::error, Build::create_error_message(result.code, spec), '\n');
            System::print2(Build::create_user_troubleshooting_message(spec), '\n');
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }

    const CommandStructure COMMAND_STRUCTURE = {
        Help::create_example_string("build zlib:x64-windows"),
        1,
        1,
        {{}, {}},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet)
    {
        // Build only takes a single package and all dependencies must already be installed
        const ParsedArguments options = args.parse_arguments(COMMAND_STRUCTURE);
        std::string first_arg = args.command_arguments.at(0);

        const FullPackageSpec spec = Input::check_and_get_full_package_spec(
            std::move(first_arg), default_triplet, COMMAND_STRUCTURE.example_text);

        Input::check_triplet(spec.package_spec.triplet(), paths);

        PathsPortFileProvider provider(paths, args.overlay_ports.get());
        const auto port_name = spec.package_spec.name();
        const auto* scfl = provider.get_control_file(port_name).get();

        Checks::check_exit(VCPKG_LINE_INFO, scfl != nullptr, "Error: Couldn't find port '%s'", port_name);

        perform_and_exit_ex(spec, *scfl, options, paths);
    }
}

namespace vcpkg::Build
{
    static const std::string NAME_EMPTY_PACKAGE = "PolicyEmptyPackage";
    static const std::string NAME_DLLS_WITHOUT_LIBS = "PolicyDLLsWithoutLIBs";
    static const std::string NAME_ONLY_RELEASE_CRT = "PolicyOnlyReleaseCRT";
    static const std::string NAME_EMPTY_INCLUDE_FOLDER = "PolicyEmptyIncludeFolder";
    static const std::string NAME_ALLOW_OBSOLETE_MSVCRT = "PolicyAllowObsoleteMsvcrt";

    const std::string& to_string(BuildPolicy policy)
    {
        switch (policy)
        {
            case BuildPolicy::EMPTY_PACKAGE: return NAME_EMPTY_PACKAGE;
            case BuildPolicy::DLLS_WITHOUT_LIBS: return NAME_DLLS_WITHOUT_LIBS;
            case BuildPolicy::ONLY_RELEASE_CRT: return NAME_ONLY_RELEASE_CRT;
            case BuildPolicy::EMPTY_INCLUDE_FOLDER: return NAME_EMPTY_INCLUDE_FOLDER;
            case BuildPolicy::ALLOW_OBSOLETE_MSVCRT: return NAME_ALLOW_OBSOLETE_MSVCRT;
            default: Checks::unreachable(VCPKG_LINE_INFO);
        }
    }

    CStringView to_cmake_variable(BuildPolicy policy)
    {
        switch (policy)
        {
            case BuildPolicy::EMPTY_PACKAGE: return "VCPKG_POLICY_EMPTY_PACKAGE";
            case BuildPolicy::DLLS_WITHOUT_LIBS: return "VCPKG_POLICY_DLLS_WITHOUT_LIBS";
            case BuildPolicy::ONLY_RELEASE_CRT: return "VCPKG_POLICY_ONLY_RELEASE_CRT";
            case BuildPolicy::EMPTY_INCLUDE_FOLDER: return "VCPKG_POLICY_EMPTY_INCLUDE_FOLDER";
            case BuildPolicy::ALLOW_OBSOLETE_MSVCRT: return "VCPKG_POLICY_ALLOW_OBSOLETE_MSVCRT";
            default: Checks::unreachable(VCPKG_LINE_INFO);
        }
    }

    static const std::string NAME_BUILD_IN_DOWNLOAD = "BUILT_IN";
    static const std::string NAME_ARIA2_DOWNLOAD = "ARIA2";

    const std::string& to_string(DownloadTool tool)
    {
        switch (tool)
        {
            case DownloadTool::BUILT_IN: return NAME_BUILD_IN_DOWNLOAD;
            case DownloadTool::ARIA2: return NAME_ARIA2_DOWNLOAD;
            default: Checks::unreachable(VCPKG_LINE_INFO);
        }
    }

    Optional<LinkageType> to_linkage_type(const std::string& str)
    {
        if (str == "dynamic") return LinkageType::DYNAMIC;
        if (str == "static") return LinkageType::STATIC;
        return nullopt;
    }

    namespace BuildInfoRequiredField
    {
        static const std::string CRT_LINKAGE = "CRTLinkage";
        static const std::string LIBRARY_LINKAGE = "LibraryLinkage";
    }

    static CStringView to_vcvarsall_target(const std::string& cmake_system_name)
    {
        if (cmake_system_name.empty()) return "";
        if (cmake_system_name == "Windows") return "";
        if (cmake_system_name == "WindowsStore") return "store";

        Checks::exit_with_message(VCPKG_LINE_INFO, "Unsupported vcvarsall target %s", cmake_system_name);
    }

    static CStringView to_vcvarsall_toolchain(const std::string& target_architecture, const Toolset& toolset)
    {
        return toolset.arch.name;      
    }

    static auto make_env_passthrough(const PreBuildInfo& pre_build_info) -> std::unordered_map<std::string, std::string>
    {
        std::unordered_map<std::string, std::string> env;

        for (auto&& env_var : pre_build_info.passthrough_env_vars)
        {
            auto env_val = System::get_environment_variable(env_var);

            if (env_val)
            {
                env[env_var] = env_val.value_or_exit(VCPKG_LINE_INFO);
            }
        }

        return env;
    }

    std::string make_build_env_cmd(const PreBuildInfo& pre_build_info, const Toolset& toolset)
    {
        if (pre_build_info.external_toolchain_file.has_value() && !pre_build_info.force_vcvar_load) return "";
        if (!pre_build_info.cmake_system_name.empty() && pre_build_info.cmake_system_name != "WindowsStore" && !pre_build_info.force_vcvar_load) return "";

        const char* tonull = " >nul";
        if (Debug::g_debugging)
        {
            tonull = "";
        }

        const auto vs_toolchain = to_vcvarsall_toolchain(pre_build_info.target_architecture, toolset);
        const auto target = to_vcvarsall_target(pre_build_info.cmake_system_name);

        return Strings::format(R"("%s" %s %s %s %s 2>&1 <NUL)",
                               toolset.vcvarsall.u8string(),
                               Strings::join(" ", toolset.vcvarsall_options),
                               vs_toolchain,
                               target,
                               tonull);
    }

    static BinaryParagraph create_binary_feature_control_file(const SourceParagraph& source_paragraph,
                                                              const FeatureParagraph& feature_paragraph,
                                                              const Triplet& triplet)
    {
        return BinaryParagraph(source_paragraph, feature_paragraph, triplet);
    }

    static std::unique_ptr<BinaryControlFile> create_binary_control_file(const SourceParagraph& source_paragraph,
                                                                         const Triplet& triplet,
                                                                         const BuildInfo& build_info,
                                                                         const std::string& abi_tag)
    {
        auto bcf = std::make_unique<BinaryControlFile>();
        BinaryParagraph bpgh(source_paragraph, triplet, abi_tag);
        if (const auto p_ver = build_info.version.get())
        {
            bpgh.version = *p_ver;
        }

        bcf->core_paragraph = std::move(bpgh);
        return bcf;
    }

    static void write_binary_control_file(const VcpkgPaths& paths, const BinaryControlFile& bcf)
    {
        std::string start = Strings::serialize(bcf.core_paragraph);
        for (auto&& feature : bcf.features)
        {
            start += "\n" + Strings::serialize(feature);
        }
        const fs::path binary_control_file = paths.packages / bcf.core_paragraph.dir() / "CONTROL";
        paths.get_filesystem().write_contents(binary_control_file, start, VCPKG_LINE_INFO);
    }

    static std::vector<Features> get_dependencies(const SourceControlFile& scf,
                                                  const std::set<std::string>& feature_list,
                                                  const Triplet& triplet)
    {
        return Util::fmap_flatten(feature_list, [&](std::string const& feature) -> std::vector<Features> {
            if (feature == "core")
            {
                return filter_dependencies_to_features(scf.core_paragraph->depends, triplet);
            }

            auto maybe_feature = scf.find_feature(feature);
            Checks::check_exit(VCPKG_LINE_INFO, maybe_feature.has_value());

            return filter_dependencies_to_features(maybe_feature.get()->depends, triplet);
        });
    }

    static std::vector<std::string> get_dependency_names(const SourceControlFile& scf,
                                                         const std::set<std::string>& feature_list,
                                                         const Triplet& triplet)
    {
        return Util::sort_unique_erase(
            Util::fmap(get_dependencies(scf, feature_list, triplet), [&](const Features& feat) { return feat.name; }));
    }

    static std::vector<FeatureSpec> compute_required_feature_specs(const BuildPackageConfig& config,
                                                                   const StatusParagraphs& status_db)
    {
        const Triplet& triplet = config.triplet;

        const std::vector<std::string> dep_strings = get_dependency_names(config.scf, config.feature_list, triplet);

        auto dep_fspecs = FeatureSpec::from_strings_and_triplet(dep_strings, triplet);
        Util::sort_unique_erase(dep_fspecs);

        // expand defaults
        std::vector<FeatureSpec> ret;
        for (auto&& fspec : dep_fspecs)
        {
            if (fspec.feature().empty())
            {
                // reference to default features
                const auto it = status_db.find_installed(fspec.spec());
                if (it == status_db.end())
                {
                    // not currently installed, so just leave the default reference so it will fail later
                    ret.push_back(fspec);
                }
                else
                {
                    ret.emplace_back(fspec.spec(), "core");
                    for (auto&& default_feature : it->get()->package.default_features)
                        ret.emplace_back(fspec.spec(), default_feature);
                }
            }
            else
            {
                ret.push_back(fspec);
            }
        }
        Util::sort_unique_erase(ret);

        return ret;
    }

    static int get_concurrency()
    {
        static int concurrency = [] {
            auto user_defined_concurrency = System::get_environment_variable("VCPKG_MAX_CONCURRENCY");
            if (user_defined_concurrency)
            {
                return std::stoi(user_defined_concurrency.value_or_exit(VCPKG_LINE_INFO));
            }
            else
            {
                return System::get_num_logical_cores() + 1;
            }
        }();

        return concurrency;
    }

    static std::vector<System::CMakeVariable> get_cmake_vars(const VcpkgPaths& paths,
                                                             const BuildPackageConfig& config,
                                                             const Triplet& triplet,
                                                             const Toolset& toolset)
    {
#if !defined(_WIN32)
        // TODO: remove when vcpkg.exe is in charge for acquiring tools. Change introduced in vcpkg v0.0.107.
        // bootstrap should have already downloaded ninja, but making sure it is present in case it was deleted.
        vcpkg::Util::unused(paths.get_tool_exe(Tools::NINJA));
#endif

        const fs::path& git_exe_path = paths.get_tool_exe(Tools::GIT);

        std::string all_features;
        for (auto& feature : config.scf.feature_paragraphs)
        {
            all_features.append(feature->name + ";");
        }

        std::vector<System::CMakeVariable> variables{
            {"CMD", "BUILD"},
            {"PORT", config.scf.core_paragraph->name},
            {"CURRENT_PORT_DIR", config.port_dir},
            {"VCPKG_ROOT_PATH", paths.root},
            {"TARGET_TRIPLET", triplet.canonical_name()},
            {"TARGET_TRIPLET_FILE", paths.get_triplet_file_path(triplet).u8string()},
            {"VCPKG_PLATFORM_TOOLSET", toolset.name.c_str()},
            {"VCPKG_CMAKE_VS_GENERATOR", toolset.cmake_generator.c_str()},
            {"VCPKG_USE_HEAD_VERSION", Util::Enum::to_bool(config.build_package_options.use_head_version) ? "1" : "0"},
            {"DOWNLOADS", paths.downloads},
            {"_VCPKG_NO_DOWNLOADS", !Util::Enum::to_bool(config.build_package_options.allow_downloads) ? "1" : "0"},
            {"_VCPKG_DOWNLOAD_TOOL", to_string(config.build_package_options.download_tool)},
            {"FEATURES", Strings::join(";", config.feature_list)},
            {"ALL_FEATURES", all_features},
            {"VCPKG_CONCURRENCY", std::to_string(get_concurrency())},
        };

        if (Util::Enum::to_bool(config.build_package_options.only_downloads))
        {
            variables.push_back({"VCPKG_DOWNLOAD_MODE", "true"});
        }

        if (!System::get_environment_variable("VCPKG_FORCE_SYSTEM_BINARIES").has_value())
        {
            variables.push_back({"GIT", git_exe_path});
        }

        const Files::Filesystem& fs = paths.get_filesystem();
        if (fs.is_regular_file(config.port_dir / "environment-overrides.cmake"))
        {
            variables.emplace_back("VCPKG_ENV_OVERRIDES_FILE", config.port_dir / "environment-overrides.cmake");
        }

        std::vector<FeatureSpec> dependencies =
            filter_dependencies_to_specs(config.scfl.source_control_file->core_paragraph->depends, triplet);

        std::vector<std::string> port_toolchains;
        for (const FeatureSpec& dependency : dependencies)
        {
            const fs::path port_toolchain_path = paths.installed / dependency.triplet().canonical_name() / "share" /
                                                 dependency.spec().name() / "port-toolchain.cmake";

            if (fs.is_regular_file(port_toolchain_path))
            {
                System::print2(port_toolchain_path.u8string());
                port_toolchains.emplace_back(port_toolchain_path.u8string());
            }
        }

        if (!port_toolchains.empty())
        {
            variables.emplace_back("VCPKG_PORT_TOOLCHAINS", Strings::join(";", port_toolchains));
        }

        return variables;
    }

    static std::string make_build_cmd(const VcpkgPaths& paths,
                                      const PreBuildInfo& pre_build_info,
                                      const BuildPackageConfig& config,
                                      const Triplet& triplet)
    {
        const Toolset& toolset = paths.get_toolset(pre_build_info);
        const fs::path& cmake_exe_path = paths.get_tool_exe(Tools::CMAKE);
        std::vector<System::CMakeVariable> variables = get_cmake_vars(paths, config, triplet, toolset);

        const std::string cmd_launch_cmake =
            System::make_cmake_cmd(cmake_exe_path, paths.ports_cmake, variables, toolset.name);

        std::string command = make_build_env_cmd(pre_build_info, toolset);

        if (!command.empty())
        {
#ifdef _WIN32
            command.append(" & ");
#else
            command.append(" && ");
#endif
        }

        command.append(cmd_launch_cmake);

        return command;
    }

    static std::string get_triplet_abi(const VcpkgPaths& paths,
                                       const PreBuildInfo& pre_build_info,
                                       const Triplet& triplet)
    {
        static std::map<fs::path, std::string> s_hash_cache;

        const fs::path triplet_file_path = paths.get_triplet_file_path(triplet);
        const auto& fs = paths.get_filesystem();

        std::string hash;

        auto it_hash = s_hash_cache.find(triplet_file_path);
        if (it_hash != s_hash_cache.end())
        {
            hash = it_hash->second;
        }
        else
        {
            const auto algo = Hash::Algorithm::Sha1;
            hash = Hash::get_file_hash(VCPKG_LINE_INFO, fs, triplet_file_path, algo);

            if (auto p = pre_build_info.external_toolchain_file.get())
            {
                hash += "-";
                hash += Hash::get_file_hash(VCPKG_LINE_INFO, fs, *p, algo);
            }
            else if (pre_build_info.cmake_system_name == "Linux")
            {
                hash += "-";
                hash += Hash::get_file_hash(VCPKG_LINE_INFO, fs, paths.scripts / "toolchains" / "linux.cmake", algo);
            }
            else if (pre_build_info.cmake_system_name == "Darwin")
            {
                hash += "-";
                hash += Hash::get_file_hash(VCPKG_LINE_INFO, fs, paths.scripts / "toolchains" / "osx.cmake", algo);
            }
            else if (pre_build_info.cmake_system_name == "FreeBSD")
            {
                hash += "-";
                hash += Hash::get_file_hash(VCPKG_LINE_INFO, fs, paths.scripts / "toolchains" / "freebsd.cmake", algo);
            }
            else if (pre_build_info.cmake_system_name == "Android")
            {
                hash += "-";
                hash += Hash::get_file_hash(VCPKG_LINE_INFO, fs, paths.scripts / "toolchains" / "android.cmake", algo);
            }

            s_hash_cache.emplace(triplet_file_path, hash);
        }

        return hash;
    }

    static ExtendedBuildResult do_build_package(const VcpkgPaths& paths,
                                                const PreBuildInfo& pre_build_info,
                                                const PackageSpec& spec,
                                                const std::string& abi_tag,
                                                const BuildPackageConfig& config)
    {
        auto& fs = paths.get_filesystem();

#if defined(_WIN32)
        const fs::path& powershell_exe_path = paths.get_tool_exe("powershell-core");
        if (!fs.exists(powershell_exe_path.parent_path() / "powershell.exe"))
        {
            fs.copy(powershell_exe_path, powershell_exe_path.parent_path() / "powershell.exe", fs::copy_options::none);
        }
#endif

        const Triplet& triplet = spec.triplet();
        const auto& triplet_file_path = paths.get_triplet_file_path(spec.triplet()).u8string();

        if (!Strings::case_insensitive_ascii_starts_with(triplet_file_path, paths.triplets.u8string()))
        {
            System::printf("-- Loading triplet configuration from: %s\n", triplet_file_path);
        }
        if (!Strings::case_insensitive_ascii_starts_with(config.port_dir.u8string(), paths.ports.u8string()))
        {
            System::printf("-- Installing port from location: %s\n", config.port_dir.u8string());
        }

        const auto timer = Chrono::ElapsedTimer::create_started();

        std::string command = make_build_cmd(paths, pre_build_info, config, triplet);
        std::unordered_map<std::string, std::string> env = make_env_passthrough(pre_build_info);

#if defined(_WIN32)
        const int return_code =
            System::cmd_execute_clean(command, env, powershell_exe_path.parent_path().u8string() + ";");
#else
        const int return_code = System::cmd_execute_clean(command, env);
#endif
        // With the exception of empty packages, builds in "Download Mode" always result in failure.
        if (config.build_package_options.only_downloads == Build::OnlyDownloads::YES)
        {
            // TODO: Capture executed command output and evaluate whether the failure was intended.
            // If an unintended error occurs then return a BuildResult::DOWNLOAD_FAILURE status.
            return BuildResult::DOWNLOADED;
        }

        const auto buildtimeus = timer.microseconds();
        const auto spec_string = spec.to_string();

        {
            auto locked_metrics = Metrics::g_metrics.lock();

            locked_metrics->track_buildtime(Hash::get_string_hash(spec.to_string(), Hash::Algorithm::Sha256) + ":[" +
                                                Strings::join(",",
                                                              config.feature_list,
                                                              [](const std::string& feature) {
                                                                  return Hash::get_string_hash(feature,
                                                                                               Hash::Algorithm::Sha256);
                                                              }) +
                                                "]",
                                            buildtimeus);
            if (return_code != 0)
            {
                locked_metrics->track_property("error", "build failed");
                locked_metrics->track_property("build_error", spec_string);
                return BuildResult::BUILD_FAILED;
            }
        }

        const BuildInfo build_info = read_build_info(fs, paths.build_info_file_path(spec));
        const size_t error_count =
            PostBuildLint::perform_all_checks(spec, paths, pre_build_info, build_info, config.port_dir);

        std::unique_ptr<BinaryControlFile> bcf =
            create_binary_control_file(*config.scf.core_paragraph, triplet, build_info, abi_tag);

        if (error_count != 0)
        {
            return BuildResult::POST_BUILD_CHECKS_FAILED;
        }
        for (auto&& feature : config.feature_list)
        {
            for (auto&& f_pgh : config.scf.feature_paragraphs)
            {
                if (f_pgh->name == feature)
                    bcf->features.push_back(
                        create_binary_feature_control_file(*config.scf.core_paragraph, *f_pgh, triplet));
            }
        }

        write_binary_control_file(paths, *bcf);
        return {BuildResult::SUCCEEDED, std::move(bcf)};
    }

    static ExtendedBuildResult do_build_package_and_clean_buildtrees(const VcpkgPaths& paths,
                                                                     const PreBuildInfo& pre_build_info,
                                                                     const PackageSpec& spec,
                                                                     const std::string& abi_tag,
                                                                     const BuildPackageConfig& config)
    {
        auto result = do_build_package(paths, pre_build_info, spec, abi_tag, config);

        if (config.build_package_options.clean_buildtrees == CleanBuildtrees::YES)
        {
            auto& fs = paths.get_filesystem();
            const fs::path buildtrees_dir = paths.buildtrees / config.scf.core_paragraph->name;
            auto buildtree_files = fs.get_files_non_recursive(buildtrees_dir);
            for (auto&& file : buildtree_files)
            {
                if (fs.is_directory(file)) // Will only keep the logs
                {
                    std::error_code ec;
                    fs::path failure_point;
                    fs.remove_all(file, ec, failure_point);
                }
            }
        }

        return result;
    }

    Optional<AbiTagAndFile> compute_abi_tag(const VcpkgPaths& paths,
                                            const BuildPackageConfig& config,
                                            const PreBuildInfo& pre_build_info,
                                            Span<const AbiEntry> dependency_abis)
    {
        auto& fs = paths.get_filesystem();
        const Triplet& triplet = config.triplet;
        const std::string& name = config.scf.core_paragraph->name;

        std::vector<AbiEntry> abi_tag_entries(dependency_abis.begin(), dependency_abis.end());

        // Sorted here as the order of dependency_abis is the only
        // non-deterministicly ordered set of AbiEntries
        Util::sort(abi_tag_entries);

        // If there is an unusually large number of files in the port then
        // something suspicious is going on.  Rather than hash all of them
        // just mark the port as no-hash
        const int max_port_file_count = 100;

        // the order of recursive_directory_iterator is undefined so save the names to sort
        std::vector<AbiEntry> port_files;
        for (auto& port_file : fs::stdfs::recursive_directory_iterator(config.port_dir))
        {
            if (fs::is_regular_file(fs.status(VCPKG_LINE_INFO, port_file)))
            {
                port_files.emplace_back(
                    port_file.path().filename().u8string(),
                    vcpkg::Hash::get_file_hash(VCPKG_LINE_INFO, fs, port_file, Hash::Algorithm::Sha1));

                if (port_files.size() > max_port_file_count)
                {
                    abi_tag_entries.emplace_back("no_hash_max_portfile", "");
                    break;
                }
            }
        }

        if (port_files.size() <= max_port_file_count)
        {
            Util::sort(port_files, [](const AbiEntry& l, const AbiEntry& r) {
                return l.value < r.value || (l.value == r.value && l.key < r.key);
            });

            std::move(port_files.begin(), port_files.end(), std::back_inserter(abi_tag_entries));
        }

        abi_tag_entries.emplace_back("cmake", paths.get_tool_version(Tools::CMAKE));

#if defined(_WIN32)
        abi_tag_entries.emplace_back("powershell", paths.get_tool_version("powershell-core"));
#endif

        abi_tag_entries.emplace_back(
            "vcpkg_fixup_cmake_targets",
            vcpkg::Hash::get_file_hash(VCPKG_LINE_INFO,
                                       fs,
                                       paths.scripts / "cmake" / "vcpkg_fixup_cmake_targets.cmake",
                                       Hash::Algorithm::Sha1));

        abi_tag_entries.emplace_back("triplet", pre_build_info.triplet_abi_tag);
        abi_tag_entries.emplace_back("features", Strings::join(";", config.feature_list));

        if (pre_build_info.public_abi_override)
        {
            abi_tag_entries.emplace_back(
                "public_abi_override",
                Hash::get_string_hash(pre_build_info.public_abi_override.value_or_exit(VCPKG_LINE_INFO),
                                      Hash::Algorithm::Sha1));
        }

        if (config.build_package_options.use_head_version == UseHeadVersion::YES)
            abi_tag_entries.emplace_back("head", "");

        const std::string full_abi_info =
            Strings::join("", abi_tag_entries, [](const AbiEntry& p) { return p.key + " " + p.value + "\n"; });

        if (Debug::g_debugging)
        {
            System::print2("[DEBUG] <abientries>\n");
            for (auto&& entry : abi_tag_entries)
            {
                System::print2("[DEBUG] ", entry.key, "|", entry.value, "\n");
            }
            System::print2("[DEBUG] </abientries>\n");
        }

        auto abi_tag_entries_missing = abi_tag_entries;
        Util::erase_remove_if(abi_tag_entries_missing, [](const AbiEntry& p) { return !p.value.empty(); });

        if (abi_tag_entries_missing.empty())
        {
            std::error_code ec;
            fs.create_directories(paths.buildtrees / name, ec);
            const auto abi_file_path = paths.buildtrees / name / (triplet.canonical_name() + ".vcpkg_abi_info.txt");
            fs.write_contents(abi_file_path, full_abi_info, VCPKG_LINE_INFO);

            return AbiTagAndFile{Hash::get_file_hash(VCPKG_LINE_INFO, fs, abi_file_path, Hash::Algorithm::Sha1),
                                 abi_file_path};
        }

        System::print2(
            "Warning: abi keys are missing values:\n",
            Strings::join("", abi_tag_entries_missing, [](const AbiEntry& e) { return "    " + e.key + "\n"; }),
            "\n");

        return nullopt;
    }

    static int decompress_archive(const VcpkgPaths& paths, const PackageSpec& spec, const fs::path& archive_path)
    {
        auto& fs = paths.get_filesystem();

        auto pkg_path = paths.package_dir(spec);
        fs.remove_all(pkg_path, VCPKG_LINE_INFO);
        std::error_code ec;
        fs.create_directories(pkg_path, ec);
        auto files = fs.get_files_non_recursive(pkg_path);
        Checks::check_exit(VCPKG_LINE_INFO, files.empty(), "unable to clear path: %s", pkg_path.u8string());

#if defined(_WIN32)
        auto&& seven_zip_exe = paths.get_tool_exe(Tools::SEVEN_ZIP);

        int result = System::cmd_execute_clean(Strings::format(
            R"("%s" x "%s" -o"%s" -y >nul)", seven_zip_exe.u8string(), archive_path.u8string(), pkg_path.u8string()));
#else
        int result = System::cmd_execute_clean(
            Strings::format(R"(unzip -qq "%s" "-d%s")", archive_path.u8string(), pkg_path.u8string()));
#endif
        return result;
    }

    // Compress the source directory into the destination file.
    static void compress_directory(const VcpkgPaths& paths, const fs::path& source, const fs::path& destination)
    {
        auto& fs = paths.get_filesystem();

        std::error_code ec;

        fs.remove(destination, ec);
        Checks::check_exit(
            VCPKG_LINE_INFO, !fs.exists(destination), "Could not remove file: %s", destination.u8string());
#if defined(_WIN32)
        auto&& seven_zip_exe = paths.get_tool_exe(Tools::SEVEN_ZIP);

        System::cmd_execute_clean(Strings::format(
            R"("%s" a "%s" "%s\*" >nul)", seven_zip_exe.u8string(), destination.u8string(), source.u8string()));
#else
        System::cmd_execute_clean(
            Strings::format(R"(cd '%s' && zip --quiet -r '%s' *)", source.u8string(), destination.u8string()));
#endif
    }

    static void compress_archive(const VcpkgPaths& paths, const PackageSpec& spec, const fs::path& destination)
    {
        compress_directory(paths, paths.package_dir(spec), destination);
    }

    ExtendedBuildResult build_package(const VcpkgPaths& paths,
                                      const BuildPackageConfig& config,
                                      const StatusParagraphs& status_db)
    {
        auto& fs = paths.get_filesystem();
        const Triplet& triplet = config.triplet;
        const std::string& name = config.scf.core_paragraph->name;

        std::vector<FeatureSpec> required_fspecs = compute_required_feature_specs(config, status_db);

        // extract out the actual package ids
        auto dep_pspecs = Util::fmap(required_fspecs, [](FeatureSpec const& fspec) { return fspec.spec(); });
        Util::sort_unique_erase(dep_pspecs);

        // Find all features that aren't installed. This mutates required_fspecs.
        // Skip this validation when running in Download Mode.
        if (config.build_package_options.only_downloads != Build::OnlyDownloads::YES)
        {
            Util::erase_remove_if(required_fspecs, [&](FeatureSpec const& fspec) {
                return status_db.is_installed(fspec) || fspec.name() == name;
            });

            if (!required_fspecs.empty())
            {
                return {BuildResult::CASCADED_DUE_TO_MISSING_DEPENDENCIES, std::move(required_fspecs)};
            }
        }

        const PackageSpec spec =
            PackageSpec::from_name_and_triplet(config.scf.core_paragraph->name, triplet).value_or_exit(VCPKG_LINE_INFO);

        std::vector<AbiEntry> dependency_abis;

        // dep_pspecs was not destroyed
        for (auto&& pspec : dep_pspecs)
        {
            if (pspec == spec || Util::Enum::to_bool(config.build_package_options.only_downloads))
            {
                continue;
            }
            const auto status_it = status_db.find_installed(pspec);
            Checks::check_exit(VCPKG_LINE_INFO, status_it != status_db.end());
            dependency_abis.emplace_back(
                AbiEntry{status_it->get()->package.spec.name(), status_it->get()->package.abi});
        }

        const auto pre_build_info = PreBuildInfo::from_triplet_file(paths, triplet, config.scfl);

        auto maybe_abi_tag_and_file = compute_abi_tag(paths, config, pre_build_info, dependency_abis);
        if (!maybe_abi_tag_and_file)
        {
            return do_build_package_and_clean_buildtrees(
                paths, pre_build_info, spec, pre_build_info.public_abi_override.value_or(AbiTagAndFile{}.tag), config);
        }

        std::error_code ec;
        const auto abi_tag_and_file = maybe_abi_tag_and_file.get();
        const fs::path archives_root_dir = paths.root / "archives";
        const std::string archive_name = abi_tag_and_file->tag + ".zip";
        const fs::path archive_subpath = fs::u8path(abi_tag_and_file->tag.substr(0, 2)) / archive_name;
        const fs::path archive_path = archives_root_dir / archive_subpath;
        const fs::path archive_tombstone_path = archives_root_dir / "fail" / archive_subpath;
        const fs::path abi_package_dir = paths.package_dir(spec) / "share" / spec.name();
        const fs::path abi_file_in_package = paths.package_dir(spec) / "share" / spec.name() / "vcpkg_abi_info.txt";

        if (config.build_package_options.binary_caching == BinaryCaching::YES)
        {
            if (fs.exists(archive_path))
            {
                System::print2("Using cached binary package: ", archive_path.u8string(), "\n");

                int archive_result = decompress_archive(paths, spec, archive_path);

                if (archive_result != 0)
                {
                    System::print2("Failed to decompress archive package\n");
                    return BuildResult::BUILD_FAILED;
                }

                auto maybe_bcf = Paragraphs::try_load_cached_package(paths, spec);
                auto bcf = std::make_unique<BinaryControlFile>(std::move(maybe_bcf).value_or_exit(VCPKG_LINE_INFO));
                return {BuildResult::SUCCEEDED, std::move(bcf)};
            }

            if (fs.exists(archive_tombstone_path))
            {
                if (config.build_package_options.fail_on_tombstone == FailOnTombstone::YES)
                {
                    System::print2("Found failure tombstone: ", archive_tombstone_path.u8string(), "\n");
                    return BuildResult::BUILD_FAILED;
                }
                else
                {
                    System::print2(
                        System::Color::warning, "Found failure tombstone: ", archive_tombstone_path.u8string(), "\n");
                }
            }

            System::printf("Could not locate cached archive: %s\n", archive_path.u8string());
        }

        ExtendedBuildResult result = do_build_package_and_clean_buildtrees(
            paths, pre_build_info, spec, pre_build_info.public_abi_override.value_or(abi_tag_and_file->tag), config);

        fs.create_directories(abi_package_dir, ec);
        Checks::check_exit(VCPKG_LINE_INFO, !ec, "Coud not create directory %s", abi_package_dir.u8string());
        fs.copy_file(abi_tag_and_file->tag_file, abi_file_in_package, fs::stdfs::copy_options::none, ec);
        Checks::check_exit(VCPKG_LINE_INFO, !ec, "Could not copy into file: %s", abi_file_in_package.u8string());

        if (config.build_package_options.binary_caching == BinaryCaching::YES && result.code == BuildResult::SUCCEEDED)
        {
            const auto tmp_archive_path = paths.buildtrees / spec.name() / (spec.triplet().to_string() + ".zip");

            compress_archive(paths, spec, tmp_archive_path);

            fs.create_directories(archive_path.parent_path(), ec);
            fs.rename_or_copy(tmp_archive_path, archive_path, ".tmp", ec);
            if (ec)
            {
                System::printf(System::Color::warning,
                               "Failed to store binary cache %s: %s\n",
                               archive_path.u8string(),
                               ec.message());
            }
            else
                System::printf("Stored binary cache: %s\n", archive_path.u8string());
        }
        else if (config.build_package_options.binary_caching == BinaryCaching::YES &&
                 (result.code == BuildResult::BUILD_FAILED || result.code == BuildResult::POST_BUILD_CHECKS_FAILED))
        {
            if (!fs.exists(archive_tombstone_path))
            {
                // Build failed, store all failure logs in the tombstone.
                const auto tmp_log_path = paths.buildtrees / spec.name() / "tmp_failure_logs";
                const auto tmp_log_path_destination = tmp_log_path / spec.name();
                const auto tmp_failure_zip = paths.buildtrees / spec.name() / "failure_logs.zip";
                fs.create_directories(tmp_log_path_destination, ec);

                for (auto& log_file : fs::stdfs::directory_iterator(paths.buildtrees / spec.name()))
                {
                    if (log_file.path().extension() == ".log")
                    {
                        fs.copy_file(log_file.path(),
                                     tmp_log_path_destination / log_file.path().filename(),
                                     fs::stdfs::copy_options::none,
                                     ec);
                    }
                }

                compress_directory(paths, tmp_log_path, paths.buildtrees / spec.name() / "failure_logs.zip");

                fs.create_directories(archive_tombstone_path.parent_path(), ec);
                fs.rename_or_copy(tmp_failure_zip, archive_tombstone_path, ".tmp", ec);

                // clean up temporary directory
                fs.remove_all(tmp_log_path, VCPKG_LINE_INFO);
            }
        }

        return result;
    }

    const std::string& to_string(const BuildResult build_result)
    {
        static const std::string NULLVALUE_STRING = Enums::nullvalue_to_string("vcpkg::Commands::Build::BuildResult");
        static const std::string SUCCEEDED_STRING = "SUCCEEDED";
        static const std::string BUILD_FAILED_STRING = "BUILD_FAILED";
        static const std::string FILE_CONFLICTS_STRING = "FILE_CONFLICTS";
        static const std::string POST_BUILD_CHECKS_FAILED_STRING = "POST_BUILD_CHECKS_FAILED";
        static const std::string CASCADED_DUE_TO_MISSING_DEPENDENCIES_STRING = "CASCADED_DUE_TO_MISSING_DEPENDENCIES";
        static const std::string EXCLUDED_STRING = "EXCLUDED";
        static const std::string DOWNLOADED_STRING = "DOWNLOADED";

        switch (build_result)
        {
            case BuildResult::NULLVALUE: return NULLVALUE_STRING;
            case BuildResult::SUCCEEDED: return SUCCEEDED_STRING;
            case BuildResult::BUILD_FAILED: return BUILD_FAILED_STRING;
            case BuildResult::POST_BUILD_CHECKS_FAILED: return POST_BUILD_CHECKS_FAILED_STRING;
            case BuildResult::FILE_CONFLICTS: return FILE_CONFLICTS_STRING;
            case BuildResult::CASCADED_DUE_TO_MISSING_DEPENDENCIES: return CASCADED_DUE_TO_MISSING_DEPENDENCIES_STRING;
            case BuildResult::EXCLUDED: return EXCLUDED_STRING;
            case BuildResult::DOWNLOADED: return DOWNLOADED_STRING;
            default: Checks::unreachable(VCPKG_LINE_INFO);
        }
    }

    std::string create_error_message(const BuildResult build_result, const PackageSpec& spec)
    {
        return Strings::format("Error: Building package %s failed with: %s", spec, Build::to_string(build_result));
    }

    std::string create_user_troubleshooting_message(const PackageSpec& spec)
    {
        return Strings::format("Please ensure you're using the latest portfiles with `.\\vcpkg update`, then\n"
                               "submit an issue at https://github.com/Microsoft/vcpkg/issues including:\n"
                               "  Package: %s\n"
                               "  Vcpkg version: %s\n"
                               "\n"
                               "Additionally, attach any relevant sections from the log files above.",
                               spec,
                               Commands::Version::version());
    }

    static BuildInfo inner_create_buildinfo(Parse::RawParagraph pgh)
    {
        Parse::ParagraphParser parser(std::move(pgh));

        BuildInfo build_info;

        {
            std::string crt_linkage_as_string;
            parser.required_field(BuildInfoRequiredField::CRT_LINKAGE, crt_linkage_as_string);

            auto crtlinkage = to_linkage_type(crt_linkage_as_string);
            if (const auto p = crtlinkage.get())
                build_info.crt_linkage = *p;
            else
                Checks::exit_with_message(VCPKG_LINE_INFO, "Invalid crt linkage type: [%s]", crt_linkage_as_string);
        }

        {
            std::string library_linkage_as_string;
            parser.required_field(BuildInfoRequiredField::LIBRARY_LINKAGE, library_linkage_as_string);
            auto liblinkage = to_linkage_type(library_linkage_as_string);
            if (const auto p = liblinkage.get())
                build_info.library_linkage = *p;
            else
                Checks::exit_with_message(
                    VCPKG_LINE_INFO, "Invalid library linkage type: [%s]", library_linkage_as_string);
        }
        std::string version = parser.optional_field("Version");
        if (!version.empty()) build_info.version = std::move(version);

        std::map<BuildPolicy, bool> policies;
        for (auto policy : G_ALL_POLICIES)
        {
            const auto setting = parser.optional_field(to_string(policy));
            if (setting.empty()) continue;
            if (setting == "enabled")
                policies.emplace(policy, true);
            else if (setting == "disabled")
                policies.emplace(policy, false);
            else
                Checks::exit_with_message(
                    VCPKG_LINE_INFO, "Unknown setting for policy '%s': %s", to_string(policy), setting);
        }

        if (const auto err = parser.error_info("PostBuildInformation"))
        {
            print_error_message(err);
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        build_info.policies = BuildPolicies(std::move(policies));

        return build_info;
    }

    BuildInfo read_build_info(const Files::Filesystem& fs, const fs::path& filepath)
    {
        const Expected<Parse::RawParagraph> pghs = Paragraphs::get_single_paragraph(fs, filepath);
        Checks::check_exit(VCPKG_LINE_INFO, pghs.get() != nullptr, "Invalid BUILD_INFO file for package");
        return inner_create_buildinfo(*pghs.get());
    }

    PreBuildInfo PreBuildInfo::from_triplet_file(const VcpkgPaths& paths,
                                                 const Triplet& triplet,
                                                 Optional<const SourceControlFileLocation&> port)
    {
        static constexpr CStringView FLAG_GUID = "c35112b6-d1ba-415b-aa5d-81de856ef8eb";

        const fs::path& cmake_exe_path = paths.get_tool_exe(Tools::CMAKE);
        const fs::path ports_cmake_script_path = paths.scripts / "get_triplet_environment.cmake";
        const fs::path triplet_file_path = paths.get_triplet_file_path(triplet);

        std::vector<System::CMakeVariable> args{{"CMAKE_TRIPLET_FILE", triplet_file_path}};

        if (port)
        {
            const SourceControlFileLocation& scfl = port.value_or_exit(VCPKG_LINE_INFO);

            if (paths.get_filesystem().is_regular_file(scfl.source_location / "environment-overrides.cmake"))
            {
                args.emplace_back("VCPKG_ENV_OVERRIDES_FILE", scfl.source_location / "environment-overrides.cmake");
            }
        }

        const auto cmd_launch_cmake = System::make_cmake_cmd(cmake_exe_path, ports_cmake_script_path, args);

        const auto ec_data = System::cmd_execute_and_capture_output(cmd_launch_cmake);
        Checks::check_exit(VCPKG_LINE_INFO, ec_data.exit_code == 0, ec_data.output);

        const std::vector<std::string> lines = Strings::split(ec_data.output, "\n");

        PreBuildInfo pre_build_info;

        pre_build_info.port = port;

        const auto e = lines.cend();
        auto cur = std::find(lines.cbegin(), e, FLAG_GUID);
        if (cur != e) ++cur;

        for (; cur != e; ++cur)
        {
            auto&& line = *cur;

            const std::vector<std::string> s = Strings::split(line, "=");
            Checks::check_exit(VCPKG_LINE_INFO,
                               s.size() == 1 || s.size() == 2,
                               "Expected format is [VARIABLE_NAME=VARIABLE_VALUE], but was [%s]",
                               line);

            const bool variable_with_no_value = s.size() == 1;
            const std::string variable_name = s.at(0);
            const std::string variable_value = variable_with_no_value ? "" : s.at(1);

            auto maybe_option = VCPKG_OPTIONS.find(variable_name);
            if (maybe_option != VCPKG_OPTIONS.end())
            {
                switch (maybe_option->second)
                {
                    case VcpkgTripletVar::TARGET_ARCHITECTURE:
                        pre_build_info.target_architecture = variable_value;
                        break;
                    case VcpkgTripletVar::CMAKE_SYSTEM_NAME: pre_build_info.cmake_system_name = variable_value; break;
                    case VcpkgTripletVar::CMAKE_SYSTEM_VERSION:
                        pre_build_info.cmake_system_version = variable_value;
                        break;
                    case VcpkgTripletVar::PLATFORM_TOOLSET:
                        pre_build_info.platform_toolset =
                            variable_value.empty() ? nullopt : Optional<std::string>{variable_value};
                        break;
                    case VcpkgTripletVar::VISUAL_STUDIO_PATH:
                        pre_build_info.visual_studio_path =
                            variable_value.empty() ? nullopt : Optional<fs::path>{variable_value};
                        break;
                    case VcpkgTripletVar::CHAINLOAD_TOOLCHAIN_FILE:
                        pre_build_info.external_toolchain_file =
                            variable_value.empty() ? nullopt : Optional<std::string>{variable_value};
                        break;
                    case VcpkgTripletVar::BUILD_TYPE:
                        if (variable_value.empty())
                            pre_build_info.build_type = nullopt;
                        else if (Strings::case_insensitive_ascii_equals(variable_value, "debug"))
                            pre_build_info.build_type = ConfigurationType::DEBUG;
                        else if (Strings::case_insensitive_ascii_equals(variable_value, "release"))
                            pre_build_info.build_type = ConfigurationType::RELEASE;
                        else
                            Checks::exit_with_message(
                                VCPKG_LINE_INFO, "Unknown setting for VCPKG_BUILD_TYPE: %s", variable_value);
                        break;
                    case VcpkgTripletVar::ENV_PASSTHROUGH:
                        pre_build_info.passthrough_env_vars = Strings::split(variable_value, ";");
                        break;
                    case VcpkgTripletVar::PUBLIC_ABI_OVERRIDE:
                        pre_build_info.public_abi_override =
                            variable_value.empty() ? nullopt : Optional<std::string>{variable_value};
                        break;
                    case VcpkgTripletVar::SKIP_POST_BUILD_LIB_ARCH_CHECK:
                        pre_build_info.skip_post_build_lib_arch_check =
                            variable_value.empty() ? nullopt : Optional<std::string>{variable_value};
                        break;
                    case VcpkgTripletVar::CMAKE_VS_GENERATOR:
                        pre_build_info.cmake_vs_generator =
                            variable_value.empty() ? nullopt : Optional<std::string>{variable_value};
                        break;
                    case VcpkgTripletVar::FORCE_VCVARS_LOAD:
                        if (variable_value.empty())
                            pre_build_info.force_vcvar_load = false;
                        else if (Strings::case_insensitive_ascii_equals(variable_value, "1"))
                            pre_build_info.force_vcvar_load = true;
                        else if (Strings::case_insensitive_ascii_equals(variable_value, "on"))
                            pre_build_info.force_vcvar_load = true;
                        else if (Strings::case_insensitive_ascii_equals(variable_value, "true"))
                            pre_build_info.force_vcvar_load = true;
                        else if (Strings::case_insensitive_ascii_equals(variable_value, "0"))
                            pre_build_info.force_vcvar_load = false;
                        else if (Strings::case_insensitive_ascii_equals(variable_value, "off"))
                            pre_build_info.force_vcvar_load = false;
                        else if (Strings::case_insensitive_ascii_equals(variable_value, "false"))
                            pre_build_info.force_vcvar_load = false;
                        else
                            Checks::exit_with_message(
                                VCPKG_LINE_INFO, "Unknown setting for VCPKG_FORCE_LOAD_VCVARS_ENV: %s", variable_value);
                        break;
                }
            }
            else
            {
                Checks::exit_with_message(VCPKG_LINE_INFO, "Unknown variable name %s", line);
            }
        }

        pre_build_info.triplet_abi_tag = get_triplet_abi(paths, pre_build_info, triplet);

        return pre_build_info;
    }

    ExtendedBuildResult::ExtendedBuildResult(BuildResult code) : code(code) {}
    ExtendedBuildResult::ExtendedBuildResult(BuildResult code, std::unique_ptr<BinaryControlFile>&& bcf)
        : code(code), binary_control_file(std::move(bcf))
    {
    }
    ExtendedBuildResult::ExtendedBuildResult(BuildResult code, std::vector<FeatureSpec>&& unmet_deps)
        : code(code), unmet_dependencies(std::move(unmet_deps))
    {
    }
}
