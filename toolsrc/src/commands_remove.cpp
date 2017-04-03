#include "pch.h"
#include "vcpkg_Commands.h"
#include "vcpkglib.h"
#include "vcpkg_System.h"
#include "vcpkg_Input.h"
#include "vcpkg_Dependencies.h"
#include "vcpkg_Util.h"

namespace vcpkg::Commands::Remove
{
    using Dependencies::package_spec_with_remove_plan;
    using Dependencies::RemovePlanType;
    using Dependencies::RequestType;
    using Update::OutdatedPackage;

    static void delete_directory(const fs::path& directory)
    {
        std::error_code ec;
        fs::remove_all(directory, ec);
        if (!ec)
        {
            System::println(System::color::success, "Cleaned up %s", directory.string());
        }
        if (fs::exists(directory))
        {
            System::println(System::color::warning, "Some files in %s were unable to be removed. Close any editors operating in this directory and retry.", directory.string());
        }
    }

    static void remove_package(const vcpkg_paths& paths, const PackageSpec& spec, StatusParagraphs* status_db)
    {
        StatusParagraph& pkg = **status_db->find(spec.name(), spec.target_triplet());

        pkg.want = Want::PURGE;
        pkg.state = InstallState::HALF_INSTALLED;
        write_update(paths, pkg);

        std::fstream listfile(paths.listfile_path(pkg.package), std::ios_base::in | std::ios_base::binary);
        if (listfile)
        {
            std::vector<fs::path> dirs_touched;
            std::string suffix;
            while (std::getline(listfile, suffix))
            {
                if (!suffix.empty() && suffix.back() == '\r')
                    suffix.pop_back();

                std::error_code ec;

                auto target = paths.installed / suffix;

                auto status = fs::status(target, ec);
                if (ec)
                {
                    System::println(System::color::error, "failed: %s", ec.message());
                    continue;
                }

                if (fs::is_directory(status))
                {
                    dirs_touched.push_back(target);
                }
                else if (fs::is_regular_file(status))
                {
                    fs::remove(target, ec);
                    if (ec)
                    {
                        System::println(System::color::error, "failed: %s: %s", target.u8string(), ec.message());
                    }
                }
                else if (!fs::status_known(status))
                {
                    System::println(System::color::warning, "Warning: unknown status: %s", target.u8string());
                }
                else
                {
                    System::println(System::color::warning, "Warning: %s: cannot handle file type", target.u8string());
                }
            }

            auto b = dirs_touched.rbegin();
            auto e = dirs_touched.rend();
            for (; b != e; ++b)
            {
                if (fs::directory_iterator(*b) == fs::directory_iterator())
                {
                    std::error_code ec;
                    fs::remove(*b, ec);
                    if (ec)
                    {
                        System::println(System::color::error, "failed: %s", ec.message());
                    }
                }
            }

            listfile.close();
            fs::remove(paths.listfile_path(pkg.package));
        }

        pkg.state = InstallState::NOT_INSTALLED;
        write_update(paths, pkg);
    }

    static void sort_packages_by_name(std::vector<const package_spec_with_remove_plan*>* packages)
    {
        std::sort(packages->begin(), packages->end(), [](const package_spec_with_remove_plan* left, const package_spec_with_remove_plan* right) -> bool
                  {
                      return left->spec.name() < right->spec.name();
                  });
    }

    static void print_plan(const std::vector<package_spec_with_remove_plan>& plan)
    {
        std::vector<const package_spec_with_remove_plan*> not_installed;
        std::vector<const package_spec_with_remove_plan*> remove;

        for (const package_spec_with_remove_plan& i : plan)
        {
            if (i.plan.plan_type == RemovePlanType::NOT_INSTALLED)
            {
                not_installed.push_back(&i);
                continue;
            }

            if (i.plan.plan_type == RemovePlanType::REMOVE)
            {
                remove.push_back(&i);
                continue;
            }

            Checks::unreachable(VCPKG_LINE_INFO);
        }

        if (!not_installed.empty())
        {
            sort_packages_by_name(&not_installed);
            System::println("The following packages are not installed, so not removed:\n%s",
                            Strings::join("\n    ", not_installed, [](const package_spec_with_remove_plan* p)
                                          {
                                              return "    " + p->spec.toString();
                                          }));
        }

        if (!remove.empty())
        {
            sort_packages_by_name(&remove);
            System::println("The following packages will be removed:\n%s",
                            Strings::join("\n", remove, [](const package_spec_with_remove_plan* p)
                                          {
                                              if (p->plan.request_type == Dependencies::RequestType::AUTO_SELECTED)
                                              {
                                                  return "  * " + p->spec.toString();
                                              }

                                              if (p->plan.request_type == Dependencies::RequestType::USER_REQUESTED)
                                              {
                                                  return "    " + p->spec.toString();
                                              }

                                              Checks::unreachable(VCPKG_LINE_INFO);
                                          }));
        }
    }

    void perform_and_exit(const VcpkgCmdArguments& args, const vcpkg_paths& paths, const Triplet& default_target_triplet)
    {
        static const std::string OPTION_PURGE = "--purge";
        static const std::string OPTION_NO_PURGE = "--no-purge";
        static const std::string OPTION_RECURSE = "--recurse";
        static const std::string OPTION_DRY_RUN = "--dry-run";
        static const std::string OPTION_OUTDATED = "--outdated";
        static const std::string example = Commands::Help::create_example_string("remove zlib zlib:x64-windows curl boost");
        const std::unordered_set<std::string> options = args.check_and_get_optional_command_arguments({ OPTION_PURGE, OPTION_NO_PURGE, OPTION_RECURSE, OPTION_DRY_RUN, OPTION_OUTDATED });

        StatusParagraphs status_db = database_load_check(paths);
        std::vector<PackageSpec> specs;
        if (options.find(OPTION_OUTDATED) != options.cend())
        {
            args.check_exact_arg_count(0, example);
            specs = Util::fmap(Update::find_outdated_packages(paths, status_db), [](auto&& outdated) { return outdated.spec; });
        }
        else
        {
            args.check_min_arg_count(1, example);
            specs = Util::fmap(args.command_arguments, [&](auto&& arg) { return Input::check_and_get_package_spec(arg, default_target_triplet, example); });
            for (auto&& spec : specs)
                Input::check_triplet(spec.target_triplet(), paths);
        }

        const bool alsoRemoveFolderFromPackages = options.find(OPTION_NO_PURGE) == options.end();
        if (options.find(OPTION_PURGE) != options.end() && !alsoRemoveFolderFromPackages)
        {
            // User specified --purge and --no-purge
            System::println(System::color::error, "Error: cannot specify both --no-purge and --purge.");
            System::print(example);
            Checks::exit_fail(VCPKG_LINE_INFO);
        }
        const bool isRecursive = options.find(OPTION_RECURSE) != options.cend();
        const bool dryRun = options.find(OPTION_DRY_RUN) != options.cend();

        const std::vector<package_spec_with_remove_plan> remove_plan = Dependencies::create_remove_plan(specs, status_db);
        Checks::check_exit(VCPKG_LINE_INFO, !remove_plan.empty(), "Remove plan cannot be empty");

        print_plan(remove_plan);

        const bool has_non_user_requested_packages = std::find_if(remove_plan.cbegin(), remove_plan.cend(), [](const package_spec_with_remove_plan& package)-> bool
                                                                  {
                                                                      return package.plan.request_type != RequestType::USER_REQUESTED;
                                                                  }) != remove_plan.cend();

        if (has_non_user_requested_packages)
        {
            System::println(System::color::warning, "Additional packages (*) need to be removed to complete this operation.");

            if (!isRecursive)
            {
                System::println(System::color::warning, "If you are sure you want to remove them, run the command with the --recurse option");
                Checks::exit_fail(VCPKG_LINE_INFO);
            }
        }

        if (dryRun)
        {
            Checks::exit_success(VCPKG_LINE_INFO);
        }

        for (const package_spec_with_remove_plan& action : remove_plan)
        {
            const std::string display_name = action.spec.display_name();

            switch (action.plan.plan_type)
            {
                case RemovePlanType::NOT_INSTALLED:
                    System::println(System::color::success, "Package %s is not installed", display_name);
                    break;
                case RemovePlanType::REMOVE:
                    System::println("Removing package %s... ", display_name);
                    remove_package(paths, action.spec, &status_db);
                    System::println(System::color::success, "Removing package %s... done", display_name);
                    break;
                case RemovePlanType::UNKNOWN:
                default:
                    Checks::unreachable(VCPKG_LINE_INFO);
            }

            if (alsoRemoveFolderFromPackages)
            {
                System::println("Purging package %s... ", display_name);
                delete_directory(paths.packages / action.spec.dir());
                System::println(System::color::success, "Purging package %s... done", display_name);
            }
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
