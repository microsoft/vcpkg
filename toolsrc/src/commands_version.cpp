#include "pch.h"

#include "metrics.h"
#include "vcpkg_Commands.h"
#include "vcpkg_System.h"

#define STRINGIFY(...) #__VA_ARGS__
#define MACRO_TO_STRING(X) STRINGIFY(X)

#define VCPKG_VERSION_AS_STRING MACRO_TO_STRING(VCPKG_VERSION)

namespace vcpkg::Commands::Version
{
    const std::string& version()
    {
        static const std::string S_VERSION =
#include "../VERSION.txt"

            +std::string(VCPKG_VERSION_AS_STRING)
#ifndef NDEBUG
            + std::string("-debug")
#endif
            + std::string(Metrics::get_compiled_metrics_enabled() ? Strings::EMPTY : "-external");
        return S_VERSION;
    }

    void warn_if_vcpkg_version_mismatch(const VcpkgPaths& paths)
    {
        auto version_file = paths.get_filesystem().read_contents(paths.root / "toolsrc" / "VERSION.txt");
        if (const auto version_contents = version_file.get())
        {
            int maj1, min1, rev1;
            const auto num1 = sscanf_s(version_contents->c_str(), "\"%d.%d.%d\"", &maj1, &min1, &rev1);

            int maj2, min2, rev2;
            const auto num2 = sscanf_s(Version::version().c_str(), "%d.%d.%d-", &maj2, &min2, &rev2);

            if (num1 == 3 && num2 == 3)
            {
                if (maj1 != maj2 || min1 != min2 || rev1 != rev2)
                {
                    System::println(System::Color::warning,
                                    "Warning: Different source is available for vcpkg (%d.%d.%d -> %d.%d.%d). Use "
                                    ".\\bootstrap-vcpkg.bat to update.",
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

    void perform_and_exit(const VcpkgCmdArguments& args)
    {
        args.check_exact_arg_count(0);
        args.check_and_get_optional_command_arguments({});

        System::println("Vcpkg package management program version %s\n"
                        "\n"
                        "See LICENSE.txt for license information.",
                        version());
        Checks::exit_success(VCPKG_LINE_INFO);
    }
}
