#include "pch.h"

#include <vcpkg/base/checks.h>
#include <vcpkg/base/chrono.h>
#include <vcpkg/base/enums.h>
#include <vcpkg/base/hash.h>
#include <vcpkg/base/optional.h>
#include <vcpkg/base/stringliteral.h>
#include <vcpkg/base/system.h>

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
using vcpkg::Parse::ParseControlErrorInfo;
using vcpkg::Parse::ParseExpected;

namespace vcpkg::Build::Command
{
    using Dependencies::InstallPlanAction;
    using Dependencies::InstallPlanType;

    static constexpr StringLiteral OPTION_CHECKS_ONLY = "--checks-only";

    void perform_and_exit_ex(const FullPackageSpec& full_spec,
                             const fs::path& port_dir,
                             const ParsedArguments& options,
                             const VcpkgPaths& paths)
    {
        const PackageSpec& spec = full_spec.package_spec;
        if (Util::Sets::contains(options.switches, OPTION_CHECKS_ONLY))
        {
            const auto pre_build_info = Build::PreBuildInfo::from_triplet_file(paths, spec.triplet());
            const auto build_info = Build::read_build_info(paths.get_filesystem(), paths.build_info_file_path(spec));
            const size_t error_count = PostBuildLint::perform_all_checks(spec, paths, pre_build_info, build_info);
            Checks::check_exit(VCPKG_LINE_INFO, error_count == 0);
            Checks::exit_success(VCPKG_LINE_INFO);
        }

        const ParseExpected<SourceControlFile> source_control_file =
            Paragraphs::try_load_port(paths.get_filesystem(), port_dir);

        if (!source_control_file.has_value())
        {
            print_error_message(source_control_file.error());
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        const auto& scf = source_control_file.value_or_exit(VCPKG_LINE_INFO);
        Checks::check_exit(VCPKG_LINE_INFO,
                           spec.name() == scf->core_paragraph->name,
                           "The Source field inside the CONTROL file does not match the port directory: '%s' != '%s'",
                           scf->core_paragraph->name,
                           spec.name());

        const StatusParagraphs status_db = database_load_check(paths);
        const Build::BuildPackageOptions build_package_options {
            Build::UseHeadVersion::NO,
            Build::AllowDownloads::YES,
            Build::CleanBuildtrees::NO,
            Build::CleanPackages::NO,
            Build::DownloadTool::BUILT_IN,
            GlobalState::g_binary_caching ? Build::BinaryCaching::YES : Build::BinaryCaching::NO,
            Build::FailOnTombstone::NO,
        };

        std::set<std::string> features_as_set(full_spec.features.begin(), full_spec.features.end());
        features_as_set.emplace("core");

        const Build::BuildPackageConfig build_config {
            *scf, spec.triplet(), fs::path {port_dir}, build_package_options, features_as_set};

        const auto build_timer = Chrono::ElapsedTimer::create_started();
        const auto result = Build::build_package(paths, build_config, status_db);
        System::println("Elapsed time for package %s: %s", spec.to_string(), build_timer.to_string());

        if (result.code == BuildResult::CASCADED_DUE_TO_MISSING_DEPENDENCIES)
        {
            System::println(System::Color::error,
                            "The build command requires all dependencies to be already installed.");
            System::println("The following dependencies are missing:");
            System::println();
            for (const auto& p : result.unmet_dependencies)
            {
                System::println("    %s", p);
            }
            System::println();
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        Checks::check_exit(VCPKG_LINE_INFO, result.code != BuildResult::EXCLUDED);

        if (result.code != BuildResult::SUCCEEDED)
        {
            System::println(System::Color::error, Build::create_error_message(result.code, spec));
            System::println(Build::create_user_troubleshooting_message(spec));
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }

    static constexpr std::array<CommandSwitch, 1> BUILD_SWITCHES = {{
        {OPTION_CHECKS_ONLY, "Only run checks, do not rebuild package"},
    }};

    const CommandStructure COMMAND_STRUCTURE = {
        Help::create_example_string("build zlib:x64-windows"),
        1,
        1,
        {BUILD_SWITCHES, {}},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet)
    {
        // Build only takes a single package and all dependencies must already be installed
        const ParsedArguments options = args.parse_arguments(COMMAND_STRUCTURE);
        const std::string command_argument = args.command_arguments.at(0);
        const FullPackageSpec spec =
            Input::check_and_get_full_package_spec(command_argument, default_triplet, COMMAND_STRUCTURE.example_text);
        Input::check_triplet(spec.package_spec.triplet(), paths);
        if (!spec.features.empty() && !GlobalState::feature_packages)
        {
            Checks::exit_with_message(
                VCPKG_LINE_INFO, "Feature packages are experimentally available under the --featurepackages flag.");
        }
        perform_and_exit_ex(spec, paths.port_dir(spec.package_spec), options, paths);
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

    CStringView to_vcvarsall_target(const std::string& cmake_system_name)
    {
        if (cmake_system_name.empty()) return "";
        if (cmake_system_name == "Windows") return "";
        if (cmake_system_name == "WindowsStore") return "store";

        Checks::exit_with_message(VCPKG_LINE_INFO, "Unsupported vcvarsall target %s", cmake_system_name);
    }

    CStringView to_vcvarsall_toolchain(const std::string& target_architecture, const Toolset& toolset)
    {
        auto maybe_target_arch = System::to_cpu_architecture(target_architecture);
        Checks::check_exit(
            VCPKG_LINE_INFO, maybe_target_arch.has_value(), "Invalid architecture string: %s", target_architecture);
        auto target_arch = maybe_target_arch.value_or_exit(VCPKG_LINE_INFO);
        auto host_architectures = System::get_supported_host_architectures();

        for (auto&& host : host_architectures)
        {
            const auto it = Util::find_if(toolset.supported_architectures, [&](const ToolsetArchOption& opt) {
                return host == opt.host_arch && target_arch == opt.target_arch;
            });
            if (it != toolset.supported_architectures.end()) return it->name;
        }

        Checks::exit_with_message(VCPKG_LINE_INFO,
                                  "Unsupported toolchain combination. Target was: %s but supported ones were:\n%s",
                                  target_architecture,
                                  Strings::join(",", toolset.supported_architectures, [](const ToolsetArchOption& t) {
                                      return t.name.c_str();
                                  }));
    }

    std::string make_build_env_cmd(const PreBuildInfo& pre_build_info, const Toolset& toolset)
    {
        if (pre_build_info.external_toolchain_file.has_value()) return "";
        if (!pre_build_info.cmake_system_name.empty() && pre_build_info.cmake_system_name != "WindowsStore") return "";

        const char* tonull = " >nul";
        if (GlobalState::debugging)
        {
            tonull = "";
        }

        const auto arch = to_vcvarsall_toolchain(pre_build_info.target_architecture, toolset);
        const auto target = to_vcvarsall_target(pre_build_info.cmake_system_name);

        return Strings::format(R"("%s" %s %s %s %s 2>&1 <NUL)",
                               toolset.vcvarsall.u8string(),
                               Strings::join(" ", toolset.vcvarsall_options),
                               arch,
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

    static void write_binary_control_file(const VcpkgPaths& paths, BinaryControlFile bcf)
    {
        std::string start = Strings::serialize(bcf.core_paragraph);
        for (auto&& feature : bcf.features)
        {
            start += "\n" + Strings::serialize(feature);
        }
        const fs::path binary_control_file = paths.packages / bcf.core_paragraph.dir() / "CONTROL";
        paths.get_filesystem().write_contents(binary_control_file, start);
    }

    static std::vector<FeatureSpec> compute_required_feature_specs(const BuildPackageConfig& config,
                                                                   const StatusParagraphs& status_db)
    {
        const Triplet& triplet = config.triplet;

        const std::vector<std::string> dep_strings =
            Util::fmap_flatten(config.feature_list, [&](std::string const& feature) -> std::vector<std::string> {
                if (feature == "core")
                {
                    return filter_dependencies(config.scf.core_paragraph->depends, triplet);
                }

                auto maybe_feature = config.scf.find_feature(feature);
                Checks::check_exit(VCPKG_LINE_INFO, maybe_feature.has_value());

                return filter_dependencies(maybe_feature.get()->depends, triplet);
            });

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

    static ExtendedBuildResult do_build_package(const VcpkgPaths& paths,
                                                const PreBuildInfo& pre_build_info,
                                                const PackageSpec& spec,
                                                const std::string& abi_tag,
                                                const BuildPackageConfig& config)
    {
        auto& fs = paths.get_filesystem();
        const Triplet& triplet = spec.triplet();

#if !defined(_WIN32)
        // TODO: remove when vcpkg.exe is in charge for acquiring tools. Change introduced in vcpkg v0.0.107.
        // bootstrap should have already downloaded ninja, but making sure it is present in case it was deleted.
        vcpkg::Util::unused(paths.get_tool_exe(Tools::NINJA));
#endif

        const fs::path& cmake_exe_path = paths.get_tool_exe(Tools::CMAKE);
        const fs::path& git_exe_path = paths.get_tool_exe(Tools::GIT);

        std::string all_features;
        for (auto& feature : config.scf.feature_paragraphs)
        {
            all_features.append(feature->name + ";");
        }

        const Toolset& toolset = paths.get_toolset(pre_build_info);
        const std::string cmd_launch_cmake = System::make_cmake_cmd(
            cmake_exe_path,
            paths.ports_cmake,
            {
                {"CMD", "BUILD"},
                {"PORT", config.scf.core_paragraph->name},
                {"CURRENT_PORT_DIR", config.port_dir},
                {"TARGET_TRIPLET", spec.triplet().canonical_name()},
                {"VCPKG_PLATFORM_TOOLSET", toolset.version.c_str()},
                {"VCPKG_USE_HEAD_VERSION",
                 Util::Enum::to_bool(config.build_package_options.use_head_version) ? "1" : "0"},
                {"_VCPKG_NO_DOWNLOADS", !Util::Enum::to_bool(config.build_package_options.allow_downloads) ? "1" : "0"},
                {"_VCPKG_DOWNLOAD_TOOL", to_string(config.build_package_options.download_tool)},
                {"GIT", git_exe_path},
                {"FEATURES", Strings::join(";", config.feature_list)},
                {"ALL_FEATURES", all_features},
            });

        auto command = make_build_env_cmd(pre_build_info, toolset);
        if (!command.empty())
        {
#ifdef _WIN32
            command.append(" & ");
#else
            command.append(" && ");
#endif
        }
        command.append(cmd_launch_cmake);
        const auto timer = Chrono::ElapsedTimer::create_started();

        const int return_code = System::cmd_execute_clean(command);
        const auto buildtimeus = timer.microseconds();
        const auto spec_string = spec.to_string();

        {
            auto locked_metrics = Metrics::g_metrics.lock();
            locked_metrics->track_buildtime(spec.to_string() + ":[" + Strings::join(",", config.feature_list) + "]",
                                            buildtimeus);
            if (return_code != 0)
            {
                locked_metrics->track_property("error", "build failed");
                locked_metrics->track_property("build_error", spec_string);
                return BuildResult::BUILD_FAILED;
            }
        }

        const BuildInfo build_info = read_build_info(fs, paths.build_info_file_path(spec));
        const size_t error_count = PostBuildLint::perform_all_checks(spec, paths, pre_build_info, build_info);

        auto bcf = create_binary_control_file(*config.scf.core_paragraph, triplet, build_info, abi_tag);

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
                    fs.remove_all(file, ec);
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
        if (config.build_package_options.binary_caching == BinaryCaching::NO) return nullopt;

        auto& fs = paths.get_filesystem();
        const Triplet& triplet = config.triplet;
        const std::string& name = config.scf.core_paragraph->name;

        std::vector<AbiEntry> abi_tag_entries;

        abi_tag_entries.emplace_back(AbiEntry {"cmake", paths.get_tool_version(Tools::CMAKE)});

        abi_tag_entries.insert(abi_tag_entries.end(), dependency_abis.begin(), dependency_abis.end());

        abi_tag_entries.emplace_back(
            AbiEntry {"portfile", vcpkg::Hash::get_file_hash(fs, config.port_dir / "portfile.cmake", "SHA1")});
        abi_tag_entries.emplace_back(
            AbiEntry {"control", vcpkg::Hash::get_file_hash(fs, config.port_dir / "CONTROL", "SHA1")});

        abi_tag_entries.emplace_back(AbiEntry {"triplet", pre_build_info.triplet_abi_tag});

        const std::string features = Strings::join(";", config.feature_list);
        abi_tag_entries.emplace_back(AbiEntry {"features", features});

        if (config.build_package_options.use_head_version == UseHeadVersion::YES)
            abi_tag_entries.emplace_back(AbiEntry {"head", ""});

        Util::sort(abi_tag_entries);

        const std::string full_abi_info =
            Strings::join("", abi_tag_entries, [](const AbiEntry& p) { return p.key + " " + p.value + "\n"; });

        if (GlobalState::debugging)
        {
            System::println("[DEBUG] <abientries>");
            for (auto&& entry : abi_tag_entries)
            {
                System::println("[DEBUG] %s|%s", entry.key, entry.value);
            }
            System::println("[DEBUG] </abientries>");
        }

        auto abi_tag_entries_missing = abi_tag_entries;
        Util::stable_keep_if(abi_tag_entries_missing, [](const AbiEntry& p) { return p.value.empty(); });

        if (abi_tag_entries_missing.empty())
        {
            std::error_code ec;
            fs.create_directories(paths.buildtrees / name, ec);
            const auto abi_file_path = paths.buildtrees / name / (triplet.canonical_name() + ".vcpkg_abi_info.txt");
            fs.write_contents(abi_file_path, full_abi_info);

            return AbiTagAndFile {Hash::get_file_hash(fs, abi_file_path, "SHA1"), abi_file_path};
        }

        System::println(
            "Warning: binary caching disabled because abi keys are missing values:\n%s",
            Strings::join("", abi_tag_entries_missing, [](const AbiEntry& e) { return "    " + e.key + "\n"; }));

        return nullopt;
    }

    static void decompress_archive(const VcpkgPaths& paths, const PackageSpec& spec, const fs::path& archive_path)
    {
        auto& fs = paths.get_filesystem();

        auto pkg_path = paths.package_dir(spec);
        std::error_code ec;
        fs.remove_all(pkg_path, ec);
        fs.create_directories(pkg_path, ec);
        auto files = fs.get_files_non_recursive(pkg_path);
        Checks::check_exit(VCPKG_LINE_INFO, files.empty(), "unable to clear path: %s", pkg_path.u8string());

#if defined(_WIN32)
        auto&& seven_zip_exe = paths.get_tool_exe(Tools::SEVEN_ZIP);

        System::cmd_execute_clean(Strings::format(
            R"("%s" x "%s" -o"%s" -y >nul)", seven_zip_exe.u8string(), archive_path.u8string(), pkg_path.u8string()));
#else
        System::cmd_execute_clean(
            Strings::format(R"(unzip -qq "%s" "-d%s")", archive_path.u8string(), pkg_path.u8string()));
#endif
    }

    static void compress_archive(const VcpkgPaths& paths, const PackageSpec& spec, const fs::path& tmp_archive_path)
    {
        auto& fs = paths.get_filesystem();

        std::error_code ec;

        fs.remove(tmp_archive_path, ec);
        Checks::check_exit(
            VCPKG_LINE_INFO, !fs.exists(tmp_archive_path), "Could not remove file: %s", tmp_archive_path.u8string());
#if defined(_WIN32)
        auto&& seven_zip_exe = paths.get_tool_exe(Tools::SEVEN_ZIP);

        System::cmd_execute_clean(Strings::format(R"("%s" a "%s" "%s\*" >nul)",
                                                  seven_zip_exe.u8string(),
                                                  tmp_archive_path.u8string(),
                                                  paths.package_dir(spec).u8string()));
#else
        System::cmd_execute_clean(Strings::format(
            R"(cd '%s' && zip --quiet -r '%s' *)", paths.package_dir(spec).u8string(), tmp_archive_path.u8string()));
#endif
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
        Util::unstable_keep_if(required_fspecs, [&](FeatureSpec const& fspec) {
            return !status_db.is_installed(fspec) && fspec.name() != name;
        });

        if (!required_fspecs.empty())
        {
            return {BuildResult::CASCADED_DUE_TO_MISSING_DEPENDENCIES, std::move(required_fspecs)};
        }

        const PackageSpec spec =
            PackageSpec::from_name_and_triplet(config.scf.core_paragraph->name, triplet).value_or_exit(VCPKG_LINE_INFO);

        std::vector<AbiEntry> dependency_abis;

        // dep_pspecs was not destroyed
        for (auto&& pspec : dep_pspecs)
        {
            if (pspec == spec) continue;
            const auto status_it = status_db.find_installed(pspec);
            Checks::check_exit(VCPKG_LINE_INFO, status_it != status_db.end());
            dependency_abis.emplace_back(
                AbiEntry {status_it->get()->package.spec.name(), status_it->get()->package.abi});
        }

        const auto pre_build_info = PreBuildInfo::from_triplet_file(paths, triplet);

        auto maybe_abi_tag_and_file = compute_abi_tag(paths, config, pre_build_info, dependency_abis);

        const auto abi_tag_and_file = maybe_abi_tag_and_file.get();

        if (config.build_package_options.binary_caching == BinaryCaching::YES && abi_tag_and_file)
        {
            const fs::path archives_root_dir = paths.root / "archives";
            const std::string archive_name = abi_tag_and_file->tag + ".zip";
            const fs::path archive_subpath = fs::u8path(abi_tag_and_file->tag.substr(0, 2)) / archive_name;
            const fs::path archive_path = archives_root_dir / archive_subpath;
            const fs::path archive_tombstone_path = archives_root_dir / "fail" / archive_subpath;

            if (fs.exists(archive_path))
            {
                System::println("Using cached binary package: %s", archive_path.u8string());

                decompress_archive(paths, spec, archive_path);

                auto maybe_bcf = Paragraphs::try_load_cached_package(paths, spec);
                std::unique_ptr<BinaryControlFile> bcf =
                    std::make_unique<BinaryControlFile>(std::move(maybe_bcf).value_or_exit(VCPKG_LINE_INFO));
                return {BuildResult::SUCCEEDED, std::move(bcf)};
            }

            if (fs.exists(archive_tombstone_path))
            {
                if (config.build_package_options.fail_on_tombstone == FailOnTombstone::YES)
                {
                    System::println("Found failure tombstone: %s", archive_tombstone_path.u8string());
                    return BuildResult::BUILD_FAILED;
                }
                else
                {
                    System::println(
                        System::Color::warning, "Found failure tombstone: %s", archive_tombstone_path.u8string());
                }
            }

            System::println("Could not locate cached archive: %s", archive_path.u8string());

            ExtendedBuildResult result = do_build_package_and_clean_buildtrees(
                paths, pre_build_info, spec, maybe_abi_tag_and_file.value_or(AbiTagAndFile {}).tag, config);

            std::error_code ec;
            fs.create_directories(paths.package_dir(spec) / "share" / spec.name(), ec);
            auto abi_file_in_package = paths.package_dir(spec) / "share" / spec.name() / "vcpkg_abi_info.txt";
            fs.copy_file(abi_tag_and_file->tag_file, abi_file_in_package, fs::stdfs::copy_options::none, ec);
            Checks::check_exit(VCPKG_LINE_INFO, !ec, "Could not copy into file: %s", abi_file_in_package.u8string());

            if (result.code == BuildResult::SUCCEEDED)
            {
                const auto tmp_archive_path = paths.buildtrees / spec.name() / (spec.triplet().to_string() + ".zip");

                compress_archive(paths, spec, tmp_archive_path);

                fs.create_directories(archive_path.parent_path(), ec);
                fs.rename_or_copy(tmp_archive_path, archive_path, ".tmp", ec);
                if (ec)
                {
                    System::println(System::Color::warning,
                                    "Failed to store binary cache %s: %s",
                                    archive_path.u8string(),
                                    ec.message());
                }
                else
                    System::println("Stored binary cache: %s", archive_path.u8string());
            }
            else if (result.code == BuildResult::BUILD_FAILED || result.code == BuildResult::POST_BUILD_CHECKS_FAILED)
            {
                // Build failed, so store tombstone archive
                fs.create_directories(archive_tombstone_path.parent_path(), ec);
                fs.write_contents(archive_tombstone_path, "", ec);
            }

            return result;
        }

        return do_build_package_and_clean_buildtrees(
            paths, pre_build_info, spec, maybe_abi_tag_and_file.value_or(AbiTagAndFile {}).tag, config);
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

        switch (build_result)
        {
            case BuildResult::NULLVALUE: return NULLVALUE_STRING;
            case BuildResult::SUCCEEDED: return SUCCEEDED_STRING;
            case BuildResult::BUILD_FAILED: return BUILD_FAILED_STRING;
            case BuildResult::POST_BUILD_CHECKS_FAILED: return POST_BUILD_CHECKS_FAILED_STRING;
            case BuildResult::FILE_CONFLICTS: return FILE_CONFLICTS_STRING;
            case BuildResult::CASCADED_DUE_TO_MISSING_DEPENDENCIES: return CASCADED_DUE_TO_MISSING_DEPENDENCIES_STRING;
            case BuildResult::EXCLUDED: return EXCLUDED_STRING;
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

    static BuildInfo inner_create_buildinfo(std::unordered_map<std::string, std::string> pgh)
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
        const Expected<std::unordered_map<std::string, std::string>> pghs =
            Paragraphs::get_single_paragraph(fs, filepath);
        Checks::check_exit(VCPKG_LINE_INFO, pghs.get() != nullptr, "Invalid BUILD_INFO file for package");
        return inner_create_buildinfo(*pghs.get());
    }

    PreBuildInfo PreBuildInfo::from_triplet_file(const VcpkgPaths& paths, const Triplet& triplet)
    {
        static constexpr CStringView FLAG_GUID = "c35112b6-d1ba-415b-aa5d-81de856ef8eb";

        const fs::path& cmake_exe_path = paths.get_tool_exe(Tools::CMAKE);
        const fs::path ports_cmake_script_path = paths.scripts / "get_triplet_environment.cmake";
        const fs::path triplet_file_path = paths.triplets / (triplet.canonical_name() + ".cmake");

        const auto cmd_launch_cmake = System::make_cmake_cmd(cmake_exe_path,
                                                             ports_cmake_script_path,
                                                             {
                                                                 {"CMAKE_TRIPLET_FILE", triplet_file_path},
                                                             });
        const auto ec_data = System::cmd_execute_and_capture_output(cmd_launch_cmake);
        Checks::check_exit(VCPKG_LINE_INFO, ec_data.exit_code == 0, ec_data.output);

        const std::vector<std::string> lines = Strings::split(ec_data.output, "\n");

        PreBuildInfo pre_build_info;

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

            if (variable_name == "VCPKG_TARGET_ARCHITECTURE")
            {
                pre_build_info.target_architecture = variable_value;
                continue;
            }

            if (variable_name == "VCPKG_CMAKE_SYSTEM_NAME")
            {
                pre_build_info.cmake_system_name = variable_value;
                continue;
            }

            if (variable_name == "VCPKG_CMAKE_SYSTEM_VERSION")
            {
                pre_build_info.cmake_system_version = variable_value;
                continue;
            }

            if (variable_name == "VCPKG_PLATFORM_TOOLSET")
            {
                pre_build_info.platform_toolset =
                    variable_value.empty() ? nullopt : Optional<std::string> {variable_value};
                continue;
            }

            if (variable_name == "VCPKG_VISUAL_STUDIO_PATH")
            {
                pre_build_info.visual_studio_path =
                    variable_value.empty() ? nullopt : Optional<fs::path> {variable_value};
                continue;
            }

            if (variable_name == "VCPKG_CHAINLOAD_TOOLCHAIN_FILE")
            {
                pre_build_info.external_toolchain_file =
                    variable_value.empty() ? nullopt : Optional<std::string> {variable_value};
                continue;
            }

            if (variable_name == "VCPKG_BUILD_TYPE")
            {
                if (variable_value.empty())
                    pre_build_info.build_type = nullopt;
                else if (Strings::case_insensitive_ascii_equals(variable_value, "debug"))
                    pre_build_info.build_type = ConfigurationType::DEBUG;
                else if (Strings::case_insensitive_ascii_equals(variable_value, "release"))
                    pre_build_info.build_type = ConfigurationType::RELEASE;
                else
                    Checks::exit_with_message(
                        VCPKG_LINE_INFO, "Unknown setting for VCPKG_BUILD_TYPE: %s", variable_value);
                continue;
            }

            Checks::exit_with_message(VCPKG_LINE_INFO, "Unknown variable name %s", line);
        }

        pre_build_info.triplet_abi_tag = [&]() {
            const auto& fs = paths.get_filesystem();
            static std::map<fs::path, std::string> s_hash_cache;

            auto it_hash = s_hash_cache.find(triplet_file_path);
            if (it_hash != s_hash_cache.end())
            {
                return it_hash->second;
            }
            auto hash = Hash::get_file_hash(fs, triplet_file_path, "SHA1");

            if (auto p = pre_build_info.external_toolchain_file.get())
            {
                hash += "-";
                hash += Hash::get_file_hash(fs, *p, "SHA1");
            }
            else if (pre_build_info.cmake_system_name == "Linux")
            {
                hash += "-";
                hash += Hash::get_file_hash(fs, paths.scripts / "toolchains" / "linux.cmake", "SHA1");
            }
            else if (pre_build_info.cmake_system_name == "Darwin")
            {
                hash += "-";
                hash += Hash::get_file_hash(fs, paths.scripts / "toolchains" / "osx.cmake", "SHA1");
            }
            else if (pre_build_info.cmake_system_name == "FreeBSD")
            {
                hash += "-";
                hash += Hash::get_file_hash(fs, paths.scripts / "toolchains" / "freebsd.cmake", "SHA1");
            }
            else if (pre_build_info.cmake_system_name == "Android")
            {
                hash += "-";
                hash += Hash::get_file_hash(fs, paths.scripts / "toolchains" / "android.cmake", "SHA1");
            }

            s_hash_cache.emplace(triplet_file_path, hash);
            return hash;
        }();

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
