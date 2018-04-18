#pragma once

#include <string>

namespace vcpkg
{
    struct LineInfo
    {
        int line_number;
        const char* file_name;

        constexpr LineInfo() noexcept : line_number(0), file_name("") {}
        constexpr LineInfo(const int lineno, const char* filename) : line_number(lineno), file_name(filename) {}

        std::string to_string() const;
    };
}

#define VCPKG_LINE_INFO vcpkg::LineInfo(__LINE__, __FILE__)
