#include "pch.h"
#include "vcpkg_Commands.h"
#include "vcpkglib.h"
#include "vcpkg_System.h"
#include "vcpkg_Input.h"
#include "vcpkg_Dependencies.h"

namespace vcpkg::Commands::Remove
{
    using Dependencies::package_spec_with_remove_plan;
    using Dependencies::remove_plan_type;

    static const std::string OPTION_PURGE = "--purge";

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

    static remove_plan_type deinstall_package_plan(
        const StatusParagraphs::iterator package_it,
        const StatusParagraphs& status_db,
        std::vector<const StatusParagraph*>& dependencies_out)
    {
        dependencies_out.clear();

        if (package_it == status_db.end() || (*package_it)->state == install_state_t::not_installed)
        {
            return remove_plan_type::NOT_INSTALLED;
        }

        auto& pkg = (*package_it)->package;

        for (auto&& inst_pkg : status_db)
        {
            if (inst_pkg->want != want_t::install)
                continue;
            if (inst_pkg->package.spec.target_triplet() != pkg.spec.target_triplet())
                continue;

            const auto& deps = inst_pkg->package.depends;

            if (std::find(deps.begin(), deps.end(), pkg.spec.name()) != deps.end())
            {
                dependencies_out.push_back(inst_pkg.get());
            }
        }

        if (!dependencies_out.empty())
            return remove_plan_type::DEPENDENCIES_NOT_SATISFIED;

        return remove_plan_type::REMOVE;
    }

    static void deinstall_package(const vcpkg_paths& paths, const package_spec& spec, StatusParagraphs& status_db)
    {
        auto package_it = status_db.find(spec.name(), spec.target_triplet());
        if (package_it == status_db.end())
        {
            System::println(System::color::success, "Package %s is not installed", spec);
            return;
        }

        auto& pkg = **package_it;

        std::vector<const StatusParagraph*> deps;
        auto plan = deinstall_package_plan(package_it, status_db, deps);
        switch (plan)
        {
            case remove_plan_type::NOT_INSTALLED:
                System::println(System::color::success, "Package %s is not installed", spec);
                return;
            case remove_plan_type::DEPENDENCIES_NOT_SATISFIED:
                System::println(System::color::error, "Error: Cannot remove package %s:", spec);
                for (auto&& dep : deps)
                {
                    System::println("  %s depends on %s", dep->package.displayname(), pkg.package.displayname());
                }
                exit(EXIT_FAILURE);
            case remove_plan_type::REMOVE:
                break;
            default:
                Checks::unreachable();
        }

        pkg.want = want_t::purge;
        pkg.state = install_state_t::half_installed;
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

        pkg.state = install_state_t::not_installed;
        write_update(paths, pkg);
        System::println(System::color::success, "Package %s was successfully removed", pkg.package.displayname());
    }

    void perform_and_exit(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths, const triplet& default_target_triplet)
    {
        static const std::string example = Commands::Help::create_example_string("remove zlib zlib:x64-windows curl boost");
        args.check_min_arg_count(1, example);

        const std::unordered_set<std::string> options = args.check_and_get_optional_command_arguments({OPTION_PURGE});
        auto status_db = database_load_check(paths);

        std::vector<package_spec> specs = Input::check_and_get_package_specs(args.command_arguments, default_target_triplet, example);
        Input::check_triplets(specs, paths);
        bool alsoRemoveFolderFromPackages = options.find(OPTION_PURGE) != options.end();

        const std::vector<package_spec_with_remove_plan> remove_plan = Dependencies::create_remove_plan(paths, specs, status_db);
        Checks::check_exit(!remove_plan.empty(), "Remove plan cannot be empty");

        for (const package_spec& spec : specs)
        {
            deinstall_package(paths, spec, status_db);

            if (alsoRemoveFolderFromPackages)
            {
                const fs::path spec_package_dir = paths.packages / spec.dir();
                delete_directory(spec_package_dir);
            }
        }
        exit(EXIT_SUCCESS);
    }
}
