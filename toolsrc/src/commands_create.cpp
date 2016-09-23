#include "vcpkg_Commands.h"
#include "vcpkg_System.h"
#include "vcpkg_Environment.h"

namespace vcpkg
{
    void create_command(const vcpkg_cmd_arguments& args, const vcpkg_paths& paths, const triplet& default_target_triplet)
    {
        args.check_max_args(3);
        package_spec spec = args.parse_all_arguments_as_package_specs(paths, default_target_triplet).at(0);
        if (args.command_arguments.size() < 2)
        {
            System::println(System::color::error, "Error: create requires the archive's URL as the second argument.");
            print_usage();
            exit(EXIT_FAILURE);
        }
        Environment::ensure_utilities_on_path(paths);

        // Space OR define the FILENAME with proper spacing
        std::wstring custom_filename = L" ";
        if (args.command_arguments.size() >= 3)
        {
            custom_filename = Strings::format(L" -DFILENAME=%s ", Strings::utf8_to_utf16(args.command_arguments.at(2)));
        }

        const std::wstring cmdline = Strings::format(LR"(cmake -DCMD=SCAFFOLD -DPORT=%s -DTARGET_TRIPLET=%s -DURL=%s%s-P "%s")",
                                                     Strings::utf8_to_utf16(spec.name),
                                                     Strings::utf8_to_utf16(spec.target_triplet.value),
                                                     Strings::utf8_to_utf16(args.command_arguments.at(1)),
                                                     custom_filename,
                                                     paths.ports_cmake.generic_wstring());

        exit(System::cmd_execute(cmdline));
    }
}
