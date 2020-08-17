#include "pch.h"

#include <vcpkg/base/hash.h>

#include <vcpkg/commands.hash.h>

namespace vcpkg::Commands::Hash
{
    const CommandStructure COMMAND_STRUCTURE = {
        Strings::format("The argument should be a file path\n%s", create_example_string("hash boost_1_62_0.tar.bz2")),
        1,
        2,
        {},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        Util::unused(args.parse_arguments(COMMAND_STRUCTURE));

        const fs::path file_to_hash = args.command_arguments[0];

        auto algorithm = vcpkg::Hash::Algorithm::Sha512;
        if (args.command_arguments.size() == 2)
        {
            algorithm = vcpkg::Hash::algorithm_from_string(args.command_arguments[1]).value_or_exit(VCPKG_LINE_INFO);
        }

        const std::string hash =
            vcpkg::Hash::get_file_hash(VCPKG_LINE_INFO, paths.get_filesystem(), file_to_hash, algorithm);
        System::print2(hash, '\n');
        Checks::exit_success(VCPKG_LINE_INFO);
    }

    void HashCommand::perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const
    {
        Hash::perform_and_exit(args, paths);
    }
}
