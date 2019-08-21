#include <catch2/catch.hpp>

#include <vcpkg/sourceparagraph.h>

using namespace vcpkg;
using Parse::parse_comma_list;

TEST_CASE ("parse depends", "[dependencies]")
{
    auto v = expand_qualified_dependencies(parse_comma_list("libA (windows)"));
    REQUIRE(v.size() == 1);
    REQUIRE(v.at(0).depend.name == "libA");
    REQUIRE(v.at(0).qualifier == "windows");
}

TEST_CASE ("filter depends", "[dependencies]")
{
    auto deps = expand_qualified_dependencies(parse_comma_list("libA (windows), libB, libC (uwp)"));
    auto v = filter_dependencies(deps, Triplet::X64_WINDOWS);
    REQUIRE(v.size() == 2);
    REQUIRE(v.at(0) == "libA");
    REQUIRE(v.at(1) == "libB");

    auto v2 = filter_dependencies(deps, Triplet::ARM_UWP);
    REQUIRE(v.size() == 2);
    REQUIRE(v2.at(0) == "libB");
    REQUIRE(v2.at(1) == "libC");
}
