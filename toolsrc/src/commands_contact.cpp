#include "pch.h"

#include "vcpkg_Commands.h"
#include "vcpkg_System.h"

namespace vcpkg::Commands::Contact
{
    const std::string& email()
    {
        static const std::string s_email = R"(vcpkg@microsoft.com)";
        return s_email;
    }

    void perform_and_exit(const VcpkgCmdArguments& args)
    {
        args.check_exact_arg_count(0);
        args.check_and_get_optional_command_arguments({});

        System::println("Send an email to %s with any feedback.", email());
        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
