#include "pch.h"

#include <vcpkg/base/files.h>
#include <vcpkg/base/hash.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/util.h>
#include <vcpkg/build.h>
#include <vcpkg/cmakevars.h>
#include <vcpkg/commands.h>
#include <vcpkg/dependencies.h>
#include <vcpkg/globalstate.h>
#include <vcpkg/help.h>
#include <vcpkg/input.h>
#include <vcpkg/install.h>
#include <vcpkg/metrics.h>
#include <vcpkg/paragraphs.h>
#include <vcpkg/remove.h>
#include <vcpkg/vcpkglib.h>

namespace vcpkg::Install
{
    using namespace vcpkg;
    using namespace Dependencies;

    using file_pack = std::pair<std::string, std::string>;

    InstallDir InstallDir::from_destination_root(const fs::path& destination_root,
                                                 const std::string& destination_subdirectory,
                                                 const fs::path& listfile)
    {
        InstallDir dirs;
        dirs.m_destination = destination_root / destination_subdirectory;
        dirs.m_destination_subdirectory = destination_subdirectory;
        dirs.m_listfile = listfile;
        return dirs;
    }

    const fs::path& InstallDir::destination() const { return this->m_destination; }

    const std::string& InstallDir::destination_subdirectory() const { return this->m_destination_subdirectory; }

    const fs::path& InstallDir::listfile() const { return this->m_listfile; }

    void install_files_and_write_listfile(Files::Filesystem& fs,
                                          const fs::path& source_dir,
                                          const InstallDir& destination_dir)
    {
        std::vector<std::string> output;
        std::error_code ec;

        const size_t prefix_length = source_dir.native().size();
        const fs::path& destination = destination_dir.destination();
        const std::string& destination_subdirectory = destination_dir.destination_subdirectory();
        const fs::path& listfile = destination_dir.listfile();

        Checks::check_exit(
            VCPKG_LINE_INFO, fs.exists(source_dir), "Source directory %s does not exist", source_dir.generic_string());
        fs.create_directories(destination, ec);
        Checks::check_exit(
            VCPKG_LINE_INFO, !ec, "Could not create destination directory %s", destination.generic_string());
        const fs::path listfile_parent = listfile.parent_path();
        fs.create_directories(listfile_parent, ec);
        Checks::check_exit(
            VCPKG_LINE_INFO, !ec, "Could not create directory for listfile %s", listfile.generic_string());

        output.push_back(Strings::format(R"(%s/)", destination_subdirectory));
        auto files = fs.get_files_recursive(source_dir);
        for (auto&& file : files)
        {
            const auto status = fs.symlink_status(file, ec);
            if (ec)
            {
                System::print2(System::Color::error, "failed: ", file.u8string(), ": ", ec.message(), "\n");
                continue;
            }

            const std::string filename = file.filename().u8string();
            if (fs::is_regular_file(status) && (Strings::case_insensitive_ascii_equals(filename, "CONTROL") ||
                                                Strings::case_insensitive_ascii_equals(filename, "BUILD_INFO")))
            {
                // Do not copy the control file
                continue;
            }

            const std::string suffix = file.generic_u8string().substr(prefix_length + 1);
            const fs::path target = destination / suffix;

            switch (status.type())
            {
                case fs::file_type::directory:
                {
                    fs.create_directory(target, ec);
                    if (ec)
                    {
                        System::printf(System::Color::error, "failed: %s: %s\n", target.u8string(), ec.message());
                    }

                    // Trailing backslash for directories
                    output.push_back(Strings::format(R"(%s/%s/)", destination_subdirectory, suffix));
                    break;
                }
                case fs::file_type::regular:
                {
                    if (fs.exists(target))
                    {
                        System::print2(System::Color::warning,
                                       "File ",
                                       target.u8string(),
                                       " was already present and will be overwritten\n");
                    }
                    fs.copy_file(file, target, fs::copy_options::overwrite_existing, ec);
                    if (ec)
                    {
                        System::printf(System::Color::error, "failed: %s: %s\n", target.u8string(), ec.message());
                    }
                    output.push_back(Strings::format(R"(%s/%s)", destination_subdirectory, suffix));
                    break;
                }
                case fs::file_type::symlink:
                {
                    if (fs.exists(target))
                    {
                        System::print2(System::Color::warning,
                                       "File ",
                                       target.u8string(),
                                       " was already present and will be overwritten\n");
                    }
                    fs.copy_symlink(file, target, ec);
                    if (ec)
                    {
                        System::printf(System::Color::error, "failed: %s: %s\n", target.u8string(), ec.message());
                    }
                    output.push_back(Strings::format(R"(%s/%s)", destination_subdirectory, suffix));
                    break;
                }
                default:
                    System::printf(System::Color::error, "failed: %s: cannot handle file type\n", file.u8string());
                    break;
            }
        }

        std::sort(output.begin(), output.end());

        fs.write_lines(listfile, output, VCPKG_LINE_INFO);
    }

    static std::vector<file_pack> extract_files_in_triplet(
        const std::vector<StatusParagraphAndAssociatedFiles>& pgh_and_files,
        const Triplet& triplet,
        const size_t remove_chars = 0)
    {
        std::vector<file_pack> output;
        for (const StatusParagraphAndAssociatedFiles& t : pgh_and_files)
        {
            if (t.pgh.package.spec.triplet() != triplet)
            {
                continue;
            }

            const std::string name = t.pgh.package.displayname();

            for (const std::string& file : t.files)
            {
                output.emplace_back(file_pack{std::string(file, remove_chars), name});
            }
        }

        std::sort(output.begin(), output.end(), [](const file_pack& lhs, const file_pack& rhs) {
            return lhs.first < rhs.first;
        });
        return output;
    }

    static SortedVector<std::string> build_list_of_package_files(const Files::Filesystem& fs,
                                                                 const fs::path& package_dir)
    {
        const std::vector<fs::path> package_file_paths = fs.get_files_recursive(package_dir);
        const size_t package_remove_char_count = package_dir.generic_string().size() + 1; // +1 for the slash
        auto package_files = Util::fmap(package_file_paths, [package_remove_char_count](const fs::path& path) {
            return std::string(path.generic_string(), package_remove_char_count);
        });

        return SortedVector<std::string>(std::move(package_files));
    }

    static SortedVector<file_pack> build_list_of_installed_files(
        const std::vector<StatusParagraphAndAssociatedFiles>& pgh_and_files, const Triplet& triplet)
    {
        const size_t installed_remove_char_count = triplet.canonical_name().size() + 1; // +1 for the slash
        std::vector<file_pack> installed_files =
            extract_files_in_triplet(pgh_and_files, triplet, installed_remove_char_count);

        return SortedVector<file_pack>(std::move(installed_files));
    }

    InstallResult install_package(const VcpkgPaths& paths, const BinaryControlFile& bcf, StatusParagraphs* status_db)
    {
        const fs::path package_dir = paths.package_dir(bcf.core_paragraph.spec);
        const Triplet& triplet = bcf.core_paragraph.spec.triplet();
        const std::vector<StatusParagraphAndAssociatedFiles> pgh_and_files = get_installed_files(paths, *status_db);

        const SortedVector<std::string> package_files =
            build_list_of_package_files(paths.get_filesystem(), package_dir);
        const SortedVector<file_pack> installed_files = build_list_of_installed_files(pgh_and_files, triplet);

        struct intersection_compare
        {
            // The VS2015 standard library requires comparison operators of T and U
            // to also support comparison of T and T, and of U and U, due to debug checks.
#if _MSC_VER <= 1910
            bool operator()(const std::string& lhs, const std::string& rhs) { return lhs < rhs; }
            bool operator()(const file_pack& lhs, const file_pack& rhs) { return lhs.first < rhs.first; }
#endif
            bool operator()(const std::string& lhs, const file_pack& rhs) { return lhs < rhs.first; }
            bool operator()(const file_pack& lhs, const std::string& rhs) { return lhs.first < rhs; }
        };

        std::vector<file_pack> intersection;

        std::set_intersection(installed_files.begin(),
                              installed_files.end(),
                              package_files.begin(),
                              package_files.end(),
                              std::back_inserter(intersection),
                              intersection_compare());

        std::sort(intersection.begin(), intersection.end(), [](const file_pack& lhs, const file_pack& rhs) {
            return lhs.second < rhs.second;
        });

        if (!intersection.empty())
        {
            const fs::path triplet_install_path = paths.installed / triplet.canonical_name();
            System::printf(System::Color::error,
                           "The following files are already installed in %s and are in conflict with %s\n\n",
                           triplet_install_path.generic_string(),
                           bcf.core_paragraph.spec);

            auto i = intersection.begin();
            while (i != intersection.end())
            {
                System::print2("Installed by ", i->second, "\n    ");
                auto next =
                    std::find_if(i, intersection.end(), [i](const auto& val) { return i->second != val.second; });

                System::print2(Strings::join("\n    ", i, next, [](const file_pack& file) { return file.first; }));
                System::print2("\n\n");

                i = next;
            }

            return InstallResult::FILE_CONFLICTS;
        }

        StatusParagraph source_paragraph;
        source_paragraph.package = bcf.core_paragraph;
        source_paragraph.want = Want::INSTALL;
        source_paragraph.state = InstallState::HALF_INSTALLED;

        write_update(paths, source_paragraph);
        status_db->insert(std::make_unique<StatusParagraph>(source_paragraph));

        std::vector<StatusParagraph> features_spghs;
        for (auto&& feature : bcf.features)
        {
            features_spghs.emplace_back();

            StatusParagraph& feature_paragraph = features_spghs.back();
            feature_paragraph.package = feature;
            feature_paragraph.want = Want::INSTALL;
            feature_paragraph.state = InstallState::HALF_INSTALLED;

            write_update(paths, feature_paragraph);
            status_db->insert(std::make_unique<StatusParagraph>(feature_paragraph));
        }

        const InstallDir install_dir = InstallDir::from_destination_root(
            paths.installed, triplet.to_string(), paths.listfile_path(bcf.core_paragraph));

        install_files_and_write_listfile(paths.get_filesystem(), package_dir, install_dir);

        source_paragraph.state = InstallState::INSTALLED;
        write_update(paths, source_paragraph);
        status_db->insert(std::make_unique<StatusParagraph>(source_paragraph));

        for (auto&& feature_paragraph : features_spghs)
        {
            feature_paragraph.state = InstallState::INSTALLED;
            write_update(paths, feature_paragraph);
            status_db->insert(std::make_unique<StatusParagraph>(feature_paragraph));
        }

        return InstallResult::SUCCESS;
    }

    using Build::BuildResult;
    using Build::ExtendedBuildResult;

    ExtendedBuildResult perform_install_plan_action(const VcpkgPaths& paths,
                                                    InstallPlanAction& action,
                                                    StatusParagraphs& status_db,
                                                    const CMakeVars::CMakeVarProvider& var_provider)
    {
        const InstallPlanType& plan_type = action.plan_type;
        const std::string display_name = action.spec.to_string();
        const std::string display_name_with_features = action.displayname();

        const bool is_user_requested = action.request_type == RequestType::USER_REQUESTED;
        const bool use_head_version = Util::Enum::to_bool(action.build_options.use_head_version);

        if (plan_type == InstallPlanType::ALREADY_INSTALLED)
        {
            if (use_head_version && is_user_requested)
                System::printf(System::Color::warning,
                               "Package %s is already installed -- not building from HEAD\n",
                               display_name);
            else
                System::printf(System::Color::success, "Package %s is already installed\n", display_name);
            return BuildResult::SUCCEEDED;
        }

        auto aux_install = [&](const std::string& name, const BinaryControlFile& bcf) -> BuildResult {
            System::printf("Installing package %s...\n", name);
            const auto install_result = install_package(paths, bcf, &status_db);
            switch (install_result)
            {
                case InstallResult::SUCCESS:
                    System::printf(System::Color::success, "Installing package %s... done\n", name);
                    return BuildResult::SUCCEEDED;
                case InstallResult::FILE_CONFLICTS: return BuildResult::FILE_CONFLICTS;
                default: Checks::unreachable(VCPKG_LINE_INFO);
            }
        };

        if (plan_type == InstallPlanType::BUILD_AND_INSTALL)
        {
            if (use_head_version)
                System::printf("Building package %s from HEAD...\n", display_name_with_features);
            else
                System::printf("Building package %s...\n", display_name_with_features);

            auto result = [&]() -> Build::ExtendedBuildResult {
                const auto& scfl = action.source_control_file_location.value_or_exit(VCPKG_LINE_INFO);
                const Build::BuildPackageConfig build_config{scfl,
                                                             action.spec.triplet(),
                                                             action.build_options,
                                                             var_provider,
                                                             std::move(action.feature_dependencies),
                                                             std::move(action.package_dependencies),
                                                             std::move(action.feature_list)};
                return Build::build_package(paths, build_config, status_db);
            }();

            if (BuildResult::DOWNLOADED == result.code)
            {
                System::print2(
                    System::Color::success, "Downloaded sources for package ", display_name_with_features, "\n");
                return result;
            }

            if (result.code != Build::BuildResult::SUCCEEDED)
            {
                System::print2(System::Color::error, Build::create_error_message(result.code, action.spec), "\n");
                return result;
            }

            System::printf("Building package %s... done\n", display_name_with_features);

            auto bcf = std::make_unique<BinaryControlFile>(
                Paragraphs::try_load_cached_package(paths, action.spec).value_or_exit(VCPKG_LINE_INFO));
            auto code = aux_install(display_name_with_features, *bcf);

            if (action.build_options.clean_packages == Build::CleanPackages::YES)
            {
                auto& fs = paths.get_filesystem();
                const fs::path package_dir = paths.package_dir(action.spec);
                fs.remove_all(package_dir, VCPKG_LINE_INFO);
            }

            if (action.build_options.clean_downloads == Build::CleanDownloads::YES)
            {
                auto& fs = paths.get_filesystem();
                const fs::path download_dir = paths.downloads;
                std::error_code ec;
                for (auto& p : fs.get_files_non_recursive(download_dir))
                {
                    if (!fs.is_directory(p))
                    {
                        fs.remove(p, VCPKG_LINE_INFO);
                    }
                }
            }

            return {code, std::move(bcf)};
        }

        if (plan_type == InstallPlanType::EXCLUDED)
        {
            System::printf(System::Color::warning, "Package %s is excluded\n", display_name);
            return BuildResult::EXCLUDED;
        }

        Checks::unreachable(VCPKG_LINE_INFO);
    }

    void InstallSummary::print() const
    {
        System::print2("RESULTS\n");

        for (const SpecSummary& result : this->results)
        {
            System::printf("    %s: %s: %s\n", result.spec, Build::to_string(result.build_result.code), result.timing);
        }

        std::map<BuildResult, int> summary;
        for (const BuildResult& v : Build::BUILD_RESULT_VALUES)
        {
            summary[v] = 0;
        }

        for (const SpecSummary& r : this->results)
        {
            summary[r.build_result.code]++;
        }

        System::print2("\nSUMMARY\n");
        for (const std::pair<const BuildResult, int>& entry : summary)
        {
            System::printf("    %s: %d\n", Build::to_string(entry.first), entry.second);
        }
    }

    InstallSummary perform(ActionPlan& action_plan,
                           const KeepGoing keep_going,
                           const VcpkgPaths& paths,
                           StatusParagraphs& status_db,
                           const CMakeVars::CMakeVarProvider& var_provider)
    {
        std::vector<SpecSummary> results;

        const auto timer = Chrono::ElapsedTimer::create_started();
        size_t counter = 0;
        const size_t package_count = action_plan.remove_actions.size() + action_plan.install_actions.size();

        auto with_tracking = [&](const PackageSpec& spec, auto f) {
            const auto build_timer = Chrono::ElapsedTimer::create_started();
            counter++;

            const std::string display_name = spec.to_string();
            System::printf("Starting package %zd/%zd: %s\n", counter, package_count, display_name);

            results.emplace_back(spec, nullptr);

            f();

            results.back().timing = build_timer.elapsed();
            System::printf("Elapsed time for package %s: %s\n", display_name, results.back().timing);
        };

        for (auto&& action : action_plan.remove_actions)
        {
            with_tracking(action.spec,
                          [&]() { Remove::perform_remove_plan_action(paths, action, Remove::Purge::YES, &status_db); });
        }

        for (auto&& action : action_plan.already_installed)
        {
            results.emplace_back(action.spec, &action);
            results.back().build_result = perform_install_plan_action(paths, action, status_db, var_provider);
        }

        for (auto&& action : action_plan.install_actions)
        {
            with_tracking(action.spec, [&]() {
                auto result = perform_install_plan_action(paths, action, status_db, var_provider);

                if (result.code != BuildResult::SUCCEEDED && keep_going == KeepGoing::NO)
                {
                    System::print2(Build::create_user_troubleshooting_message(action.spec), '\n');
                    Checks::exit_fail(VCPKG_LINE_INFO);
                }

                results.back().action = &action;
                results.back().build_result = std::move(result);
            });
        }
        return InstallSummary{std::move(results), timer.to_string()};
    }

    static constexpr StringLiteral OPTION_DRY_RUN = "--dry-run";
    static constexpr StringLiteral OPTION_USE_HEAD_VERSION = "--head";
    static constexpr StringLiteral OPTION_NO_DOWNLOADS = "--no-downloads";
    static constexpr StringLiteral OPTION_ONLY_DOWNLOADS = "--only-downloads";
    static constexpr StringLiteral OPTION_RECURSE = "--recurse";
    static constexpr StringLiteral OPTION_KEEP_GOING = "--keep-going";
    static constexpr StringLiteral OPTION_XUNIT = "--x-xunit";
    static constexpr StringLiteral OPTION_USE_ARIA2 = "--x-use-aria2";
    static constexpr StringLiteral OPTION_CLEAN_AFTER_BUILD = "--clean-after-build";

    static constexpr std::array<CommandSwitch, 8> INSTALL_SWITCHES = {{
        {OPTION_DRY_RUN, "Do not actually build or install"},
        {OPTION_USE_HEAD_VERSION, "Install the libraries on the command line using the latest upstream sources"},
        {OPTION_NO_DOWNLOADS, "Do not download new sources"},
        {OPTION_ONLY_DOWNLOADS, "Download sources but don't build packages"},
        {OPTION_RECURSE, "Allow removal of packages as part of installation"},
        {OPTION_KEEP_GOING, "Continue installing packages on failure"},
        {OPTION_USE_ARIA2, "Use aria2 to perform download tasks"},
        {OPTION_CLEAN_AFTER_BUILD, "Clean buildtrees, packages and downloads after building each package"},
    }};
    static constexpr std::array<CommandSetting, 1> INSTALL_SETTINGS = {{
        {OPTION_XUNIT, "File to output results in XUnit format (Internal use)"},
    }};

    std::vector<std::string> get_all_port_names(const VcpkgPaths& paths)
    {
        auto sources_and_errors = Paragraphs::try_load_all_ports(paths.get_filesystem(), paths.ports);

        return Util::fmap(sources_and_errors.paragraphs,
                          [](auto&& pgh) -> std::string { return pgh->core_paragraph->name; });
    }

    const CommandStructure COMMAND_STRUCTURE = {
        Help::create_example_string("install zlib zlib:x64-windows curl boost"),
        1,
        SIZE_MAX,
        {INSTALL_SWITCHES, INSTALL_SETTINGS},
        &get_all_port_names,
    };

    static void print_cmake_information(const BinaryParagraph& bpgh, const VcpkgPaths& paths)
    {
        static const std::regex cmake_library_regex(R"(\badd_library\(([^\$\s\)]+)\s)",
                                                    std::regex_constants::ECMAScript);

        auto& fs = paths.get_filesystem();

        auto usage_file = paths.installed / bpgh.spec.triplet().canonical_name() / "share" / bpgh.spec.name() / "usage";
        if (fs.exists(usage_file))
        {
            auto maybe_contents = fs.read_contents(usage_file);
            if (auto p_contents = maybe_contents.get())
            {
                System::print2(*p_contents, '\n');
            }
            return;
        }

        auto files = fs.read_lines(paths.listfile_path(bpgh));
        if (auto p_lines = files.get())
        {
            std::map<std::string, std::string> config_files;
            std::map<std::string, std::vector<std::string>> library_targets;

            for (auto&& suffix : *p_lines)
            {
                if (Strings::case_insensitive_ascii_contains(suffix, "/share/") && Strings::ends_with(suffix, ".cmake"))
                {
                    // CMake file is inside the share folder
                    auto path = paths.installed / suffix;
                    auto maybe_contents = fs.read_contents(path);
                    auto find_package_name = path.parent_path().filename().u8string();
                    if (auto p_contents = maybe_contents.get())
                    {
                        std::sregex_iterator next(p_contents->begin(), p_contents->end(), cmake_library_regex);
                        std::sregex_iterator last;

                        while (next != last)
                        {
                            auto match = *next;
                            auto& targets = library_targets[find_package_name];
                            if (std::find(targets.cbegin(), targets.cend(), match[1]) == targets.cend())
                                targets.push_back(match[1]);
                            ++next;
                        }
                    }

                    auto filename = fs::u8path(suffix).filename().u8string();

                    if (Strings::ends_with(filename, "Config.cmake"))
                    {
                        auto root = filename.substr(0, filename.size() - 12);
                        if (Strings::case_insensitive_ascii_equals(root, find_package_name))
                            config_files[find_package_name] = root;
                    }
                    else if (Strings::ends_with(filename, "-config.cmake"))
                    {
                        auto root = filename.substr(0, filename.size() - 13);
                        if (Strings::case_insensitive_ascii_equals(root, find_package_name))
                            config_files[find_package_name] = root;
                    }
                }
            }

            if (library_targets.empty())
            {
            }
            else
            {
                System::print2("The package ", bpgh.spec, " provides CMake targets:\n\n");

                for (auto&& library_target_pair : library_targets)
                {
                    auto config_it = config_files.find(library_target_pair.first);
                    if (config_it != config_files.end())
                        System::printf("    find_package(%s CONFIG REQUIRED)\n", config_it->second);
                    else
                        System::printf("    find_package(%s CONFIG REQUIRED)\n", library_target_pair.first);

                    std::sort(library_target_pair.second.begin(),
                              library_target_pair.second.end(),
                              [](const std::string& l, const std::string& r) {
                                  if (l.size() < r.size()) return true;
                                  if (l.size() > r.size()) return false;
                                  return l < r;
                              });

                    if (library_target_pair.second.size() <= 4)
                    {
                        System::printf("    target_link_libraries(main PRIVATE %s)\n\n",
                                       Strings::join(" ", library_target_pair.second));
                    }
                    else
                    {
                        auto omitted = library_target_pair.second.size() - 4;
                        library_target_pair.second.erase(library_target_pair.second.begin() + 4,
                                                         library_target_pair.second.end());
                        System::printf("    # Note: %zd target(s) were omitted.\n"
                                       "    target_link_libraries(main PRIVATE %s)\n\n",
                                       omitted,
                                       Strings::join(" ", library_target_pair.second));
                    }
                }
            }
        }
    }

    ///
    /// <summary>
    /// Run "install" command.
    /// </summary>
    ///
    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet)
    {
        // input sanitization
        const ParsedArguments options = args.parse_arguments(COMMAND_STRUCTURE);

        const std::vector<FullPackageSpec> specs = Util::fmap(args.command_arguments, [&](auto&& arg) {
            return Input::check_and_get_full_package_spec(
                std::string(arg), default_triplet, COMMAND_STRUCTURE.example_text);
        });

        for (auto&& spec : specs)
        {
            Input::check_triplet(spec.package_spec.triplet(), paths);
        }

        const bool dry_run = Util::Sets::contains(options.switches, OPTION_DRY_RUN);
        const bool use_head_version = Util::Sets::contains(options.switches, (OPTION_USE_HEAD_VERSION));
        const bool no_downloads = Util::Sets::contains(options.switches, (OPTION_NO_DOWNLOADS));
        const bool only_downloads = Util::Sets::contains(options.switches, (OPTION_ONLY_DOWNLOADS));
        const bool is_recursive = Util::Sets::contains(options.switches, (OPTION_RECURSE));
        const bool use_aria2 = Util::Sets::contains(options.switches, (OPTION_USE_ARIA2));
        const bool clean_after_build = Util::Sets::contains(options.switches, (OPTION_CLEAN_AFTER_BUILD));
        const KeepGoing keep_going =
            to_keep_going(Util::Sets::contains(options.switches, OPTION_KEEP_GOING) || only_downloads);

        auto& fs = paths.get_filesystem();

        // create the plan
        System::print2("Computing installation plan...\n");
        StatusParagraphs status_db = database_load_check(paths);

        Build::DownloadTool download_tool = Build::DownloadTool::BUILT_IN;
        if (use_aria2) download_tool = Build::DownloadTool::ARIA2;

        const Build::BuildPackageOptions install_plan_options = {
            Util::Enum::to_enum<Build::UseHeadVersion>(use_head_version),
            Util::Enum::to_enum<Build::AllowDownloads>(!no_downloads),
            Util::Enum::to_enum<Build::OnlyDownloads>(only_downloads),
            clean_after_build ? Build::CleanBuildtrees::YES : Build::CleanBuildtrees::NO,
            clean_after_build ? Build::CleanPackages::YES : Build::CleanPackages::NO,
            clean_after_build ? Build::CleanDownloads::YES : Build::CleanDownloads::NO,
            download_tool,
            (GlobalState::g_binary_caching && !only_downloads) ? Build::BinaryCaching::YES : Build::BinaryCaching::NO,
            Build::FailOnTombstone::NO,
        };

        //// Load ports from ports dirs
        PortFileProvider::PathsPortFileProvider provider(paths, args.overlay_ports.get());
        CMakeVars::TripletCMakeVarProvider var_provider(paths);

        // Note: action_plan will hold raw pointers to SourceControlFileLocations from this map
        auto action_plan = Dependencies::create_feature_install_plan(provider, var_provider, specs, status_db);

        std::vector<FullPackageSpec> install_package_specs;
        for (auto&& action : action_plan.install_actions)
        {
            action.build_options = install_plan_options;
            if (action.request_type != RequestType::USER_REQUESTED)
                action.build_options.use_head_version = Build::UseHeadVersion::NO;

            install_package_specs.emplace_back(FullPackageSpec{action.spec, action.feature_list});
        }

        var_provider.load_tag_vars(install_package_specs, provider);

        // install plan will be empty if it is already installed - need to change this at status paragraph part
        Checks::check_exit(VCPKG_LINE_INFO, !action_plan.empty(), "Install plan cannot be empty");

        // log the plan
        std::string specs_string;
        for (auto&& remove_action : action_plan.remove_actions)
        {
            if (!specs_string.empty()) specs_string += ",";
            specs_string += "R$" + Hash::get_string_hash(remove_action.spec.to_string(), Hash::Algorithm::Sha256);
        }
        for (auto&& install_action : action_plan.install_actions)
        {
            if (!specs_string.empty()) specs_string += ",";
            specs_string += Hash::get_string_hash(install_action.spec.to_string(), Hash::Algorithm::Sha256);
        }

        Metrics::g_metrics.lock()->track_property("installplan_1", specs_string);

        Dependencies::print_plan(action_plan, is_recursive, paths.ports);

        if (dry_run)
        {
            Checks::exit_success(VCPKG_LINE_INFO);
        }

        const InstallSummary summary = perform(action_plan, keep_going, paths, status_db, var_provider);

        System::print2("\nTotal elapsed time: ", summary.total_elapsed_time, "\n\n");

        if (keep_going == KeepGoing::YES)
        {
            summary.print();
        }

        auto it_xunit = options.settings.find(OPTION_XUNIT);
        if (it_xunit != options.settings.end())
        {
            std::string xunit_doc = "<assemblies><assembly><collection>\n";

            xunit_doc += summary.xunit_results();

            xunit_doc += "</collection></assembly></assemblies>\n";
            fs.write_contents(fs::u8path(it_xunit->second), xunit_doc, VCPKG_LINE_INFO);
        }

        for (auto&& result : summary.results)
        {
            if (!result.action) continue;
            if (result.action->request_type != RequestType::USER_REQUESTED) continue;
            auto bpgh = result.get_binary_paragraph();
            if (!bpgh) continue;
            print_cmake_information(*bpgh, paths);
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }

    SpecSummary::SpecSummary(const PackageSpec& spec, const Dependencies::InstallPlanAction* action)
        : spec(spec), build_result{BuildResult::NULLVALUE, nullptr}, action(action)
    {
    }

    const BinaryParagraph* SpecSummary::get_binary_paragraph() const
    {
        if (build_result.binary_control_file) return &build_result.binary_control_file->core_paragraph;
        if (action)
            if (auto p_status = action->installed_package.get())
            {
                return &p_status->core->package;
            }
        return nullptr;
    }

    static std::string xunit_result(const PackageSpec& spec, Chrono::ElapsedTime time, BuildResult code)
    {
        std::string message_block;
        const char* result_string = "";
        switch (code)
        {
            case BuildResult::POST_BUILD_CHECKS_FAILED:
            case BuildResult::FILE_CONFLICTS:
            case BuildResult::BUILD_FAILED:
                result_string = "Fail";
                message_block =
                    Strings::format("<failure><message><![CDATA[%s]]></message></failure>", to_string(code));
                break;
            case BuildResult::EXCLUDED:
            case BuildResult::CASCADED_DUE_TO_MISSING_DEPENDENCIES:
                result_string = "Skip";
                message_block = Strings::format("<reason><![CDATA[%s]]></reason>", to_string(code));
                break;
            case BuildResult::SUCCEEDED: result_string = "Pass"; break;
            default: Checks::exit_fail(VCPKG_LINE_INFO);
        }

        return Strings::format(R"(<test name="%s" method="%s" time="%lld" result="%s">%s</test>)"
                               "\n",
                               spec,
                               spec,
                               time.as<std::chrono::seconds>().count(),
                               result_string,
                               message_block);
    }

    std::string InstallSummary::xunit_results() const
    {
        std::string xunit_doc;
        for (auto&& result : results)
        {
            xunit_doc += xunit_result(result.spec, result.timing, result.build_result.code);
        }
        return xunit_doc;
    }
}
