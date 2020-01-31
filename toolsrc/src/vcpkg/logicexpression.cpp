#include "pch.h"

#include <vcpkg/base/strings.h>
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

        std::string format_error() const
        {
            return Strings::concat("Error: ",
                                   message,
                                   "\n"
                                   "   on expression: \"",
                                   line,
                                   "\"\n",
                                   "                   ",
                                   std::string(column, ' '),
                                   "^\n");
        }
    };

    enum class Identifier
    {
        invalid, // not a recognized identifier
        x64,
        x86,
        arm,
        arm64,

        windows,
        linux,
        osx,
        uwp,
        android,

        static_link,
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
        ExpressionParser(const std::string& str, const ExpressionContext& context)
            : raw_text(str)
            , evaluation_context(context)
            , current_iter(raw_text.begin())
            , current_char(get_current_char())
        {
            {
                auto override_vars = evaluation_context.cmake_context.find("VCPKG_DEP_INFO_OVERRIDE_VARS");
                if (override_vars != evaluation_context.cmake_context.end())
                {
                    auto cmake_list = Strings::split(override_vars->second, ";");
                    for (auto& override_id : cmake_list)
                    {
                        if (!override_id.empty())
                        {
                            if (override_id[0] == '!')
                            {
                                context_override.insert({override_id.substr(1), false});
                            }
                            else
                            {
                                context_override.insert({override_id, true});
                            }
                        }
                    }
                }
            }
            skip_whitespace();

            final_result = logic_expression();

            if (current_iter != raw_text.end())
            {
                add_error("Invalid logic expression");
            }
        }

        bool get_result() const { return final_result; }

        const ParseError* get_error() const { return err.get(); }

    private:
        const std::string& raw_text;

        const ExpressionContext& evaluation_context;
        std::map<std::string, bool> context_override;

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

        // Legacy evaluation only searches for substrings.  Use this only for diagnostic purposes.
        bool evaluate_identifier_legacy(const std::string name) const
        {
            return evaluation_context.legacy_context.find(name) != std::string::npos;
        }

        static Identifier string2identifier(const std::string& name)
        {
            static const std::map<std::string, Identifier> id_map = {
                {"x64", Identifier::x64},
                {"x86", Identifier::x86},
                {"arm", Identifier::arm},
                {"arm64", Identifier::arm64},
                {"windows", Identifier::windows},
                {"linux", Identifier::linux},
                {"osx", Identifier::osx},
                {"uwp", Identifier::uwp},
                {"android", Identifier::android},
                {"static", Identifier::static_link},
            };

            auto id_pair = id_map.find(name);

            if (id_pair == id_map.end())
            {
                return Identifier::invalid;
            }

            return id_pair->second;
        }

        bool true_if_exists_and_equal(const std::string& variable_name, const std::string& value)
        {
            auto iter = evaluation_context.cmake_context.find(variable_name);
            if (iter == evaluation_context.cmake_context.end())
            {
                return false;
            }
            return iter->second == value;
        }

        // If an identifier is on the explicit override list, return the override value
        // Otherwise fall back to the built in logic to evaluate
        // All unrecognized identifiers are an error
        bool evaluate_identifier_cmake(const std::string name, int column)
        {
            auto id = string2identifier(name);

            switch (id)
            {
                case Identifier::invalid:
                    // Point out in the diagnostic that they should add to the override list because that is what
                    // most users should do, however it is also valid to update the built in identifiers to recognize
                    // the name.
                    add_error("Unrecognized identifer name.  Add to override list in triplet file.", column);
                    break;

                case Identifier::x64: return true_if_exists_and_equal("VCPKG_TARGET_ARCHITECTURE", "x64");
                case Identifier::x86: return true_if_exists_and_equal("VCPKG_TARGET_ARCHITECTURE", "x86");
                case Identifier::arm:
                    // For backwards compatability arm is also true for arm64.
                    // This is because it previously was only checking for a substring.
                    return true_if_exists_and_equal("VCPKG_TARGET_ARCHITECTURE", "arm") ||
                           true_if_exists_and_equal("VCPKG_TARGET_ARCHITECTURE", "arm64");
                case Identifier::arm64: return true_if_exists_and_equal("VCPKG_TARGET_ARCHITECTURE", "arm64");
                case Identifier::windows: return true_if_exists_and_equal("VCPKG_CMAKE_SYSTEM_NAME", "") || true_if_exists_and_equal("VCPKG_CMAKE_SYSTEM_NAME", "WindowsStore");
                case Identifier::linux: return true_if_exists_and_equal("VCPKG_CMAKE_SYSTEM_NAME", "Linux");
                case Identifier::osx: return true_if_exists_and_equal("VCPKG_CMAKE_SYSTEM_NAME", "Darwin");
                case Identifier::uwp: return true_if_exists_and_equal("VCPKG_CMAKE_SYSTEM_NAME", "WindowsStore");
                case Identifier::android: return true_if_exists_and_equal("VCPKG_CMAKE_SYSTEM_NAME", "Android");
                case Identifier::static_link: return true_if_exists_and_equal("VCPKG_LIBRARY_LINKAGE", "static");
            }

            return evaluation_context.legacy_context.find(name) != std::string::npos;
        }

        bool evaluate_identifier(const std::string name, int column)
        {
            if (!context_override.empty())
            {
                auto override_id = context_override.find(name);
                if (override_id != context_override.end())
                {
                    return override_id->second;
                }
                // Fall through to use the cmake logic if the id does not have an override
            }

            bool legacy = evaluate_identifier_legacy(name);
            bool cmake = evaluate_identifier_cmake(name, column);
            if (legacy != cmake)
            {
                // Legacy evaluation only used the name of the triplet, now we use the actual
                // cmake variables. This has the potential to break custom triplets.
                // For now just print a message, this will need to change once we start introducing
                // new variables that did not exist previously (such as host-*)
                System::print2(
                    "Warning: Identifier logic evaluation does not match legacy evaluation:\n   ", name, '\n');
            }
            return cmake;
        }

        //  identifier:
        //    alpha-numeric string of characters
        bool identifier_expression()
        {
            auto curr = current();
            std::string name;
            auto starting_column = current_column();

            for (curr = current(); is_alphanum(curr); curr = next())
            {
                name += curr;
            }

            if (name.empty())
            {
                add_error("Invalid logic expression, unexpected character");
                return false;
            }

            bool result = evaluate_identifier(name, starting_column);
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
                skip_whitespace();
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
                    add_error("missing closing )");
                    return result;
                }
                next_skip_whitespace();
                return result;
            }

            return identifier_expression();
        }
    };

    ExpectedT<bool, std::string> evaluate_expression(const std::string& expression, const ExpressionContext& context)
    {
        ExpressionParser parser(expression, context);

        if (auto err = parser.get_error())
        {
            return err->format_error();
        }

        return parser.get_result();
    }
}
