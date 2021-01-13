#include <vcpkg/base/downloads.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/base/util.h>

#include <vcpkg/input.h>
#include <vcpkg/packagespec.h>
#include <vcpkg/remote_install.h>
#include <vcpkg/tools.h>
#include <vcpkg/vcpkgcmdarguments.h>
#include <vcpkg/vcpkgpaths.h>

namespace vcpkg::RemoteInstall
{
    static constexpr StringLiteral ARCHIVE_ENDING = "-vcpkg.zip";
    static constexpr StringLiteral GITHUB_URL = "https://github.com";

    static constexpr StringLiteral OPTION_AUTHOR_NAME = "author-name";

    static constexpr std::array<CommandSetting, 1> REMOTE_INSTALL_SETTINGS = {{
        {OPTION_AUTHOR_NAME, "author name"},
    }};

    const CommandStructure COMMAND_STRUCTURE = {
        create_example_string("remote-install nnoops-long-arith-lib --author-name=Mr-Leshiy"),
        1,
        1,
        {{}, REMOTE_INSTALL_SETTINGS},
        nullptr,
    };

    static void do_archive_unzip(const VcpkgPaths& paths, const fs::path& destination, const std::string& file_name)
    {
        const fs::path& cmake_exe = paths.get_tool_exe(Tools::CMAKE);

        System::CmdLineBuilder cmd;
        cmd.string_arg("cd").path_arg(destination);
        cmd.ampersand();
        cmd.path_arg(cmake_exe).string_arg("-E").string_arg("tar").string_arg("xzf").path_arg(file_name);

        auto cmdline = cmd.extract();
#ifdef WIN32
        // Invoke through `cmd` to support `&&`
        cmdline.insert(0, "cmd /c \"");
        cmdline.push_back('"');
#endif

        const int exit_code = System::cmd_execute_clean(cmdline);
        Checks::check_exit(VCPKG_LINE_INFO, exit_code == 0, "Error: %s unzip failed", file_name);
    }

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, Triplet default_triplet)
    {
        const ParsedArguments options = args.parse_arguments(COMMAND_STRUCTURE);

        const std::vector<FullPackageSpec> specs = Util::fmap(args.command_arguments, [&](auto&& arg) {
            return Input::check_and_get_full_package_spec(
                std::string(arg), default_triplet, COMMAND_STRUCTURE.example_text);
        });

        FullPackageSpec spec = specs[0];

        std::string author_name = "";
        auto it_author_name = options.settings.find(OPTION_AUTHOR_NAME);
        if (it_author_name != options.settings.end())
        {
            author_name = it_author_name->second;
        }
        else
        {
            System::printf(System::Color::error, "setting '%s' has not been set \n", OPTION_AUTHOR_NAME);
            Checks::exit_fail(LineInfo());
        }

        Input::check_triplet(spec.package_spec.triplet(), paths);

        Files::Filesystem& fs = paths.get_filesystem();
        std::string package_directory_name = Strings::format("%s_%s", author_name, spec.package_spec.name());

        // create directories
        std::error_code err;
        fs::path destination = paths.builtin_ports_directory() / package_directory_name;
        fs.create_directory(destination, err);
        Checks::check_exit(VCPKG_LINE_INFO,
                           !err.value(),
                           "Failed to create directory '%s', code: %d",
                           fs::u8string(destination),
                           err.value());

        // Download archive
        std::string archive_name = Strings::format("%s%s", spec.package_spec.name(), ARCHIVE_ENDING);
        std::string archive_url =
            Strings::format("%s/%s/%s/raw/master/%s", GITHUB_URL, author_name, spec.package_spec.name(), archive_name);
        Downloads::download_file(
            fs, archive_url, paths.builtin_ports_directory() / package_directory_name / archive_name);

        // Unzip
        do_archive_unzip(paths, destination, Strings::format("%s%s", spec.package_spec.name(), ARCHIVE_ENDING));

        Checks::exit_success(VCPKG_LINE_INFO);
    }

    void RemoteInstallCommand::perform_and_exit(const VcpkgCmdArguments& args,
                                                const VcpkgPaths& paths,
                                                Triplet default_triplet) const
    {
        RemoteInstall::perform_and_exit(args, paths, default_triplet);
    }
}