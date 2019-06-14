#include "pch.h"

#include <vcpkg/build.h>
#include <vcpkg/commands.h>
#include <vcpkg/help.h>
#include <vcpkg/input.h>

namespace vcpkg::Commands::BuildExternal
{
    const CommandStructure COMMAND_STRUCTURE = {
        Help::create_example_string(R"(build_external zlib2 C:\path\to\dir\with\controlfile\)"),
        2,
        2,
        {},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet)
    {
        const ParsedArguments options = args.parse_arguments(COMMAND_STRUCTURE);

        const FullPackageSpec spec = Input::check_and_get_full_package_spec(
            std::string(args.command_arguments.at(0)), default_triplet, COMMAND_STRUCTURE.example_text);
        Input::check_triplet(spec.package_spec.triplet(), paths);

        const fs::path port_dir = args.command_arguments.at(1);
        Build::Command::perform_and_exit_ex(spec, port_dir, options, paths);
    }
}
