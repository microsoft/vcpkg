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
    const CommandStructure COMMAND_STRUCTURE = {
        create_example_string("remote-install nnoops-long-arith-lib"),
        1,
        1,
        {{}, {}},
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

        Files::Filesystem& fs = paths.get_filesystem();
        // create directories
        for (auto&& spec : specs)
        {
            std::error_code err;
            fs::path destination = paths.builtin_ports_directory() / spec.package_spec.name();
            fs.create_directory(destination, err);
            Checks::check_exit(VCPKG_LINE_INFO,
                               !err.value(),
                               "Failed to create directory '%s', code: %d",
                               fs::u8string(destination),
                               err.value());
        }

        // Downloads::download_file(
        //     fs,
        //     "https://github.com/Mr-Leshiy/nnoops-long-arith-lib/raw/master/nnoops-long-arith-vcpkg.zip",
        //     paths.builtin_ports_directory() / "nnoops-long-arith-lib" / "nnoops-long-arith-lib-vcpkg.zip");

        Checks::exit_success(VCPKG_LINE_INFO);
    }

    void RemoteInstallCommand::perform_and_exit(const VcpkgCmdArguments& args,
                                                const VcpkgPaths& paths,
                                                Triplet default_triplet) const
    {
        RemoteInstall::perform_and_exit(args, paths, default_triplet);
    }
}