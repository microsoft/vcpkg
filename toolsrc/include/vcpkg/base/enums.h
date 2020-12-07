#pragma once

#include <vcpkg/base/fwd/lineinfo.h>

#include <vcpkg/base/cstringview.h>

namespace vcpkg::Enums
{
    std::string nullvalue_to_string(const CStringView enum_name);

    [[noreturn]] void nullvalue_used(const LineInfo& line_info, const CStringView enum_name);
}
