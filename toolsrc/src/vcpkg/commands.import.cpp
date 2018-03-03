#include "pch.h"

#include <vcpkg/base/files.h>
#include <vcpkg/base/util.h>
#include <vcpkg/commands.h>
#include <vcpkg/help.h>
#include <vcpkg/import.h>
#include <vcpkg/import.ext.h>
#include <vcpkg/import.pkg.h>

namespace vcpkg::Commands::Import
{
    static Optional<std::string> maybe_lookup(std::unordered_map<std::string, std::string> const& m,
                                              std::string const& key)
    {
        const auto it = m.find(key);
        if (it != m.end()) return it->second;
        return nullopt;
    } 

    struct ImportArguments
    {
        bool dry_run;
        bool external;
        bool vcexport;

        vcpkg::Import::Pkg::Options vcexport_options;
        vcpkg::Import::Ext::Options external_options;
    };

    static constexpr StringLiteral OPTION_DRY_RUN = "--dry-run";
    static constexpr StringLiteral OPTION_EXTERNAL = "--ext";
    static constexpr StringLiteral OPTION_VCEXPORT = "--vc";
    static constexpr StringLiteral OPTION_CONTROL_FILE_PATH = "--control";
    static constexpr StringLiteral OPTION_INCLUDE_DIRECTORY = "--include";
    static constexpr StringLiteral OPTION_PROJECT_DIRECTORY = "--project";
    static constexpr StringLiteral OPTION_VCEXPORT_FILE_PATH = "--pkg";

    static constexpr std::array<CommandSwitch, 3> IMPORT_SWITCHES = {{
        {OPTION_DRY_RUN, "Do not actually export"},
        {OPTION_EXTERNAL, "Import from an external directory"},
        {OPTION_VCEXPORT, "Import a vcpkg exported package"},
    }};

    static constexpr std::array<CommandSetting, 4> IMPORT_SETTINGS = {{
        {OPTION_CONTROL_FILE_PATH, "Specify a CONTROL file"},
        {OPTION_INCLUDE_DIRECTORY, "Specify a include directory"},
        {OPTION_PROJECT_DIRECTORY, "Specify a project directory"},
        {OPTION_VCEXPORT_FILE_PATH, "SPecify a vcexport.7z file"},
    }};

    const CommandStructure COMMAND_STRUCTURE = {
        Help::create_example_string(
            R"(import --ext --control C:\path\to\CONTROLfile --include C:\path\to\includedir --project C:\path\to\projectdir)"),
        0,
        3,
        {IMPORT_SWITCHES, IMPORT_SETTINGS},
        nullptr,
    };

    static ImportArguments handle_import_command_arguments(const VcpkgCmdArguments& args)
    {
        ImportArguments ret;

        const auto options = args.parse_arguments(COMMAND_STRUCTURE);

        ret.dry_run = options.switches.find(OPTION_DRY_RUN) != options.switches.cend();
        ret.external = options.switches.find(OPTION_EXTERNAL) != options.switches.cend();
        ret.vcexport = options.switches.find(OPTION_VCEXPORT) != options.switches.cend();

        if (!ret.external && !ret.vcexport && !ret.dry_run)
        {
            // For backword compatibility, fall back to external import
            ret.external = true;
        }

        // option handler stolen from export.cpp
        struct OptionPair
        {
            const std::string& name;
            Optional<std::string>& out_opt;
        };
        const auto options_implies =
            [&](const std::string& main_opt_name, bool main_opt, Span<const OptionPair> implying_opts) {
                if (main_opt)
                {
                    for (auto&& opt : implying_opts)
                        opt.out_opt = maybe_lookup(options.settings, opt.name);
                }
                else
                {
                    for (auto&& opt : implying_opts)
                        Checks::check_exit(VCPKG_LINE_INFO,
                                           !maybe_lookup(options.settings, opt.name),
                                           "%s is only valid with %s",
                                           opt.name,
                                           main_opt_name);
                }
            };
        options_implies(OPTION_VCEXPORT,
                        ret.vcexport,
                        {
                            {OPTION_VCEXPORT_FILE_PATH, ret.vcexport_options.maybe_vcexport_file_path},
                        });
        options_implies(OPTION_EXTERNAL,
                        ret.external,
                        {
                            {OPTION_CONTROL_FILE_PATH, ret.external_options.maybe_control_file_path},
                            {OPTION_INCLUDE_DIRECTORY, ret.external_options.maybe_include_directory},
                            {OPTION_PROJECT_DIRECTORY, ret.external_options.maybe_project_directory},
                        });
        return ret;
    }

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        const auto opts = handle_import_command_arguments(args);

        if (opts.dry_run)
        {
            Checks::exit_success(VCPKG_LINE_INFO);
        }
        if (opts.vcexport)
        {
            vcpkg::Import::Pkg::do_import(paths, opts.vcexport_options);
        }
        if (opts.external)
        {
            vcpkg::Import::Ext::do_import(paths, opts.external_options);
        } 
        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
