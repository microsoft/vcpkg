#pragma once

namespace vcpkg
{
    struct LineInfo
    {
        int line_number;
        const char* file_name;

        constexpr LineInfo() : line_number(0), file_name(nullptr) {}
        constexpr LineInfo(const int line_number, const char* file_name) : line_number(line_number), file_name(file_name) {}

        std::string toString() const;
    };
}

#define VCPKG_LINE_INFO vcpkg::LineInfo(__LINE__, __FILE__)
