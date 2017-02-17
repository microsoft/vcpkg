#include "pch.h"
#include "vcpkg_Commands.h"
#include "vcpkg_System.h"
#include "vcpkg_Input.h"
#include "vcpkg_Environment.h"

namespace vcpkg::Commands::Edit
{
    void perform_and_exit(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths)
    {
        static const std::string example = Commands::Help::create_example_string("edit zlib");
        args.check_exact_arg_count(1, example);
        args.check_and_get_optional_command_arguments({});
        const std::string port_name = args.command_arguments.at(0);

        const fs::path portpath = paths.ports / port_name;
        Checks::check_exit(fs::is_directory(portpath), R"(Could not find port named "%s")", port_name);

        // Find editor
        const optional<std::wstring> env_EDITOR_optional = System::get_environmental_variable(L"EDITOR");
        std::wstring env_EDITOR;

        if (env_EDITOR_optional)
        {
            env_EDITOR = *env_EDITOR_optional;
        }
        else
        {
            static const fs::path CODE_EXE_PATH = Environment::get_ProgramFiles_32_bit() / "Microsoft VS Code/Code.exe";
            if (fs::exists(CODE_EXE_PATH))
            {
                env_EDITOR = CODE_EXE_PATH;
            }
            else
            {
                Checks::exit_with_message("Visual Studio Code was not found and the environmental variable EDITOR is not set");
            }
        }

        std::wstring cmdLine = Strings::wformat(LR"("%s" "%s" "%s" -n)", env_EDITOR, portpath.native(), (portpath / "portfile.cmake").native());
        exit(System::cmd_execute(cmdLine));
    }
}
