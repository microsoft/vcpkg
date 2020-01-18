#include <catch2/catch.hpp>
#include <vcpkg-test/mockcmakevarprovider.h>
#include <vcpkg-test/util.h>
#include <vcpkg/dependencies.h>
#include <vcpkg/sourceparagraph.h>

using namespace vcpkg;
using Parse::parse_comma_list;

TEST_CASE ("parse depends", "[dependencies]")
{
    auto v = expand_qualified_dependencies(parse_comma_list("liba (windows)"));
    REQUIRE(v.size() == 1);
    REQUIRE(v.at(0).depend.name == "liba");
    REQUIRE(v.at(0).qualifier == "windows");
}

TEST_CASE ("filter depends", "[dependencies]")
{
    const std::unordered_map<std::string, std::string> x64_win_cmake_vars{{"VCPKG_TARGET_ARCHITECTURE", "x64"},
                                                                          {"VCPKG_CMAKE_SYSTEM_NAME", ""}};

    const std::unordered_map<std::string, std::string> arm_uwp_cmake_vars{{"VCPKG_TARGET_ARCHITECTURE", "arm"},
                                                                          {"VCPKG_CMAKE_SYSTEM_NAME", "WindowsStore"}};

    auto deps = expand_qualified_dependencies(parse_comma_list("liba (windows), libb, libc (uwp)"));
    auto v = filter_dependencies(deps, Triplet::X64_WINDOWS, x64_win_cmake_vars);
    REQUIRE(v.size() == 2);
    REQUIRE(v.at(0).package_spec.name() == "liba");
    REQUIRE(v.at(1).package_spec.name() == "libb");

    auto v2 = filter_dependencies(deps, Triplet::ARM_UWP, arm_uwp_cmake_vars);
    REQUIRE(v.size() == 2);
    REQUIRE(v2.at(0).package_spec.name() == "libb");
    REQUIRE(v2.at(1).package_spec.name() == "libc");
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

TEST_CASE ("qualified dependency", "[dependencies]")
{
    using namespace Test;
    PackageSpecMap spec_map;
    auto spec_a = FullPackageSpec{spec_map.emplace("a", "b, b[b1] (linux)"), {}};
    auto spec_b = FullPackageSpec{spec_map.emplace("b", "", {{"b1", ""}}), {}};

    PortFileProvider::MapPortFileProvider map_port{spec_map.map};
    MockCMakeVarProvider var_provider;

    auto plan = vcpkg::Dependencies::create_feature_install_plan(map_port, var_provider, {spec_a}, {});
    REQUIRE(plan.install_actions.size() == 2);
    REQUIRE(plan.install_actions.at(0).feature_list == std::vector<std::string>{"core"});

    FullPackageSpec linspec_a{PackageSpec::from_name_and_triplet("a", Triplet::from_canonical_name("x64-linux"))
                                  .value_or_exit(VCPKG_LINE_INFO),
                              {}};
    var_provider.dep_info_vars[linspec_a.package_spec].emplace("VCPKG_CMAKE_SYSTEM_NAME", "Linux");
    auto plan2 = vcpkg::Dependencies::create_feature_install_plan(map_port, var_provider, {linspec_a}, {});
    REQUIRE(plan2.install_actions.size() == 2);
    REQUIRE(plan2.install_actions.at(0).feature_list == std::vector<std::string>{"b1", "core"});
}
