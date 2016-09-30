#include <regex>
#include <array>
#include "vcpkg_Environment.h"
#include "vcpkg_Commands.h"
#include "vcpkg.h"
#include "metrics.h"
#include "vcpkg_System.h"

namespace vcpkg {namespace Environment
{
    static const fs::path default_cmake_installation_dir = "C:/Program Files/CMake/bin";
    static const fs::path default_cmake_installation_dir_x86 = "C:/Program Files (x86)/CMake/bin";
    static const fs::path default_git_installation_dir = "C:/Program Files/git/cmd";
    static const fs::path default_git_installation_dir_x86 = "C:/Program Files (x86)/git/cmd";

    static void ensure_on_path(const std::array<int, 3>& version, const wchar_t* version_check_cmd, const wchar_t* install_cmd)
    {
        System::exit_code_and_output ec_data = System::cmd_execute_and_capture_output(version_check_cmd);
        if (ec_data.exit_code == 0)
        {
            // version check
            std::regex re(R"###((\d+)\.(\d+)\.(\d+))###");
            std::match_results<std::string::const_iterator> match;
            auto found = std::regex_search(ec_data.output, match, re);
            if (found)
            {
                int d1 = atoi(match[1].str().c_str());
                int d2 = atoi(match[2].str().c_str());
                int d3 = atoi(match[3].str().c_str());
                if (d1 > version[0] || (d1 == version[0] && d2 > version[1]) || (d1 == version[0] && d2 == version[1] && d3 >= version[2]))
                {
                    // satisfactory version found
                    return;
                }
            }
        }

        auto rc = System::cmd_execute(install_cmd);
        if (rc)
        {
            System::println(System::color::error, "Launching powershell failed or was denied");
            TrackProperty("error", "powershell install failed");
            TrackProperty("installcmd", install_cmd);
            exit(rc);
        }
    }

    void ensure_git_on_path(const vcpkg_paths& paths)
    {
        const fs::path downloaded_git = paths.downloads / "PortableGit" / "cmd";
        const std::wstring path_buf = Strings::wformat(L"%s;%s;%s;%s",
                                                       downloaded_git.native(),
                                                       System::wdupenv_str(L"PATH"),
                                                       default_git_installation_dir.native(),
                                                       default_git_installation_dir_x86.native());
        _wputenv_s(L"PATH", path_buf.c_str());

        static constexpr std::array<int, 3> git_version = {2,0,0};
        // TODO: switch out ExecutionPolicy Bypass with "Remove Mark Of The Web" code and restore RemoteSigned
        ensure_on_path(git_version, L"git --version 2>&1", L"powershell -ExecutionPolicy Bypass scripts\\fetchDependency.ps1 -Dependency git");
    }

    void ensure_cmake_on_path(const vcpkg_paths& paths)
    {
        const fs::path downloaded_cmake = paths.downloads / "cmake-3.5.2-win32-x86" / "bin";
        const std::wstring path_buf = Strings::wformat(L"%s;%s;%s;%s",
                                                       downloaded_cmake.native(),
                                                       System::wdupenv_str(L"PATH"),
                                                       default_cmake_installation_dir.native(),
                                                       default_cmake_installation_dir_x86.native());
        _wputenv_s(L"PATH", path_buf.c_str());

        static constexpr std::array<int, 3> cmake_version = {3,5,0};
        // TODO: switch out ExecutionPolicy Bypass with "Remove Mark Of The Web" code and restore RemoteSigned
        ensure_on_path(cmake_version, L"cmake --version 2>&1", L"powershell -ExecutionPolicy Bypass scripts\\fetchDependency.ps1 -Dependency cmake");
    }

    void ensure_nuget_on_path(const vcpkg_paths& paths)
    {
        const std::wstring path_buf = Strings::wformat(L"%s;%s", paths.downloads.native(), System::wdupenv_str(L"PATH"));
        _wputenv_s(L"PATH", path_buf.c_str());

        static constexpr std::array<int, 3> nuget_version = {1,0,0};
        // TODO: switch out ExecutionPolicy Bypass with "Remove Mark Of The Web" code and restore RemoteSigned
        ensure_on_path(nuget_version, L"nuget 2>&1", L"powershell -ExecutionPolicy Bypass scripts\\fetchDependency.ps1 -Dependency nuget");
    }
}}
