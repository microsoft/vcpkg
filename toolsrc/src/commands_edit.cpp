#include "pch.h"

#include "vcpkg_Commands.h"
#include "vcpkg_Input.h"
#include "vcpkg_System.h"

namespace vcpkg::Commands::Edit
{
    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        static const std::string OPTION_BUILDTREES = "--buildtrees";

        auto& fs = paths.get_filesystem();

        static const std::string EXAMPLE = Commands::Help::create_example_string("edit zlib");
        args.check_exact_arg_count(1, EXAMPLE);
        const std::unordered_set<std::string> options =
            args.check_and_get_optional_command_arguments({OPTION_BUILDTREES});
        const std::string port_name = args.command_arguments.at(0);

        const fs::path portpath = paths.ports / port_name;
        Checks::check_exit(VCPKG_LINE_INFO, fs.is_directory(portpath), R"(Could not find port named "%s")", port_name);

        // Find the user's selected editor
        std::wstring env_editor;

        if (env_editor.empty())
        {
            const Optional<std::wstring> env_editor_optional = System::get_environment_variable(L"EDITOR");
            if (const auto e = env_editor_optional.get())
            {
                env_editor = *e;
            }
        }

        if (env_editor.empty())
        {
            const fs::path code_exe_path = System::get_ProgramFiles_platform_bitness() / "Microsoft VS Code/Code.exe";
            if (fs.exists(code_exe_path))
            {
                env_editor = code_exe_path;
            }
        }

        if (env_editor.empty())
        {
            const fs::path code_exe_path = System::get_ProgramFiles_32_bit() / "Microsoft VS Code/Code.exe";
            if (fs.exists(code_exe_path))
            {
                env_editor = code_exe_path;
            }
        }

        if (env_editor.empty())
        {
            static const std::array<const wchar_t*, 4> REGKEYS = {
                LR"(SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{C26E74D1-022E-4238-8B9D-1E7564A36CC9}_is1)",
                LR"(SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{C26E74D1-022E-4238-8B9D-1E7564A36CC9}_is1)",
                LR"(SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{F8A2A208-72B3-4D61-95FC-8A65D340689B}_is1)",
                LR"(SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{F8A2A208-72B3-4D61-95FC-8A65D340689B}_is1)",
            };
            for (auto&& keypath : REGKEYS)
            {
                const Optional<std::wstring> code_installpath =
                    System::get_registry_string(HKEY_LOCAL_MACHINE, keypath, L"InstallLocation");
                if (const auto c = code_installpath.get())
                {
                    auto p = fs::path(*c) / "Code.exe";
                    if (fs.exists(p))
                    {
                        env_editor = p.native();
                        break;
                    }
                    auto p_insiders = fs::path(*c) / "Code - Insiders.exe";
                    if (fs.exists(p_insiders))
                    {
                        env_editor = p_insiders.native();
                        break;
                    }
                }
            }
        }

        if (env_editor.empty())
        {
            Checks::exit_with_message(
                VCPKG_LINE_INFO, "Visual Studio Code was not found and the environment variable EDITOR is not set");
        }

        if (options.find(OPTION_BUILDTREES) != options.cend())
        {
            const auto buildtrees_current_dir = paths.buildtrees / port_name;

            const std::wstring cmd_line =
                Strings::wformat(LR"("%s" "%s" -n)", env_editor, buildtrees_current_dir.native());
            Checks::exit_with_code(VCPKG_LINE_INFO, System::cmd_execute(cmd_line));
        }

        const std::wstring cmd_line = Strings::wformat(
            LR"("%s" "%s" "%s" -n)", env_editor, portpath.native(), (portpath / "portfile.cmake").native());
        Checks::exit_with_code(VCPKG_LINE_INFO, System::cmd_execute(cmd_line));
    }
}
