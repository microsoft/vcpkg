#pragma once

#include <vcpkg/base/stringliteral.h>
#include <vcpkg/base/stringview.h>

#include <string>

namespace vcpkg
{
    struct XmlSerializer
    {
        XmlSerializer& emit_declaration();
        XmlSerializer& open_tag(StringLiteral sl);
        XmlSerializer& start_complex_open_tag(StringLiteral sl);
        XmlSerializer& text_attr(StringLiteral name, StringView content);
        XmlSerializer& finish_complex_open_tag();
        XmlSerializer& finish_self_closing_complex_tag();
        XmlSerializer& close_tag(StringLiteral sl);
        XmlSerializer& text(StringView sv);
        XmlSerializer& simple_tag(StringLiteral tag, StringView content);
        XmlSerializer& line_break();

        std::string buf;

    private:
        XmlSerializer& emit_pending_indent();

        int m_indent = 0;
        bool m_pending_indent = false;
    };
}
