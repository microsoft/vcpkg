#include "pch.h"

#include <vcpkg/base/system.print.h>
#include <vcpkg/commands.h>
#include <vcpkg/help.h>
#include <vcpkg/metrics.h>

#define STRINGIFY(...) #__VA_ARGS__
#define MACRO_TO_STRING(X) STRINGIFY(X)

#if defined(VCPKG_VERSION)
#define VCPKG_VERSION_AS_STRING MACRO_TO_STRING(VCPKG_VERSION)
#else
#define VCPKG_VERSION_AS_STRING "-unknownhash"
#endif

namespace vcpkg::Commands::Version
{
    const char* base_version()
    {
        return
#include "../VERSION.txt"
            ;
    }

    const std::string& version()
    {
        static const std::string S_VERSION =
#include "../VERSION.txt"

            +std::string(VCPKG_VERSION_AS_STRING)
#ifndef NDEBUG
            + std::string("-debug")
#endif
            + std::string(Metrics::get_compiled_metrics_enabled() ? "" : "-external");
        return S_VERSION;
    }

    static int scan3(const char* input, const char* pattern, int* a, int* b, int* c)
    {
#if defined(_WIN32)
        return sscanf_s(input, pattern, a, b, c);
#else
        return sscanf(input, pattern, a, b, c);
#endif
    }

    void warn_if_vcpkg_version_mismatch(const VcpkgPaths& paths)
    {
        auto version_file = paths.get_filesystem().read_contents(paths.root / "toolsrc" / "VERSION.txt");
        if (const auto version_contents = version_file.get())
        {
            int maj1, min1, rev1;
            const auto num1 = scan3(version_contents->c_str(), "\"%d.%d.%d\"", &maj1, &min1, &rev1);

            int maj2, min2, rev2;
            const auto num2 = scan3(Version::version().c_str(), "%d.%d.%d-", &maj2, &min2, &rev2);

            if (num1 == 3 && num2 == 3)
            {
                if (maj1 != maj2 || min1 != min2 || rev1 != rev2)
                {
                    System::printf(System::Color::warning,
                                   "Warning: Different source is available for vcpkg (%d.%d.%d -> %d.%d.%d). Use "
                                   ".\\bootstrap-vcpkg.bat to update.\n",
                                   maj2,
                                   min2,
                                   rev2,
                                   maj1,
                                   min1,
                                   rev1);
                }
            }
        }
    }
    const CommandStructure COMMAND_STRUCTURE = {
        Help::create_example_string("version"),
        0,
        0,
        {},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args)
    {
        Util::unused(args.parse_arguments(COMMAND_STRUCTURE));

        System::print2("Vcpkg package management program version ",
                       version(),
                       "\n"
                       "\n"
                       "See LICENSE.txt for license information.\n");
        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
