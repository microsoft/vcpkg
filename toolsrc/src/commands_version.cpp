#include "pch.h"
#include "vcpkg_Commands.h"
#include "vcpkg_System.h"
#include "metrics.h"

#define STRINGIFY(X) #X
#define MACRO_TO_STRING(X) STRINGIFY(X)

#define VCPKG_VERSION_AS_STRING MACRO_TO_STRING(VCPKG_VERSION)"" // Double quotes needed at the end to prevent blank token

namespace vcpkg::Commands::Version
{
    const std::string& version()
    {
        static const std::string s_version =
#include "../VERSION.txt"


#pragma warning( push )
#pragma warning( disable : 4003)
            // VCPKG_VERSION can be defined but have no value, which yields C4003.
            + std::string(VCPKG_VERSION_AS_STRING)
#pragma warning( pop )
#ifndef NDEBUG
            + std::string("-debug")
#endif
            + std::string(GetCompiledMetricsEnabled() ? "" : "-external");
        return s_version;
    }

    void perform_and_exit(const vcpkg_cmd_arguments& args)
    {
        args.check_exact_arg_count(0);
        args.check_and_get_optional_command_arguments({});

        System::println("Vcpkg package management program version %s\n"
                        "\n"
                        "See LICENSE.txt for license information.", version()
        );
        exit(EXIT_SUCCESS);
    }
}
