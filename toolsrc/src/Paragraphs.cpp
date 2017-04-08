#include "pch.h"
#include "Paragraphs.h"
#include "vcpkg_Files.h"
#include "ParagraphParseResult.h"

namespace vcpkg::Paragraphs
{
    struct Parser
    {
        Parser(const char* c, const char* e) : cur(c), end(e) { }

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

        void skip_comment(char& ch)
        {
            while (ch != '\r' && ch != '\n' && ch != '\0')
                next(ch);
            if (ch == '\r')
                next(ch);
            if (ch == '\n')
                next(ch);
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

        static bool is_comment(char ch)
        {
            return (ch == '#');
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

                if (is_alphanum(ch) || is_comment(ch))
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
            Checks::check_exit(VCPKG_LINE_INFO, ch == ':', "Expected ':'");
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
                if (is_comment(ch))
                {
                    skip_comment(ch);
                    continue;
                }

                get_fieldname(ch, fieldname);

                auto it = fields.find(fieldname);
                Checks::check_exit(VCPKG_LINE_INFO, it == fields.end(), "Duplicate field");

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

    Expected<std::unordered_map<std::string, std::string>> get_single_paragraph(Files::Filesystem& fs, const fs::path& control_path)
    {
        const Expected<std::string> contents = fs.read_contents(control_path);
        if (auto spgh = contents.get())
        {
            return parse_single_paragraph(*spgh);
        }

        return contents.error_code();
    }

    Expected<std::vector<std::unordered_map<std::string, std::string>>> get_paragraphs(Files::Filesystem& fs, const fs::path& control_path)
    {
        const Expected<std::string> contents = fs.read_contents(control_path);
        if (auto spgh = contents.get())
        {
            return parse_paragraphs(*spgh);
        }

        return contents.error_code();
    }

    Expected<std::unordered_map<std::string, std::string>> parse_single_paragraph(const std::string& str)
    {
        const std::vector<std::unordered_map<std::string, std::string>> p = Parser(str.c_str(), str.c_str() + str.size()).get_paragraphs();

        if (p.size() == 1)
        {
            return p.at(0);
        }

        return std::error_code(ParagraphParseResult::EXPECTED_ONE_PARAGRAPH);
    }

    Expected<std::vector<std::unordered_map<std::string, std::string>>> parse_paragraphs(const std::string& str)
    {
        return Parser(str.c_str(), str.c_str() + str.size()).get_paragraphs();
    }

    Expected<SourceParagraph> try_load_port(Files::Filesystem& fs, const fs::path& path)
    {
        Expected<std::unordered_map<std::string, std::string>> pghs = get_single_paragraph(fs, path / "CONTROL");
        if (auto p = pghs.get())
        {
            return SourceParagraph(*p);
        }

        return pghs.error_code();
    }

    Expected<BinaryParagraph> try_load_cached_package(const VcpkgPaths& paths, const PackageSpec& spec)
    {
        Expected<std::unordered_map<std::string, std::string>> pghs = get_single_paragraph(paths.get_filesystem(), paths.package_dir(spec) / "CONTROL");

        if (auto p = pghs.get())
        {
            return BinaryParagraph(*p);
        }

        return pghs.error_code();
    }

    std::vector<SourceParagraph> load_all_ports(Files::Filesystem& fs, const fs::path& ports_dir)
    {
        std::vector<SourceParagraph> output;
        for (auto it = fs::directory_iterator(ports_dir); it != fs::directory_iterator(); ++it)
        {
            const fs::path& path = it->path();
            Expected<SourceParagraph> source_paragraph = try_load_port(fs, path);
            if (auto srcpgh = source_paragraph.get())
            {
                output.emplace_back(std::move(*srcpgh));
            }
        }

        return output;
    }

    std::map<std::string, VersionT> extract_port_names_and_versions(const std::vector<SourceParagraph>& source_paragraphs)
    {
        std::map<std::string, VersionT> names_and_versions;
        for (const SourceParagraph& port : source_paragraphs)
        {
            names_and_versions.emplace(port.name, port.version);
        }

        return names_and_versions;
    }
}
