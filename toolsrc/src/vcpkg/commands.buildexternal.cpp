#include "pch.h"

#include <vcpkg/binarycaching.h>
#include <vcpkg/build.h>
#include <vcpkg/cmakevars.h>
#include <vcpkg/commands.buildexternal.h>
#include <vcpkg/help.h>
#include <vcpkg/input.h>

namespace vcpkg::Commands::BuildExternal
{
    const CommandStructure COMMAND_STRUCTURE = {
        create_example_string(R"(build_external zlib2 C:\path\to\dir\with\controlfile\)"),
        2,
        2,
        {},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, Triplet default_triplet)
    {
        const ParsedArguments options = args.parse_arguments(COMMAND_STRUCTURE);

        auto binaryprovider = create_binary_provider_from_configs(args.binary_sources).value_or_exit(VCPKG_LINE_INFO);

        const FullPackageSpec spec = Input::check_and_get_full_package_spec(
            std::string(args.command_arguments.at(0)), default_triplet, COMMAND_STRUCTURE.example_text);
        Input::check_triplet(spec.package_spec.triplet(), paths);

        auto overlays = args.overlay_ports;
        overlays.insert(overlays.begin(), args.command_arguments.at(1));

        PortFileProvider::PathsPortFileProvider provider(paths, overlays);
        auto maybe_scfl = provider.get_control_file(spec.package_spec.name());

        Checks::check_exit(
            VCPKG_LINE_INFO, maybe_scfl.has_value(), "could not load control file for %s", spec.package_spec.name());

        Build::Command::perform_and_exit_ex(spec,
                                            maybe_scfl.value_or_exit(VCPKG_LINE_INFO),
                                            provider,
                                            args.binary_caching_enabled() ? *binaryprovider : null_binary_provider(),
                                            Build::null_build_logs_recorder(),
                                            paths);
    }

    void BuildExternalCommand::perform_and_exit(const VcpkgCmdArguments& args,
                                                const VcpkgPaths& paths,
                                                Triplet default_triplet) const
    {
        BuildExternal::perform_and_exit(args, paths, default_triplet);
    }
}
