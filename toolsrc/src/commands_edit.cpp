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

        static const std::string example = Commands::Help::create_example_string("edit zlib");
        args.check_exact_arg_count(1, example);
        const std::unordered_set<std::string> options =
            args.check_and_get_optional_command_arguments({OPTION_BUILDTREES});
        const std::string port_name = args.command_arguments.at(0);

        const fs::path portpath = paths.ports / port_name;
        Checks::check_exit(VCPKG_LINE_INFO, fs.is_directory(portpath), R"(Could not find port named "%s")", port_name);

        // Find the user's selected editor
        std::wstring env_EDITOR;

        if (env_EDITOR.empty())
        {
            const Optional<std::wstring> env_EDITOR_optional = System::get_environment_variable(L"EDITOR");
            if (auto e = env_EDITOR_optional.get())
            {
                env_EDITOR = *e;
            }
        }

        if (env_EDITOR.empty())
        {
            const fs::path CODE_EXE_PATH = System::get_ProgramFiles_platform_bitness() / "Microsoft VS Code/Code.exe";
            if (fs.exists(CODE_EXE_PATH))
            {
                env_EDITOR = CODE_EXE_PATH;
            }
        }

        if (env_EDITOR.empty())
        {
            const fs::path CODE_EXE_PATH = System::get_ProgramFiles_32_bit() / "Microsoft VS Code/Code.exe";
            if (fs.exists(CODE_EXE_PATH))
            {
                env_EDITOR = CODE_EXE_PATH;
            }
        }

        if (env_EDITOR.empty())
        {
            static const std::array<const wchar_t*, 4> regkeys = {
                LR"(SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{C26E74D1-022E-4238-8B9D-1E7564A36CC9}_is1)",
                LR"(SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{C26E74D1-022E-4238-8B9D-1E7564A36CC9}_is1)",
                LR"(SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{F8A2A208-72B3-4D61-95FC-8A65D340689B}_is1)",
                LR"(SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{F8A2A208-72B3-4D61-95FC-8A65D340689B}_is1)",
            };
            for (auto&& keypath : regkeys)
            {
                const Optional<std::wstring> code_installpath =
                    System::get_registry_string(HKEY_LOCAL_MACHINE, keypath, L"InstallLocation");
                if (auto c = code_installpath.get())
                {
                    auto p = fs::path(*c) / "Code.exe";
                    if (fs.exists(p))
                    {
                        env_EDITOR = p.native();
                        break;
                    }
                    auto p_insiders = fs::path(*c) / "Code - Insiders.exe";
                    if (fs.exists(p_insiders))
                    {
                        env_EDITOR = p_insiders.native();
                        break;
                    }
                }
            }
        }

        if (env_EDITOR.empty())
        {
            Checks::exit_with_message(
                VCPKG_LINE_INFO, "Visual Studio Code was not found and the environment variable EDITOR is not set");
        }

        if (options.find(OPTION_BUILDTREES) != options.cend())
        {
            const auto buildtrees_current_dir = paths.buildtrees / port_name;

            std::wstring cmdLine = Strings::wformat(LR"("%s" "%s" -n)", env_EDITOR, buildtrees_current_dir.native());
            Checks::exit_with_code(VCPKG_LINE_INFO, System::cmd_execute(cmdLine));
        }

        std::wstring cmdLine = Strings::wformat(
            LR"("%s" "%s" "%s" -n)", env_EDITOR, portpath.native(), (portpath / "portfile.cmake").native());
        Checks::exit_with_code(VCPKG_LINE_INFO, System::cmd_execute(cmdLine));
    }
}
