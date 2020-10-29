#include <catch2/catch.hpp>

#include <vcpkg/base/graphs.h>

#include <vcpkg/dependencies.h>
#include <vcpkg/portfileprovider.h>
#include <vcpkg/sourceparagraph.h>
#include <vcpkg/triplet.h>

#include <memory>
#include <unordered_map>
#include <vector>

#include <vcpkg-test/mockcmakevarprovider.h>
#include <vcpkg-test/util.h>

using namespace vcpkg;

using Test::make_control_file;
using Test::make_status_feature_pgh;
using Test::make_status_pgh;
using Test::MockCMakeVarProvider;
using Test::PackageSpecMap;

///// <summary>
///// Assert that the given action an install of given features from given package.
///// </summary>
// static void features_check(Dependencies::InstallPlanAction& plan,
//                           std::string pkg_name,
//                           std::vector<std::string> expected_features,
//                           Triplet triplet = Test::X86_WINDOWS)
//{
//    const auto& feature_list = plan.feature_list;
//
//    REQUIRE(plan.spec.triplet().to_string() == triplet.to_string());
//    REQUIRE(pkg_name == plan.spec.name());
//    REQUIRE(feature_list.size() == expected_features.size());
//
//    for (auto&& feature_name : expected_features)
//    {
//        // TODO: see if this can be simplified
//        if (feature_name == "core" || feature_name.empty())
//        {
//            REQUIRE((Util::find(feature_list, "core") != feature_list.end() ||
//                     Util::find(feature_list, "") != feature_list.end()));
//            continue;
//        }
//        REQUIRE(Util::find(feature_list, feature_name) != feature_list.end());
//    }
//}

struct MockBaselineProvider : PortFileProvider::IBaselineProvider
{
    std::map<std::string, Versions::Version> v;

    Optional<Versions::Version> get_baseline(const std::string& name) override
    {
        auto it = v.find(name);
        if (it == v.end()) return nullopt;
        return it->second;
    }
};

struct MockVersionedPortfileProvider : PortFileProvider::IVersionedPortfileProvider
{
    std::map<std::string, std::map<Versions::Version, SourceControlFileLocation>> v;

    ExpectedS<const SourceControlFileLocation&> get_control_file(
        const vcpkg::Versions::VersionSpec& version_spec) override
    {
        auto it = v.find(version_spec.name);
        if (it == v.end()) return std::string("Unknown port name");
        auto it2 = it->second.find(version_spec.version);
        if (it2 == it->second.end()) return std::string("Unknown port version");
        return it2->second;
    }

    SourceControlFileLocation& emplace(std::string&& name,
                                       Versions::Version&& version,
                                       Versions::Scheme scheme = Versions::Scheme::String)
    {
        auto it = v.find(name);
        if (it == v.end()) it = v.emplace(name, std::map<Versions::Version, SourceControlFileLocation>{}).first;

        auto it2 = it->second.find(version);
        if (it2 == it->second.end())
        {
            auto scf = std::make_unique<SourceControlFile>();
            auto core = std::make_unique<SourceParagraph>();
            core->name = name;
            core->version = version.text;
            core->port_version = version.port_version;
            core->version_scheme = scheme;
            scf->core_paragraph = std::move(core);
            it2 = it->second.emplace(version, SourceControlFileLocation{std::move(scf), fs::u8path(name)}).first;
        }
        return it2->second;
    }
};

using Versions::Constraint;
using Versions::Scheme;

template<class T>
T unwrap(ExpectedS<T> e)
{
    REQUIRE(e.has_value());
    return std::move(*e.get());
}

TEST_CASE ("basic version install single", "[versionplan]")
{
    MockBaselineProvider bp;
    bp.v["a"] = {"1", 0};

    MockVersionedPortfileProvider vp;
    vp.emplace("a", {"1", 0});

    MockCMakeVarProvider var_provider;

    auto install_plan =
        unwrap(Dependencies::create_versioned_install_plan(vp, bp, var_provider, {{"a"}}, {}, Test::X86_WINDOWS));

    REQUIRE(install_plan.size() == 1);
    REQUIRE(install_plan.install_actions.at(0).spec.name() == "a");
}

TEST_CASE ("basic version install detect cycle", "[versionplan]")
{
    MockBaselineProvider bp;
    bp.v["a"] = {"1", 0};
    bp.v["b"] = {"1", 0};

    MockVersionedPortfileProvider vp;
    vp.emplace("a", {"1", 0}).source_control_file->core_paragraph->dependencies = {
        Dependency{"b", {}, {}, DependencyConstraint{}},
    };
    vp.emplace("b", {"1", 0}).source_control_file->core_paragraph->dependencies = {
        Dependency{"a", {}, {}, DependencyConstraint{}},
    };

    MockCMakeVarProvider var_provider;

    auto install_plan =
        Dependencies::create_versioned_install_plan(vp, bp, var_provider, {{"a"}}, {}, Test::X86_WINDOWS);

    REQUIRE(!install_plan.has_value());
}

TEST_CASE ("basic version install scheme", "[versionplan]")
{
    MockBaselineProvider bp;
    bp.v["a"] = {"1", 0};
    bp.v["b"] = {"1", 0};

    MockVersionedPortfileProvider vp;
    vp.emplace("a", {"1", 0}).source_control_file->core_paragraph->dependencies = {
        Dependency{"b", {}, {}, DependencyConstraint{}},
    };
    vp.emplace("b", {"1", 0});

    MockCMakeVarProvider var_provider;

    auto install_plan =
        unwrap(Dependencies::create_versioned_install_plan(vp, bp, var_provider, {{"a"}}, {}, Test::X86_WINDOWS));

    CHECK(install_plan.size() == 2);

    StringLiteral names[] = {"b", "a"};
    for (size_t i = 0; i < install_plan.install_actions.size() && i < 2; ++i)
    {
        CHECK(install_plan.install_actions[i].spec.name() == names[i]);
    }
}

TEST_CASE ("basic version install scheme diamond", "[versionplan]")
{
    MockBaselineProvider bp;
    bp.v["a"] = {"1", 0};
    bp.v["b"] = {"1", 0};
    bp.v["c"] = {"1", 0};
    bp.v["d"] = {"1", 0};

    MockVersionedPortfileProvider vp;
    vp.emplace("a", {"1", 0}).source_control_file->core_paragraph->dependencies = {
        Dependency{"b", {}, {}, DependencyConstraint{}},
        Dependency{"c", {}, {}, DependencyConstraint{}},
    };
    vp.emplace("b", {"1", 0}).source_control_file->core_paragraph->dependencies = {
        Dependency{"c", {}, {}, DependencyConstraint{}},
        Dependency{"d", {}, {}, DependencyConstraint{}},
    };
    vp.emplace("c", {"1", 0}).source_control_file->core_paragraph->dependencies = {
        Dependency{"d", {}, {}, DependencyConstraint{}},
    };
    vp.emplace("d", {"1", 0});

    MockCMakeVarProvider var_provider;

    auto install_plan =
        unwrap(Dependencies::create_versioned_install_plan(vp, bp, var_provider, {{"a"}}, {}, Test::X86_WINDOWS));

    CHECK(install_plan.size() == 4);

    StringLiteral names[] = {"d", "c", "b", "a"};
    for (size_t i = 0; i < install_plan.install_actions.size() && i < 4; ++i)
    {
        CHECK(install_plan.install_actions[i].spec.name() == names[i]);
    }
}

TEST_CASE ("basic version install scheme baseline missing", "[versionplan]")
{
    MockBaselineProvider bp;

    MockVersionedPortfileProvider vp;
    vp.emplace("a", {"1", 0});

    MockCMakeVarProvider var_provider;

    auto install_plan =
        Dependencies::create_versioned_install_plan(vp, bp, var_provider, {{"a"}}, {}, Test::X86_WINDOWS);

    REQUIRE(!install_plan.has_value());
}

TEST_CASE ("basic version install scheme baseline missing success", "[versionplan]")
{
    MockBaselineProvider bp;

    MockVersionedPortfileProvider vp;
    vp.emplace("a", {"1", 0});
    vp.emplace("a", {"2", 0});
    vp.emplace("a", {"3", 0});

    MockCMakeVarProvider var_provider;

    auto install_plan =
        unwrap(Dependencies::create_versioned_install_plan(vp,
                                                           bp,
                                                           var_provider,
                                                           {
                                                               Dependency{"a", {}, {}, {Constraint::Type::Exact, "2"}},
                                                           },
                                                           {},
                                                           Test::X86_WINDOWS));

    REQUIRE(install_plan.size() == 1);
    REQUIRE(install_plan.install_actions[0].spec.name() == "a");
    REQUIRE(install_plan.install_actions[0].source_control_file_location.has_value());
    REQUIRE(install_plan.install_actions[0]
                .source_control_file_location.get()
                ->source_control_file->core_paragraph->version == "2");
}

TEST_CASE ("basic version install scheme baseline", "[versionplan]")
{
    MockBaselineProvider bp;
    bp.v["a"] = {"2", 0};

    MockVersionedPortfileProvider vp;
    vp.emplace("a", {"1", 0});
    vp.emplace("a", {"2", 0});
    vp.emplace("a", {"3", 0});

    MockCMakeVarProvider var_provider;

    auto install_plan =
        unwrap(Dependencies::create_versioned_install_plan(vp, bp, var_provider, {{"a"}}, {}, Test::X86_WINDOWS));

    REQUIRE(install_plan.size() == 1);
    REQUIRE(install_plan.install_actions[0].spec.name() == "a");
    REQUIRE(install_plan.install_actions[0].source_control_file_location.has_value());
    REQUIRE(install_plan.install_actions[0]
                .source_control_file_location.get()
                ->source_control_file->core_paragraph->version == "2");
}

TEST_CASE ("version string baseline agree", "[versionplan]")
{
    MockBaselineProvider bp;
    bp.v["a"] = {"2", 0};

    MockVersionedPortfileProvider vp;
    vp.emplace("a", {"1", 0});
    vp.emplace("a", {"2", 0});
    vp.emplace("a", {"3", 0});

    MockCMakeVarProvider var_provider;

    auto install_plan =
        Dependencies::create_versioned_install_plan(vp,
                                                    bp,
                                                    var_provider,
                                                    {
                                                        Dependency{"a", {}, {}, {Constraint::Type::Exact, "2"}},
                                                    },
                                                    {},
                                                    Test::X86_WINDOWS);

    REQUIRE(install_plan.has_value());
}

TEST_CASE ("version install scheme baseline conflict", "[versionplan]")
{
    MockBaselineProvider bp;
    bp.v["a"] = {"2", 0};

    MockVersionedPortfileProvider vp;
    vp.emplace("a", {"1", 0});
    vp.emplace("a", {"2", 0});
    vp.emplace("a", {"3", 0});

    MockCMakeVarProvider var_provider;

    auto install_plan =
        Dependencies::create_versioned_install_plan(vp,
                                                    bp,
                                                    var_provider,
                                                    {
                                                        Dependency{"a", {}, {}, {Constraint::Type::Exact, "3"}},
                                                    },
                                                    {},
                                                    Test::X86_WINDOWS);

    REQUIRE(!install_plan.has_value());
}

TEST_CASE ("version install string port version", "[versionplan]")
{
    MockBaselineProvider bp;
    bp.v["a"] = {"2", 0};

    MockVersionedPortfileProvider vp;
    vp.emplace("a", {"2", 0});
    vp.emplace("a", {"2", 1});
    vp.emplace("a", {"2", 2});

    MockCMakeVarProvider var_provider;

    auto install_plan = unwrap(
        Dependencies::create_versioned_install_plan(vp,
                                                    bp,
                                                    var_provider,
                                                    {
                                                        Dependency{"a", {}, {}, {Constraint::Type::Exact, "2", 1}},
                                                    },
                                                    {},
                                                    Test::X86_WINDOWS));

    REQUIRE(install_plan.size() == 1);
    REQUIRE(install_plan.install_actions[0]
                .source_control_file_location.get()
                ->source_control_file->core_paragraph->port_version == 1);
}

TEST_CASE ("version install string port version 2", "[versionplan]")
{
    MockBaselineProvider bp;
    bp.v["a"] = {"2", 1};

    MockVersionedPortfileProvider vp;
    vp.emplace("a", {"2", 0});
    vp.emplace("a", {"2", 1});
    vp.emplace("a", {"2", 2});

    MockCMakeVarProvider var_provider;

    auto install_plan = unwrap(
        Dependencies::create_versioned_install_plan(vp,
                                                    bp,
                                                    var_provider,
                                                    {
                                                        Dependency{"a", {}, {}, {Constraint::Type::Exact, "2", 0}},
                                                    },
                                                    {},
                                                    Test::X86_WINDOWS));

    REQUIRE(install_plan.size() == 1);
    REQUIRE(install_plan.install_actions[0]
                .source_control_file_location.get()
                ->source_control_file->core_paragraph->port_version == 1);
}
