#include "pch.h"
#include "vcpkg_Commands.h"
#include "vcpkglib.h"
#include "vcpkg_System.h"
#include "vcpkg_Dependencies.h"
#include "vcpkg_Input.h"
#include "vcpkg_Util.h"
#include "Paragraphs.h"

namespace vcpkg::Commands::Export
{
    using Install::InstallDir;
    using Dependencies::ExportPlanAction;
    using Dependencies::RequestType;
    using Dependencies::ExportPlanType;

    static void print_plan(const std::map<ExportPlanType, std::vector<const ExportPlanAction*>>& group_by_plan_type)
    {
        static constexpr std::array<ExportPlanType, 2> order = { ExportPlanType::ALREADY_BUILT, ExportPlanType::PORT_AVAILABLE_BUT_NOT_BUILT };

        for (const ExportPlanType plan_type : order)
        {
            auto it = group_by_plan_type.find(plan_type);
            if (it == group_by_plan_type.cend())
            {
                continue;
            }

            std::vector<const ExportPlanAction*> cont = it->second;
            std::sort(cont.begin(), cont.end(), &ExportPlanAction::compare_by_name);
            const std::string as_string = Strings::join("\n", cont, [](const ExportPlanAction* p)
                                                        {
                                                            return Dependencies::to_output_string(p->request_type, p->spec.to_string());
                                                        });

            switch (plan_type)
            {
                case ExportPlanType::ALREADY_BUILT:
                    System::println("The following packages are already built and will be exported:\n%s", as_string);
                    continue;
                case ExportPlanType::PORT_AVAILABLE_BUT_NOT_BUILT:
                    System::println("The following packages need to be built:\n%s", as_string);
                    continue;
                default:
                    Checks::unreachable(VCPKG_LINE_INFO);
            }
        }
    }

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet)
    {
        static const std::string OPTION_DRY_RUN = "--dry-run";
        // input sanitization
        static const std::string example = Commands::Help::create_example_string("export zlib zlib:x64-windows curl boost");
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
        std::vector<ExportPlanAction> export_plan = Dependencies::create_export_plan(paths, specs, status_db);
        Checks::check_exit(VCPKG_LINE_INFO, !export_plan.empty(), "Export plan cannot be empty");

        std::map<ExportPlanType, std::vector<const ExportPlanAction*>> group_by_plan_type;
        Util::group_by(export_plan, &group_by_plan_type, [](const ExportPlanAction& p) { return p.plan_type; });
        print_plan(group_by_plan_type);

        const bool has_non_user_requested_packages = std::find_if(export_plan.cbegin(), export_plan.cend(), [](const ExportPlanAction& package)-> bool
                                                                  {
                                                                      return package.request_type != RequestType::USER_REQUESTED;
                                                                  }) != export_plan.cend();

        if (has_non_user_requested_packages)
        {
            System::println(System::Color::warning, "Additional packages (*) need to be exported to complete this operation.");
        }

        if (dryRun)
        {
            Checks::exit_success(VCPKG_LINE_INFO);
        }

        Files::Filesystem& fs = paths.get_filesystem();
        const fs::path output = paths.root / "exported";
        std::error_code ec;
        fs.remove_all(output, ec);
        fs.create_directory(output, ec);

        // execute the plan
        for (const ExportPlanAction& action : export_plan)
        {
            const std::string display_name = action.spec.to_string();
            System::println("Exporting package %s... ", display_name);

            const BinaryParagraph& binary_paragraph = action.any_paragraph.binary_paragraph.value_or_exit(VCPKG_LINE_INFO);
            const InstallDir dirs = InstallDir::from_destination_root(
                output,
                action.spec.triplet().to_string(),
                output / "vcpkg" / "info" / (binary_paragraph.fullstem() + ".list"));

            Install::install_files_and_write_listfile(paths.get_filesystem(), paths.package_dir(action.spec), dirs);
            System::println(System::Color::success, "Exporting package %s... done", display_name);
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
