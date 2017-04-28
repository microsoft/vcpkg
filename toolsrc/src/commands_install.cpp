#include "pch.h"

#include "Paragraphs.h"
#include "metrics.h"
#include "vcpkg_Commands.h"
#include "vcpkg_Dependencies.h"
#include "vcpkg_Files.h"
#include "vcpkg_Input.h"
#include "vcpkg_System.h"
#include "vcpkg_Util.h"
#include "vcpkglib.h"

namespace vcpkg::Commands::Install
{
    using Dependencies::InstallPlanAction;
    using Dependencies::RequestType;
    using Dependencies::InstallPlanType;

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
            auto status = fs.status(file, ec);
            if (ec)
            {
                System::println(System::Color::error, "failed: %s: %s", file.u8string(), ec.message());
                continue;
            }

            const std::string filename = file.filename().generic_string();
            if (fs::is_regular_file(status) &&
                (_stricmp(filename.c_str(), "CONTROL") == 0 || _stricmp(filename.c_str(), "BUILD_INFO") == 0))
            {
                // Do not copy the control file
                continue;
            }

            const std::string suffix = file.generic_u8string().substr(prefix_length + 1);
            const fs::path target = destination / suffix;

            if (fs::is_directory(status))
            {
                fs.create_directory(target, ec);
                if (ec)
                {
                    System::println(System::Color::error, "failed: %s: %s", target.u8string(), ec.message());
                }

                // Trailing backslash for directories
                output.push_back(Strings::format(R"(%s/%s/)", destination_subdirectory, suffix));
                continue;
            }

            if (fs::is_regular_file(status))
            {
                if (fs.exists(target))
                {
                    System::println(System::Color::warning,
                                    "File %s was already present and will be overwritten",
                                    target.u8string(),
                                    ec.message());
                }
                fs.copy_file(file, target, fs::copy_options::overwrite_existing, ec);
                if (ec)
                {
                    System::println(System::Color::error, "failed: %s: %s", target.u8string(), ec.message());
                }
                output.push_back(Strings::format(R"(%s/%s)", destination_subdirectory, suffix));
                continue;
            }

            if (!fs::status_known(status))
            {
                System::println(System::Color::error, "failed: %s: unknown status", file.u8string());
                continue;
            }

            System::println(System::Color::error, "failed: %s: cannot handle file type", file.u8string());
        }

        std::sort(output.begin(), output.end());

        fs.write_lines(listfile, output);
    }

    static void remove_first_n_chars(std::vector<std::string>* strings, const size_t n)
    {
        for (std::string& s : *strings)
        {
            s.erase(0, n);
        }
    };

    static std::vector<std::string> extract_files_in_triplet(
        const std::vector<StatusParagraphAndAssociatedFiles>& pgh_and_files, const Triplet& triplet)
    {
        std::vector<std::string> output;
        for (const StatusParagraphAndAssociatedFiles& t : pgh_and_files)
        {
            if (t.pgh.package.spec.triplet() != triplet)
            {
                continue;
            }

            output.insert(output.end(), t.files.begin(), t.files.end());
        }

        std::sort(output.begin(), output.end());
        return output;
    }

    static SortedVector<std::string> build_list_of_package_files(const Files::Filesystem& fs,
                                                                 const fs::path& package_dir)
    {
        const std::vector<fs::path> package_file_paths = fs.get_files_recursive(package_dir);
        const size_t package_remove_char_count = package_dir.generic_string().size() + 1; // +1 for the slash
        auto package_files = Util::fmap(package_file_paths, [package_remove_char_count](const fs::path& path) {
            std::string as_string = path.generic_string();
            as_string.erase(0, package_remove_char_count);
            return std::move(as_string);
        });

        return SortedVector<std::string>(std::move(package_files));
    }

    static SortedVector<std::string> build_list_of_installed_files(
        const std::vector<StatusParagraphAndAssociatedFiles>& pgh_and_files, const Triplet& triplet)
    {
        std::vector<std::string> installed_files = extract_files_in_triplet(pgh_and_files, triplet);
        const size_t installed_remove_char_count = triplet.canonical_name().size() + 1; // +1 for the slash
        remove_first_n_chars(&installed_files, installed_remove_char_count);

        return SortedVector<std::string>(std::move(installed_files));
    }

    static void print_plan(const std::map<InstallPlanType, std::vector<const InstallPlanAction*>>& group_by_plan_type)
    {
        static constexpr std::array<InstallPlanType, 3> order = { InstallPlanType::ALREADY_INSTALLED,
                                                                  InstallPlanType::BUILD_AND_INSTALL,
                                                                  InstallPlanType::INSTALL };

        for (const InstallPlanType plan_type : order)
        {
            auto it = group_by_plan_type.find(plan_type);
            if (it == group_by_plan_type.cend())
            {
                continue;
            }

            std::vector<const InstallPlanAction*> cont = it->second;
            std::sort(cont.begin(), cont.end(), &InstallPlanAction::compare_by_name);
            const std::string as_string = Strings::join("\n", cont, [](const InstallPlanAction* p) {
                return Dependencies::to_output_string(p->request_type, p->spec.to_string());
            });

            switch (plan_type)
            {
                case InstallPlanType::ALREADY_INSTALLED:
                    System::println("The following packages are already installed:\n%s", as_string);
                    continue;
                case InstallPlanType::BUILD_AND_INSTALL:
                    System::println("The following packages will be built and installed:\n%s", as_string);
                    continue;
                case InstallPlanType::INSTALL:
                    System::println("The following packages will be installed:\n%s", as_string);
                    continue;
                default: Checks::unreachable(VCPKG_LINE_INFO);
            }
        }
    }

    void install_package(const VcpkgPaths& paths, const BinaryParagraph& binary_paragraph, StatusParagraphs* status_db)
    {
        const fs::path package_dir = paths.package_dir(binary_paragraph.spec);
        const Triplet& triplet = binary_paragraph.spec.triplet();
        const std::vector<StatusParagraphAndAssociatedFiles> pgh_and_files = get_installed_files(paths, *status_db);

        const SortedVector<std::string> package_files =
            build_list_of_package_files(paths.get_filesystem(), package_dir);
        const SortedVector<std::string> installed_files = build_list_of_installed_files(pgh_and_files, triplet);

        std::vector<std::string> intersection;
        std::set_intersection(package_files.begin(),
                              package_files.end(),
                              installed_files.begin(),
                              installed_files.end(),
                              std::back_inserter(intersection));

        if (!intersection.empty())
        {
            const fs::path triplet_install_path = paths.installed / triplet.canonical_name();
            System::println(System::Color::error,
                            "The following files are already installed in %s and are in conflict with %s",
                            triplet_install_path.generic_string(),
                            binary_paragraph.spec);
            System::print("\n    ");
            System::println(Strings::join("\n    ", intersection));
            System::println("");
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        StatusParagraph source_paragraph;
        source_paragraph.package = binary_paragraph;
        source_paragraph.want = Want::INSTALL;
        source_paragraph.state = InstallState::HALF_INSTALLED;
        for (auto&& dep : source_paragraph.package.depends)
        {
            if (status_db->find_installed(dep, source_paragraph.package.spec.triplet()) == status_db->end())
            {
                Checks::unreachable(VCPKG_LINE_INFO);
            }
        }
        write_update(paths, source_paragraph);
        status_db->insert(std::make_unique<StatusParagraph>(source_paragraph));

        const InstallDir install_dir = InstallDir::from_destination_root(
            paths.installed, triplet.to_string(), paths.listfile_path(binary_paragraph));

        install_files_and_write_listfile(paths.get_filesystem(), package_dir, install_dir);

        source_paragraph.state = InstallState::INSTALLED;
        write_update(paths, source_paragraph);
        status_db->insert(std::make_unique<StatusParagraph>(source_paragraph));
    }

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet)
    {
        static const std::string OPTION_DRY_RUN = "--dry-run";

        // input sanitization
        static const std::string example =
            Commands::Help::create_example_string("install zlib zlib:x64-windows curl boost");
        args.check_min_arg_count(1, example);

        const std::vector<PackageSpec> specs = Util::fmap(args.command_arguments, [&](auto&& arg) {
            return Input::check_and_get_package_spec(arg, default_triplet, example);
        });
        for (auto&& spec : specs)
            Input::check_triplet(spec.triplet(), paths);

        const std::unordered_set<std::string> options =
            args.check_and_get_optional_command_arguments({ OPTION_DRY_RUN });
        const bool dryRun = options.find(OPTION_DRY_RUN) != options.cend();

        // create the plan
        StatusParagraphs status_db = database_load_check(paths);
        std::vector<InstallPlanAction> install_plan = Dependencies::create_install_plan(paths, specs, status_db);
        Checks::check_exit(VCPKG_LINE_INFO, !install_plan.empty(), "Install plan cannot be empty");

        // log the plan
        const std::string specs_string =
            Strings::join(",", install_plan, [](const InstallPlanAction& plan) { return plan.spec.to_string(); });
        Metrics::track_property("installplan", specs_string);

        std::map<InstallPlanType, std::vector<const InstallPlanAction*>> group_by_plan_type;
        Util::group_by(install_plan, &group_by_plan_type, [](const InstallPlanAction& p) { return p.plan_type; });
        print_plan(group_by_plan_type);

        const bool has_non_user_requested_packages =
            Util::find_if(install_plan, [](const InstallPlanAction& package) -> bool {
                return package.request_type != RequestType::USER_REQUESTED;
            }) != install_plan.cend();

        if (has_non_user_requested_packages)
        {
            System::println(System::Color::warning,
                            "Additional packages (*) need to be installed to complete this operation.");
        }

        if (dryRun)
        {
            Checks::exit_success(VCPKG_LINE_INFO);
        }

        // execute the plan
        for (const InstallPlanAction& action : install_plan)
        {
            const std::string display_name = action.spec.to_string();

            try
            {
                switch (action.plan_type)
                {
                    case InstallPlanType::ALREADY_INSTALLED:
                        System::println(System::Color::success, "Package %s is already installed", display_name);
                        break;
                    case InstallPlanType::BUILD_AND_INSTALL:
                    {
                        System::println("Building package %s... ", display_name);
                        const auto result = Commands::Build::build_package(
                            action.any_paragraph.source_paragraph.value_or_exit(VCPKG_LINE_INFO),
                            action.spec,
                            paths,
                            paths.port_dir(action.spec),
                            status_db);
                        if (result.code != Build::BuildResult::SUCCEEDED)
                        {
                            System::println(System::Color::error,
                                            Build::create_error_message(result.code, action.spec));
                            System::println(Build::create_user_troubleshooting_message(action.spec));
                            Checks::exit_fail(VCPKG_LINE_INFO);
                        }
                        System::println(System::Color::success, "Building package %s... done", display_name);

                        const BinaryParagraph bpgh =
                            Paragraphs::try_load_cached_package(paths, action.spec).value_or_exit(VCPKG_LINE_INFO);
                        System::println("Installing package %s... ", display_name);
                        install_package(paths, bpgh, &status_db);
                        System::println(System::Color::success, "Installing package %s... done", display_name);
                        break;
                    }
                    case InstallPlanType::INSTALL:
                        System::println("Installing package %s... ", display_name);
                        install_package(
                            paths, action.any_paragraph.binary_paragraph.value_or_exit(VCPKG_LINE_INFO), &status_db);
                        System::println(System::Color::success, "Installing package %s... done", display_name);
                        break;
                    case InstallPlanType::UNKNOWN:
                    default: Checks::unreachable(VCPKG_LINE_INFO);
                }
            }
            catch (const std::exception& e)
            {
                System::println(System::Color::error, "Error: Could not install package %s: %s", action.spec, e.what());
                Checks::exit_fail(VCPKG_LINE_INFO);
            }
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
