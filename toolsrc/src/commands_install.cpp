#include "pch.h"
#include "vcpkg_Commands.h"
#include "vcpkglib.h"
#include "metrics.h"
#include "vcpkg_Files.h"
#include "vcpkg_System.h"
#include "vcpkg_Dependencies.h"
#include "vcpkg_Input.h"
#include "vcpkg_Util.h"
#include "Paragraphs.h"

namespace vcpkg::Commands::Install
{
    using Dependencies::InstallPlanAction;
    using Dependencies::RequestType;
    using Dependencies::InstallPlanType;

    static void install_and_write_listfile(const VcpkgPaths& paths, const BinaryParagraph& bpgh)
    {
        std::vector<std::string> output;

        const fs::path package_prefix_path = paths.package_dir(bpgh.spec);
        const size_t prefix_length = package_prefix_path.native().size();

        const Triplet& triplet = bpgh.spec.triplet();
        const std::string& triplet_subfolder = triplet.canonical_name();
        const fs::path triplet_subfolder_path = paths.installed / triplet_subfolder;
        std::error_code ec;
        fs::create_directory(triplet_subfolder_path, ec);
        output.push_back(Strings::format(R"(%s/)", triplet_subfolder));

        for (auto it = fs::recursive_directory_iterator(package_prefix_path); it != fs::recursive_directory_iterator(); ++it)
        {
            const std::string filename = it->path().filename().generic_string();
            if (fs::is_regular_file(it->status()) && (_stricmp(filename.c_str(), "CONTROL") == 0 || _stricmp(filename.c_str(), "BUILD_INFO") == 0))
            {
                // Do not copy the control file
                continue;
            }

            const std::string suffix = it->path().generic_u8string().substr(prefix_length + 1);
            const fs::path target = triplet_subfolder_path / suffix;

            auto status = it->status(ec);
            if (ec)
            {
                System::println(System::Color::error, "failed: %s: %s", it->path().u8string(), ec.message());
                continue;
            }

            if (fs::is_directory(status))
            {
                fs::create_directory(target, ec);
                if (ec)
                {
                    System::println(System::Color::error, "failed: %s: %s", target.u8string(), ec.message());
                }

                // Trailing backslash for directories
                output.push_back(Strings::format(R"(%s/%s/)", triplet_subfolder, suffix));
                continue;
            }

            if (fs::is_regular_file(status))
            {
                if (fs::exists(target))
                {
                    System::println(System::Color::warning, "File %s was already present and will be overwritten", target.u8string(), ec.message());
                }
                fs::copy_file(*it, target, fs::copy_options::overwrite_existing, ec);
                if (ec)
                {
                    System::println(System::Color::error, "failed: %s: %s", target.u8string(), ec.message());
                }
                output.push_back(Strings::format(R"(%s/%s)", triplet_subfolder, suffix));
                continue;
            }

            if (!fs::status_known(status))
            {
                System::println(System::Color::error, "failed: %s: unknown status", it->path().u8string());
                continue;
            }

            System::println(System::Color::error, "failed: %s: cannot handle file type", it->path().u8string());
        }

        std::sort(output.begin(), output.end());

        Files::write_all_lines(paths.listfile_path(bpgh), output);
    }

    static void remove_first_n_chars(std::vector<std::string>* strings, const size_t n)
    {
        for (std::string& s : *strings)
        {
            s.erase(0, n);
        }
    };

    static std::vector<std::string> extract_files_in_triplet(const std::vector<StatusParagraphAndAssociatedFiles>& pgh_and_files, const Triplet& triplet)
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

    static SortedVector<std::string> build_list_of_package_files(const fs::path& package_dir)
    {
        const std::vector<fs::path> package_file_paths = Files::recursive_find_all_files_in_dir(package_dir);
        const size_t package_remove_char_count = package_dir.generic_string().size() + 1; // +1 for the slash
        auto package_files = Util::fmap(package_file_paths, [package_remove_char_count](const fs::path& path)
                                        {
                                            std::string as_string = path.generic_string();
                                            as_string.erase(0, package_remove_char_count);
                                            return std::move(as_string);
                                        });

        return SortedVector<std::string>(std::move(package_files));
    }

    static SortedVector<std::string> build_list_of_installed_files(const std::vector<StatusParagraphAndAssociatedFiles>& pgh_and_files, const Triplet& triplet)
    {
        std::vector<std::string> installed_files = extract_files_in_triplet(pgh_and_files, triplet);
        const size_t installed_remove_char_count = triplet.canonical_name().size() + 1; // +1 for the slash
        remove_first_n_chars(&installed_files, installed_remove_char_count);

        return SortedVector<std::string>(std::move(installed_files));
    }

    static void print_plan(const std::vector<InstallPlanAction>& plan)
    {
        static constexpr std::array<InstallPlanType, 3> order = { InstallPlanType::ALREADY_INSTALLED, InstallPlanType::BUILD_AND_INSTALL, InstallPlanType::INSTALL };

        std::map<InstallPlanType, std::vector<const InstallPlanAction*>> group_by_plan_type;
        Util::group_by(plan, &group_by_plan_type, [](const InstallPlanAction& p) { return p.plan_type; });

        for (const InstallPlanType plan_type : order)
        {
            auto it = group_by_plan_type.find(plan_type);
            if (it == group_by_plan_type.cend())
            {
                continue;
            }

            std::vector<const InstallPlanAction*> cont = it->second;
            std::sort(cont.begin(), cont.end(), &InstallPlanAction::compare_by_name);
            const std::string as_string = Strings::join("\n", cont, [](const InstallPlanAction* p)
                                                        {
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
                default:
                    Checks::unreachable(VCPKG_LINE_INFO);
            }
        }
    }

    void install_package(const VcpkgPaths& paths, const BinaryParagraph& binary_paragraph, StatusParagraphs* status_db)
    {
        const fs::path package_dir = paths.package_dir(binary_paragraph.spec);
        const Triplet& triplet = binary_paragraph.spec.triplet();
        const std::vector<StatusParagraphAndAssociatedFiles> pgh_and_files = get_installed_files(paths, *status_db);

        const SortedVector<std::string> package_files = build_list_of_package_files(package_dir);
        const SortedVector<std::string> installed_files = build_list_of_installed_files(pgh_and_files, triplet);

        std::vector<std::string> intersection;
        std::set_intersection(package_files.begin(), package_files.end(),
                              installed_files.begin(), installed_files.end(),
                              std::back_inserter(intersection));

        if (!intersection.empty())
        {
            const fs::path triplet_install_path = paths.installed / triplet.canonical_name();
            System::println(System::Color::error, "The following files are already installed in %s and are in conflict with %s",
                            triplet_install_path.generic_string(),
                            binary_paragraph.spec);
            System::print("\n    ");
            System::println(Strings::join("\n    ", intersection));
            System::println("");
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        StatusParagraph spgh;
        spgh.package = binary_paragraph;
        spgh.want = Want::INSTALL;
        spgh.state = InstallState::HALF_INSTALLED;
        for (auto&& dep : spgh.package.depends)
        {
            if (status_db->find_installed(dep, spgh.package.spec.triplet()) == status_db->end())
            {
                Checks::unreachable(VCPKG_LINE_INFO);
            }
        }
        write_update(paths, spgh);
        status_db->insert(std::make_unique<StatusParagraph>(spgh));

        install_and_write_listfile(paths, spgh.package);

        spgh.state = InstallState::INSTALLED;
        write_update(paths, spgh);
        status_db->insert(std::make_unique<StatusParagraph>(spgh));
    }

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet)
    {
        static const std::string OPTION_DRY_RUN = "--dry-run";

        // input sanitization
        static const std::string example = Commands::Help::create_example_string("install zlib zlib:x64-windows curl boost");
        args.check_min_arg_count(1, example);

        const std::vector<PackageSpec> specs = Util::fmap(args.command_arguments, [&](auto&& arg)
                                                          {
                                                              return Input::check_and_get_package_spec(arg, default_triplet, example);
                                                          });
        for (auto&& spec : specs)
            Input::check_triplet(spec.triplet(), paths);

        const std::unordered_set<std::string> options = args.check_and_get_optional_command_arguments({ OPTION_DRY_RUN });
        const bool dryRun = options.find(OPTION_DRY_RUN) != options.cend();

        // create the plan
        StatusParagraphs status_db = database_load_check(paths);
        std::vector<InstallPlanAction> install_plan = Dependencies::create_install_plan(paths, specs, status_db);
        Checks::check_exit(VCPKG_LINE_INFO, !install_plan.empty(), "Install plan cannot be empty");

        // log the plan
        const std::string specs_string = Strings::join(",", install_plan, [](const InstallPlanAction& plan) { return plan.spec.to_string(); });
        Metrics::track_property("installplan", specs_string);

        print_plan(install_plan);

        const bool has_non_user_requested_packages = Util::find_if(install_plan, [](const InstallPlanAction& package)-> bool
                                                                   {
                                                                       return package.request_type != RequestType::USER_REQUESTED;
                                                                   }) != install_plan.cend();

        if (has_non_user_requested_packages)
        {
            System::println(System::Color::warning, "Additional packages (*) need to be installed to complete this operation.");
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
                            const Build::BuildResult result = Commands::Build::build_package(action.any_paragraph.source_paragraph.value_or_exit(VCPKG_LINE_INFO),
                                                                                             action.spec,
                                                                                             paths,
                                                                                             paths.port_dir(action.spec),
                                                                                             status_db);
                            if (result != Build::BuildResult::SUCCEEDED)
                            {
                                System::println(System::Color::error, Build::create_error_message(result, action.spec));
                                System::println(Build::create_user_troubleshooting_message(action.spec));
                                Checks::exit_fail(VCPKG_LINE_INFO);
                            }
                            System::println(System::Color::success, "Building package %s... done", display_name);

                            const BinaryParagraph bpgh = Paragraphs::try_load_cached_package(paths, action.spec).value_or_exit(VCPKG_LINE_INFO);
                            System::println("Installing package %s... ", display_name);
                            install_package(paths, bpgh, &status_db);
                            System::println(System::Color::success, "Installing package %s... done", display_name);
                            break;
                        }
                    case InstallPlanType::INSTALL:
                        System::println("Installing package %s... ", display_name);
                        install_package(paths, action.any_paragraph.binary_paragraph.value_or_exit(VCPKG_LINE_INFO), &status_db);
                        System::println(System::Color::success, "Installing package %s... done", display_name);
                        break;
                    case InstallPlanType::UNKNOWN:
                    default:
                        Checks::unreachable(VCPKG_LINE_INFO);
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
