#include "pch.h"

#include <vcpkg/base/checks.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/commands.h>
#include <vcpkg/help.h>

namespace vcpkg::Commands::Create
{
    const CommandStructure COMMAND_STRUCTURE = {
        Help::create_example_string(R"###(create zlib2 http://zlib.net/zlib1211.zip "zlib1211-2.zip" windows cmake linux make)###"),
        2,
        9,
        {},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        Util::unused(args.parse_arguments(COMMAND_STRUCTURE));
        const std::string port_name = args.command_arguments.at(0);
        const std::string url = args.command_arguments.at(1);
        std::string zip_file_name;

        bool bWithGithub = url.find("github.com") != std::string::npos;
        bool bWithGitLab = url.find("gitlab.") != std::string::npos;
        bool bWithGit = (url.find("git.") != std::string::npos || url.find("googlesource.com") != std::string::npos);
        bool bWithUrl = (!bWithGithub && !bWithGitLab && !bWithGit);
        
        std::string ref;
        // download with git needs arg REF
        if (bWithGit)
        {
            if (args.command_arguments.size() == 2)
            {
                System::printf(System::Color::error,
                               "Error: '%s' requires %u arguments, but %u were provided.\n",
                               args.command,
                               3,
                               2);
                Checks::exit_with_code(VCPKG_LINE_INFO, 1);

            }
            ref = args.command_arguments.at(2);
        }
        else
        {
            zip_file_name = args.command_arguments.at(2);
            Checks::check_exit(VCPKG_LINE_INFO,
                               !Files::has_invalid_chars_for_filesystem(zip_file_name),
                               R"(Filename cannot contain invalid chars %s, but was %s)",
                               Files::FILESYSTEM_INVALID_CHARACTERS,
                               zip_file_name);

            // check if this arg is REF
            if (zip_file_name.length() == 40)
            {
                ref = zip_file_name;
            }
        }
        
        std::vector<System::CMakeVariable> build_types;
        if (args.command_arguments.size() >= 4)
        {
            for (size_t i = 0; i < (args.command_arguments.size() - 3) / 2; i++)
            {
                std::string triplet = args.command_arguments.at(3 + i * 2);
                std::string build_type = args.command_arguments.at(3 + i * 2 + 1);

                transform(triplet.begin(), triplet.end(), triplet.begin(), ::tolower);
                transform(build_type.begin(), build_type.end(), build_type.begin(), ::tolower);

                if (triplet == "windows" || triplet == "win")
                    build_types.push_back(System::CMakeVariable({"TRIPLET_WIN", build_type}));
                else if (triplet == "linux")
                    build_types.push_back(System::CMakeVariable({"TRIPLET_LINUX", build_type}));
                else if (triplet == "osx")
                    build_types.push_back(System::CMakeVariable({"TRIPLET_OSX", build_type}));
            }
        }


        const fs::path& cmake_exe = paths.get_tool_exe(Tools::CMAKE);

        std::vector<System::CMakeVariable> cmake_args{
            {"CMD", "CREATE"},
            {"PORT", port_name},
            {"URL", url},
            {"FILENAME", zip_file_name},
            {"DOWNLOAD_WITH_GITHUB", bWithGithub ? "1" : "0"},
            {"DOWNLOAD_WITH_GITLAB", bWithGitLab ? "1" : "0"},
            {"DOWNLOAD_WITH_GIT", bWithGit ? "1" : "0"},
            {"DOWNLOAD_WITH_URL", bWithUrl ? "1" : "0"},
            {"VCPKG_ROOT_PATH", paths.root}};

        if (!ref.empty())
            cmake_args.push_back(System::CMakeVariable({"REF", ref}));

        cmake_args.insert(cmake_args.begin(), build_types.begin(), build_types.end());

        const std::string cmd_launch_cmake = make_cmake_cmd(cmake_exe, paths.ports_cmake, cmake_args);
        Checks::exit_with_code(VCPKG_LINE_INFO, System::cmd_execute_clean(cmd_launch_cmake));
    }
}
