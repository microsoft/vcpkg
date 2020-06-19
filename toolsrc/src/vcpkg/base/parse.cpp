#include "pch.h"

#include <vcpkg/base/parse.h>

#include <utility>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/util.h>
#include <vcpkg/packagespec.h>
#include <vcpkg/paragraphparser.h>

using namespace vcpkg;

namespace vcpkg::Parse
{
    static void advance_rowcol(char32_t ch, int& row, int& column)
    {
        if (ch == '\t')
            column = (column + 7) / 8 * 8 + 1; // round to next 8-width tab stop
        else if (ch == '\n')
        {
            row++;
            column = 1;
        }
        else
        {
            ++column;
        }
    }

    std::string ParseError::format() const
    {
        auto caret_spacing = std::string(18, ' ');
        auto decoder = Unicode::Utf8Decoder(line.data(), line.data() + line.size());
        for (int i = 0; i < caret_col; ++i, ++decoder)
        {
            const char32_t cp = *decoder;
            // this may eventually want to check for full-width characters and grapheme clusters as well
            caret_spacing.push_back(cp == '\t' ? '\t' : ' ');
        }

        return Strings::concat("Error: ",
                               origin,
                               ":",
                               row,
                               ":",
                               column,
                               ": ",
                               message,
                               "\n"
                               "   on expression: ", // 18 columns
                               line,
                               "\n",
                               caret_spacing,
                               "^\n");
    }

    ParserBase::ParserBase(StringView text, StringView origin, TextRowCol init_rowcol)
        : m_it(text.begin(), text.end())
        , m_start_of_line(m_it)
        , m_row(init_rowcol.row_or(1))
        , m_column(init_rowcol.column_or(1))
        , m_text(text)
        , m_origin(origin)
    {
    }

    char32_t ParserBase::next()
    {
        if (m_it == m_it.end())
        {
            return Unicode::end_of_file;
        }
        // See https://www.gnu.org/prep/standards/standards.html#Errors
        advance_rowcol(*m_it, m_row, m_column);

        ++m_it;
        if (m_it != m_it.end() && Unicode::utf16_is_surrogate_code_point(*m_it))
        {
            m_it = m_it.end();
        }

        return cur();
    }

    void ParserBase::add_error(std::string message, const SourceLoc& loc)
    {
        // avoid cascading errors by only saving the first
        if (!m_err)
        {
            // find end of line
            auto line_end = loc.it;
            while (line_end != line_end.end() && *line_end != '\n' && *line_end != '\r')
            {
                ++line_end;
            }
            m_err = std::make_unique<ParseError>(
                m_origin.to_string(),
                loc.row,
                loc.column,
                static_cast<int>(std::distance(loc.start_of_line, loc.it)),
                std::string(loc.start_of_line.pointer_to_current(), line_end.pointer_to_current()),
                std::move(message));
        }

        // Avoid error loops by skipping to the end
        skip_to_eof();
    }

    static Optional<std::pair<std::string, TextRowCol>> remove_field(Paragraph* fields, const std::string& fieldname)
    {
        auto it = fields->find(fieldname);
        if (it == fields->end())
        {
            return nullopt;
        }

        auto value = std::move(it->second);
        fields->erase(it);
        return value;
    }

    void ParagraphParser::required_field(const std::string& fieldname, std::pair<std::string&, TextRowCol&> out)
    {
        auto maybe_field = remove_field(&fields, fieldname);
        if (const auto field = maybe_field.get())
            out = std::move(*field);
        else
            missing_fields.push_back(fieldname);
    }
    void ParagraphParser::optional_field(const std::string& fieldname, std::pair<std::string&, TextRowCol&> out)
    {
        auto maybe_field = remove_field(&fields, fieldname);
        if (auto field = maybe_field.get()) out = std::move(*field);
    }
    void ParagraphParser::required_field(const std::string& fieldname, std::string& out)
    {
        TextRowCol ignore;
        required_field(fieldname, {out, ignore});
    }
    std::string ParagraphParser::optional_field(const std::string& fieldname)
    {
        std::string out;
        TextRowCol ignore;
        optional_field(fieldname, {out, ignore});
        return out;
    }

    std::unique_ptr<ParseControlErrorInfo> ParagraphParser::error_info(const std::string& name) const
    {
        if (!fields.empty() || !missing_fields.empty())
        {
            auto err = std::make_unique<ParseControlErrorInfo>();
            err->name = name;
            err->extra_fields = Util::extract_keys(fields);
            err->missing_fields = std::move(missing_fields);
            return err;
        }
        return nullptr;
    }

    template<class T, class F>
    static Optional<std::vector<T>> parse_list_until_eof(StringLiteral plural_item_name, Parse::ParserBase& parser, F f)
    {
        std::vector<T> ret;
        parser.skip_whitespace();
        if (parser.at_eof()) return std::vector<T>{};
        do
        {
            auto item = f(parser);
            if (!item) return nullopt;
            ret.push_back(std::move(item).value_or_exit(VCPKG_LINE_INFO));
            parser.skip_whitespace();
            if (parser.at_eof()) return {std::move(ret)};
            if (parser.cur() != ',')
            {
                parser.add_error(Strings::concat("expected ',' or end of text in ", plural_item_name, " list"));
                return nullopt;
            }
            parser.next();
            parser.skip_whitespace();
        } while (true);
    }

    ExpectedS<std::vector<std::string>> parse_default_features_list(const std::string& str,
                                                                    StringView origin,
                                                                    TextRowCol textrowcol)
    {
        auto parser = Parse::ParserBase(str, origin, textrowcol);
        auto opt = parse_list_until_eof<std::string>("default features", parser, &parse_feature_name);
        if (!opt) return {parser.get_error()->format(), expected_right_tag};
        return {std::move(opt).value_or_exit(VCPKG_LINE_INFO), expected_left_tag};
    }
    ExpectedS<std::vector<ParsedQualifiedSpecifier>> parse_qualified_specifier_list(const std::string& str,
                                                                                    StringView origin,
                                                                                    TextRowCol textrowcol)
    {
        auto parser = Parse::ParserBase(str, origin, textrowcol);
        auto opt = parse_list_until_eof<ParsedQualifiedSpecifier>(
            "dependencies", parser, [](ParserBase& parser) { return parse_qualified_specifier(parser); });
        if (!opt) return {parser.get_error()->format(), expected_right_tag};

        return {std::move(opt).value_or_exit(VCPKG_LINE_INFO), expected_left_tag};
    }
    ExpectedS<std::vector<Dependency>> parse_dependencies_list(const std::string& str,
                                                               StringView origin,
                                                               TextRowCol textrowcol)
    {
        auto parser = Parse::ParserBase(str, origin, textrowcol);
        auto opt = parse_list_until_eof<Dependency>("dependencies", parser, [](ParserBase& parser) {
            auto loc = parser.cur_loc();
            return parse_qualified_specifier(parser).then([&](ParsedQualifiedSpecifier&& pqs) -> Optional<Dependency> {
                if (pqs.triplet)
                {
                    parser.add_error("triplet specifier not allowed in this context", loc);
                    return nullopt;
                }
                return Dependency{{pqs.name, pqs.features.value_or({})}, pqs.qualifier.value_or({})};
            });
        });
        if (!opt) return {parser.get_error()->format(), expected_right_tag};

        return {std::move(opt).value_or_exit(VCPKG_LINE_INFO), expected_left_tag};
    }
}
