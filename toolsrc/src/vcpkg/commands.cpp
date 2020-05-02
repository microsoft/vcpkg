#include "pch.h"

#include <vcpkg/base/hash.h>
#include <vcpkg/base/system.print.h>

#include <vcpkg/build.h>
#include <vcpkg/commands.h>
#include <vcpkg/export.h>
#include <vcpkg/help.h>
#include <vcpkg/install.h>
#include <vcpkg/remove.h>
#include <vcpkg/update.h>

namespace vcpkg::Commands
{
    Span<const PackageNameAndFunction<CommandTypeA>> get_available_commands_type_a()
    {
        static std::vector<PackageNameAndFunction<CommandTypeA>> t = {
            {"install", &Install::perform_and_exit},
            {"x-set-installed", &SetInstalled::perform_and_exit},
            {"ci", &CI::perform_and_exit},
            {"remove", &Remove::perform_and_exit},
            {"upgrade", &Upgrade::perform_and_exit},
            {"build", &Build::Command::perform_and_exit},
            {"env", &Env::perform_and_exit},
            {"build-external", &BuildExternal::perform_and_exit},
            {"export", &Export::perform_and_exit},
            {"depend-info", &DependInfo::perform_and_exit},
        };
        return t;
    }

    Span<const PackageNameAndFunction<CommandTypeB>> get_available_commands_type_b()
    {
        static std::vector<PackageNameAndFunction<CommandTypeB>> t = {
            {"/?", &Help::perform_and_exit},
            {"help", &Help::perform_and_exit},
            {"search", &Search::perform_and_exit},
            {"list", &List::perform_and_exit},
            {"integrate", &Integrate::perform_and_exit},
            {"owns", &Owns::perform_and_exit},
            {"update", &Update::perform_and_exit},
            {"edit", &Edit::perform_and_exit},
            {"create", &Create::perform_and_exit},
            {"import", &Import::perform_and_exit},
            {"cache", &Cache::perform_and_exit},
            {"portsdiff", &PortsDiff::perform_and_exit},
            {"autocomplete", &Autocomplete::perform_and_exit},
            {"hash", &Hash::perform_and_exit},
            {"fetch", &Fetch::perform_and_exit},
            {"x-history", &PortHistory::perform_and_exit},
            {"x-vsinstances", &X_VSInstances::perform_and_exit},
        };
        return t;
    }

    Span<const PackageNameAndFunction<CommandTypeC>> get_available_commands_type_c()
    {
        static std::vector<PackageNameAndFunction<CommandTypeC>> t = {
            {"version", &Version::perform_and_exit},
            {"contact", &Contact::perform_and_exit},
        };
        return t;
    }
}

namespace vcpkg::Commands::Fetch
{
    const CommandStructure COMMAND_STRUCTURE = {
        Strings::format("The argument should be tool name\n%s", Help::create_example_string("fetch cmake")),
        1,
        1,
        {},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        Util::unused(args.parse_arguments(COMMAND_STRUCTURE));

        const std::string tool = args.command_arguments[0];
        const fs::path tool_path = paths.get_tool_exe(tool);
        System::print2(tool_path.u8string(), '\n');
        Checks::exit_success(VCPKG_LINE_INFO);
    }
}

namespace vcpkg::Commands::Hash
{
    const CommandStructure COMMAND_STRUCTURE = {
        Strings::format("The argument should be a file path\n%s",
                        Help::create_example_string("hash boost_1_62_0.tar.bz2")),
        1,
        2,
        {},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        Util::unused(args.parse_arguments(COMMAND_STRUCTURE));

        const fs::path file_to_hash = args.command_arguments[0];

        auto algorithm = vcpkg::Hash::Algorithm::Sha512;
        if (args.command_arguments.size() == 2)
        {
            algorithm = vcpkg::Hash::algorithm_from_string(args.command_arguments[1]).value_or_exit(VCPKG_LINE_INFO);
        }

        const std::string hash =
            vcpkg::Hash::get_file_hash(VCPKG_LINE_INFO, paths.get_filesystem(), file_to_hash, algorithm);
        System::print2(hash, '\n');
        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
