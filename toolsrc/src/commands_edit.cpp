#include "vcpkg_Commands.h"
#include "vcpkg_System.h"
#include "vcpkg_Input.h"

namespace vcpkg
{
    void edit_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths, const triplet& default_target_triplet)
    {
        static const std::string example = create_example_string("edit zlib");
        args.check_exact_arg_count(1, example.c_str());
        const package_spec spec = Input::check_and_get_package_spec(args.command_arguments.at(0), default_target_triplet, example.c_str());
        Input::check_triplet(spec.target_triplet, paths);

        // Find editor
        std::wstring env_EDITOR = System::wdupenv_str(L"EDITOR");
        if (env_EDITOR.empty())
            env_EDITOR = LR"(C:\Program Files (x86)\Microsoft VS Code\Code.exe)";

        const fs::path portpath = paths.ports / spec.name;
        std::wstring cmdLine = Strings::wformat(LR"("%s" "%s" "%s")", env_EDITOR, portpath.native(), (portpath / "portfile.cmake").native());
        exit(System::cmd_execute(cmdLine));
    }
}
