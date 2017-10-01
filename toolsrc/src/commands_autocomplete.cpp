#include "pch.h"

#include "Paragraphs.h"
#include "SortedVector.h"
#include "vcpkg_Commands.h"
#include "vcpkg_Maps.h"
#include "vcpkg_System.h"

namespace vcpkg::Commands::Autocomplete
{
    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        static const std::string EXAMPLE =
            Strings::format("The argument should be a command line to autocomplete.\n%s",
                            Commands::Help::create_example_string("autocomplete install z"));

        args.check_max_arg_count(1, EXAMPLE);
        args.check_and_get_optional_command_arguments({});

        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
