#include <catch2/catch.hpp>

#include <vcpkg/platform-expression.h>

using vcpkg::StringView;
using namespace vcpkg::PlatformExpression;

static vcpkg::ExpectedS<Expr> parse_expr(StringView s)
{
    return parse_platform_expression(s, MultipleBinaryOperators::Deny);
}

TEST_CASE ("platform-expression-identifier", "[platform-expression]")
{
    auto m_expr = parse_expr("windows");
    REQUIRE(m_expr);
    auto& expr = *m_expr.get();

    CHECK(expr.evaluate({{"VCPKG_CMAKE_SYSTEM_NAME", ""}}));
    CHECK(expr.evaluate({{"VCPKG_CMAKE_SYSTEM_NAME", "WindowsStore"}}));
    CHECK_FALSE(expr.evaluate({{"VCPKG_CMAKE_SYSTEM_NAME", "Linux"}}));
    CHECK_FALSE(expr.evaluate({{"VCPKG_CMAKE_SYSTEM_NAME", "Darwin"}}));
}

TEST_CASE ("platform-expression-not", "[platform-expression]")
{
    auto m_expr = parse_expr("!windows");
    REQUIRE(m_expr);
    auto& expr = *m_expr.get();

    CHECK_FALSE(expr.evaluate({{"VCPKG_CMAKE_SYSTEM_NAME", ""}}));
    CHECK_FALSE(expr.evaluate({{"VCPKG_CMAKE_SYSTEM_NAME", "WindowsStore"}}));
    CHECK(expr.evaluate({{"VCPKG_CMAKE_SYSTEM_NAME", "Linux"}}));
    CHECK(expr.evaluate({{"VCPKG_CMAKE_SYSTEM_NAME", "Darwin"}}));
}

TEST_CASE ("platform-expression-and", "[platform-expression]")
{
    auto m_expr = parse_expr("!windows & !arm");
    REQUIRE(m_expr);
    auto& expr = *m_expr.get();

    CHECK_FALSE(expr.evaluate({{"VCPKG_CMAKE_SYSTEM_NAME", ""}}));
    CHECK_FALSE(expr.evaluate({{"VCPKG_CMAKE_SYSTEM_NAME", "WindowsStore"}}));
    CHECK(expr.evaluate({{"VCPKG_CMAKE_SYSTEM_NAME", "Linux"}}));
    CHECK_FALSE(expr.evaluate({
        {"VCPKG_CMAKE_SYSTEM_NAME", "Linux"},
        {"VCPKG_TARGET_ARCHITECTURE", "arm"},
    }));
}

TEST_CASE ("platform-expression-or", "[platform-expression]")
{
    auto m_expr = parse_expr("!windows | arm");
    REQUIRE(m_expr);
    auto& expr = *m_expr.get();

    CHECK_FALSE(expr.evaluate({{"VCPKG_CMAKE_SYSTEM_NAME", ""}}));
    CHECK(expr.evaluate({{"VCPKG_CMAKE_SYSTEM_NAME", ""}, {"VCPKG_TARGET_ARCHITECTURE", "arm"}}));
    CHECK(expr.evaluate({{"VCPKG_CMAKE_SYSTEM_NAME", "Linux"}}));
}

TEST_CASE ("weird platform-expressions whitespace", "[platform-expression]")
{
    auto m_expr = parse_expr(" ! \t  windows \n| arm \r");
    REQUIRE(m_expr);
    auto& expr = *m_expr.get();

    CHECK_FALSE(expr.evaluate({{"VCPKG_CMAKE_SYSTEM_NAME", ""}}));
    CHECK(expr.evaluate({{"VCPKG_CMAKE_SYSTEM_NAME", ""}, {"VCPKG_TARGET_ARCHITECTURE", "arm"}}));
    CHECK(expr.evaluate({{"VCPKG_CMAKE_SYSTEM_NAME", "Linux"}}));
}

TEST_CASE ("no mixing &, | in platform expressions", "[platform-expression]")
{
    auto m_expr = parse_expr("windows & arm | linux");
    CHECK_FALSE(m_expr);
    m_expr = parse_expr("windows | !arm & linux");
    CHECK_FALSE(m_expr);
}
