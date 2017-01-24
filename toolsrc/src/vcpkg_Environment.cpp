#include <regex>
#include <array>
#include "vcpkg_Environment.h"
#include "vcpkg_Commands.h"
#include "metrics.h"
#include "vcpkg_System.h"
#include "vcpkg_Strings.h"
#include "vcpkg_Files.h"

namespace vcpkg::Environment
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

    static std::vector<std::string> get_VS2017_installation_instances(const vcpkg_paths& paths)
    {
        const fs::path script = paths.scripts / "findVisualStudioInstallationInstances.ps1";
        const std::wstring cmd = Strings::wformat(L"powershell -ExecutionPolicy Bypass %s", script.native());
        System::exit_code_and_output ec_data = System::cmd_execute_and_capture_output(cmd);
        Checks::check_exit(ec_data.exit_code == 0, "Could not run script to detect VS 2017 instances");
        return Strings::split(ec_data.output, "\n");
    }

    static const fs::path& get_VS2015_installation_instance()
    {
        static const fs::path vs2015_cmntools = fs::path(System::wdupenv_str(L"VS140COMNTOOLS")).parent_path(); // TODO: Check why this requires parent_path() call
        static const fs::path vs2015_path = vs2015_cmntools.parent_path().parent_path();
        return vs2015_path;
    }

    static fs::path find_dumpbin_exe(const vcpkg_paths& paths)
    {
        const std::vector<std::string> vs2017_installation_instances = get_VS2017_installation_instances(paths);
        std::vector<fs::path> paths_examined;

        // VS2017
        for (const std::string& instance : vs2017_installation_instances)
        {
            const fs::path msvc_path = Strings::format(R"(%s\VC\Tools\MSVC)", instance);
            std::vector<fs::path> msvc_subdirectories;
            Files::non_recursive_find_matching_paths_in_dir(msvc_path, [&](const fs::path& current)
                                                            {
                                                                return fs::is_directory(current);
                                                            }, &msvc_subdirectories);

            Checks::check_exit(!msvc_subdirectories.empty(), "No subdirectories were found in %s", msvc_path.generic_string());

            // Sort them so that latest comes first
            std::sort(msvc_subdirectories.begin(), msvc_subdirectories.end(), [&](const fs::path& left, const fs::path& right)
                      {
                          return left.filename() > right.filename();
                      });

            for (const fs::path& subdir : msvc_subdirectories)
            {
                const fs::path dumpbin_path = subdir / "bin" / "HostX86" / "x86" / "dumpbin.exe";
                paths_examined.push_back(dumpbin_path);
                if (fs::exists(dumpbin_path))
                {
                    return dumpbin_path;
                }
            }
        }

        // VS2015
        const fs::path vs2015_dumpbin_exe = get_VS2015_installation_instance() / "VC" / "bin" / "dumpbin.exe";
        paths_examined.push_back(vs2015_dumpbin_exe);
        if (fs::exists(vs2015_dumpbin_exe))
        {
            return vs2015_dumpbin_exe;
        }

        System::println(System::color::error, "Could not detect dumpbin.exe.");
        System::println("The following paths were examined:");
        for (const fs::path& path : paths_examined)
        {
            System::println(path.generic_string());
        }
        exit(EXIT_FAILURE);
    }

    const fs::path& get_dumpbin_exe(const vcpkg_paths& paths)
    {
        static const fs::path dumpbin_exe = find_dumpbin_exe(paths);
        return dumpbin_exe;
    }

    static fs::path find_vcvarsall_bat(const vcpkg_paths& paths)
    {
        const std::vector<std::string> vs2017_installation_instances = get_VS2017_installation_instances(paths);
        std::vector<fs::path> paths_examined;

        // VS2017
        for (const fs::path& instance : vs2017_installation_instances)
        {
            const fs::path vcvarsall_bat = instance / "VC" / "Auxiliary" / "Build" / "vcvarsall.bat";
            paths_examined.push_back(vcvarsall_bat);
            if (fs::exists(vcvarsall_bat))
            {
                return vcvarsall_bat;
            }
        }

        // VS2015
        const fs::path vs2015_vcvarsall_bat = get_VS2015_installation_instance() / "VC" / "vcvarsall.bat";
        paths_examined.push_back(vs2015_vcvarsall_bat);
        if (fs::exists(vs2015_vcvarsall_bat))
        {
            return vs2015_vcvarsall_bat;
        }

        System::println(System::color::error, "Could not detect vccarsall.bat.");
        System::println("The following paths were examined:");
        for (const fs::path& path : paths_examined)
        {
            System::println(path.generic_string());
        }
        exit(EXIT_FAILURE);
    }

    const fs::path& get_vcvarsall_bat(const vcpkg_paths& paths)
    {
        static const fs::path vcvarsall_bat = find_vcvarsall_bat(paths);
        return vcvarsall_bat;
    }
}
