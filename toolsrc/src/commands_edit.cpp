#include "vcpkg_Commands.h"
#include "vcpkg_System.h"

namespace vcpkg
{
    void edit_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths, const triplet& default_target_triplet)
    {
        static const std::string example = create_example_string("edit zlib");
        args.check_exact_arg_count(1, example.c_str());
        package_spec spec = args.parse_all_arguments_as_package_specs(default_target_triplet, example.c_str()).at(0);

        // Find editor
        std::wstring env_EDITOR = System::wdupenv_str(L"EDITOR");
        if (env_EDITOR.empty())
            env_EDITOR = LR"(C:\Program Files (x86)\Microsoft VS Code\Code.exe)";

        auto portpath = paths.ports / spec.name;
        std::wstring cmdLine = Strings::wformat(LR"("%s" "%s" "%s")", env_EDITOR, portpath.native(), (portpath / "portfile.cmake").native());
        exit(System::cmd_execute(cmdLine));
    }
}
