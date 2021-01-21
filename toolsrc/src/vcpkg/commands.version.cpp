#include <vcpkg/base/system.print.h>

#include <vcpkg/commands.version.h>
#include <vcpkg/help.h>
#include <vcpkg/metrics.h>
#include <vcpkg/vcpkgcmdarguments.h>
#include <vcpkg/vcpkgpaths.h>

#define STRINGIFY(...) #__VA_ARGS__
#define MACRO_TO_STRING(X) STRINGIFY(X)

#if !defined(VCPKG_VERSION)
#error VCPKG_VERSION must be defined
#endif

#define VCPKG_VERSION_AS_STRING MACRO_TO_STRING(VCPKG_VERSION)

#if !defined(VCPKG_BASE_VERSION)
#error VCPKG_BASE_VERSION must be defined
#endif

#define VCPKG_BASE_VERSION_AS_STRING MACRO_TO_STRING(VCPKG_BASE_VERSION)

namespace vcpkg::Commands::Version
{
    const char* base_version() noexcept { return VCPKG_BASE_VERSION_AS_STRING; }

    const char* version() noexcept
    {
        return VCPKG_BASE_VERSION_AS_STRING "-" VCPKG_VERSION_AS_STRING
#ifndef NDEBUG
                                            "-debug"
#endif
            ;
    }

    const CommandStructure COMMAND_STRUCTURE = {
        create_example_string("version"),
        0,
        0,
        {},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, Files::Filesystem&)
    {
        (void)args.parse_arguments(COMMAND_STRUCTURE);
        System::print2("Vcpkg package management program version ",
                       version(),
                       "\n"
                       "\n"
                       "See LICENSE.txt for license information.\n");
        Checks::exit_success(VCPKG_LINE_INFO);
    }

    void VersionCommand::perform_and_exit(const VcpkgCmdArguments& args, Files::Filesystem& fs) const
    {
        Version::perform_and_exit(args, fs);
    }
}
