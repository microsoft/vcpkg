#include "pch.h"

#include <vcpkg/base/strings.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/commands.h>
#include <vcpkg/help.h>
#include <vcpkg/paragraphs.h>

namespace vcpkg::Commands::Edit
{
    static std::vector<fs::path> find_from_registry()
    {
        std::vector<fs::path> output;

#if defined(_WIN32)
        struct RegKey
        {
            HKEY root;
            StringLiteral subkey;
        } REGKEYS[] = {
            {HKEY_LOCAL_MACHINE,
             R"(SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{C26E74D1-022E-4238-8B9D-1E7564A36CC9}_is1)"},
            {HKEY_LOCAL_MACHINE,
             R"(SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{1287CAD5-7C8D-410D-88B9-0D1EE4A83FF2}_is1)"},
            {HKEY_LOCAL_MACHINE,
             R"(SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{F8A2A208-72B3-4D61-95FC-8A65D340689B}_is1)"},
            {HKEY_CURRENT_USER,
             R"(Software\Microsoft\Windows\CurrentVersion\Uninstall\{771FD6B0-FA20-440A-A002-3B3BAC16DC50}_is1)"},
            {HKEY_LOCAL_MACHINE,
             R"(SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{EA457B21-F73E-494C-ACAB-524FDE069978}_is1)"},
        };

        for (auto&& keypath : REGKEYS)
        {
            const Optional<std::string> code_installpath =
                System::get_registry_string(keypath.root, keypath.subkey, "InstallLocation");
            if (const auto c = code_installpath.get())
            {
                const fs::path install_path = fs::u8path(*c);
                output.push_back(install_path / "Code - Insiders.exe");
                output.push_back(install_path / "Code.exe");
            }
        }
#endif
        return output;
    }

    static constexpr StringLiteral OPTION_BUILDTREES = "--buildtrees";

    static constexpr StringLiteral OPTION_ALL = "--all";

    static std::vector<std::string> valid_arguments(const VcpkgPaths& paths)
    {
        auto sources_and_errors = Paragraphs::try_load_all_ports(paths.get_filesystem(), paths.ports);

        return Util::fmap(sources_and_errors.paragraphs,
                          [](auto&& pgh) -> std::string { return pgh->core_paragraph->name; });
    }

    static constexpr std::array<CommandSwitch, 2> EDIT_SWITCHES = {
        {{OPTION_BUILDTREES, "Open editor into the port-specific buildtree subfolder"},
         {OPTION_ALL, "Open editor into the port as well as the port-specific buildtree subfolder"}}};

    const CommandStructure COMMAND_STRUCTURE = {
        Help::create_example_string("edit zlib"),
        1,
        10,
        {EDIT_SWITCHES, {}},
        &valid_arguments,
    };

    static std::vector<std::string> create_editor_arguments(const VcpkgPaths& paths,
                                                            const ParsedArguments& options,
                                                            const std::vector<std::string>& ports)
    {
        if (Util::Sets::contains(options.switches, OPTION_ALL))
        {
            const auto& fs = paths.get_filesystem();
            auto packages = fs.get_files_non_recursive(paths.packages);

            // TODO: Support edit for --overlay-ports
            return Util::fmap(ports, [&](const std::string& port_name) -> std::string {
                const auto portpath = paths.ports / port_name;
                const auto portfile = portpath / "portfile.cmake";
                const auto buildtrees_current_dir = paths.buildtrees / port_name;
                const auto pattern = port_name + "_";

                std::string package_paths;
                for (auto&& package : packages)
                {
                    if (Strings::case_insensitive_ascii_starts_with(package.filename().u8string(), pattern))
                    {
                        package_paths.append(Strings::format(" \"%s\"", package.u8string()));
                    }
                }

                return Strings::format(R"###("%s" "%s" "%s"%s)###",
                                       portpath.u8string(),
                                       portfile.u8string(),
                                       buildtrees_current_dir.u8string(),
                                       package_paths);
            });
        }

        if (Util::Sets::contains(options.switches, OPTION_BUILDTREES))
        {
            return Util::fmap(ports, [&](const std::string& port_name) -> std::string {
                const auto buildtrees_current_dir = paths.buildtrees / port_name;
                return Strings::format(R"###("%s")###", buildtrees_current_dir.u8string());
            });
        }

        return Util::fmap(ports, [&](const std::string& port_name) -> std::string {
            const auto portpath = paths.ports / port_name;
            const auto portfile = portpath / "portfile.cmake";
            return Strings::format(R"###("%s" "%s")###", portpath.u8string(), portfile.u8string());
        });
    }

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        auto& fs = paths.get_filesystem();

        const ParsedArguments options = args.parse_arguments(COMMAND_STRUCTURE);

        const std::vector<std::string>& ports = args.command_arguments;
        for (auto&& port_name : ports)
        {
            const fs::path portpath = paths.ports / port_name;
            Checks::check_exit(
                VCPKG_LINE_INFO, fs.is_directory(portpath), R"(Could not find port named "%s")", port_name);
        }

        std::vector<fs::path> candidate_paths;
        auto maybe_editor_path = System::get_environment_variable("EDITOR");
        if (const std::string* editor_path = maybe_editor_path.get())
        {
            candidate_paths.emplace_back(*editor_path);
        }

#ifdef _WIN32
        static const fs::path VS_CODE_INSIDERS = fs::path{"Microsoft VS Code Insiders"} / "Code - Insiders.exe";
        static const fs::path VS_CODE = fs::path{"Microsoft VS Code"} / "Code.exe";

        const auto& program_files = System::get_program_files_platform_bitness();
        if (const fs::path* pf = program_files.get())
        {
            candidate_paths.push_back(*pf / VS_CODE_INSIDERS);
            candidate_paths.push_back(*pf / VS_CODE);
        }

        const auto& program_files_32_bit = System::get_program_files_32_bit();
        if (const fs::path* pf = program_files_32_bit.get())
        {
            candidate_paths.push_back(*pf / VS_CODE_INSIDERS);
            candidate_paths.push_back(*pf / VS_CODE);
        }

        const auto& app_data = System::get_environment_variable("APPDATA");
        if (const auto* ad = app_data.get())
        {
            const fs::path default_base = fs::path{*ad}.parent_path() / "Local" / "Programs";
            candidate_paths.push_back(default_base / VS_CODE_INSIDERS);
            candidate_paths.push_back(default_base / VS_CODE);
        }

        const std::vector<fs::path> from_registry = find_from_registry();
        candidate_paths.insert(candidate_paths.end(), from_registry.cbegin(), from_registry.cend());
#elif defined(__APPLE__)
        candidate_paths.push_back(
            fs::path{"/Applications/Visual Studio Code - Insiders.app/Contents/Resources/app/bin/code"});
        candidate_paths.push_back(fs::path{"/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"});
#elif defined(__linux__)
        candidate_paths.push_back(fs::path{"/usr/share/code/bin/code"});
        candidate_paths.push_back(fs::path{"/usr/bin/code"});
#endif

        const auto it = Util::find_if(candidate_paths, [&](const fs::path& p) { return fs.exists(p); });
        if (it == candidate_paths.cend())
        {
            System::print2(
                System::Color::error,
                "Error: Visual Studio Code was not found and the environment variable EDITOR is not set or invalid.\n");
            System::print2("The following paths were examined:\n");
            Files::print_paths(candidate_paths);
            System::print2("You can also set the environmental variable EDITOR to your editor of choice.\n");
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        const fs::path env_editor = *it;
        const std::vector<std::string> arguments = create_editor_arguments(paths, options, ports);
        const auto args_as_string = Strings::join(" ", arguments);
        const auto cmd_line = Strings::format(R"("%s" %s -n)", env_editor.u8string(), args_as_string);

        auto editor_exe = env_editor.filename().u8string();

#ifdef _WIN32
        if (editor_exe == "Code.exe" || editor_exe == "Code - Insiders.exe")
        {
            System::cmd_execute_no_wait(cmd_line + " <NUL");
            Checks::exit_success(VCPKG_LINE_INFO);
        }
#endif
        Checks::exit_with_code(VCPKG_LINE_INFO, System::cmd_execute(cmd_line));
    }
}
