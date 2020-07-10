#pragma once

#include <string>
#include <unordered_map>

#include <vcpkg/base/expected.h>
#include <vcpkg/base/stringview.h>

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

    // platform expression parses the following :
    // <platform-expression>:
    //     <platform-expression.not>
    //     <platform-expression.and>
    //     <platform-expression.or>
    // <platform-expression.simple>:
    //     ( <platform-expression> )
    //     <platform-expression.identifier>
    // <platform-expression.identifier>:
    //     A lowercase alpha-numeric string
    // <platform-expression.not>:
    //     <platform-expression.simple>
    //     ! <platform-expression.simple>
    // <platform-expression.and>
    //     <platform-expression.not>
    //     <platform-expression.and> & <platform-expression.not>
    // <platform-expression.or>
    //     <platform-expression.not>
    //     <platform-expression.or> | <platform-expression.not>
    ExpectedS<Expr> parse_platform_expression(StringView expression, MultipleBinaryOperators multiple_binary_operators);
}
