#include "pch.h"

#include <vcpkg/commands.h>
#include <vcpkg/help.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/input.h>
#include <vcpkg/install.h>
#include <vcpkg/vcpkglib.h>

namespace vcpkg::Commands::SetInstalled
{
    using Install::KeepGoing;

    static constexpr StringLiteral OPTION_DRY_RUN = "--dry-run";
    static constexpr StringLiteral OPTION_USE_HEAD_VERSION = "--head";
    static constexpr StringLiteral OPTION_NO_DOWNLOADS = "--no-downloads";
    static constexpr StringLiteral OPTION_RECURSE = "--recurse";
    static constexpr StringLiteral OPTION_KEEP_GOING = "--keep-going";
    static constexpr StringLiteral OPTION_XUNIT = "--x-xunit";
    static constexpr StringLiteral OPTION_USE_ARIA2 = "--x-use-aria2";

    static constexpr std::array<CommandSwitch, 6> INSTALL_SWITCHES = { {
        {OPTION_DRY_RUN, "Do not actually build or install"},
        {OPTION_USE_HEAD_VERSION, "Install the libraries on the command line using the latest upstream sources"},
        {OPTION_NO_DOWNLOADS, "Do not download new sources"},
        {OPTION_RECURSE, "Allow removal of packages as part of installation"},
        {OPTION_KEEP_GOING, "Continue installing packages on failure"},
        {OPTION_USE_ARIA2, "Use aria2 to perform download tasks"},
    } };

    const CommandStructure COMMAND_STRUCTURE = {
        Help::create_example_string(R"(set-installed <package>...)"),
        1,
        SIZE_MAX,
        {INSTALL_SWITCHES},
        nullptr,
    };

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
        const bool is_recursive = Util::Sets::contains(options.switches, (OPTION_RECURSE));
        const bool use_aria2 = Util::Sets::contains(options.switches, (OPTION_USE_ARIA2));
        const KeepGoing keep_going = Install::to_keep_going(Util::Sets::contains(options.switches, OPTION_KEEP_GOING));

        Dependencies::PathsPortFileProvider provider(paths);

        struct Node
        {
            InstalledPackageView current_ipv;
            const Dependencies::InstallPlanAction* install_action;
        };

        std::map<PackageSpec, Node> node_map;

        auto status_db = database_load_check(paths);

        for (auto&& status_pgh : status_db)
        {
            if (!status_pgh->is_installed()) continue;
            if (status_pgh->package.is_feature()) continue;
            node_map[status_pgh->package.spec].current_ipv = status_db.get_installed_package_view(status_pgh->package.spec).value_or_exit(VCPKG_LINE_INFO);
        }

        auto action_plan = Dependencies::create_feature_install_plan(provider, FullPackageSpec::to_feature_specs(specs), {}, {});
        for (auto&& action : action_plan)
        {
            if (action.remove_action.get()) {
                Checks::exit_with_message(VCPKG_LINE_INFO, "Unexpected remove action %s", action.remove_action.get()->spec);
            }
            else
            {
                auto p_install = action.install_action.get();
                node_map[p_install->spec].install_action = p_install;
            }
        }

        Dependencies::PackageGraph pgraph(provider, status_db);
        for (auto&& node : node_map)
        {
            if (node.second.current_ipv.core) {
                if (node.second.install_action)
                {
                    // test for upgrade requirements
                    std::set<std::string> current_features;
                    for (auto&& feature : node.second.current_ipv.features) current_features.insert(feature->package.feature);
                    auto&& new_version = node.second.install_action->source_control_file.value_or_exit(VCPKG_LINE_INFO).core_paragraph->version;
                    if (node.second.current_ipv.core->package.version != new_version || node.second.install_action->feature_list != current_features)
                    {
                        pgraph.remove(node.first);
                        pgraph.install({ node.first, "core" });
                        for (auto&& feature : node.second.install_action->feature_list)
                            pgraph.install({ node.first, feature });
                    }
                }
                else
                {
                    pgraph.remove(node.first);
                }
            }
            else
            {
                if (node.second.install_action)
                {
                    pgraph.remove(node.first);
                }
            }
        }

        auto new_action_plan = pgraph.serialize();

        Dependencies::print_plan(new_action_plan, true);

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
