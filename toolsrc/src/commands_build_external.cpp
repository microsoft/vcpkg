#include "pch.h"
#include "vcpkg_Commands.h"
#include "vcpkg_System.h"
#include "vcpkg_Input.h"

namespace vcpkg::Commands::BuildExternal
{
    void perform_and_exit(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths, const triplet& default_target_triplet)
    {
        static const std::string example = Commands::Help::create_example_string(R"(build_external zlib2 C:\path\to\dir\with\controlfile\)");
        args.check_exact_arg_count(2, example);
        const PackageSpec spec = Input::check_and_get_package_spec(args.command_arguments.at(0), default_target_triplet, example);
        Input::check_triplet(spec.target_triplet(), paths);
        const std::unordered_set<std::string> options = args.check_and_get_optional_command_arguments({});

        const fs::path port_dir = args.command_arguments.at(1);
        Build::perform_and_exit(spec, port_dir, options, paths);
    }
}
