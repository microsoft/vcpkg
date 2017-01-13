#include "vcpkg_Commands.h"

namespace vcpkg::Commands
{
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
            {"/?", help_command},
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
            {"portsdiff", portsdiff_command}
        };
        return t;
    }

    const std::vector<package_name_and_function<command_type_c>>& get_available_commands_type_c()
    {
        static std::vector<package_name_and_function<command_type_c>> t = {
            {"version", &version_command},
            {"contact", &contact_command},
            {"hash", &hash_command},
        };
        return t;
    }
}
