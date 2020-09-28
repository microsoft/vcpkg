#pragma once

#include <vcpkg/base/expected.h>
#include <vcpkg/base/stringview.h>

#include <string>
#include <unordered_map>

namespace vcpkg::PlatformExpression
{
    // map of cmake variables and their values.
    using Context = std::unordered_map<std::string, std::string>;

    namespace detail
    {
        struct ExprImpl;
    }
    struct Expr
    {
        static Expr Identifier(StringView id);
        static Expr Not(Expr&& e);
        static Expr And(std::vector<Expr>&& exprs);
        static Expr Or(std::vector<Expr>&& exprs);

        // The empty expression is always true
        static Expr Empty() { return Expr(); }

        // since ExprImpl is not yet defined, we need to define the ctor and dtor in the C++ file
        Expr();
        Expr(const Expr&);
        Expr(Expr&&);
        Expr& operator=(const Expr& e);
        Expr& operator=(Expr&&);

        explicit Expr(std::unique_ptr<detail::ExprImpl>&& e);
        ~Expr();

        bool evaluate(const Context& context) const;
        bool is_empty() const { return !static_cast<bool>(underlying_); }

        // returns:
        //   - 0 for empty
        //   - 1 for identifiers
        //   - 1 + complexity(inner) for !
        //   - 1 + sum(complexity(inner)) for & and |
        int complexity() const;

        // these two are friends so that they're only findable via ADL

        // this does a structural equality, so, for example:
        //   !structurally_equal((x & y) & z, x & y & z)
        //   !structurally_equal((x & y) | z, (x | z) & (y | z))
        // even though these expressions are equivalent
        friend bool structurally_equal(const Expr& lhs, const Expr& rhs);

        // returns 0 if and only if structurally_equal(lhs, rhs)
        // Orders via the following:
        //   - If complexity(a) < complexity(b) => a < b
        //   - Otherwise, if to_string(a).size() < to_string(b).size() => a < b
        //   - Otherwise, if to_string(a) < to_string(b) => a < b
        //   - else, they must be structurally equal
        friend int compare(const Expr& lhs, const Expr& rhs);

        friend std::string to_string(const Expr& expr);

    private:
        std::unique_ptr<detail::ExprImpl> underlying_;
    };

    // Note: for backwards compatibility, in CONTROL files,
    // multiple binary operators are allowed to be next to one another; i.e.
    // (windows & arm) = (windows && arm) = (windows &&& arm), etc.
    enum class MultipleBinaryOperators
    {
        Deny,
        Allow,
    };

    // platform expression parses a platform expression; the EBNF of such is defined in
    // /docs/maintainers/manifest-files.md#supports
    ExpectedS<Expr> parse_platform_expression(StringView expression, MultipleBinaryOperators multiple_binary_operators);
}
