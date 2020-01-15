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
    const std::unordered_map<std::string, std::string> x64_win_cmake_vars{{"VCPKG_TARGET_ARCHITECTURE", "x64"},
                                                                          {"VCPKG_CMAKE_SYSTEM_NAME", ""}};

    const std::unordered_map<std::string, std::string> arm_uwp_cmake_vars{{"VCPKG_TARGET_ARCHITECTURE", "arm"},
                                                                          {"VCPKG_CMAKE_SYSTEM_NAME", "WindowsStore"}};

    auto deps = expand_qualified_dependencies(parse_comma_list("libA (windows), libB, libC (uwp)"));
    auto v = filter_dependencies(deps, Triplet::X64_WINDOWS, x64_win_cmake_vars);
    REQUIRE(v.size() == 2);
    REQUIRE(v.at(0) == "libA");
    REQUIRE(v.at(1) == "libB");

    auto v2 = filter_dependencies(deps, Triplet::ARM_UWP, arm_uwp_cmake_vars);
    REQUIRE(v.size() == 2);
    REQUIRE(v2.at(0) == "libB");
    REQUIRE(v2.at(1) == "libC");
}

TEST_CASE ("parse feature depends", "[dependencies]")
{
    auto u = parse_comma_list("libwebp[anim, gif2webp, img2webp, info, mux, nearlossless, "
                              "simd, cwebp, dwebp], libwebp[vwebp_sdl, extras] (!osx)");
    REQUIRE(u.at(1) == "libwebp[vwebp_sdl, extras] (!osx)");
    auto v = expand_qualified_dependencies(u);
    REQUIRE(v.size() == 2);
    auto&& a0 = v.at(0);
    REQUIRE(a0.depend.name == "libwebp");
    REQUIRE(a0.depend.features.size() == 9);
    REQUIRE(a0.qualifier.empty());

    auto&& a1 = v.at(1);
    REQUIRE(a1.depend.name == "libwebp");
    REQUIRE(a1.depend.features.size() == 2);
    REQUIRE(a1.qualifier == "!osx");
}
