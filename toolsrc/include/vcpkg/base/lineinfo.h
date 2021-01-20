#pragma once

namespace vcpkg
{
    struct LineInfo
    {
        int line_number;
        const char* file_name;
    };
}

#define VCPKG_LINE_INFO                                                                                                \
    vcpkg::LineInfo { __LINE__, __FILE__ }
