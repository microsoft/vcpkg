#include <vcpkg/base/strings.h>
#include <vcpkg/base/xmlserializer.h>

namespace vcpkg
{
    XmlSerializer& XmlSerializer::emit_declaration()
    {
        buf.append(R"(<?xml version="1.0" encoding="utf-8"?>)");
        return *this;
    }
    XmlSerializer& XmlSerializer::open_tag(StringLiteral sl)
    {
        emit_pending_indent();
        Strings::append(buf, '<', sl, '>');
        m_indent += 2;
        return *this;
    }
    XmlSerializer& XmlSerializer::start_complex_open_tag(StringLiteral sl)
    {
        emit_pending_indent();
        Strings::append(buf, '<', sl);
        m_indent += 2;
        return *this;
    }
    XmlSerializer& XmlSerializer::text_attr(StringLiteral name, StringView content)
    {
        if (m_pending_indent)
        {
            m_pending_indent = false;
            buf.append(m_indent, ' ');
        }
        else
        {
            buf.push_back(' ');
        }
        Strings::append(buf, name, "=\"");
        text(content);
        Strings::append(buf, '"');
        return *this;
    }
    XmlSerializer& XmlSerializer::finish_complex_open_tag()
    {
        emit_pending_indent();
        Strings::append(buf, '>');
        return *this;
    }
    XmlSerializer& XmlSerializer::finish_self_closing_complex_tag()
    {
        emit_pending_indent();
        Strings::append(buf, "/>");
        m_indent -= 2;
        return *this;
    }
    XmlSerializer& XmlSerializer::close_tag(StringLiteral sl)
    {
        m_indent -= 2;
        emit_pending_indent();
        Strings::append(buf, "</", sl, '>');
        return *this;
    }
    XmlSerializer& XmlSerializer::text(StringView sv)
    {
        emit_pending_indent();
        for (auto ch : sv)
        {
            if (ch == '&')
            {
                buf.append("&amp;");
            }
            else if (ch == '<')
            {
                buf.append("&lt;");
            }
            else if (ch == '>')
            {
                buf.append("&gt;");
            }
            else if (ch == '"')
            {
                buf.append("&quot;");
            }
            else if (ch == '\'')
            {
                buf.append("&apos;");
            }
            else
            {
                buf.push_back(ch);
            }
        }
        return *this;
    }
    XmlSerializer& XmlSerializer::simple_tag(StringLiteral tag, StringView content)
    {
        return emit_pending_indent().open_tag(tag).text(content).close_tag(tag);
    }
    XmlSerializer& XmlSerializer::line_break()
    {
        buf.push_back('\n');
        m_pending_indent = true;
        return *this;
    }
    XmlSerializer& XmlSerializer::emit_pending_indent()
    {
        if (m_pending_indent)
        {
            m_pending_indent = false;
            buf.append(m_indent, ' ');
        }
        return *this;
    }

}
