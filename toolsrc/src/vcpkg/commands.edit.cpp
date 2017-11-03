#include "pch.h"

#include <vcpkg/base/system.h>
#include <vcpkg/commands.h>
#include <vcpkg/help.h>
#include <vcpkg/paragraphs.h>

namespace vcpkg::Commands::Edit
{
    static std::vector<fs::path> find_from_registry()
    {
        static const std::array<const char*, 3> REGKEYS = {
            R"(SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{C26E74D1-022E-4238-8B9D-1E7564A36CC9}_is1)",
            R"(SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{1287CAD5-7C8D-410D-88B9-0D1EE4A83FF2}_is1)",
            R"(SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{F8A2A208-72B3-4D61-95FC-8A65D340689B}_is1)",
        };

        std::vector<fs::path> output;
#if defined(_WIN32)
        for (auto&& keypath : REGKEYS)
        {
            const Optional<std::string> code_installpath =
                System::get_registry_string(HKEY_LOCAL_MACHINE, keypath, "InstallLocation");
            if (const auto c = code_installpath.get())
            {
                const fs::path install_path = fs::path(*c);
                output.push_back(install_path / "Code - Insiders.exe");
                output.push_back(install_path / "Code.exe");
            }
        }
#endif
        return output;
    }

    static const std::string OPTION_BUILDTREES = "--buildtrees";

    static std::vector<std::string> valid_arguments(const VcpkgPaths& paths)
    {
        auto sources_and_errors = Paragraphs::try_load_all_ports(paths.get_filesystem(), paths.ports);

        return Util::fmap(sources_and_errors.paragraphs,
                          [](auto&& pgh) -> std::string { return pgh->core_paragraph->name; });
    }

    static const std::array<CommandSwitch, 1> EDIT_SWITCHES = {{
        {OPTION_BUILDTREES, "Open editor into the port-specific buildtree subfolder"},
    }};

    const CommandStructure COMMAND_STRUCTURE = {
        Help::create_example_string("edit zlib"),
        1,
        1,
        {EDIT_SWITCHES, {}},
        &valid_arguments,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        static const fs::path VS_CODE_INSIDERS = fs::path{"Microsoft VS Code Insiders"} / "Code - Insiders.exe";
        static const fs::path VS_CODE = fs::path{"Microsoft VS Code"} / "Code.exe";

        auto& fs = paths.get_filesystem();

        const ParsedArguments options = args.parse_arguments(COMMAND_STRUCTURE);
        const std::string port_name = args.command_arguments.at(0);

        const fs::path portpath = paths.ports / port_name;
        Checks::check_exit(VCPKG_LINE_INFO, fs.is_directory(portpath), R"(Could not find port named "%s")", port_name);

        std::vector<fs::path> candidate_paths;
        const std::vector<fs::path> from_path = Files::find_from_PATH("EDITOR");
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
        if (Util::Sets::contains(options.switches, OPTION_BUILDTREES))
        {
            const auto buildtrees_current_dir = paths.buildtrees / port_name;

            const auto cmd_line =
                Strings::format(R"("%s" "%s" -n)", env_editor.u8string(), buildtrees_current_dir.u8string());
            Checks::exit_with_code(VCPKG_LINE_INFO, System::cmd_execute(cmd_line));
        }

        const auto cmd_line = Strings::format(
            R"("%s" "%s" "%s" -n)",
            env_editor.u8string(),
            portpath.u8string(),
            (portpath / "portfile.cmake").u8string());
        Checks::exit_with_code(VCPKG_LINE_INFO, System::cmd_execute(cmd_line));
    }
}
