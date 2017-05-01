#include "pch.h"

#include "vcpkg_Checks.h"
#include "vcpkg_Enums.h"

namespace vcpkg::Enums
{
    std::string nullvalue_to_string(const CStringView enum_name) { return Strings::format("%s_NULLVALUE", enum_name); }

    [[noreturn]] void nullvalue_used(const LineInfo& line_info, const CStringView enum_name)
    {
        Checks::exit_with_message(line_info, "NULLVALUE of enum %s was used", enum_name);
    }
}
