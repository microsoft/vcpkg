#include "pch.h"

#include <vcpkg/base/files.h>
#include <vcpkg/base/system.debug.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/util.h>
#include <vcpkg/paragraphparseresult.h>
#include <vcpkg/paragraphs.h>

using namespace vcpkg::Parse;

namespace vcpkg::Paragraphs
{
    struct Parser
    {
        Parser(const char* c, const char* e) : cur(c), end(e) {}

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
            if (ch == '\r') next(ch);
            if (ch == '\n') next(ch);
        }

        void skip_spaces(char& ch)
        {
            while (ch == ' ' || ch == '\t')
                next(ch);
        }

        static bool is_alphanum(char ch)
        {
            return (ch >= 'A' && ch <= 'Z') || (ch >= 'a' && ch <= 'z') || (ch >= '0' && ch <= '9');
        }

        static bool is_comment(char ch) { return (ch == '#'); }

        static bool is_lineend(char ch) { return ch == '\r' || ch == '\n' || ch == 0; }

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

                if (ch == '\r') next(ch);
                if (ch == '\n') next(ch);

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
            } while (true);
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
            } while (!is_lineend(ch));
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

    Expected<std::unordered_map<std::string, std::string>> get_single_paragraph(const Files::Filesystem& fs,
                                                                                const fs::path& control_path)
    {
        const Expected<std::string> contents = fs.read_contents(control_path);
        if (auto spgh = contents.get())
        {
            return parse_single_paragraph(*spgh);
        }

        return contents.error();
    }

    Expected<std::vector<std::unordered_map<std::string, std::string>>> get_paragraphs(const Files::Filesystem& fs,
                                                                                       const fs::path& control_path)
    {
        const Expected<std::string> contents = fs.read_contents(control_path);
        if (auto spgh = contents.get())
        {
            return parse_paragraphs(*spgh);
        }

        return contents.error();
    }

    Expected<std::unordered_map<std::string, std::string>> parse_single_paragraph(const std::string& str)
    {
        const std::vector<std::unordered_map<std::string, std::string>> p =
            Parser(str.c_str(), str.c_str() + str.size()).get_paragraphs();

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

    ParseExpected<SourceControlFile> try_load_port(const Files::Filesystem& fs, const fs::path& path)
    {
        Expected<std::vector<std::unordered_map<std::string, std::string>>> pghs = get_paragraphs(fs, path / "CONTROL");
        if (auto vector_pghs = pghs.get())
        {
            return SourceControlFile::parse_control_file(std::move(*vector_pghs));
        }
        auto error_info = std::make_unique<ParseControlErrorInfo>();
        error_info->name = path.filename().generic_u8string();
        error_info->error = pghs.error();
        return error_info;
    }

    Expected<BinaryControlFile> try_load_cached_package(const VcpkgPaths& paths, const PackageSpec& spec)
    {
        Expected<std::vector<std::unordered_map<std::string, std::string>>> pghs =
            get_paragraphs(paths.get_filesystem(), paths.package_dir(spec) / "CONTROL");

        if (auto p = pghs.get())
        {
            BinaryControlFile bcf;
            bcf.core_paragraph = BinaryParagraph(p->front());
            p->erase(p->begin());

            bcf.features =
                Util::fmap(*p, [&](auto&& raw_feature) -> BinaryParagraph { return BinaryParagraph(raw_feature); });

            return bcf;
        }

        return pghs.error();
    }

    LoadResults try_load_all_ports(const Files::Filesystem& fs, const fs::path& ports_dir)
    {
        LoadResults ret;
        auto port_dirs = fs.get_files_non_recursive(ports_dir);
        Util::sort(port_dirs);
        Util::erase_remove_if(port_dirs, [&](auto&& port_dir_entry) {
            return fs.is_regular_file(port_dir_entry) && port_dir_entry.filename() == ".DS_Store";
        });

        for (auto&& path : port_dirs)
        {
            auto maybe_spgh = try_load_port(fs, path);
            if (const auto spgh = maybe_spgh.get())
            {
                ret.paragraphs.emplace_back(std::move(*spgh));
            }
            else
            {
                ret.errors.emplace_back(std::move(maybe_spgh).error());
            }
        }
        return ret;
    }

    std::vector<std::unique_ptr<SourceControlFile>> load_all_ports(const Files::Filesystem& fs,
                                                                   const fs::path& ports_dir)
    {
        auto results = try_load_all_ports(fs, ports_dir);
        if (!results.errors.empty())
        {
            if (Debug::g_debugging)
            {
                print_error_message(results.errors);
            }
            else
            {
                for (auto&& error : results.errors)
                {
                    System::print2(
                        System::Color::warning, "Warning: an error occurred while parsing '", error->name, "'\n");
                }
                System::print2(System::Color::warning,
                               "Use '--debug' to get more information about the parse failures.\n\n");
            }
        }
        return std::move(results.paragraphs);
    }
}
