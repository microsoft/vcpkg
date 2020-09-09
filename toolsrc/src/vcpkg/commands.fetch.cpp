#include <vcpkg/base/system.print.h>
#include <vcpkg/base/system.process.h>

#include <vcpkg/commands.fetch.h>
#include <vcpkg/tools.h>
#include <vcpkg/vcpkgcmdarguments.h>
#include <vcpkg/vcpkgpaths.h>

namespace vcpkg::Commands::Fetch
{
    const CommandStructure COMMAND_STRUCTURE = {
        Strings::format("The argument should be tool name\n%s", create_example_string("fetch cmake")),
        1,
        1,
        {},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        (void)args.parse_arguments(COMMAND_STRUCTURE);
        const std::string tool = args.command_arguments[0];

        if (tool == "update")
        {
            const fs::path& git_exe = paths.get_tool_exe(Tools::GIT);
            const std::string repo = "https://github.com/microsoft/vcpkg";
            fs::path fetch_dir = paths.root / fs::u8path("vcpkg-fetch");

            Files::Filesystem& fs = paths.get_filesystem();

            fs.remove_all(fetch_dir, ignore_errors);
            fs.create_directory(fetch_dir, VCPKG_LINE_INFO);

            const std::string full_cmd = Strings::format(
                R"(%s clone %s %s)", fs::u8string(git_exe), fs::u8string(repo), fs::u8string(fetch_dir));

            auto output = System::cmd_execute_and_capture_output(full_cmd);

            std::error_code ec;
            fs.remove_all(paths.ports, ignore_errors);
            fs.rename(fetch_dir / fs::u8path("ports"), paths.ports, ec);
            fs.remove_all(paths.scripts, ignore_errors);
            fs.rename(fetch_dir / fs::u8path("scripts"), paths.scripts, ec);
            fs.remove_all(paths.triplets, ignore_errors);
            fs.rename(fetch_dir / fs::u8path("triplets"), paths.triplets, ec);

            Checks::check_exit(VCPKG_LINE_INFO, output.exit_code == 0, "Failed to fetch: %s", full_cmd);

            Checks::exit_success(VCPKG_LINE_INFO);
        }

        const fs::path tool_path = paths.get_tool_exe(tool);
        System::print2(fs::u8string(tool_path), '\n');
        Checks::exit_success(VCPKG_LINE_INFO);
    }

    void FetchCommand::perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const
    {
        Fetch::perform_and_exit(args, paths);
    }
}
