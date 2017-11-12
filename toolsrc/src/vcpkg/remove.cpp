#include "pch.h"

#include <vcpkg/base/system.h>
#include <vcpkg/base/util.h>
#include <vcpkg/commands.h>
#include <vcpkg/dependencies.h>
#include <vcpkg/help.h>
#include <vcpkg/input.h>
#include <vcpkg/paragraphs.h>
#include <vcpkg/remove.h>
#include <vcpkg/update.h>
#include <vcpkg/vcpkglib.h>

namespace vcpkg::Remove
{
    using Dependencies::RemovePlanAction;
    using Dependencies::RemovePlanType;
    using Dependencies::RequestType;
    using Update::OutdatedPackage;

    void remove_package(const VcpkgPaths& paths, const PackageSpec& spec, StatusParagraphs* status_db)
    {
        auto& fs = paths.get_filesystem();
        auto spghs = status_db->find_all(spec.name(), spec.triplet());
        const auto core_pkg = **status_db->find(spec.name(), spec.triplet(), "");

        for (auto&& spgh : spghs)
        {
            StatusParagraph& pkg = **spgh;
            if (pkg.state != InstallState::INSTALLED) continue;
            pkg.want = Want::PURGE;
            pkg.state = InstallState::HALF_INSTALLED;
            write_update(paths, pkg);
        }

        auto maybe_lines = fs.read_lines(paths.listfile_path(core_pkg.package));

        if (const auto lines = maybe_lines.get())
        {
            std::vector<fs::path> dirs_touched;
            for (auto&& suffix : *lines)
            {
                if (!suffix.empty() && suffix.back() == '\r') suffix.pop_back();

                std::error_code ec;

                auto target = paths.installed / suffix;

                const auto status = fs.status(target, ec);
                if (ec)
                {
                    System::println(System::Color::error, "failed: %s", ec.message());
                    continue;
                }

                if (fs::is_directory(status))
                {
                    dirs_touched.push_back(target);
                }
                else if (fs::is_regular_file(status))
                {
                    fs.remove(target, ec);
                    if (ec)
                    {
                        System::println(System::Color::error, "failed: %s: %s", target.u8string(), ec.message());
                    }
                }
                else if (!fs::status_known(status))
                {
                    System::println(System::Color::warning, "Warning: unknown status: %s", target.u8string());
                }
                else
                {
                    System::println(System::Color::warning, "Warning: %s: cannot handle file type", target.u8string());
                }
            }

            auto b = dirs_touched.rbegin();
            const auto e = dirs_touched.rend();
            for (; b != e; ++b)
            {
                if (fs.is_empty(*b))
                {
                    std::error_code ec;
                    fs.remove(*b, ec);
                    if (ec)
                    {
                        System::println(System::Color::error, "failed: %s", ec.message());
                    }
                }
            }

            fs.remove(paths.listfile_path(core_pkg.package));
        }

        for (auto&& spgh : spghs)
        {
            StatusParagraph& pkg = **spgh;
            if (pkg.state != InstallState::HALF_INSTALLED) continue;
            pkg.state = InstallState::NOT_INSTALLED;
            write_update(paths, pkg);
        }
    }

    static void print_plan(const std::map<RemovePlanType, std::vector<const RemovePlanAction*>>& group_by_plan_type)
    {
        static constexpr std::array<RemovePlanType, 2> ORDER = {RemovePlanType::NOT_INSTALLED, RemovePlanType::REMOVE};

        for (const RemovePlanType plan_type : ORDER)
        {
            const auto it = group_by_plan_type.find(plan_type);
            if (it == group_by_plan_type.cend())
            {
                continue;
            }

            std::vector<const RemovePlanAction*> cont = it->second;
            std::sort(cont.begin(), cont.end(), &RemovePlanAction::compare_by_name);
            const std::string as_string = Strings::join("\n", cont, [](const RemovePlanAction* p) {
                return Dependencies::to_output_string(p->request_type, p->spec.to_string());
            });

            switch (plan_type)
            {
                case RemovePlanType::NOT_INSTALLED:
                    System::println("The following packages are not installed, so not removed:\n%s", as_string);
                    continue;
                case RemovePlanType::REMOVE:
                    System::println("The following packages will be removed:\n%s", as_string);
                    continue;
                default: Checks::unreachable(VCPKG_LINE_INFO);
            }
        }
    }

    void perform_remove_plan_action(const VcpkgPaths& paths,
                                    const RemovePlanAction& action,
                                    const Purge purge,
                                    StatusParagraphs& status_db)
    {
        const std::string display_name = action.spec.to_string();

        switch (action.plan_type)
        {
            case RemovePlanType::NOT_INSTALLED:
                System::println(System::Color::success, "Package %s is not installed", display_name);
                break;
            case RemovePlanType::REMOVE:
                System::println("Removing package %s... ", display_name);
                remove_package(paths, action.spec, &status_db);
                System::println(System::Color::success, "Removing package %s... done", display_name);
                break;
            case RemovePlanType::UNKNOWN:
            default: Checks::unreachable(VCPKG_LINE_INFO);
        }

        if (purge == Purge::YES)
        {
            System::println("Purging package %s... ", display_name);
            Files::Filesystem& fs = paths.get_filesystem();
            std::error_code ec;
            fs.remove_all(paths.packages / action.spec.dir(), ec);
            System::println(System::Color::success, "Purging package %s... done", display_name);
        }
    }

    static const std::string OPTION_PURGE = "--purge";
    static const std::string OPTION_NO_PURGE = "--no-purge";
    static const std::string OPTION_RECURSE = "--recurse";
    static const std::string OPTION_DRY_RUN = "--dry-run";
    static const std::string OPTION_OUTDATED = "--outdated";

    static const std::array<CommandSwitch, 5> SWITCHES = {{
        {OPTION_PURGE, "Remove the cached copy of the package (default)"},
        {OPTION_NO_PURGE, "Do not remove the cached copy of the package"},
        {OPTION_RECURSE, "Allow removal of packages not explicitly specified on the command line"},
        {OPTION_DRY_RUN, "Print the packages to be removed, but do not remove them"},
        {OPTION_OUTDATED, "Select all packages with versions that do not match the portfiles"},
    }};

    static std::vector<std::string> valid_arguments(const VcpkgPaths& paths)
    {
        const StatusParagraphs status_db = database_load_check(paths);
        const std::vector<StatusParagraph*> installed_packages = get_installed_ports(status_db);

        return Util::fmap(installed_packages, [](auto&& pgh) -> std::string { return pgh->package.spec.to_string(); });
    }

    const CommandStructure COMMAND_STRUCTURE = {
        Help::create_example_string("remove zlib zlib:x64-windows curl boost"),
        0,
        SIZE_MAX,
        {SWITCHES, {}},
        &valid_arguments,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet)
    {
        const ParsedArguments options = args.parse_arguments(COMMAND_STRUCTURE);

        StatusParagraphs status_db = database_load_check(paths);
        std::vector<PackageSpec> specs;
        if (Util::Sets::contains(options.switches, OPTION_OUTDATED))
        {
            if (args.command_arguments.size() != 0)
            {
                System::println(System::Color::error, "Error: 'remove' accepts either libraries or '--outdated'");
                Checks::exit_fail(VCPKG_LINE_INFO);
            }
            specs = Util::fmap(
                Update::find_outdated_packages(
                    Paragraphs::load_all_port_names_and_versions(paths.get_filesystem(), paths.ports), status_db),
                [](auto&& outdated) { return outdated.spec; });

            if (specs.empty())
            {
                System::println(System::Color::success, "There are no outdated packages.");
                Checks::exit_success(VCPKG_LINE_INFO);
            }
        }
        else
        {
            if (args.command_arguments.size() < 1)
            {
                System::println(System::Color::error, "Error: 'remove' accepts either libraries or '--outdated'");
                Checks::exit_fail(VCPKG_LINE_INFO);
            }
            specs = Util::fmap(args.command_arguments, [&](auto&& arg) {
                return Input::check_and_get_package_spec(arg, default_triplet, COMMAND_STRUCTURE.example_text);
            });

            for (auto&& spec : specs)
                Input::check_triplet(spec.triplet(), paths);
        }

        const bool no_purge_was_passed = Util::Sets::contains(options.switches, OPTION_NO_PURGE);
        const bool purge_was_passed = Util::Sets::contains(options.switches, OPTION_PURGE);
        if (purge_was_passed && no_purge_was_passed)
        {
            System::println(System::Color::error, "Error: cannot specify both --no-purge and --purge.");
            System::print(COMMAND_STRUCTURE.example_text);
            Checks::exit_fail(VCPKG_LINE_INFO);
        }
        const Purge purge = to_purge(purge_was_passed || !no_purge_was_passed);
        const bool is_recursive = Util::Sets::contains(options.switches, OPTION_RECURSE);
        const bool dry_run = Util::Sets::contains(options.switches, OPTION_DRY_RUN);

        const std::vector<RemovePlanAction> remove_plan = Dependencies::create_remove_plan(specs, status_db);
        Checks::check_exit(VCPKG_LINE_INFO, !remove_plan.empty(), "Remove plan cannot be empty");

        std::map<RemovePlanType, std::vector<const RemovePlanAction*>> group_by_plan_type;
        Util::group_by(remove_plan, &group_by_plan_type, [](const RemovePlanAction& p) { return p.plan_type; });
        print_plan(group_by_plan_type);

        const bool has_non_user_requested_packages =
            Util::find_if(remove_plan, [](const RemovePlanAction& package) -> bool {
                return package.request_type != RequestType::USER_REQUESTED;
            }) != remove_plan.cend();

        if (has_non_user_requested_packages)
        {
            System::println(System::Color::warning,
                            "Additional packages (*) need to be removed to complete this operation.");

            if (!is_recursive)
            {
                System::println(System::Color::warning,
                                "If you are sure you want to remove them, run the command with the --recurse option");
                Checks::exit_fail(VCPKG_LINE_INFO);
            }
        }

        if (dry_run)
        {
            Checks::exit_success(VCPKG_LINE_INFO);
        }

        for (const RemovePlanAction& action : remove_plan)
        {
            perform_remove_plan_action(paths, action, purge, status_db);
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
