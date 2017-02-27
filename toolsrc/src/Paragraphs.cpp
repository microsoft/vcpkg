#include "pch.h"
#include "Paragraphs.h"
#include "vcpkg_Files.h"

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
            Checks::check_exit(ch == ':', "Expected ':'");
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
                Checks::check_exit(it == fields.end(), "Duplicate field");

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

    expected<SourceParagraph> try_load_port(const fs::path& path)
    {
        try
        {
            auto pghs = get_paragraphs(path / "CONTROL");
            Checks::check_exit(pghs.size() == 1, "Invalid control file at %s\\CONTROL", path.string());
            return SourceParagraph(pghs[0]);
        }
        catch (std::runtime_error const&) {}

        return std::errc::no_such_file_or_directory;
    }

    expected<BinaryParagraph> try_load_cached_package(const vcpkg_paths& paths, const package_spec& spec)
    {
        const fs::path path = paths.package_dir(spec) / "CONTROL";

        auto control_contents_maybe = Files::read_contents(path);
        if (auto control_contents = control_contents_maybe.get())
        {
            std::vector<std::unordered_map<std::string, std::string>> pghs;
            try
            {
                pghs = parse_paragraphs(*control_contents);
            }
            catch (std::runtime_error) {}
            Checks::check_exit(pghs.size() == 1, "Invalid control file at %s", path.string());
            return BinaryParagraph(pghs[0]);
        }
        return control_contents_maybe.error_code();
    }

    std::vector<SourceParagraph> load_all_ports(const fs::path& ports_dir)
    {
        std::vector<SourceParagraph> output;
        for (auto it = fs::directory_iterator(ports_dir); it != fs::directory_iterator(); ++it)
        {
            const fs::path& path = it->path();
            expected<SourceParagraph> source_paragraph = try_load_port(path);
            if (auto srcpgh = source_paragraph.get())
            {
                output.emplace_back(std::move(*srcpgh));
            }
            else
            {
                Checks::exit_with_message("Error loading port from %s: %s", path.generic_string(), source_paragraph.error_code().message());
            }
        }

        return output;
    }
}
