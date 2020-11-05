#include <catch2/catch.hpp>

#include <vcpkg/dependencies.h>
#include <vcpkg/paragraphparser.h>
#include <vcpkg/portfileprovider.h>
#include <vcpkg/sourceparagraph.h>

#include <vcpkg-test/mockcmakevarprovider.h>
#include <vcpkg-test/util.h>

using namespace vcpkg;
using namespace vcpkg::Parse;

TEST_CASE ("parse depends", "[dependencies]")
{
    auto w = parse_dependencies_list("liba (windows)");
    REQUIRE(w);
    auto& v = *w.get();
    REQUIRE(v.size() == 1);
    REQUIRE(v.at(0).name == "liba");
    REQUIRE(v.at(0).platform.evaluate({{"VCPKG_CMAKE_SYSTEM_NAME", ""}}));
    REQUIRE(v.at(0).platform.evaluate({{"VCPKG_CMAKE_SYSTEM_NAME", "WindowsStore"}}));
    REQUIRE(!v.at(0).platform.evaluate({{"VCPKG_CMAKE_SYSTEM_NAME", "Darwin"}}));
}

TEST_CASE ("filter depends", "[dependencies]")
{
    const std::unordered_map<std::string, std::string> x64_win_cmake_vars{{"VCPKG_TARGET_ARCHITECTURE", "x64"},
                                                                          {"VCPKG_CMAKE_SYSTEM_NAME", ""}};

    const std::unordered_map<std::string, std::string> arm_uwp_cmake_vars{{"VCPKG_TARGET_ARCHITECTURE", "arm"},
                                                                          {"VCPKG_CMAKE_SYSTEM_NAME", "WindowsStore"}};

    auto deps_ = parse_dependencies_list("liba (!uwp), libb, libc (uwp)");
    REQUIRE(deps_);
    auto& deps = *deps_.get();
    auto v = filter_dependencies(deps, Test::X64_WINDOWS, x64_win_cmake_vars);
    REQUIRE(v.size() == 2);
    REQUIRE(v.at(0).package_spec.name() == "liba");
    REQUIRE(v.at(1).package_spec.name() == "libb");

    auto v2 = filter_dependencies(deps, Test::ARM_UWP, arm_uwp_cmake_vars);
    REQUIRE(v.size() == 2);
    REQUIRE(v2.at(0).package_spec.name() == "libb");
    REQUIRE(v2.at(1).package_spec.name() == "libc");
}

TEST_CASE ("parse feature depends", "[dependencies]")
{
    auto u_ = parse_dependencies_list("libwebp[anim, gif2webp, img2webp, info, mux, nearlossless, "
                                      "simd, cwebp, dwebp], libwebp[vwebp-sdl, extras] (!osx)");
    REQUIRE(u_);
    auto& v = *u_.get();
    REQUIRE(v.size() == 2);
    auto&& a0 = v.at(0);
    REQUIRE(a0.name == "libwebp");
    REQUIRE(a0.features.size() == 9);
    REQUIRE(a0.platform.is_empty());

    auto&& a1 = v.at(1);
    REQUIRE(a1.name == "libwebp");
    REQUIRE(a1.features.size() == 2);
    REQUIRE(!a1.platform.is_empty());
    REQUIRE(a1.platform.evaluate({{"VCPKG_CMAKE_SYSTEM_NAME", ""}}));
    REQUIRE(a1.platform.evaluate({{"VCPKG_CMAKE_SYSTEM_NAME", "Linux"}}));
    REQUIRE_FALSE(a1.platform.evaluate({{"VCPKG_CMAKE_SYSTEM_NAME", "Darwin"}}));
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

    FullPackageSpec linspec_a{{"a", Triplet::from_canonical_name("x64-linux")}, {}};
    var_provider.dep_info_vars[linspec_a.package_spec].emplace("VCPKG_CMAKE_SYSTEM_NAME", "Linux");
    auto plan2 = vcpkg::Dependencies::create_feature_install_plan(map_port, var_provider, {linspec_a}, {});
    REQUIRE(plan2.install_actions.size() == 2);
    REQUIRE(plan2.install_actions.at(0).feature_list == std::vector<std::string>{"b1", "core"});
}

TEST_CASE ("resolve_deps_as_top_level", "[dependencies]")
{
    using namespace Test;
    PackageSpecMap spec_map;
    FullPackageSpec spec_a{spec_map.emplace("a", "b, b[b1] (linux)"), {}};
    FullPackageSpec spec_b{spec_map.emplace("b", "", {{"b1", ""}}), {}};
    FullPackageSpec spec_c{spec_map.emplace("c", "b", {{"c1", "b[b1]"}, {"c2", "c[c1], a"}}, {"c1"}), {"core"}};
    FullPackageSpec spec_d{spec_map.emplace("d", "c[core]"), {}};

    PortFileProvider::MapPortFileProvider map_port{spec_map.map};
    MockCMakeVarProvider var_provider;
    Triplet t_linux = Triplet::from_canonical_name("x64-linux");
    var_provider.dep_info_vars[{"a", t_linux}].emplace("VCPKG_CMAKE_SYSTEM_NAME", "Linux");
    {
        auto deps = vcpkg::Dependencies::resolve_deps_as_top_level(
            *spec_map.map.at("a").source_control_file, Test::X86_WINDOWS, {}, var_provider);
        REQUIRE(deps.size() == 1);
        REQUIRE(deps.at(0) == spec_b);
    }
    {
        auto deps = vcpkg::Dependencies::resolve_deps_as_top_level(
            *spec_map.map.at("a").source_control_file, t_linux, {}, var_provider);
        REQUIRE(deps.size() == 1);
        REQUIRE(deps.at(0) == FullPackageSpec({"b", t_linux}, {"b1"}));
    }
    {
        // without defaults
        auto deps = vcpkg::Dependencies::resolve_deps_as_top_level(
            *spec_map.map.at("c").source_control_file, Test::X86_WINDOWS, {}, var_provider);
        REQUIRE(deps.size() == 1);
        REQUIRE(deps.at(0) == spec_b);
    }
    FullPackageSpec spec_b_with_b1{spec_b.package_spec, {"b1"}};
    {
        // with defaults of c (c1)
        auto deps = vcpkg::Dependencies::resolve_deps_as_top_level(
            *spec_map.map.at("c").source_control_file, Test::X86_WINDOWS, {"default"}, var_provider);
        REQUIRE(deps.size() == 1);
        REQUIRE(deps.at(0) == spec_b_with_b1);
    }
    {
        // with c1
        auto deps = vcpkg::Dependencies::resolve_deps_as_top_level(
            *spec_map.map.at("c").source_control_file, Test::X86_WINDOWS, {"c1"}, var_provider);
        REQUIRE(deps.size() == 1);
        REQUIRE(deps.at(0) == spec_b_with_b1);
    }
    {
        // with c2 implying c1
        auto deps = vcpkg::Dependencies::resolve_deps_as_top_level(
            *spec_map.map.at("c").source_control_file, Test::X86_WINDOWS, {"c2"}, var_provider);
        REQUIRE(deps.size() == 2);
        REQUIRE(deps.at(0) == spec_a);
        REQUIRE(deps.at(1) == spec_b_with_b1);
    }
    {
        // d -> c[core]
        auto deps = vcpkg::Dependencies::resolve_deps_as_top_level(
            *spec_map.map.at("d").source_control_file, Test::X86_WINDOWS, {}, var_provider);
        REQUIRE(deps.size() == 1);
        REQUIRE(deps.at(0) == spec_c);
    }
}
