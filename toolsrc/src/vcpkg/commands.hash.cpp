#include "pch.h"

#include <vcpkg/base/system.h>
#include <vcpkg/base/util.h>
#include <vcpkg/commands.h>
#include <vcpkg/help.h>

namespace vcpkg::Commands::Hash
{
    static void do_file_hash(fs::path const &cmake_exe_path, fs::path const& path, std::string const& hash_type)
    {
        const std::string cmd_line = Strings::format(
            R"("%s" -E %ssum %s)", cmake_exe_path.u8string(), Strings::ascii_to_lowercase(hash_type), path.u8string());

        const auto ec_data = System::cmd_execute_and_capture_output(cmd_line);
        Checks::check_exit(VCPKG_LINE_INFO, ec_data.exit_code == 0, "Running command:\n   %s\n failed", cmd_line);

        std::string const& output = ec_data.output;

        const auto start = output.find_first_of(" ");
        Checks::check_exit(
            VCPKG_LINE_INFO, start != std::string::npos, "Unexpected output format from command: %s", cmd_line);

        const auto end = output.find_first_of("\r\n", start + 1);
        Checks::check_exit(
            VCPKG_LINE_INFO, end != std::string::npos, "Unexpected output format from command: %s", cmd_line);

        auto hash = output.substr(0, start);
        Util::erase_remove_if(hash, isspace);
        System::println(hash);
    }

    const CommandStructure COMMAND_STRUCTURE = {
        Strings::format("The argument should be a file path\n%s",
                        Help::create_example_string("hash boost_1_62_0.tar.bz2")),
        1,
        2,
        {},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        args.parse_arguments(COMMAND_STRUCTURE);

        if (args.command_arguments.size() == 1)
        {
            do_file_hash(paths.get_cmake_exe(), args.command_arguments[0], "SHA512");
        }
        if (args.command_arguments.size() == 2)
        {
            do_file_hash(paths.get_cmake_exe(), args.command_arguments[0], args.command_arguments[1]);
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
