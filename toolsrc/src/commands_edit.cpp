#include "vcpkg_Commands.h"
#include "vcpkg_System.h"
#include "vcpkg_Input.h"

namespace vcpkg::Commands::Edit
{
    void perform_and_exit(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths)
    {
        static const std::string example = Commands::Help::create_example_string("edit zlib");
        args.check_exact_arg_count(1, example);
        const std::string port_name = args.command_arguments.at(0);

        const fs::path portpath = paths.ports / port_name;

        // Find editor
        std::wstring env_EDITOR = System::wdupenv_str(L"EDITOR");
        if (env_EDITOR.empty())
        {
            static const std::wstring CODE_EXE_PATH = LR"(C:\Program Files (x86)\Microsoft VS Code\Code.exe)";
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
