#pragma once

#include <string>

namespace vcpkg
{
    struct LineInfo
    {
        constexpr LineInfo() noexcept : m_line_number(0), m_file_name("") { }
        constexpr LineInfo(const int lineno, const char* filename) : m_line_number(lineno), m_file_name(filename) { }

        std::string to_string() const;
        void to_string(std::string& out) const;

    private:
        int m_line_number;
        const char* m_file_name;
    };
}

#define VCPKG_LINE_INFO vcpkg::LineInfo(__LINE__, __FILE__)
