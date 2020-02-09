#include "pch.h"

#include <utility>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/util.h>
#include <vcpkg/packagespec.h>
#include <vcpkg/paragraphparser.h>
#include <vcpkg/parse.h>

using namespace vcpkg;

namespace vcpkg::Parse
{
    std::string ParseError::format() const
    {
        return Strings::concat("Error: ",
                               origin,
                               ":",
                               row,
                               ":",
                               column,
                               ": ",
                               message,
                               "\n"
                               "   on expression: \"",
                               line,
                               "\"\n",
                               "                   ",
                               std::string(column - 1, ' '),
                               "^\n");
    }

    void ParserBase::add_error(std::string message, const ParserBase::SourceLoc& loc)
    {
        // avoid cascading errors by only saving the first
        if (!m_err)
        {
            // find beginning of line
            auto linestart = loc.it;
            while (linestart != m_text.c_str())
            {
                if (linestart[-1] == '\n') break;
                --linestart;
            }

            // find end of line
            auto lineend = loc.it;
            while (*lineend != '\n' && *lineend != '\r' && *lineend != '\0')
                ++lineend;
            m_err.reset(
                new ParseError(m_origin.c_str(), loc.row, loc.column, {linestart, lineend}, std::move(message)));
        }

        // Avoid error loops by skipping to the end
        skip_to_eof();
    }

    static Optional<std::string> remove_field(RawParagraph* fields, const std::string& fieldname)
    {
        auto it = fields->find(fieldname);
        if (it == fields->end())
        {
            return nullopt;
        }

        const std::string value = std::move(it->second);
        fields->erase(it);
        return value;
    }

    void ParagraphParser::required_field(const std::string& fieldname, std::string& out)
    {
        auto maybe_field = remove_field(&fields, fieldname);
        if (const auto field = maybe_field.get())
            out = std::move(*field);
        else
            missing_fields.push_back(fieldname);
    }
    std::string ParagraphParser::optional_field(const std::string& fieldname) const
    {
        return remove_field(&fields, fieldname).value_or("");
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

    ExpectedS<std::vector<std::string>> parse_default_features_list(const std::string& str, CStringView origin)
    {
        Parse::ParserBase parser;
        parser.init(str, origin);
        auto opt = parse_list_until_eof<std::string>("default features", parser, &parse_feature_name);
        if (!opt) return {parser.get_error()->format(), expected_right_tag};
        return {std::move(opt).value_or_exit(VCPKG_LINE_INFO), expected_left_tag};
    }
    ExpectedS<std::vector<ParsedQualifiedSpecifier>> parse_qualified_specifier_list(const std::string& str,
                                                                                    CStringView origin)
    {
        Parse::ParserBase parser;
        parser.init(str, origin);
        auto opt = parse_list_until_eof<ParsedQualifiedSpecifier>(
            "dependencies", parser, [](ParserBase& parser) { return parse_qualified_specifier(parser); });
        if (!opt) return {parser.get_error()->format(), expected_right_tag};

        return {std::move(opt).value_or_exit(VCPKG_LINE_INFO), expected_left_tag};
    }
    ExpectedS<std::vector<Dependency>> parse_dependencies_list(const std::string& str, CStringView origin)
    {
        Parse::ParserBase parser;
        parser.init(str, origin);
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
