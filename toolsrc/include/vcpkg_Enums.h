#pragma once
#include <string>
#include "LineInfo.h"

namespace vcpkg::Enums
{
    std::string nullvalue_toString(const std::string& enum_name);

    [[noreturn]]
    void nullvalue_used(const LineInfo& line_info, const std::string& enum_name);
}
