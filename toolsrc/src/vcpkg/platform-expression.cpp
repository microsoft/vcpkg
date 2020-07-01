#include "pch.h"

#include <vcpkg/base/parse.h>
#include <vcpkg/base/strings.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/platform-expression.h>

#include <string>
#include <variant>
#include <vector>

namespace vcpkg::PlatformExpression
{
    using vcpkg::Parse::ParseError;

    enum class Identifier
    {
        invalid = -1, // not a recognized identifier
        x86,
        x64,
        arm,
        arm64,
        wasm32,

        windows,
        linux,
        osx,
        uwp,
        android,
        emscripten,

        static_link,
    };

    static Identifier string2identifier(StringView name)
    {
        static const std::map<StringView, Identifier> id_map = {
            {"x86", Identifier::x86},
            {"x64", Identifier::x64},
            {"arm", Identifier::arm},
            {"arm64", Identifier::arm64},
            {"wasm32", Identifier::wasm32},
            {"windows", Identifier::windows},
            {"linux", Identifier::linux},
            {"osx", Identifier::osx},
            {"uwp", Identifier::uwp},
            {"android", Identifier::android},
            {"emscripten", Identifier::emscripten},
            {"static", Identifier::static_link},
        };

        auto id_pair = id_map.find(name);

        if (id_pair == id_map.end())
        {
            return Identifier::invalid;
        }

        return id_pair->second;
    }

    namespace detail
    {
        struct ExprIdentifier
        {
            std::string identifier;
        };
        struct ExprNot
        {
            std::unique_ptr<ExprImpl> expr;
        };
        struct ExprAnd
        {
            std::vector<ExprImpl> exprs;
        };
        struct ExprOr
        {
            std::vector<ExprImpl> exprs;
        };

        struct ExprImpl
        {
            std::variant<ExprIdentifier, ExprNot, ExprAnd, ExprOr> underlying;

            explicit ExprImpl(ExprIdentifier e) : underlying(std::move(e)) { }
            explicit ExprImpl(ExprNot e) : underlying(std::move(e)) { }
            explicit ExprImpl(ExprAnd e) : underlying(std::move(e)) { }
            explicit ExprImpl(ExprOr e) : underlying(std::move(e)) { }

            ExprImpl clone() const
            {
                struct Visitor
                {
                    ExprImpl operator()(const ExprIdentifier& e) { return ExprImpl(e); }
                    ExprImpl operator()(const ExprNot& e)
                    {
                        return ExprImpl(ExprNot{std::make_unique<ExprImpl>(e.expr->clone())});
                    }
                    ExprImpl operator()(const ExprAnd& e)
                    {
                        ExprAnd res;
                        for (const auto& expr : e.exprs)
                        {
                            res.exprs.push_back(expr.clone());
                        }
                        return ExprImpl(std::move(res));
                    }
                    ExprImpl operator()(const ExprOr& e)
                    {
                        ExprOr res;
                        for (const auto& expr : e.exprs)
                        {
                            res.exprs.push_back(expr.clone());
                        }
                        return ExprImpl(std::move(res));
                    }
                };
                return std::visit(Visitor{}, underlying);
            }
        };

        class ExpressionParser : public Parse::ParserBase
        {
        public:
            ExpressionParser(StringView str, MultipleBinaryOperators multiple_binary_operators) : Parse::ParserBase(str, "CONTROL"), multiple_binary_operators(multiple_binary_operators) { }

            MultipleBinaryOperators multiple_binary_operators;

            bool allow_multiple_binary_operators() const
            {
                return multiple_binary_operators == MultipleBinaryOperators::Allow;
            }

            PlatformExpression::Expr parse()
            {
                skip_whitespace();

                auto res = expr();

                if (!at_eof())
                {
                    add_error("invalid logic expression, unexpected character");
                }

                return Expr(std::make_unique<ExprImpl>(std::move(res)));
            }

        private:
            // <platform-expression.and>
            //     <platform-expression.not>
            //     <platform-expression.and> & <platform-expression.not>
            // <platform-expression.or>
            //     <platform-expression.not>
            //     <platform-expression.or> | <platform-expression.not>

            static bool is_identifier_char(char32_t ch)
            {
                return is_lower_alpha(ch) || is_ascii_digit(ch);
            }

            // <platform-expression>:
            //     <platform-expression.not>
            //     <platform-expression.and>
            //     <platform-expression.or>
            ExprImpl expr()
            {
                auto result = expr_not();

                switch (cur())
                {
                    case '|':
                    {
                        ExprOr e;
                        e.exprs.push_back(std::move(result));
                        return expr_binary<'|', '&'>(std::move(e));
                    }
                    case '&':
                    {
                        ExprAnd e;
                        e.exprs.push_back(std::move(result));
                        return expr_binary<'&', '|'>(std::move(e));
                    }
                    default: return result;
                }
            }

            // <platform-expression.simple>:
            //     ( <platform-expression> )
            //     <platform-expression.identifier>
            ExprImpl expr_simple()
            {
                if (cur() == '(')
                {
                    next();
                    skip_whitespace();
                    auto result = expr();
                    if (cur() != ')')
                    {
                        add_error("missing closing )");
                        return result;
                    }
                    next();
                    skip_whitespace();
                    return result;
                }

                return expr_identifier();
            }

            // <platform-expression.identifier>:
            //     A lowercase alpha-numeric string
            ExprImpl expr_identifier()
            {
                std::string name = match_zero_or_more(is_identifier_char).to_string();

                if (name.empty())
                {
                    add_error("unexpected character in logic expression");
                }

                skip_whitespace();
                return ExprImpl{ExprIdentifier{name}};
            }

            // <platform-expression.not>:
            //     <platform-expression.simple>
            //     ! <platform-expression.simple>
            ExprImpl expr_not()
            {
                if (cur() == '!')
                {
                    next();
                    skip_whitespace();
                    return ExprImpl(ExprNot{std::make_unique<ExprImpl>(expr_simple())});
                }

                return expr_simple();
            }

            template<char oper, char other, class ExprKind>
            ExprImpl expr_binary(ExprKind&& seed)
            {
                do
                {
                    // Support chains of the operator to avoid breaking backwards compatibility
                    do
                    {
                        next();
                    } while (allow_multiple_binary_operators() && cur() == oper);

                    skip_whitespace();
                    seed.exprs.push_back(expr_not());
                } while (cur() == oper);

                if (cur() == other)
                {
                    add_error("mixing & and | is not allowed; use () to specify order of operations");
                }

                skip_whitespace();
                return ExprImpl(std::move(seed));
            }
        };
    }

    using namespace detail;

    Expr::Expr() = default;
    Expr::Expr(Expr&& other) = default;
    Expr& Expr::operator=(Expr&& other) = default;

    Expr::Expr(const Expr& other)
    {
        if (other.underlying_)
        {
            underlying_ = std::make_unique<ExprImpl>(other.underlying_->clone());
        }
    }
    Expr& Expr::operator=(const Expr& other)
    {
        if (other.underlying_)
        {
            if (this->underlying_)
            {
                *this->underlying_ = other.underlying_->clone();
            }
            else
            {
                this->underlying_ = std::make_unique<ExprImpl>(other.underlying_->clone());
            }
        }
        else
        {
            this->underlying_.reset();
        }

        return *this;
    }

    Expr::Expr(std::unique_ptr<ExprImpl>&& e) : underlying_(std::move(e)) { }
    Expr::~Expr() = default;

    Expr Expr::Identifier(StringView id)
    {
        return Expr(std::make_unique<ExprImpl>(ExprImpl{ExprIdentifier{id.to_string()}}));
    }
    Expr Expr::Not(Expr&& e) { return Expr(std::make_unique<ExprImpl>(ExprImpl{ExprNot{std::move(e.underlying_)}})); }
    Expr Expr::And(std::vector<Expr>&& exprs)
    {
        std::vector<ExprImpl> impls;
        for (auto& e : exprs)
        {
            impls.push_back(std::move(*e.underlying_));
        }
        return Expr(std::make_unique<ExprImpl>(ExprAnd{std::move(impls)}));
    }
    Expr Expr::Or(std::vector<Expr>&& exprs)
    {
        std::vector<ExprImpl> impls;
        for (auto& e : exprs)
        {
            impls.push_back(std::move(*e.underlying_));
        }
        return Expr(std::make_unique<ExprImpl>(ExprOr{std::move(impls)}));
    }

    bool Expr::evaluate(const Context& context) const
    {
        if (!underlying_)
        {
            return true; // empty expression is always true
        }

        std::map<std::string, bool> override_ctxt;
        {
            auto override_vars = context.find("VCPKG_DEP_INFO_OVERRIDE_VARS");
            if (override_vars != context.end())
            {
                auto cmake_list = Strings::split(override_vars->second, ';');
                for (auto& override_id : cmake_list)
                {
                    if (!override_id.empty())
                    {
                        if (override_id[0] == '!')
                        {
                            override_ctxt.insert({override_id.substr(1), false});
                        }
                        else
                        {
                            override_ctxt.insert({override_id, true});
                        }
                    }
                }
            }
        }

        struct Visitor
        {
            const Context& context;
            const std::map<std::string, bool>& override_ctxt;

            bool true_if_exists_and_equal(const std::string& variable_name, const std::string& value) const
            {
                auto iter = context.find(variable_name);
                if (iter == context.end())
                {
                    return false;
                }
                return iter->second == value;
            }

            bool visit(const ExprImpl& e) const { return std::visit(*this, e.underlying); }

            bool operator()(const ExprIdentifier& expr) const
            {
                if (!override_ctxt.empty())
                {
                    auto override_id = override_ctxt.find(expr.identifier);
                    if (override_id != override_ctxt.end())
                    {
                        return override_id->second;
                    }
                    // Fall through to use the cmake logic if the id does not have an override
                }

                auto id = string2identifier(expr.identifier);
                switch (id)
                {
                    case Identifier::invalid:
                        // Point out in the diagnostic that they should add to the override list because that is what
                        // most users should do, however it is also valid to update the built in identifiers to
                        // recognize the name.
                        System::printf(System::Color::error,
                                       "Error: Unrecognized identifer name %s. Add to override list in triplet file.\n",
                                       expr.identifier);
                        return false;
                    case Identifier::x64: return true_if_exists_and_equal("VCPKG_TARGET_ARCHITECTURE", "x64");
                    case Identifier::x86: return true_if_exists_and_equal("VCPKG_TARGET_ARCHITECTURE", "x86");
                    case Identifier::arm:
                        // For backwards compatability arm is also true for arm64.
                        // This is because it previously was only checking for a substring.
                        return true_if_exists_and_equal("VCPKG_TARGET_ARCHITECTURE", "arm") ||
                               true_if_exists_and_equal("VCPKG_TARGET_ARCHITECTURE", "arm64");
                    case Identifier::arm64: return true_if_exists_and_equal("VCPKG_TARGET_ARCHITECTURE", "arm64");
                    case Identifier::windows:
                        return true_if_exists_and_equal("VCPKG_CMAKE_SYSTEM_NAME", "") ||
                               true_if_exists_and_equal("VCPKG_CMAKE_SYSTEM_NAME", "WindowsStore");
                    case Identifier::linux: return true_if_exists_and_equal("VCPKG_CMAKE_SYSTEM_NAME", "Linux");
                    case Identifier::osx: return true_if_exists_and_equal("VCPKG_CMAKE_SYSTEM_NAME", "Darwin");
                    case Identifier::uwp: return true_if_exists_and_equal("VCPKG_CMAKE_SYSTEM_NAME", "WindowsStore");
                    case Identifier::android: return true_if_exists_and_equal("VCPKG_CMAKE_SYSTEM_NAME", "Android");
                    case Identifier::emscripten:
                        return true_if_exists_and_equal("VCPKG_CMAKE_SYSTEM_NAME", "Emscripten");
                    case Identifier::wasm32: return true_if_exists_and_equal("VCPKG_TARGET_ARCHITECTURE", "wasm32");
                    case Identifier::static_link: return true_if_exists_and_equal("VCPKG_LIBRARY_LINKAGE", "static");
                    default:
                        Checks::exit_with_message(
                            VCPKG_LINE_INFO,
                            "vcpkg bug: string2identifier returned a value that we don't recognize: %d\n",
                            static_cast<int>(id));
                }
            }

            bool operator()(const ExprNot& expr) const {
                bool res = visit(*expr.expr);
                return !res;
            }

            bool operator()(const ExprAnd& expr) const
            {
                bool valid = true;

                // we want to print errors in all expressions, so we check all of the expressions all the time
                for (const auto& e : expr.exprs)
                {
                    valid &= visit(e);
                }

                return valid;
            }

            bool operator()(const ExprOr& expr) const
            {
                bool valid = false;
                // we want to print errors in all expressions, so we check all of the expressions all the time
                for (const auto& e : expr.exprs)
                {
                    valid |= visit(e);
                }
                return valid;
            }
        };

        return Visitor{context, override_ctxt}.visit(*underlying_);
    }

    ExpectedS<Expr> parse_platform_expression(StringView expression, MultipleBinaryOperators multiple_binary_operators)
    {
        auto parser = ExpressionParser(expression, multiple_binary_operators);
        auto res = parser.parse();

        if (auto p = parser.extract_error())
        {
            return p->format();
        }
        else
        {
            return res;
        }
    }
}
