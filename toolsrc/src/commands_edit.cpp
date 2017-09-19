#include "pch.h"

#include "vcpkg_Commands.h"
#include "vcpkg_Input.h"
#include "vcpkg_System.h"

namespace vcpkg::Commands::Edit
{
    static std::vector<fs::path> find_from_registry()
    {
        static const std::array<const wchar_t*, 3> REGKEYS = {
            LR"(SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{C26E74D1-022E-4238-8B9D-1E7564A36CC9}_is1)",
            LR"(SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{1287CAD5-7C8D-410D-88B9-0D1EE4A83FF2}_is1)",
            LR"(SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{F8A2A208-72B3-4D61-95FC-8A65D340689B}_is1)",
        };

        std::vector<fs::path> output;
        for (auto&& keypath : REGKEYS)
        {
            const Optional<std::wstring> code_installpath =
                System::get_registry_string(HKEY_LOCAL_MACHINE, keypath, L"InstallLocation");
            if (const auto c = code_installpath.get())
            {
                const fs::path install_path = fs::path(*c);
                output.push_back(install_path / "Code - Insiders.exe");
                output.push_back(install_path / "Code.exe");
            }
        }
        return output;
    }

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        static const std::string OPTION_BUILDTREES = "--buildtrees";

        static const fs::path VS_CODE_INSIDERS = fs::path{"Microsoft VS Code Insiders"} / "Code - Insiders.exe";
        static const fs::path VS_CODE = fs::path{"Microsoft VS Code"} / "Code.exe";

        auto& fs = paths.get_filesystem();

        static const std::string EXAMPLE = Commands::Help::create_example_string("edit zlib");
        args.check_exact_arg_count(1, EXAMPLE);
        const std::unordered_set<std::string> options =
            args.check_and_get_optional_command_arguments({OPTION_BUILDTREES});
        const std::string port_name = args.command_arguments.at(0);

        const fs::path portpath = paths.ports / port_name;
        Checks::check_exit(VCPKG_LINE_INFO, fs.is_directory(portpath), R"(Could not find port named "%s")", port_name);

        std::vector<fs::path> candidate_paths;
        const std::vector<fs::path> from_path = Files::find_from_PATH(L"EDITOR");
        candidate_paths.insert(candidate_paths.end(), from_path.cbegin(), from_path.cend());
        candidate_paths.push_back(System::get_program_files_platform_bitness() / VS_CODE_INSIDERS);
        candidate_paths.push_back(System::get_program_files_32_bit() / VS_CODE_INSIDERS);
        candidate_paths.push_back(System::get_program_files_platform_bitness() / VS_CODE);
        candidate_paths.push_back(System::get_program_files_32_bit() / VS_CODE);

        const std::vector<fs::path> from_registry = find_from_registry();
        candidate_paths.insert(candidate_paths.end(), from_registry.cbegin(), from_registry.cend());

        auto it = Util::find_if(candidate_paths, [&](const fs::path& p) { return fs.exists(p); });
        if (it == candidate_paths.cend())
        {
            System::println(System::Color::error,
                            "Error: Visual Studio Code was not found and the environment variable EDITOR is not set.");
            System::println("The following paths were examined:");
            Files::print_paths(candidate_paths);
            System::println("You can also set the environmental variable EDITOR to your editor of choice.");
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        const fs::path env_editor = *it;
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
