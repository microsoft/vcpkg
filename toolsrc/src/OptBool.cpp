#include "pch.h"
#include "OptBool.h"
#include "vcpkg_Checks.h"

namespace vcpkg::OptBool
{
    static const std::string UNSPECIFIED_NAME = "unspecified";
    static const std::string ENABLED_NAME = "enabled";
    static const std::string DISABLED_NAME = "disabled";
    Type parse(const std::string& s)
    {
        if (s == UNSPECIFIED_NAME)
        {
            return OptBoolT::UNSPECIFIED;
        }

        if (s == ENABLED_NAME)
        {
            return OptBoolT::ENABLED;
        }

        if (s == DISABLED_NAME)
        {
            return OptBoolT::DISABLED;
        }

        Checks::exit_with_message(VCPKG_LINE_INFO, "Could not convert string [%s] to OptBool", s);
    }
}
