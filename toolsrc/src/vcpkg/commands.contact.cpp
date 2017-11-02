#include "pch.h"

#include <vcpkg/base/system.h>
#include <vcpkg/commands.h>
#include <vcpkg/help.h>

namespace vcpkg::Commands::Contact
{
    const std::string& email()
    {
        static const std::string S_EMAIL = R"(vcpkg@microsoft.com)";
        return S_EMAIL;
    }

    const CommandStructure COMMAND_STRUCTURE = {
        Help::create_example_string("contact"),
        0,
        0,
        {},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args)
    {
        args.parse_arguments(COMMAND_STRUCTURE);

        System::println("Send an email to %s with any feedback.", email());
        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
