#include "pch.h"
#include "Paragraphs.h"
#include "vcpkg_Files.h"

namespace vcpkg::Paragraphs
{
    struct Parser
    {
        Parser(const char* c, const char* e) : cur(c), end(e)
        {
        }

    private:
        const char* cur;
        const char* const end;

        void peek(char& ch) const
        {
            if (cur == end)
                ch = 0;
            else
                ch = *cur;
        }

        void next(char& ch)
        {
            if (cur == end)
                ch = 0;
            else
            {
                ++cur;
                peek(ch);
            }
        }

        void skip_spaces(char& ch)
        {
            while (ch == ' ' || ch == '\t')
                next(ch);
        }

        static bool is_alphanum(char ch)
        {
            return (ch >= 'A' && ch <= 'Z')
                   || (ch >= 'a' && ch <= 'z')
                   || (ch >= '0' && ch <= '9');
        }

        static bool is_lineend(char ch)
        {
            return ch == '\r' || ch == '\n' || ch == 0;
        }

        void get_fieldvalue(char& ch, std::string& fieldvalue)
        {
            fieldvalue.clear();

            auto beginning_of_line = cur;
            do
            {
                // scan to end of current line (it is part of the field value)
                while (!is_lineend(ch))
                    next(ch);

                fieldvalue.append(beginning_of_line, cur);

                if (ch == '\r')
                    next(ch);
                if (ch == '\n')
                    next(ch);

                if (is_alphanum(ch))
                {
                    // Line begins a new field.
                    return;
                }

                beginning_of_line = cur;

                // Line may continue the current field with data or terminate the paragraph,
                // depending on first nonspace character.
                skip_spaces(ch);

                if (is_lineend(ch))
                {
                    // Line was whitespace or empty.
                    // This terminates the field and the paragraph.
                    // We leave the blank line's whitespace consumed, because it doesn't matter.
                    return;
                }

                // First nonspace is not a newline. This continues the current field value.
                // We forcibly convert all newlines into single '\n' for ease of text handling later on.
                fieldvalue.push_back('\n');
            }
            while (true);
        }

        void get_fieldname(char& ch, std::string& fieldname)
        {
            auto begin_fieldname = cur;
            while (is_alphanum(ch) || ch == '-')
                next(ch);
            Checks::check_throw(ch == ':', "Expected ':'");
            fieldname = std::string(begin_fieldname, cur);

            // skip ': '
            next(ch);
            skip_spaces(ch);
        }

        void get_paragraph(char& ch, std::unordered_map<std::string, std::string>& fields)
        {
            fields.clear();
            std::string fieldname;
            std::string fieldvalue;
            do
            {
                get_fieldname(ch, fieldname);

                auto it = fields.find(fieldname);
                Checks::check_throw(it == fields.end(), "Duplicate field");

                get_fieldvalue(ch, fieldvalue);

                fields.emplace(fieldname, fieldvalue);
            }
            while (!is_lineend(ch));
        }

    public:
        std::vector<std::unordered_map<std::string, std::string>> get_paragraphs()
        {
            std::vector<std::unordered_map<std::string, std::string>> paragraphs;

            char ch;
            peek(ch);

            while (ch != 0)
            {
                if (ch == '\n' || ch == '\r' || ch == ' ' || ch == '\t')
                {
                    next(ch);
                    continue;
                }

                paragraphs.emplace_back();
                get_paragraph(ch, paragraphs.back());
            }

            return paragraphs;
        }
    };

    std::vector<std::unordered_map<std::string, std::string>> get_paragraphs(const fs::path& control_path)
    {
        const expected<std::string> contents = Files::read_contents(control_path);
        if (auto spgh = contents.get())
        {
            return parse_paragraphs(*spgh);
        }

        Checks::exit_with_message("Error while reading %s: %s", control_path.generic_string(), contents.error_code().message());
    }

    std::vector<std::unordered_map<std::string, std::string>> parse_paragraphs(const std::string& str)
    {
        return Parser(str.c_str(), str.c_str() + str.size()).get_paragraphs();
    }
}
