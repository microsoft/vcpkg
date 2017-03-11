#include "pch.h"
#include "vcpkg_Commands.h"
#include "vcpkg_Environment.h"
#include "vcpkg_Checks.h"
#include "vcpkg_System.h"
#include "vcpkg_Files.h"

namespace vcpkg::Commands::Integrate
{
    static const std::array<fs::path, 2> old_system_target_files = {
        Environment::get_ProgramFiles_32_bit() / "MSBuild/14.0/Microsoft.Common.Targets/ImportBefore/vcpkg.nuget.targets",
        Environment::get_ProgramFiles_32_bit() / "MSBuild/14.0/Microsoft.Common.Targets/ImportBefore/vcpkg.system.targets"
    };
    static const fs::path system_wide_targets_file = Environment::get_ProgramFiles_32_bit() / "MSBuild/Microsoft.Cpp/v4.0/V140/ImportBefore/Default/vcpkg.system.props";

    static std::string create_appdata_targets_shortcut(const std::string& target_path) noexcept
    {
        return Strings::format(R"###(
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <Import Condition="Exists('%s') and '$(VCPkgLocalAppDataDisabled)' == ''" Project="%s" />
</Project>
)###", target_path, target_path);
    }

    static std::string create_system_targets_shortcut() noexcept
    {
        return R"###(
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <!-- version 1 -->
  <PropertyGroup>
    <VCLibPackagePath Condition="'$(VCLibPackagePath)' == ''">$(LOCALAPPDATA)\vcpkg\vcpkg.user</VCLibPackagePath>
  </PropertyGroup>
  <Import Condition="'$(VCLibPackagePath)' != '' and Exists('$(VCLibPackagePath).targets')" Project="$(VCLibPackagePath).targets" />
</Project>
)###";
    }

    static std::string create_nuget_targets_file(const fs::path& msbuild_vcpkg_targets_file) noexcept
    {
        const std::string as_string = msbuild_vcpkg_targets_file.string();

        return Strings::format(R"###(
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <Import Project="%s" Condition="Exists('%s')" />
  <Target Name="CheckValidPlatform" BeforeTargets="Build">
    <Error Text="Unsupported architecture combination. Remove the 'vcpkg' nuget package." Condition="'$(VCPkgEnabled)' != 'true' and '$(VCPkgDisableError)' == ''"/>
  </Target>
</Project>
)###", as_string, as_string);
    }

    static std::string create_nuget_props_file() noexcept
    {
        return R"###(
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <VCPkgLocalAppDataDisabled>true</VCPkgLocalAppDataDisabled>
  </PropertyGroup>
</Project>
)###";
    }

    static std::string get_nuget_id(const fs::path& vcpkg_root_dir)
    {
        std::string dir_id = vcpkg_root_dir.generic_string();
        std::replace(dir_id.begin(), dir_id.end(), '/', '.');
        dir_id.erase(1, 1); // Erasing the ":"

        // NuGet id cannot have invalid characters. We will only use alphanumeric and dot.
        dir_id.erase(std::remove_if(dir_id.begin(), dir_id.end(), [](char c)
                                    {
                                        return !isalnum(c) && (c != '.');
                                    }), dir_id.end());

        const std::string nuget_id = "vcpkg." + dir_id;
        return nuget_id;
    }

    static std::string create_nuspec_file(const fs::path& vcpkg_root_dir, const std::string& nuget_id, const std::string& nupkg_version)
    {
        const std::string nuspec_file_content_template = R"(
<package>
    <metadata>
        <id>@NUGET_ID@</id>
        <version>@VERSION@</version>
        <authors>cpp-packages</authors>
        <description>
            This package imports all libraries currently installed in @VCPKG_DIR@. This package does not contain any libraries and instead refers to the folder directly (like a symlink).
        </description>
    </metadata>
    <files>
        <file src="vcpkg.nuget.props" target="build\native\@NUGET_ID@.props" />
        <file src="vcpkg.nuget.targets" target="build\native\@NUGET_ID@.targets" />
    </files>
</package>
)";

        std::string nuspec_file_content = std::regex_replace(nuspec_file_content_template, std::regex("@NUGET_ID@"), nuget_id);
        nuspec_file_content = std::regex_replace(nuspec_file_content, std::regex("@VCPKG_DIR@"), vcpkg_root_dir.string());
        nuspec_file_content = std::regex_replace(nuspec_file_content, std::regex("@VERSION@"), nupkg_version);
        return nuspec_file_content;
    }

    enum class elevation_prompt_user_choice
    {
        yes,
        no
    };

    static elevation_prompt_user_choice elevated_cmd_execute(const std::string& param)
    {
        SHELLEXECUTEINFO shExInfo = { 0 };
        shExInfo.cbSize = sizeof(shExInfo);
        shExInfo.fMask = SEE_MASK_NOCLOSEPROCESS;
        shExInfo.hwnd = nullptr;
        shExInfo.lpVerb = "runas";
        shExInfo.lpFile = "cmd"; // Application to start

        shExInfo.lpParameters = param.c_str(); // Additional parameters
        shExInfo.lpDirectory = nullptr;
        shExInfo.nShow = SW_HIDE;
        shExInfo.hInstApp = nullptr;

        if (!ShellExecuteExA(&shExInfo))
        {
            return elevation_prompt_user_choice::no;
        }
        if (shExInfo.hProcess == nullptr)
        {
            return elevation_prompt_user_choice::no;
        }
        WaitForSingleObject(shExInfo.hProcess, INFINITE);
        CloseHandle(shExInfo.hProcess);
        return elevation_prompt_user_choice::yes;
    }

    static fs::path get_appdata_targets_path()
    {
        return fs::path(*System::get_environmental_variable(L"LOCALAPPDATA")) / "vcpkg" / "vcpkg.user.targets";
    }

    static void integrate_install(const vcpkg_paths& paths)
    {
        // TODO: This block of code should eventually be removed
        for (auto&& old_system_wide_targets_file : old_system_target_files)
        {
            if (fs::exists(old_system_wide_targets_file))
            {
                const std::string param = Strings::format(R"(/c DEL "%s" /Q > nul)", old_system_wide_targets_file.string());
                elevation_prompt_user_choice user_choice = elevated_cmd_execute(param);
                switch (user_choice)
                {
                    case elevation_prompt_user_choice::yes:
                        break;
                    case elevation_prompt_user_choice::no:
                        System::println(System::color::warning, "Warning: Previous integration file was not removed");
                        exit(EXIT_FAILURE);
                    default:
                        Checks::unreachable();
                }
            }
        }

        const fs::path tmp_dir = paths.buildsystems / "tmp";
        fs::create_directory(paths.buildsystems);
        fs::create_directory(tmp_dir);

        bool should_install_system = true;
        const expected<std::string> system_wide_file_contents = Files::read_contents(system_wide_targets_file);
        if (auto contents_data = system_wide_file_contents.get())
        {
            std::regex re(R"###(<!-- version (\d+) -->)###");
            std::match_results<std::string::const_iterator> match;
            auto found = std::regex_search(*contents_data, match, re);
            if (found)
            {
                int ver = atoi(match[1].str().c_str());
                if (ver >= 1)
                    should_install_system = false;
            }
        }

        if (should_install_system)
        {
            const fs::path sys_src_path = tmp_dir / "vcpkg.system.targets";
            std::ofstream(sys_src_path) << create_system_targets_shortcut();

            const std::string param = Strings::format(R"(/c mkdir "%s" & copy "%s" "%s" /Y > nul)", system_wide_targets_file.parent_path().string(), sys_src_path.string(), system_wide_targets_file.string());
            elevation_prompt_user_choice user_choice = elevated_cmd_execute(param);
            switch (user_choice)
            {
                case elevation_prompt_user_choice::yes:
                    break;
                case elevation_prompt_user_choice::no:
                    System::println(System::color::warning, "Warning: integration was not applied");
                    exit(EXIT_FAILURE);
                default:
                    Checks::unreachable();
            }

            Checks::check_exit(fs::exists(system_wide_targets_file), "Error: failed to copy targets file to %s", system_wide_targets_file.string());
        }

        const fs::path appdata_src_path = tmp_dir / "vcpkg.user.targets";
        std::ofstream(appdata_src_path) << create_appdata_targets_shortcut(paths.buildsystems_msbuild_targets.string());
        auto appdata_dst_path = get_appdata_targets_path();

        if (!fs::copy_file(appdata_src_path, appdata_dst_path, fs::copy_options::overwrite_existing))
        {
            System::println(System::color::error, "Error: Failed to copy file: %s -> %s", appdata_src_path.string(), appdata_dst_path.string());
            exit(EXIT_FAILURE);
        }
        System::println(System::color::success, "Applied user-wide integration for this vcpkg root.");
        const fs::path cmake_toolchain = paths.buildsystems / "vcpkg.cmake";
        System::println("\n"
                        "All MSBuild C++ projects can now #include any installed libraries.\n"
                        "Linking will be handled automatically.\n"
                        "Installing new libraries will make them instantly available.\n"
                        "\n"
                        "CMake projects should use -DCMAKE_TOOLCHAIN_FILE=%s", cmake_toolchain.generic_string());

        exit(EXIT_SUCCESS);
    }

    static void integrate_remove()
    {
        const fs::path path = get_appdata_targets_path();

        std::error_code ec;
        bool was_deleted = fs::remove(path, ec);

        if (ec)
        {
            System::println(System::color::error, "Error: Unable to remove user-wide integration: %d", ec.message());
            exit(EXIT_FAILURE);
        }

        if (was_deleted)
        {
            System::println(System::color::success, "User-wide integration was removed");
        }
        else
        {
            System::println(System::color::success, "User-wide integration is not installed");
        }

        exit(EXIT_SUCCESS);
    }

    static void integrate_project(const vcpkg_paths& paths)
    {
        const fs::path& nuget_exe = paths.get_nuget_exe();

        const fs::path& buildsystems_dir = paths.buildsystems;
        const fs::path tmp_dir = buildsystems_dir / "tmp";
        fs::create_directory(buildsystems_dir);
        fs::create_directory(tmp_dir);

        const fs::path targets_file_path = tmp_dir / "vcpkg.nuget.targets";
        const fs::path props_file_path = tmp_dir / "vcpkg.nuget.props";
        const fs::path nuspec_file_path = tmp_dir / "vcpkg.nuget.nuspec";
        const std::string nuget_id = get_nuget_id(paths.root);
        const std::string nupkg_version = "1.0.0";

        std::ofstream(targets_file_path) << create_nuget_targets_file(paths.buildsystems_msbuild_targets);
        std::ofstream(props_file_path) << create_nuget_props_file();
        std::ofstream(nuspec_file_path) << create_nuspec_file(paths.root, nuget_id, nupkg_version);

        // Using all forward slashes for the command line
        const std::wstring cmd_line = Strings::wformat(LR"("%s" pack -OutputDirectory "%s" "%s" > nul)", nuget_exe.native(), buildsystems_dir.native(), nuspec_file_path.native());

        const int exit_code = System::cmd_execute_clean(cmd_line);

        const fs::path nuget_package = buildsystems_dir / Strings::format("%s.%s.nupkg", nuget_id, nupkg_version);
        Checks::check_exit(exit_code == 0 && fs::exists(nuget_package), "Error: NuGet package creation failed");
        System::println(System::color::success, "Created nupkg: %s", nuget_package.string());

        System::println(R"(
With a project open, go to Tools->NuGet Package Manager->Package Manager Console and paste:
    Install-Package %s -Source "%s"
)", nuget_id, buildsystems_dir.generic_string());

        exit(EXIT_SUCCESS);
    }

    const char* const INTEGRATE_COMMAND_HELPSTRING =
    "  vcpkg integrate install         Make installed packages available user-wide. Requires admin privileges on first use\n"
    "  vcpkg integrate remove          Remove user-wide integration\n"
    "  vcpkg integrate project         Generate a referencing nuget package for individual VS project use\n";

    void perform_and_exit(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths)
    {
        static const std::string example = Strings::format("Commands:\n"
                                                           "%s", INTEGRATE_COMMAND_HELPSTRING);
        args.check_exact_arg_count(1, example);
        args.check_and_get_optional_command_arguments({});

        if (args.command_arguments[0] == "install")
        {
            return integrate_install(paths);
        }
        if (args.command_arguments[0] == "remove")
        {
            return integrate_remove();
        }
        if (args.command_arguments[0] == "project")
        {
            return integrate_project(paths);
        }

        System::println(System::color::error, "Unknown parameter %s for integrate", args.command_arguments[0]);
        exit(EXIT_FAILURE);
    }
}
