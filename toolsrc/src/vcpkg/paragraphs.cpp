#include "pch.h"

#include <vcpkg/base/files.h>
#include <vcpkg/base/system.debug.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/util.h>
#include <vcpkg/binaryparagraph.h>
#include <vcpkg/paragraphparseresult.h>
#include <vcpkg/paragraphs.h>
#include <vcpkg/parse.h>

using namespace vcpkg::Parse;
using namespace vcpkg;

namespace vcpkg::Paragraphs
{
    struct PghParser : private Parse::ParserBase
    {
    private:
        void get_fieldvalue(std::string& fieldvalue)
        {
            fieldvalue.clear();

            do
            {
                // scan to end of current line (it is part of the field value)
                Strings::append(fieldvalue, match_until(is_lineend));
                skip_newline();

                if (cur() != ' ') return;
                auto spacing = skip_tabs_spaces();
                if (is_lineend(cur())) return add_error("unexpected end of line, to span a blank line use \"  .\"");
                Strings::append(fieldvalue, "\n", spacing);
            } while (true);
        }

        void get_fieldname(std::string& fieldname)
        {
            fieldname = match_zero_or_more(is_alphanumdash).to_string();
            if (fieldname.empty()) return add_error("expected fieldname");
        }

        void get_paragraph(RawParagraph& fields)
        {
            fields.clear();
            std::string fieldname;
            std::string fieldvalue;
            do
            {
                if (cur() == '#')
                {
                    skip_line();
                    continue;
                }

                auto loc = cur_loc();
                get_fieldname(fieldname);
                if (cur() != ':') return add_error("expected ':' after field name");
                if (Util::Sets::contains(fields, fieldname)) return add_error("duplicate field", loc);
                next();
                skip_tabs_spaces();

                get_fieldvalue(fieldvalue);

                fields.emplace(fieldname, fieldvalue);
            } while (!is_lineend(cur()));
        }

    public:
        ExpectedS<std::vector<RawParagraph>> get_paragraphs(CStringView text, CStringView origin)
        {
            std::vector<RawParagraph> paragraphs;

            init(text, origin);

            skip_whitespace();
            while (!at_eof())
            {
                paragraphs.emplace_back();
                get_paragraph(paragraphs.back());
                match_zero_or_more(is_lineend);
            }
            if (get_error()) return get_error()->format();

            return paragraphs;
        }
    };

    static ExpectedS<RawParagraph> parse_single_paragraph(const std::string& str, const std::string& origin)
    {
        PghParser parser;
        auto pghs = parser.get_paragraphs(str, origin);

        if (auto p = pghs.get())
        {
            if (p->size() != 1) return std::error_code(ParagraphParseResult::EXPECTED_ONE_PARAGRAPH).message();
            return std::move(p->front());
        }
        else
        {
            return pghs.error();
        }
    }

    ExpectedS<RawParagraph> get_single_paragraph(const Files::Filesystem& fs, const fs::path& control_path)
    {
        const Expected<std::string> contents = fs.read_contents(control_path);
        if (auto spgh = contents.get())
        {
            return parse_single_paragraph(*spgh, control_path.u8string());
        }

        return contents.error().message();
    }

    ExpectedS<std::vector<RawParagraph>> get_paragraphs(const Files::Filesystem& fs, const fs::path& control_path)
    {
        const Expected<std::string> contents = fs.read_contents(control_path);
        if (auto spgh = contents.get())
        {
            return parse_paragraphs(*spgh, control_path.u8string());
        }

        return contents.error().message();
    }

    ExpectedS<std::vector<RawParagraph>> parse_paragraphs(const std::string& str, const std::string& origin)
    {
        PghParser parser;
        return parser.get_paragraphs(str, origin);
    }

    ParseExpected<SourceControlFile> try_load_port(const Files::Filesystem& fs, const fs::path& path)
    {
        const auto path_to_control = path / "CONTROL";
        ExpectedS<std::vector<RawParagraph>> pghs = get_paragraphs(fs, path_to_control);
        if (auto vector_pghs = pghs.get())
        {
            return SourceControlFile::parse_control_file(path_to_control, std::move(*vector_pghs));
        }
        auto error_info = std::make_unique<ParseControlErrorInfo>();
        error_info->name = path.filename().generic_u8string();
        error_info->error = pghs.error();
        return error_info;
    }

    ExpectedS<BinaryControlFile> try_load_cached_package(const VcpkgPaths& paths, const PackageSpec& spec)
    {
        ExpectedS<std::vector<RawParagraph>> pghs =
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
