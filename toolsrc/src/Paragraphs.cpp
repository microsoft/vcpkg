#include "pch.h"

#include "ParagraphParseResult.h"
#include "Paragraphs.h"
#include "vcpkg_Files.h"
#include "vcpkg_GlobalState.h"
#include "vcpkg_Util.h"

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
            auto csf = SourceControlFile::parse_control_file(std::move(*vector_pghs));
            if (!GlobalState::feature_packages)
            {
                if (auto ptr = csf.get())
                {
                    Checks::check_exit(VCPKG_LINE_INFO, ptr->get() != nullptr);
                    ptr->get()->core_paragraph->default_features.clear();
                    ptr->get()->feature_paragraphs.clear();
                }
            }
            return csf;
        }
        auto error_info = std::make_unique<ParseControlErrorInfo>();
        error_info->name = path.filename().generic_u8string();
        error_info->error = pghs.error();
        return error_info;
    }

    Expected<BinaryControlFile> try_load_cached_control_package(const VcpkgPaths& paths, const PackageSpec& spec)
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
        for (auto&& path : fs.get_files_non_recursive(ports_dir))
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
            if (GlobalState::debugging)
            {
                print_error_message(results.errors);
            }
            else
            {
                for (auto&& error : results.errors)
                {
                    System::println(
                        System::Color::warning, "Warning: an error occurred while parsing '%s'", error->name);
                }
                System::println(System::Color::warning,
                                "Use '--debug' to get more information about the parse failures.\n");
            }
        }
        return std::move(results.paragraphs);
    }

    std::map<std::string, VersionT> load_all_port_names_and_versions(const Files::Filesystem& fs,
                                                                     const fs::path& ports_dir)
    {
        auto all_ports = load_all_ports(fs, ports_dir);

        std::map<std::string, VersionT> names_and_versions;
        for (auto&& port : all_ports)
            names_and_versions.emplace(port->core_paragraph->name, port->core_paragraph->version);

        return names_and_versions;
    }
}
