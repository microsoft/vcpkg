#include "pch.h"

#include "vcpkg_Commands.h"
#include "vcpkg_Input.h"

namespace vcpkg::Commands::BuildExternal
{
    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, const Triplet& default_triplet)
    {
        static const std::string EXAMPLE =
            Commands::Help::create_example_string(R"(build_external zlib2 C:\path\to\dir\with\controlfile\)");
        args.check_exact_arg_count(2, EXAMPLE);
        const FullPackageSpec spec =
            Input::check_and_get_full_package_spec(args.command_arguments.at(0), default_triplet, EXAMPLE);
        Input::check_triplet(spec.package_spec.triplet(), paths);
        const std::unordered_set<std::string> options = args.check_and_get_optional_command_arguments({});

        const fs::path port_dir = args.command_arguments.at(1);
        BuildCommand::perform_and_exit(spec, port_dir, options, paths);
    }
}
