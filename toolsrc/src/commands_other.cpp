#include "vcpkg_Commands.h"
#include "vcpkg_System.h"
#include "vcpkg.h"

namespace vcpkg
{
    void print_usage()
    {
        System::println(
            "Commands:\n"
            "  vcpkg search [pat]              Search for packages available to be built\n"
            "  vcpkg install <pkg>             Install a package\n"
            "  vcpkg remove <pkg>              Uninstall a package. \n"
            "  vcpkg remove --purge <pkg>      Uninstall and delete a package. \n"
            "  vcpkg list                      List installed packages\n"
            "  vcpkg update                    Display list of packages for updating\n"
            "\n"
            "%s" // Integration help
            "\n"
            "  vcpkg edit <pkg>                Open up a port for editing (uses %%EDITOR%%, default 'code')\n"
            "  vcpkg import <pkg>              Import a pre-built library\n"
            "  vcpkg create <pkg> <url>\n"
            "             [archivename]        Create a new package\n"
            "  vcpkg owns <pat>                Search for files in installed packages\n"
            "  vcpkg cache                     List cached compiled packages\n"
            "  vcpkg version                   Display version information\n"
            "  vcpkg contact                   Display contact information to send feedback\n"
            "\n"
            //"internal commands:\n"
            //"  --check-build-deps <controlfile>\n"
            //"  --create-binary-control <controlfile>\n"
            //"\n"
            "Options:\n"
            "  --triplet <t>                   Specify the target architecture triplet.\n"
            "                                  (default: %%VCPKG_DEFAULT_TRIPLET%%, see 'vcpkg help triplet')\n"
            "\n"
            "  --vcpkg-root <path>             Specify the vcpkg root directory\n"
            "                                  (default: %%VCPKG_ROOT%%)\n"
            "\n"
            "For more help (including examples) see the accompanying README.md."
            , INTEGRATE_COMMAND_HELPSTRING);
    }

    std::string create_example_string(const char* command_and_arguments)
    {
        std::string cs = Strings::format("Example:\n"
                                         "  vcpkg %s", command_and_arguments);
        return cs;
    }

    void print_example(const char* command_and_arguments)
    {
        System::println(create_example_string(command_and_arguments).c_str());
    }

    void internal_test_command(const vcpkg_cmd_arguments& /*args*/, const vcpkg_paths& /*paths*/)
    {
        //        auto data = FormatEventData("test");
        //        Track(data);
        exit(EXIT_SUCCESS);
    }

    const std::vector<package_name_and_function<command_type_a>>& get_available_commands_type_a()
    {
        static std::vector<package_name_and_function<command_type_a>> t = {
            {"install", install_command},
            {"remove", remove_command},
            {"build", build_command},
            {"build_external", build_external_command}
        };
        return t;
    }

    const std::vector<package_name_and_function<command_type_b>>& get_available_commands_type_b()
    {
        static std::vector<package_name_and_function<command_type_b>> t = {
            {"help", help_command},
            {"search", search_command},
            {"list", list_command},
            {"integrate", integrate_command},
            {"owns", owns_command},
            {"update", update_command},
            {"edit", edit_command},
            {"create", create_command},
            {"import", import_command},
            {"cache", cache_command},
            {"internal_test", internal_test_command},
        };
        return t;
    }

    const std::vector<package_name_and_function<command_type_c>>& get_available_commands_type_c()
    {
        static std::vector<package_name_and_function<command_type_c>> t = {
            {"version", &version_command},
            {"contact", &contact_command}
        };
        return t;
    }
}
