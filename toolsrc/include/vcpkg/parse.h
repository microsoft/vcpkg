#pragma once

#include <vcpkg/base/cstringview.h>
#include <vcpkg/base/optional.h>
#include <vcpkg/base/stringview.h>
#include <vcpkg/textrowcol.h>

#include <memory>
#include <string>

namespace vcpkg::Parse
{
    struct IParseError
    {
        virtual ~IParseError() = default;
        virtual std::string format() const = 0;
    };

    struct ParseError : IParseError
    {
        ParseError(std::string origin, int row, int column, int caret_col, std::string line, std::string message)
            : origin(std::move(origin))
            , row(row)
            , column(column)
            , caret_col(caret_col)
            , line(std::move(line))
            , message(std::move(message))
        {
        }

        const std::string origin;
        const int row;
        const int column;
        const int caret_col;
        const std::string line;
        const std::string message;

        virtual std::string format() const override;
    };

    struct ParserBase
    {
        struct SourceLoc
        {
            const char* it;
            int row;
            int column;
        };

        void init(CStringView text, CStringView origin, TextRowCol init_rowcol = {})
        {
            m_text = text;
            m_origin = origin;
            m_it = text.c_str();
            row = init_rowcol.row ? init_rowcol.row : 1;
            column = init_rowcol.column ? init_rowcol.column : 1;
        }

        static constexpr bool is_whitespace(char ch) { return ch == ' ' || ch == '\t' || ch == '\r' || ch == '\n'; }
        static constexpr bool is_lower_alpha(char ch) { return ch >= 'a' && ch <= 'z'; }
        static constexpr bool is_upper_alpha(char ch) { return ch >= 'A' && ch <= 'Z'; }
        static constexpr bool is_ascii_digit(char ch) { return ch >= '0' && ch <= '9'; }
        static constexpr bool is_lineend(char ch) { return ch == '\r' || ch == '\n' || ch == '\0'; }
        static constexpr bool is_alphanum(char ch)
        {
            return is_upper_alpha(ch) || is_lower_alpha(ch) || is_ascii_digit(ch);
        }
        static constexpr bool is_alphanumdash(char ch) { return is_alphanum(ch) || ch == '-'; }

        StringView skip_whitespace() { return match_zero_or_more(is_whitespace); }
        StringView skip_tabs_spaces()
        {
            return match_zero_or_more([](char ch) { return ch == ' ' || ch == '\t'; });
        }
        void skip_to_eof()
        {
            while (cur())
                ++m_it;
        }
        void skip_newline()
        {
            if (cur() == '\r') next();
            if (cur() == '\n') next();
        }
        void skip_line()
        {
            match_until(is_lineend);
            skip_newline();
        }

        template<class Pred>
        StringView match_zero_or_more(Pred p)
        {
            const char* start = m_it;
            auto ch = cur();
            while (ch != '\0' && p(ch))
                ch = next();
            return {start, m_it};
        }
        template<class Pred>
        StringView match_until(Pred p)
        {
            const char* start = m_it;
            auto ch = cur();
            while (ch != '\0' && !p(ch))
                ch = next();
            return {start, m_it};
        }

        CStringView text() const { return m_text; }
        const char* it() const { return m_it; }
        char cur() const { return *m_it; }
        SourceLoc cur_loc() const { return {m_it, row, column}; }
        TextRowCol cur_rowcol() const { return {row, column}; }
        char next();
        bool at_eof() const { return *m_it == 0; }

        void add_error(std::string message) { add_error(std::move(message), cur_loc()); }
        void add_error(std::string message, const SourceLoc& loc);

        const Parse::IParseError* get_error() const { return m_err.get(); }
        std::unique_ptr<Parse::IParseError> extract_error() { return std::move(m_err); }

    private:
        const char* m_it;
        int row;
        int column;

        CStringView m_text;
        CStringView m_origin;

        std::unique_ptr<IParseError> m_err;
    };
}
