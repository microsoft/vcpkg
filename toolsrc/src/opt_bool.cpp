#include "pch.h"
#include "opt_bool.h"
#include "vcpkg_Checks.h"

namespace vcpkg::opt_bool
{
    static const std::string UNSPECIFIED_NAME = "unspecified";
    static const std::string ENABLED_NAME = "enabled";
    static const std::string DISABLED_NAME = "disabled";
    type parse(const std::string& s)
    {
        if (s == UNSPECIFIED_NAME)
        {
            return opt_bool_t::UNSPECIFIED;
        }

        if (s == ENABLED_NAME)
        {
            return opt_bool_t::ENABLED;
        }

        if (s == DISABLED_NAME)
        {
            return opt_bool_t::DISABLED;
        }

        Checks::exit_with_message("Could not convert string [%s] to opt_bool", s);
    }
}
