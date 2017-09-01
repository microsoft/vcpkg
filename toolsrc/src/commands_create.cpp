#include "pch.h"

#include "vcpkg_Commands.h"
#include "vcpkg_Files.h"
#include "vcpkg_System.h"
#include "vcpkglib.h"

namespace vcpkg::Commands::Create
{
    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        static const std::string EXAMPLE = Commands::Help::create_example_string(
            R"###(create zlib2 http://zlib.net/zlib1211.zip "zlib1211-2.zip")###");
        args.check_max_arg_count(3, EXAMPLE);
        args.check_min_arg_count(2, EXAMPLE);
        args.check_and_get_optional_command_arguments({});
        const std::string port_name = args.command_arguments.at(0);
        const std::string url = args.command_arguments.at(1);

        const fs::path& cmake_exe = paths.get_cmake_exe();

        std::vector<CMakeVariable> cmake_args{{L"CMD", L"CREATE"}, {L"PORT", port_name}, {L"URL", url}};

        if (args.command_arguments.size() >= 3)
        {
            const std::string& zip_file_name = args.command_arguments.at(2);
            Checks::check_exit(VCPKG_LINE_INFO,
                               !Files::has_invalid_chars_for_filesystem(zip_file_name),
                               R"(Filename cannot contain invalid chars %s, but was %s)",
                               Files::FILESYSTEM_INVALID_CHARACTERS,
                               zip_file_name);
            cmake_args.push_back({L"FILENAME", zip_file_name});
        }

        const std::wstring cmd_launch_cmake = make_cmake_cmd(cmake_exe, paths.ports_cmake, cmake_args);
        Checks::exit_with_code(VCPKG_LINE_INFO, System::cmd_execute_clean(cmd_launch_cmake));
    }
}
