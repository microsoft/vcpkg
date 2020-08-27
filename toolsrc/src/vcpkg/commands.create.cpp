#include <vcpkg/base/checks.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/util.h>

#include <vcpkg/buildenvironment.h>
#include <vcpkg/commands.create.h>
#include <vcpkg/help.h>
#include <vcpkg/vcpkgcmdarguments.h>
#include <vcpkg/vcpkgpaths.h>

namespace vcpkg::Commands::Create
{
    const CommandStructure COMMAND_STRUCTURE = {
        create_example_string(R"###(create zlib2 http://zlib.net/zlib1211.zip "zlib1211-2.zip")###"),
        2,
        3,
        {},
        nullptr,
    };

    int perform(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        (void)args.parse_arguments(COMMAND_STRUCTURE);
        const std::string port_name = args.command_arguments.at(0);
        const std::string url = args.command_arguments.at(1);

        std::vector<System::CMakeVariable> cmake_args{{"CMD", "CREATE"}, {"PORT", port_name}, {"URL", url}};

        if (args.command_arguments.size() >= 3)
        {
            const std::string& zip_file_name = args.command_arguments.at(2);
            Checks::check_exit(VCPKG_LINE_INFO,
                               !Files::has_invalid_chars_for_filesystem(zip_file_name),
                               R"(Filename cannot contain invalid chars %s, but was %s)",
                               Files::FILESYSTEM_INVALID_CHARACTERS,
                               zip_file_name);
            cmake_args.emplace_back("FILENAME", zip_file_name);
        }

        const std::string cmd_launch_cmake = make_cmake_cmd(paths, paths.ports_cmake, std::move(cmake_args));
        return System::cmd_execute_clean(cmd_launch_cmake);
    }

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        Checks::exit_with_code(VCPKG_LINE_INFO, perform(args, paths));
    }

    void CreateCommand::perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const
    {
        Create::perform_and_exit(args, paths);
    }
}
