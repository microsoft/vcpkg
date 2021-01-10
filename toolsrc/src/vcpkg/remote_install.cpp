#include <vcpkg/base/downloads.h>
#include <vcpkg/base/files.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/base/util.h>

#include <vcpkg/input.h>
#include <vcpkg/packagespec.h>
#include <vcpkg/remote_install.h>
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
        create_example_string("remote-install nnoops-long-arith-lib"),
        1,
        1,
        {{}, REMOTE_INSTALL_SETTINGS},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths, Triplet default_triplet)
    {
        const ParsedArguments options = args.parse_arguments(COMMAND_STRUCTURE);

        const std::vector<FullPackageSpec> specs = Util::fmap(args.command_arguments, [&](auto&& arg) {
            return Input::check_and_get_full_package_spec(
                std::string(arg), default_triplet, COMMAND_STRUCTURE.example_text);
        });

        // check triplets
        for (auto&& spec : specs)
        {
            Input::check_triplet(spec.package_spec.triplet(), paths);

            System::printf("dir: %s, name: %s, triplet: %s \n",
                           spec.package_spec.dir(),
                           spec.package_spec.name(),
                           spec.package_spec.triplet().to_string());
        }

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

        Files::Filesystem& fs = paths.get_filesystem();
        // create directories
        for (auto&& spec : specs)
        {
            std::error_code err;
            fs::path destination = paths.builtin_ports_directory() / (author_name + "_" + spec.package_spec.name());

            fs.create_directory(destination, err);
            Checks::check_exit(VCPKG_LINE_INFO,
                               !err.value(),
                               "Failed to create directory '%s', code: %d",
                               fs::u8string(destination),
                               err.value());
        }

        // Download archive
        for (auto&& spec : specs)
        {
            Downloads::download_file(
                fs,
                GITHUB_URL + "/" + author_name + "/" + spec.package_spec.name() + "/raw/master/" +
                    spec.package_spec.name() + ARCHIVE_ENDING.to_string(),
                (paths.builtin_ports_directory() / (author_name + "_" + spec.package_spec.name())) /
                    (spec.package_spec.name() + ARCHIVE_ENDING.to_string()));
        }

        Checks::exit_success(VCPKG_LINE_INFO);
    }

    void RemoteInstallCommand::perform_and_exit(const VcpkgCmdArguments& args,
                                                const VcpkgPaths& paths,
                                                Triplet default_triplet) const
    {
        RemoteInstall::perform_and_exit(args, paths, default_triplet);
    }
}