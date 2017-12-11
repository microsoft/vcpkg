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

    static const CommandSwitch switches[] = {{"--survey", "Launch default browser to the current vcpkg survey"}};

    const CommandStructure COMMAND_STRUCTURE = {
        Help::create_example_string("contact"),
        0,
        0,
        {switches, {}},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args)
    {
        auto parsed_args = args.parse_arguments(COMMAND_STRUCTURE);

        if (Util::Sets::contains(parsed_args.switches, switches[0].name))
        {
            System::cmd_execute("start https://aka.ms/NPS_vcpkg");
            System::println("Default browser launched to https://aka.ms/NPS_vcpkg, thank you for your feedback!");
        }
        else
        {
            System::println("Send an email to %s with any feedback.", email());
        }
        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
