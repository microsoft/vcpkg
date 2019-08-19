
#include "pch.h"

#include <vcpkg/base/checks.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/logicexpression.h>

#include <string>
#include <vector>

namespace vcpkg
{
    struct ParseError
    {
        ParseError(int column, std::string line, std::string message) : column(column), line(line), message(message) {}

        const int column;
        const std::string line;
        const std::string message;

        void print_error() const
        {
            System::print2(System::Color::error,
                           "Error: ",
                           message,
                           "\n"
                           "   on expression: \"",
                           line,
                           "\"\n",
                           "                   ",
                           std::string(column, ' '),
                           "^\n");
            Checks::exit_fail(VCPKG_LINE_INFO);
        }
    };

    // logic expression supports the following :
    //  primary-expression:
    //    ( logic-expression )
    //    identifier
    //  identifier:
    //    alpha-numeric string of characters
    //  logic-expression: <- this is the entry point
    //    not-expression
    //    not-expression | logic-expression
    //    not-expression & logic-expression
    //  not-expression:
    //    ! primary-expression
    //    primary-expression
    //
    // | and & have equal precidence and cannot be used together at the same nesting level
    //   for example a|b&c is not allowd but (a|b)&c and a|(b&c) are allowed.
    class ExpressionParser
    {
    public:
        ExpressionParser(const std::string& str, const std::string& evaluation_context)
            : raw_text(str)
            , evaluation_context(evaluation_context)
            , current_iter(raw_text.begin())
            , current_char(get_current_char())
        {
            skip_whitespace();

            final_result = logic_expression();

            if (current_iter != raw_text.end())
            {
                add_error("Invalid logic expression");
            }

            if (err)
            {
                err->print_error();
                final_result = false;
            }
        }

        bool get_result() const { return final_result; }

        bool has_error() const { return err == nullptr; }

    private:
        const std::string& raw_text;
        const std::string& evaluation_context;
        std::string::const_iterator current_iter;
        char current_char;

        bool final_result;

        std::unique_ptr<ParseError> err;

        char get_current_char() const { return (current_iter != raw_text.end() ? *current_iter : '\0'); }

        void add_error(std::string message, int column = -1)
        {
            // avoid castcading errors by only saving the first
            if (!err)
            {
                if (column < 0)
                {
                    column = current_column();
                }
                err = std::make_unique<ParseError>(column, raw_text, message);
            }

            // Avoid error loops by skipping to the end
            skip_to_end();
        }

        int current_column() const { return static_cast<int>(current_iter - raw_text.begin()); }

        void skip_to_end()
        {
            current_iter = raw_text.end();
            current_char = '\0';
        }
        char current() const { return current_char; }
        char next()
        {
            if (current_char != '\0')
            {
                current_iter++;
                current_char = get_current_char();
            }
            return current();
        }
        void skip_whitespace()
        {
            while (current_char == ' ' || current_char == '\t')
            {
                current_char = next();
            }
        }
        char next_skip_whitespace()
        {
            next();
            skip_whitespace();
            return current_char;
        }

        static bool is_alphanum(char ch)
        {
            return (ch >= 'A' && ch <= 'Z') || (ch >= 'a' && ch <= 'z') || (ch >= '0' && ch <= '9') || (ch == '-');
        }

        bool evaluate_identifier(const std::string name) const
        {
            return evaluation_context.find(name) != std::string::npos;
        }

        //  identifier:
        //    alpha-numeric string of characters
        bool identifier_expression()
        {
            auto curr = current();
            std::string name;

            for (curr = current(); is_alphanum(curr); curr = next())
            {
                name += curr;
            }

            if (name.empty())
            {
                add_error("Invalid logic expression, unexpected character");
                return false;
            }

            bool result = evaluate_identifier(name);
            skip_whitespace();
            return result;
        }

        //  not-expression:
        //    ! primary-expression
        //    primary-expression
        bool not_expression()
        {
            if (current() == '!')
            {
                next_skip_whitespace();
                return !primary_expression();
            }

            return primary_expression();
        }

        template<char oper, char other, bool operation(bool, bool)>
        bool logic_expression_helper(bool seed)
        {
            do
            {
                // Support chains of the operator to avoid breaking backwards compatability
                while (next() == oper)
                {
                };
                seed = operation(not_expression(), seed);

            } while (current() == oper);

            if (current() == other)
            {
                add_error("Mixing & and | is not allowed, Use () to specify order of operations.");
            }

            skip_whitespace();
            return seed;
        }
        static bool and_helper(bool left, bool right) { return left && right; }
        static bool or_helper(bool left, bool right) { return left || right; }

        //  logic-expression: <- entry point
        //    not-expression
        //    not-expression | logic-expression
        //    not-expression & logic-expression
        bool logic_expression()
        {
            auto result = not_expression();

            switch (current())
            {
                case '|':
                {
                    return logic_expression_helper<'|', '&', or_helper>(result);
                }
                case '&':
                {
                    return logic_expression_helper<'&', '|', and_helper>(result);
                }
                default: return result;
            }
        }

        //  primary-expression:
        //    ( logic-expression )
        //    identifier
        bool primary_expression()
        {
            if (current() == '(')
            {
                next_skip_whitespace();
                bool result = logic_expression();
                if (current() != ')')
                {
                    add_error("Error: missing closing )");
                    return result;
                }
                next_skip_whitespace();
                return result;
            }

            return identifier_expression();
        }
    };

    bool evaluate_expression(const std::string& expression, const std::string& evaluation_context)
    {
        ExpressionParser parser(expression, evaluation_context);

        return parser.get_result();
    }
}
