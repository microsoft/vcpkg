#include "pch.h"
#include "vcpkg_Commands.h"
#include "vcpkglib.h"
#include "metrics.h"
#include "vcpkg_Files.h"
#include "vcpkg_System.h"
#include "vcpkg_Dependencies.h"
#include "vcpkg_Input.h"
#include "Paragraphs.h"

namespace vcpkg::Commands::Install
{
    using Dependencies::package_spec_with_install_plan;
    using Dependencies::install_plan_type;

    static void install_and_write_listfile(const vcpkg_paths& paths, const BinaryParagraph& bpgh)
    {
        std::vector<std::string> output;

        const fs::path package_prefix_path = paths.package_dir(bpgh.spec);
        const size_t prefix_length = package_prefix_path.native().size();

        const triplet& target_triplet = bpgh.spec.target_triplet();
        const std::string& target_triplet_as_string = target_triplet.canonical_name();
        std::error_code ec;
        fs::create_directory(paths.installed / target_triplet_as_string, ec);
        output.push_back(Strings::format(R"(%s/)", target_triplet_as_string));

        for (auto it = fs::recursive_directory_iterator(package_prefix_path); it != fs::recursive_directory_iterator(); ++it)
        {
            const std::string filename = it->path().filename().generic_string();
            if (fs::is_regular_file(it->status()) && (_stricmp(filename.c_str(), "CONTROL") == 0 || _stricmp(filename.c_str(), "BUILD_INFO") == 0))
            {
                // Do not copy the control file
                continue;
            }

            const std::string suffix = it->path().generic_u8string().substr(prefix_length + 1);
            const fs::path target = paths.installed / target_triplet_as_string / suffix;

            auto status = it->status(ec);
            if (ec)
            {
                System::println(System::color::error, "failed: %s: %s", it->path().u8string(), ec.message());
                continue;
            }

            if (fs::is_directory(status))
            {
                fs::create_directory(target, ec);
                if (ec)
                {
                    System::println(System::color::error, "failed: %s: %s", target.u8string(), ec.message());
                }

                // Trailing backslash for directories
                output.push_back(Strings::format(R"(%s/%s/)", target_triplet_as_string, suffix));
                continue;
            }

            if (fs::is_regular_file(status))
            {
                if (fs::exists(target))
                {
                    System::println(System::color::warning, "File %s was already present and will be overwritten", target.u8string(), ec.message());
                }
                fs::copy_file(*it, target, fs::copy_options::overwrite_existing, ec);
                if (ec)
                {
                    System::println(System::color::error, "failed: %s: %s", target.u8string(), ec.message());
                }
                output.push_back(Strings::format(R"(%s/%s)", target_triplet_as_string, suffix));
                continue;
            }

            if (!fs::status_known(status))
            {
                System::println(System::color::error, "failed: %s: unknown status", it->path().u8string());
                continue;
            }

            System::println(System::color::error, "failed: %s: cannot handle file type", it->path().u8string());
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

    static std::vector<std::string> extract_files_in_triplet(const std::vector<StatusParagraph_and_associated_files>& pgh_and_files, const triplet& triplet)
    {
        std::vector<std::string> output;
        for (const StatusParagraph_and_associated_files& t : pgh_and_files)
        {
            if (t.pgh.package.spec.target_triplet() != triplet)
            {
                continue;
            }

            output.insert(output.end(), t.files.cbegin(), t.files.cend());
        }

        std::sort(output.begin(), output.end());
        return output;
    }

    static ImmutableSortedVector<std::string> build_list_of_package_files(const fs::path& package_dir)
    {
        const std::vector<fs::path> package_file_paths = Files::recursive_find_all_files_in_dir(package_dir);
        std::vector<std::string> package_files;
        const size_t package_remove_char_count = package_dir.generic_string().size() + 1; // +1 for the slash
        std::transform(package_file_paths.cbegin(), package_file_paths.cend(), std::back_inserter(package_files), [package_remove_char_count](const fs::path& path)
                       {
                           std::string as_string = path.generic_string();
                           as_string.erase(0, package_remove_char_count);
                           return std::move(as_string);
                       });

        return ImmutableSortedVector<std::string>::create(std::move(package_files));
    }

    static ImmutableSortedVector<std::string> build_list_of_installed_files(const std::vector<StatusParagraph_and_associated_files>& pgh_and_files, const triplet& triplet)
    {
        std::vector<std::string> installed_files = extract_files_in_triplet(pgh_and_files, triplet);
        const size_t installed_remove_char_count = triplet.canonical_name().size() + 1; // +1 for the slash
        remove_first_n_chars(&installed_files, installed_remove_char_count);

        return ImmutableSortedVector<std::string>::create(std::move(installed_files));
    }

    void install_package(const vcpkg_paths& paths, const BinaryParagraph& binary_paragraph, StatusParagraphs* status_db)
    {
        const fs::path package_dir = paths.package_dir(binary_paragraph.spec);
        const triplet& triplet = binary_paragraph.spec.target_triplet();
        const std::vector<StatusParagraph_and_associated_files> pgh_and_files = get_installed_files(paths, *status_db);

        const ImmutableSortedVector<std::string> package_files = build_list_of_package_files(package_dir);
        const ImmutableSortedVector<std::string> installed_files = build_list_of_installed_files(pgh_and_files, triplet);

        std::vector<std::string> intersection;
        std::set_intersection(package_files.cbegin(), package_files.cend(),
                              installed_files.cbegin(), installed_files.cend(),
                              std::back_inserter(intersection));

        if (!intersection.empty())
        {
            const fs::path triplet_install_path = paths.installed / triplet.canonical_name();
            System::println(System::color::error, "The following files are already installed in %s and are in conflict with %s",
                            triplet_install_path.generic_string(),
                            binary_paragraph.spec);
            System::print("\n    ");
            System::println(Strings::join("\n    ", intersection));
            System::println("");
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        StatusParagraph spgh;
        spgh.package = binary_paragraph;
        spgh.want = want_t::install;
        spgh.state = install_state_t::half_installed;
        for (auto&& dep : spgh.package.depends)
        {
            if (status_db->find_installed(dep, spgh.package.spec.target_triplet()) == status_db->end())
            {
                Checks::unreachable(VCPKG_LINE_INFO);
            }
        }
        write_update(paths, spgh);
        status_db->insert(std::make_unique<StatusParagraph>(spgh));

        install_and_write_listfile(paths, spgh.package);

        spgh.state = install_state_t::installed;
        write_update(paths, spgh);
        status_db->insert(std::make_unique<StatusParagraph>(spgh));
    }

    void perform_and_exit(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths, const triplet& default_target_triplet)
    {
        static const std::string example = Commands::Help::create_example_string("install zlib zlib:x64-windows curl boost");
        args.check_min_arg_count(1, example);
        std::vector<package_spec> specs = Input::check_and_get_package_specs(args.command_arguments, default_target_triplet, example);
        Input::check_triplets(specs, paths);
        args.check_and_get_optional_command_arguments({});

        StatusParagraphs status_db = database_load_check(paths);
        std::vector<package_spec_with_install_plan> install_plan = Dependencies::create_install_plan(paths, specs, status_db);
        Checks::check_exit(VCPKG_LINE_INFO, !install_plan.empty(), "Install plan cannot be empty");

        std::string specs_string = install_plan[0].spec.toString();
        for (size_t i = 1; i < install_plan.size(); ++i)
        {
            specs_string.push_back(',');
            specs_string.append(install_plan[i].spec.toString());
        }
        TrackProperty("installplan", specs_string);

        for (const package_spec_with_install_plan& action : install_plan)
        {
            try
            {
                if (action.plan.plan_type == install_plan_type::ALREADY_INSTALLED)
                {
                    if (std::find(specs.begin(), specs.end(), action.spec) != specs.end())
                    {
                        System::println(System::color::success, "Package %s is already installed", action.spec);
                    }
                }
                else if (action.plan.plan_type == install_plan_type::BUILD_AND_INSTALL)
                {
                    const Build::BuildResult result = Commands::Build::build_package(action.plan.source_pgh.get_or_exit(VCPKG_LINE_INFO),
                                                                                     action.spec,
                                                                                     paths,
                                                                                     paths.port_dir(action.spec),
                                                                                     status_db);
                    if (result != Build::BuildResult::SUCCEEDED)
                    {
                        System::println(System::color::error, Build::create_error_message(result, action.spec));
                        System::println(Build::create_user_troubleshooting_message(action.spec));
                        Checks::exit_fail(VCPKG_LINE_INFO);
                    }
                    const BinaryParagraph bpgh = Paragraphs::try_load_cached_package(paths, action.spec).value_or_exit(VCPKG_LINE_INFO);
                    install_package(paths, bpgh, &status_db);
                    System::println(System::color::success, "Package %s is installed", action.spec);
                }
                else if (action.plan.plan_type == install_plan_type::INSTALL)
                {
                    install_package(paths, action.plan.binary_pgh.get_or_exit(VCPKG_LINE_INFO), &status_db);
                    System::println(System::color::success, "Package %s is installed", action.spec);
                }
                else
                    Checks::unreachable(VCPKG_LINE_INFO);
            }
            catch (const std::exception& e)
            {
                System::println(System::color::error, "Error: Could not install package %s: %s", action.spec, e.what());
                Checks::exit_fail(VCPKG_LINE_INFO);
            }
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
