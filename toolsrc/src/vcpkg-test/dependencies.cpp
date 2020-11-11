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

    ExpectedS<const SourceControlFileLocation&> get_control_file(const std::string& name,
                                                                 const vcpkg::Versions::Version& version) override
    {
        auto it = v.find(name);
        if (it == v.end()) return std::string("Unknown port name");
        auto it2 = it->second.find(version);
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
    if (!e.has_value())
    {
        INFO(e.error());
        REQUIRE(false);
    }
    return std::move(*e.get());
}

static void check_name_and_version(const Dependencies::InstallPlanAction& ipa,
                                   StringLiteral name,
                                   Versions::Version v,
                                   View<StringLiteral> features = {})
{
    CHECK(ipa.spec.name() == name);
    CHECK(ipa.source_control_file_location.has_value());
    CHECK(ipa.feature_list.size() == features.size() + 1);
    {
        INFO("ipa.feature_list = [" << Strings::join(", ", ipa.feature_list) << "]");
        for (auto&& f : features)
        {
            INFO("f = \"" << f.c_str() << "\"");
            CHECK(Util::find(ipa.feature_list, f) != ipa.feature_list.end());
        }
        CHECK(Util::find(ipa.feature_list, "core") != ipa.feature_list.end());
    }
    if (auto scfl = ipa.source_control_file_location.get())
    {
        CHECK(scfl->source_control_file->core_paragraph->version == v.text);
        CHECK(scfl->source_control_file->core_paragraph->port_version == v.port_version);
    }
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
    check_name_and_version(install_plan.install_actions[0], "a", {"2", 0});
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
    check_name_and_version(install_plan.install_actions[0], "a", {"2", 0});
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
    check_name_and_version(install_plan.install_actions[0], "a", {"2", 1});
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
    check_name_and_version(install_plan.install_actions[0], "a", {"2", 1});
}

TEST_CASE ("version install transitive string", "[versionplan]")
{
    MockBaselineProvider bp;
    bp.v["a"] = {"2", 0};

    MockVersionedPortfileProvider vp;
    vp.emplace("a", {"2", 0}).source_control_file->core_paragraph->dependencies = {
        Dependency{"b", {}, {}, DependencyConstraint{Constraint::Type::Exact, "1"}},
    };
    vp.emplace("a", {"2", 1}).source_control_file->core_paragraph->dependencies = {
        Dependency{"b", {}, {}, DependencyConstraint{Constraint::Type::Exact, "2"}},
    };
    vp.emplace("b", {"1", 0});
    vp.emplace("b", {"2", 0});

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

    REQUIRE(install_plan.size() == 2);
    check_name_and_version(install_plan.install_actions[0], "b", {"2", 0});
    check_name_and_version(install_plan.install_actions[1], "a", {"2", 1});
}

TEST_CASE ("version install simple relaxed", "[versionplan]")
{
    MockBaselineProvider bp;
    bp.v["a"] = {"2", 0};

    MockVersionedPortfileProvider vp;
    vp.emplace("a", {"2", 0}, Scheme::Relaxed);
    vp.emplace("a", {"3", 0}, Scheme::Relaxed);

    MockCMakeVarProvider var_provider;

    auto install_plan = unwrap(
        Dependencies::create_versioned_install_plan(vp,
                                                    bp,
                                                    var_provider,
                                                    {
                                                        Dependency{"a", {}, {}, {Constraint::Type::Minimum, "3", 0}},
                                                    },
                                                    {},
                                                    Test::X86_WINDOWS));

    REQUIRE(install_plan.size() == 1);
    check_name_and_version(install_plan.install_actions[0], "a", {"3", 0});
}

TEST_CASE ("version install transitive relaxed", "[versionplan]")
{
    MockBaselineProvider bp;
    bp.v["a"] = {"2", 0};
    bp.v["b"] = {"2", 0};

    MockVersionedPortfileProvider vp;
    vp.emplace("a", {"2", 0}, Scheme::Relaxed);
    vp.emplace("a", {"3", 0}, Scheme::Relaxed).source_control_file->core_paragraph->dependencies = {
        Dependency{"b", {}, {}, DependencyConstraint{Constraint::Type::Minimum, "3"}},
    };
    vp.emplace("b", {"2", 0}, Scheme::Relaxed);
    vp.emplace("b", {"3", 0}, Scheme::Relaxed);

    MockCMakeVarProvider var_provider;

    auto install_plan = unwrap(
        Dependencies::create_versioned_install_plan(vp,
                                                    bp,
                                                    var_provider,
                                                    {
                                                        Dependency{"a", {}, {}, {Constraint::Type::Minimum, "3", 0}},
                                                    },
                                                    {},
                                                    Test::X86_WINDOWS));

    REQUIRE(install_plan.size() == 2);
    check_name_and_version(install_plan.install_actions[0], "b", {"3", 0});
    check_name_and_version(install_plan.install_actions[1], "a", {"3", 0});
}

TEST_CASE ("version install diamond relaxed", "[versionplan]")
{
    MockBaselineProvider bp;
    bp.v["a"] = {"2", 0};
    bp.v["b"] = {"3", 0};

    MockVersionedPortfileProvider vp;
    vp.emplace("a", {"2", 0}, Scheme::Relaxed);
    vp.emplace("a", {"3", 0}, Scheme::Relaxed).source_control_file->core_paragraph->dependencies = {
        Dependency{"b", {}, {}, DependencyConstraint{Constraint::Type::Minimum, "2", 1}},
        Dependency{"c", {}, {}, DependencyConstraint{Constraint::Type::Minimum, "5", 1}},
    };
    vp.emplace("b", {"2", 1}, Scheme::Relaxed);
    vp.emplace("b", {"3", 0}, Scheme::Relaxed).source_control_file->core_paragraph->dependencies = {
        Dependency{"c", {}, {}, DependencyConstraint{Constraint::Type::Minimum, "9", 2}},
    };
    vp.emplace("c", {"5", 1}, Scheme::Relaxed);
    vp.emplace("c", {"9", 2}, Scheme::Relaxed);

    MockCMakeVarProvider var_provider;

    auto install_plan = unwrap(
        Dependencies::create_versioned_install_plan(vp,
                                                    bp,
                                                    var_provider,
                                                    {
                                                        Dependency{"a", {}, {}, {Constraint::Type::Minimum, "3", 0}},
                                                        Dependency{"b", {}, {}, {Constraint::Type::Minimum, "2", 1}},
                                                    },
                                                    {},
                                                    Test::X86_WINDOWS));

    REQUIRE(install_plan.size() == 3);
    check_name_and_version(install_plan.install_actions[0], "c", {"9", 2});
    check_name_and_version(install_plan.install_actions[1], "b", {"3", 0});
    check_name_and_version(install_plan.install_actions[2], "a", {"3", 0});
}

TEST_CASE ("version install scheme change in port version", "[versionplan]")
{
    MockVersionedPortfileProvider vp;
    vp.emplace("a", {"2", 0}).source_control_file->core_paragraph->dependencies = {
        Dependency{"b", {}, {}, DependencyConstraint{Constraint::Type::Exact, "1"}},
    };
    vp.emplace("a", {"2", 1}).source_control_file->core_paragraph->dependencies = {
        Dependency{"b", {}, {}, DependencyConstraint{Constraint::Type::Minimum, "1", 1}},
    };
    vp.emplace("b", {"1", 0}, Scheme::String);
    vp.emplace("b", {"1", 1}, Scheme::Relaxed);

    MockCMakeVarProvider var_provider;

    SECTION ("lower baseline")
    {
        MockBaselineProvider bp;
        bp.v["a"] = {"2", 0};

        auto install_plan = unwrap(
            Dependencies::create_versioned_install_plan(vp,
                                                        bp,
                                                        var_provider,
                                                        {
                                                            Dependency{"a", {}, {}, {Constraint::Type::Exact, "2", 1}},
                                                        },
                                                        {},
                                                        Test::X86_WINDOWS));

        REQUIRE(install_plan.size() == 2);
        check_name_and_version(install_plan.install_actions[0], "b", {"1", 1});
        check_name_and_version(install_plan.install_actions[1], "a", {"2", 1});
    }
    SECTION ("higher baseline")
    {
        MockBaselineProvider bp;
        bp.v["a"] = {"2", 1};

        auto install_plan = unwrap(
            Dependencies::create_versioned_install_plan(vp,
                                                        bp,
                                                        var_provider,
                                                        {
                                                            Dependency{"a", {}, {}, {Constraint::Type::Exact, "2", 0}},
                                                        },
                                                        {},
                                                        Test::X86_WINDOWS));

        REQUIRE(install_plan.size() == 2);
        check_name_and_version(install_plan.install_actions[0], "b", {"1", 1});
        check_name_and_version(install_plan.install_actions[1], "a", {"2", 1});
    }
}

TEST_CASE ("version install simple feature", "[versionplan]")
{
    MockVersionedPortfileProvider vp;
    auto a_x = std::make_unique<FeatureParagraph>();
    a_x->name = "x";
    vp.emplace("a", {"1", 0}, Scheme::Relaxed).source_control_file->feature_paragraphs.push_back(std::move(a_x));

    MockCMakeVarProvider var_provider;

    SECTION ("with baseline")
    {
        MockBaselineProvider bp;
        bp.v["a"] = {"1", 0};

        auto install_plan = unwrap(Dependencies::create_versioned_install_plan(vp,
                                                                               bp,
                                                                               var_provider,
                                                                               {
                                                                                   Dependency{"a", {"x"}},
                                                                               },
                                                                               {},
                                                                               Test::X86_WINDOWS));

        REQUIRE(install_plan.size() == 1);
        check_name_and_version(install_plan.install_actions[0], "a", {"1", 0}, {"x"});
    }

    SECTION ("without baseline")
    {
        MockBaselineProvider bp;

        auto install_plan = unwrap(Dependencies::create_versioned_install_plan(
            vp,
            bp,
            var_provider,
            {
                Dependency{"a", {"x"}, {}, {Constraint::Type::Minimum, "1", 0}},
            },
            {},
            Test::X86_WINDOWS));

        REQUIRE(install_plan.size() == 1);
        check_name_and_version(install_plan.install_actions[0], "a", {"1", 0}, {"x"});
    }
}

static std::unique_ptr<FeatureParagraph> make_fpgh(std::string name)
{
    auto f = std::make_unique<FeatureParagraph>();
    f->name = std::move(name);
    return f;
}

TEST_CASE ("version install transitive features", "[versionplan]")
{
    MockVersionedPortfileProvider vp;

    auto a_x = make_fpgh("x");
    a_x->dependencies.push_back(Dependency{"b", {"y"}});
    vp.emplace("a", {"1", 0}, Scheme::Relaxed).source_control_file->feature_paragraphs.push_back(std::move(a_x));

    auto b_y = make_fpgh("y");
    vp.emplace("b", {"1", 0}, Scheme::Relaxed).source_control_file->feature_paragraphs.push_back(std::move(b_y));

    MockCMakeVarProvider var_provider;

    MockBaselineProvider bp;
    bp.v["a"] = {"1", 0};
    bp.v["b"] = {"1", 0};

    auto install_plan = unwrap(Dependencies::create_versioned_install_plan(vp,
                                                                           bp,
                                                                           var_provider,
                                                                           {
                                                                               Dependency{"a", {"x"}},
                                                                           },
                                                                           {},
                                                                           Test::X86_WINDOWS));

    REQUIRE(install_plan.size() == 2);
    check_name_and_version(install_plan.install_actions[0], "b", {"1", 0}, {"y"});
    check_name_and_version(install_plan.install_actions[1], "a", {"1", 0}, {"x"});
}

TEST_CASE ("version install transitive feature versioned", "[versionplan]")
{
    MockVersionedPortfileProvider vp;

    auto a_x = make_fpgh("x");
    a_x->dependencies.push_back(Dependency{"b", {"y"}, {}, {Constraint::Type::Minimum, "2", 0}});
    vp.emplace("a", {"1", 0}, Scheme::Relaxed).source_control_file->feature_paragraphs.push_back(std::move(a_x));

    {
        auto b_y = make_fpgh("y");
        vp.emplace("b", {"1", 0}, Scheme::Relaxed).source_control_file->feature_paragraphs.push_back(std::move(b_y));
    }
    {
        auto b_y = make_fpgh("y");
        b_y->dependencies.push_back(Dependency{"c"});
        vp.emplace("b", {"2", 0}, Scheme::Relaxed).source_control_file->feature_paragraphs.push_back(std::move(b_y));
    }

    vp.emplace("c", {"1", 0}, Scheme::Relaxed);

    MockCMakeVarProvider var_provider;

    MockBaselineProvider bp;
    bp.v["a"] = {"1", 0};
    bp.v["c"] = {"1", 0};

    auto install_plan = unwrap(Dependencies::create_versioned_install_plan(vp,
                                                                           bp,
                                                                           var_provider,
                                                                           {
                                                                               Dependency{"a", {"x"}},
                                                                           },
                                                                           {},
                                                                           Test::X86_WINDOWS));

    REQUIRE(install_plan.size() == 3);
    check_name_and_version(install_plan.install_actions[0], "c", {"1", 0});
    check_name_and_version(install_plan.install_actions[1], "b", {"2", 0}, {"y"});
    check_name_and_version(install_plan.install_actions[2], "a", {"1", 0}, {"x"});
}

TEST_CASE ("version install constraint-reduction", "[versionplan]")
{
    MockCMakeVarProvider var_provider;

    SECTION ("higher baseline")
    {
        MockVersionedPortfileProvider vp;

        vp.emplace("b", {"1", 0}, Scheme::Relaxed).source_control_file->core_paragraph->dependencies = {
            Dependency{"c", {}, {}, {Constraint::Type::Minimum, "2"}},
        };
        vp.emplace("b", {"2", 0}, Scheme::Relaxed).source_control_file->core_paragraph->dependencies = {
            Dependency{"c", {}, {}, {Constraint::Type::Minimum, "1"}},
        };

        vp.emplace("c", {"1", 0}, Scheme::Relaxed);
        // c@2 is used to detect if certain constraints were evaluated
        vp.emplace("c", {"2", 0}, Scheme::Relaxed);

        MockBaselineProvider bp;
        bp.v["b"] = {"2", 0};
        bp.v["c"] = {"1", 0};

        auto install_plan = unwrap(
            Dependencies::create_versioned_install_plan(vp,
                                                        bp,
                                                        var_provider,
                                                        {
                                                            Dependency{"b", {}, {}, {Constraint::Type::Minimum, "1"}},
                                                        },
                                                        {},
                                                        Test::X86_WINDOWS));

        REQUIRE(install_plan.size() == 2);
        check_name_and_version(install_plan.install_actions[0], "c", {"1", 0});
        check_name_and_version(install_plan.install_actions[1], "b", {"2", 0});
    }

    SECTION ("higher toplevel")
    {
        MockVersionedPortfileProvider vp;

        vp.emplace("b", {"1", 0}, Scheme::Relaxed).source_control_file->core_paragraph->dependencies = {
            Dependency{"c", {}, {}, {Constraint::Type::Minimum, "2"}},
        };
        vp.emplace("b", {"2", 0}, Scheme::Relaxed).source_control_file->core_paragraph->dependencies = {
            Dependency{"c", {}, {}, {Constraint::Type::Minimum, "1"}},
        };

        vp.emplace("c", {"1", 0}, Scheme::Relaxed);
        // c@2 is used to detect if certain constraints were evaluated
        vp.emplace("c", {"2", 0}, Scheme::Relaxed);

        MockBaselineProvider bp;
        bp.v["b"] = {"1", 0};
        bp.v["c"] = {"1", 0};

        auto install_plan = unwrap(
            Dependencies::create_versioned_install_plan(vp,
                                                        bp,
                                                        var_provider,
                                                        {
                                                            Dependency{"b", {}, {}, {Constraint::Type::Minimum, "2"}},
                                                        },
                                                        {},
                                                        Test::X86_WINDOWS));

        REQUIRE(install_plan.size() == 2);
        check_name_and_version(install_plan.install_actions[0], "c", {"1", 0});
        check_name_and_version(install_plan.install_actions[1], "b", {"2", 0});
    }
}
