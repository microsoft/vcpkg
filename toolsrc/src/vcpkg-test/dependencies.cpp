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
    mutable std::map<std::string, Versions::Version, std::less<>> v;

    Optional<Versions::Version> get_baseline_version(StringView name) const override
    {
        auto it = v.find(name);
        if (it == v.end()) return nullopt;
        return it->second;
    }
};

struct MockVersionedPortfileProvider : PortFileProvider::IVersionedPortfileProvider
{
    mutable std::map<std::string, std::map<Versions::Version, SourceControlFileLocation, VersionTMapLess>> v;

    ExpectedS<const SourceControlFileLocation&> get_control_file(
        const vcpkg::Versions::VersionSpec& versionspec) const override
    {
        return get_control_file(versionspec.port_name, versionspec.version);
    }

    ExpectedS<const SourceControlFileLocation&> get_control_file(const std::string& name,
                                                                 const vcpkg::Versions::Version& version) const
    {
        auto it = v.find(name);
        if (it == v.end()) return std::string("Unknown port name");
        auto it2 = it->second.find(version);
        if (it2 == it->second.end()) return std::string("Unknown port version");
        return it2->second;
    }

    virtual View<vcpkg::VersionT> get_port_versions(StringView) const override { Checks::unreachable(VCPKG_LINE_INFO); }

    SourceControlFileLocation& emplace(std::string&& name,
                                       Versions::Version&& version,
                                       Versions::Scheme scheme = Versions::Scheme::String)
    {
        auto it = v.find(name);
        if (it == v.end())
            it = v.emplace(name, std::map<Versions::Version, SourceControlFileLocation, VersionTMapLess>{}).first;

        auto it2 = it->second.find(version);
        if (it2 == it->second.end())
        {
            auto scf = std::make_unique<SourceControlFile>();
            auto core = std::make_unique<SourceParagraph>();
            core->name = name;
            core->version = version.text();
            core->port_version = version.port_version();
            core->version_scheme = scheme;
            scf->core_paragraph = std::move(core);
            it2 = it->second.emplace(version, SourceControlFileLocation{std::move(scf), fs::u8path(name)}).first;
        }
        return it2->second;
    }

    virtual void load_all_control_files(std::map<std::string, const SourceControlFileLocation*>&) const override
    {
        Checks::unreachable(VCPKG_LINE_INFO);
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
                                   std::initializer_list<StringLiteral> features = {})
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
        CHECK(scfl->source_control_file->core_paragraph->version == v.text());
        CHECK(scfl->source_control_file->core_paragraph->port_version == v.port_version());
    }
}

static void check_semver_version(const ExpectedS<Versions::SemanticVersion>& maybe_version,
                                 const std::string& version_string,
                                 const std::string& prerelease_string,
                                 uint64_t major,
                                 uint64_t minor,
                                 uint64_t patch,
                                 const std::vector<std::string>& identifiers)
{
    auto actual_version = unwrap(maybe_version);
    CHECK(actual_version.version_string == version_string);
    CHECK(actual_version.prerelease_string == prerelease_string);
    REQUIRE(actual_version.version.size() == 3);
    CHECK(actual_version.version[0] == major);
    CHECK(actual_version.version[1] == minor);
    CHECK(actual_version.version[2] == patch);
    CHECK(actual_version.identifiers == identifiers);
}

static void check_relaxed_version(const ExpectedS<Versions::RelaxedVersion>& maybe_version,
                                  const std::vector<uint64_t>& version)
{
    auto actual_version = unwrap(maybe_version);
    CHECK(actual_version.version == version);
}

static void check_date_version(const ExpectedS<Versions::DateVersion>& maybe_version,
                               const std::string& version_string,
                               const std::string& identifiers_string,
                               const std::vector<uint64_t>& identifiers)
{
    auto actual_version = unwrap(maybe_version);
    CHECK(actual_version.version_string == version_string);
    CHECK(actual_version.identifiers_string == identifiers_string);
    CHECK(actual_version.identifiers == identifiers);
}

static const PackageSpec& toplevel_spec()
{
    static const PackageSpec ret("toplevel-spec", Test::X86_WINDOWS);
    return ret;
}

struct MockOverlayProvider : PortFileProvider::IOverlayProvider, Util::ResourceBase
{
    virtual Optional<const SourceControlFileLocation&> get_control_file(StringView name) const override
    {
        auto it = mappings.find(name);
        if (it != mappings.end())
            return it->second;
        else
            return nullopt;
    }

    SourceControlFileLocation& emplace(const std::string& name,
                                       Versions::Version&& version,
                                       Versions::Scheme scheme = Versions::Scheme::String)
    {
        auto it = mappings.find(name);
        if (it == mappings.end())
        {
            auto scf = std::make_unique<SourceControlFile>();
            auto core = std::make_unique<SourceParagraph>();
            core->name = name;
            core->version = version.text();
            core->port_version = version.port_version();
            core->version_scheme = scheme;
            scf->core_paragraph = std::move(core);
            it = mappings.emplace(name, SourceControlFileLocation{std::move(scf), fs::u8path(name)}).first;
        }
        return it->second;
    }

    virtual void load_all_control_files(std::map<std::string, const SourceControlFileLocation*>&) const override
    {
        Checks::unreachable(VCPKG_LINE_INFO);
    }

private:
    std::map<std::string, SourceControlFileLocation, std::less<>> mappings;
};

static const MockOverlayProvider s_empty_mock_overlay;

static ExpectedS<Dependencies::ActionPlan> create_versioned_install_plan(
    const PortFileProvider::IVersionedPortfileProvider& provider,
    const PortFileProvider::IBaselineProvider& bprovider,
    const CMakeVars::CMakeVarProvider& var_provider,
    const std::vector<Dependency>& deps,
    const std::vector<DependencyOverride>& overrides,
    const PackageSpec& toplevel)
{
    return Dependencies::create_versioned_install_plan(
        provider, bprovider, s_empty_mock_overlay, var_provider, deps, overrides, toplevel);
}

TEST_CASE ("basic version install single", "[versionplan]")
{
    MockBaselineProvider bp;
    bp.v["a"] = {"1", 0};

    MockVersionedPortfileProvider vp;
    vp.emplace("a", {"1", 0});

    MockCMakeVarProvider var_provider;

    auto install_plan = unwrap(create_versioned_install_plan(vp, bp, var_provider, {{"a"}}, {}, toplevel_spec()));

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

    auto install_plan = create_versioned_install_plan(vp, bp, var_provider, {{"a"}}, {}, toplevel_spec());

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

    auto install_plan = unwrap(create_versioned_install_plan(vp, bp, var_provider, {{"a"}}, {}, toplevel_spec()));

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

    auto install_plan = unwrap(create_versioned_install_plan(vp, bp, var_provider, {{"a"}}, {}, toplevel_spec()));

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

    auto install_plan = create_versioned_install_plan(vp, bp, var_provider, {{"a"}}, {}, toplevel_spec());

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
        unwrap(create_versioned_install_plan(vp,
                                             bp,
                                             var_provider,
                                             {
                                                 Dependency{"a", {}, {}, {Constraint::Type::Minimum, "2"}},
                                             },
                                             {},
                                             toplevel_spec()));

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

    auto install_plan = unwrap(create_versioned_install_plan(vp, bp, var_provider, {{"a"}}, {}, toplevel_spec()));

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

    auto install_plan = create_versioned_install_plan(
        vp, bp, var_provider, {Dependency{"a", {}, {}, {Constraint::Type::Minimum, "2"}}}, {}, toplevel_spec());

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

    auto install_plan = create_versioned_install_plan(vp,
                                                      bp,
                                                      var_provider,
                                                      {
                                                          Dependency{"a", {}, {}, {Constraint::Type::Minimum, "3"}},
                                                      },
                                                      {},
                                                      toplevel_spec());

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

    auto install_plan =
        unwrap(create_versioned_install_plan(vp,
                                             bp,
                                             var_provider,
                                             {
                                                 Dependency{"a", {}, {}, {Constraint::Type::Minimum, "2", 1}},
                                             },
                                             {},
                                             toplevel_spec()));

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

    auto install_plan =
        unwrap(create_versioned_install_plan(vp,
                                             bp,
                                             var_provider,
                                             {
                                                 Dependency{"a", {}, {}, {Constraint::Type::Minimum, "2", 0}},
                                             },
                                             {},
                                             toplevel_spec()));

    REQUIRE(install_plan.size() == 1);
    check_name_and_version(install_plan.install_actions[0], "a", {"2", 1});
}

TEST_CASE ("version install transitive string", "[versionplan]")
{
    MockBaselineProvider bp;
    bp.v["a"] = {"2", 0};

    MockVersionedPortfileProvider vp;
    vp.emplace("a", {"2", 0}).source_control_file->core_paragraph->dependencies = {
        Dependency{"b", {}, {}, DependencyConstraint{Constraint::Type::Minimum, "1"}},
    };
    vp.emplace("a", {"2", 1}).source_control_file->core_paragraph->dependencies = {
        Dependency{"b", {}, {}, DependencyConstraint{Constraint::Type::Minimum, "2"}},
    };
    vp.emplace("b", {"1", 0});
    vp.emplace("b", {"2", 0});

    MockCMakeVarProvider var_provider;

    auto install_plan =
        unwrap(create_versioned_install_plan(vp,
                                             bp,
                                             var_provider,
                                             {
                                                 Dependency{"a", {}, {}, {Constraint::Type::Minimum, "2", 1}},
                                             },
                                             {},
                                             toplevel_spec()));

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

    auto install_plan =
        unwrap(create_versioned_install_plan(vp,
                                             bp,
                                             var_provider,
                                             {
                                                 Dependency{"a", {}, {}, {Constraint::Type::Minimum, "3", 0}},
                                             },
                                             {},
                                             toplevel_spec()));

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

    auto install_plan =
        unwrap(create_versioned_install_plan(vp,
                                             bp,
                                             var_provider,
                                             {
                                                 Dependency{"a", {}, {}, {Constraint::Type::Minimum, "3", 0}},
                                             },
                                             {},
                                             toplevel_spec()));

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

    auto install_plan =
        unwrap(create_versioned_install_plan(vp,
                                             bp,
                                             var_provider,
                                             {
                                                 Dependency{"a", {}, {}, {Constraint::Type::Minimum, "3", 0}},
                                                 Dependency{"b", {}, {}, {Constraint::Type::Minimum, "2", 1}},
                                             },
                                             {},
                                             toplevel_spec()));

    REQUIRE(install_plan.size() == 3);
    check_name_and_version(install_plan.install_actions[0], "c", {"9", 2});
    check_name_and_version(install_plan.install_actions[1], "b", {"3", 0});
    check_name_and_version(install_plan.install_actions[2], "a", {"3", 0});
}

TEST_CASE ("version parse semver", "[versionplan]")
{
    auto version_basic = Versions::SemanticVersion::from_string("1.2.3");
    check_semver_version(version_basic, "1.2.3", "", 1, 2, 3, {});

    auto version_simple_tag = Versions::SemanticVersion::from_string("1.0.0-alpha");
    check_semver_version(version_simple_tag, "1.0.0", "alpha", 1, 0, 0, {"alpha"});

    auto version_alphanumeric_tag = Versions::SemanticVersion::from_string("1.0.0-0alpha0");
    check_semver_version(version_alphanumeric_tag, "1.0.0", "0alpha0", 1, 0, 0, {"0alpha0"});

    auto version_complex_tag = Versions::SemanticVersion::from_string("1.0.0-alpha.1.0.0");
    check_semver_version(version_complex_tag, "1.0.0", "alpha.1.0.0", 1, 0, 0, {"alpha", "1", "0", "0"});

    auto version_complexer_tag = Versions::SemanticVersion::from_string("1.0.0-alpha.1.x.y.z.0-alpha.0-beta.l-a-s-t");
    check_semver_version(version_complexer_tag,
                         "1.0.0",
                         "alpha.1.x.y.z.0-alpha.0-beta.l-a-s-t",
                         1,
                         0,
                         0,
                         {"alpha", "1", "x", "y", "z", "0-alpha", "0-beta", "l-a-s-t"});

    auto version_ridiculous_tag = Versions::SemanticVersion::from_string("1.0.0----------------------------------");
    check_semver_version(version_ridiculous_tag,
                         "1.0.0",
                         "---------------------------------",
                         1,
                         0,
                         0,
                         {"---------------------------------"});

    auto version_build_tag = Versions::SemanticVersion::from_string("1.0.0+build");
    check_semver_version(version_build_tag, "1.0.0", "", 1, 0, 0, {});

    auto version_prerelease_build_tag = Versions::SemanticVersion::from_string("1.0.0-alpha+build");
    check_semver_version(version_prerelease_build_tag, "1.0.0", "alpha", 1, 0, 0, {"alpha"});

    auto version_invalid_incomplete = Versions::SemanticVersion::from_string("1.0-alpha");
    CHECK(!version_invalid_incomplete.has_value());

    auto version_invalid_leading_zeroes = Versions::SemanticVersion::from_string("1.02.03-alpha+build");
    CHECK(!version_invalid_leading_zeroes.has_value());

    auto version_invalid_leading_zeroes_in_tag = Versions::SemanticVersion::from_string("1.0.0-01");
    CHECK(!version_invalid_leading_zeroes_in_tag.has_value());

    auto version_invalid_characters = Versions::SemanticVersion::from_string("1.0.0-alpha#2");
    CHECK(!version_invalid_characters.has_value());
}

TEST_CASE ("version parse relaxed", "[versionplan]")
{
    auto version_basic = Versions::RelaxedVersion::from_string("1.2.3");
    check_relaxed_version(version_basic, {1, 2, 3});

    auto version_short = Versions::RelaxedVersion::from_string("1");
    check_relaxed_version(version_short, {1});

    auto version_long =
        Versions::RelaxedVersion::from_string("1.20.300.4000.50000.6000000.70000000.80000000.18446744073709551610");
    check_relaxed_version(version_long, {1, 20, 300, 4000, 50000, 6000000, 70000000, 80000000, 18446744073709551610u});

    auto version_invalid_characters = Versions::RelaxedVersion::from_string("1.a.0");
    CHECK(!version_invalid_characters.has_value());

    auto version_invalid_identifiers_2 = Versions::RelaxedVersion::from_string("1.1a.2");
    CHECK(!version_invalid_identifiers_2.has_value());

    auto version_invalid_leading_zeroes = Versions::RelaxedVersion::from_string("01.002.003");
    CHECK(!version_invalid_leading_zeroes.has_value());
}

TEST_CASE ("version parse date", "[versionplan]")
{
    auto version_basic = Versions::DateVersion::from_string("2020-12-25");
    check_date_version(version_basic, "2020-12-25", "", {});

    auto version_identifiers = Versions::DateVersion::from_string("2020-12-25.1.2.3");
    check_date_version(version_identifiers, "2020-12-25", "1.2.3", {1, 2, 3});

    auto version_invalid_date = Versions::DateVersion::from_string("2020-1-1");
    CHECK(!version_invalid_date.has_value());

    auto version_invalid_identifiers = Versions::DateVersion::from_string("2020-01-01.alpha");
    CHECK(!version_invalid_identifiers.has_value());

    auto version_invalid_identifiers_2 = Versions::DateVersion::from_string("2020-01-01.2a");
    CHECK(!version_invalid_identifiers_2.has_value());

    auto version_invalid_leading_zeroes = Versions::DateVersion::from_string("2020-01-01.01");
    CHECK(!version_invalid_leading_zeroes.has_value());
}

TEST_CASE ("version sort semver", "[versionplan]")
{
    std::vector<Versions::SemanticVersion> versions{unwrap(Versions::SemanticVersion::from_string("1.0.0")),
                                                    unwrap(Versions::SemanticVersion::from_string("0.0.0")),
                                                    unwrap(Versions::SemanticVersion::from_string("1.1.0")),
                                                    unwrap(Versions::SemanticVersion::from_string("2.0.0")),
                                                    unwrap(Versions::SemanticVersion::from_string("1.1.1")),
                                                    unwrap(Versions::SemanticVersion::from_string("1.0.1")),
                                                    unwrap(Versions::SemanticVersion::from_string("1.0.0-alpha.1")),
                                                    unwrap(Versions::SemanticVersion::from_string("1.0.0-beta")),
                                                    unwrap(Versions::SemanticVersion::from_string("1.0.0-alpha")),
                                                    unwrap(Versions::SemanticVersion::from_string("1.0.0-alpha.beta")),
                                                    unwrap(Versions::SemanticVersion::from_string("1.0.0-rc")),
                                                    unwrap(Versions::SemanticVersion::from_string("1.0.0-beta.2")),
                                                    unwrap(Versions::SemanticVersion::from_string("1.0.0-beta.20")),
                                                    unwrap(Versions::SemanticVersion::from_string("1.0.0-beta.3")),
                                                    unwrap(Versions::SemanticVersion::from_string("1.0.0-1")),
                                                    unwrap(Versions::SemanticVersion::from_string("1.0.0-0alpha"))};

    std::sort(std::begin(versions), std::end(versions), [](const auto& lhs, const auto& rhs) -> bool {
        return Versions::compare(lhs, rhs) == Versions::VerComp::lt;
    });

    CHECK(versions[0].original_string == "0.0.0");
    CHECK(versions[1].original_string == "1.0.0-1");
    CHECK(versions[2].original_string == "1.0.0-0alpha");
    CHECK(versions[3].original_string == "1.0.0-alpha");
    CHECK(versions[4].original_string == "1.0.0-alpha.1");
    CHECK(versions[5].original_string == "1.0.0-alpha.beta");
    CHECK(versions[6].original_string == "1.0.0-beta");
    CHECK(versions[7].original_string == "1.0.0-beta.2");
    CHECK(versions[8].original_string == "1.0.0-beta.3");
    CHECK(versions[9].original_string == "1.0.0-beta.20");
    CHECK(versions[10].original_string == "1.0.0-rc");
    CHECK(versions[11].original_string == "1.0.0");
    CHECK(versions[12].original_string == "1.0.1");
    CHECK(versions[13].original_string == "1.1.0");
    CHECK(versions[14].original_string == "1.1.1");
    CHECK(versions[15].original_string == "2.0.0");
}

TEST_CASE ("version sort relaxed", "[versionplan]")
{
    std::vector<Versions::RelaxedVersion> versions{unwrap(Versions::RelaxedVersion::from_string("1.0.0")),
                                                   unwrap(Versions::RelaxedVersion::from_string("1.0")),
                                                   unwrap(Versions::RelaxedVersion::from_string("1")),
                                                   unwrap(Versions::RelaxedVersion::from_string("2")),
                                                   unwrap(Versions::RelaxedVersion::from_string("1.1")),
                                                   unwrap(Versions::RelaxedVersion::from_string("1.10.1")),
                                                   unwrap(Versions::RelaxedVersion::from_string("1.0.1")),
                                                   unwrap(Versions::RelaxedVersion::from_string("1.0.0.1")),
                                                   unwrap(Versions::RelaxedVersion::from_string("1.0.0.2"))};

    std::sort(std::begin(versions), std::end(versions), [](const auto& lhs, const auto& rhs) -> bool {
        return Versions::compare(lhs, rhs) == Versions::VerComp::lt;
    });

    CHECK(versions[0].original_string == "1");
    CHECK(versions[1].original_string == "1.0");
    CHECK(versions[2].original_string == "1.0.0");
    CHECK(versions[3].original_string == "1.0.0.1");
    CHECK(versions[4].original_string == "1.0.0.2");
    CHECK(versions[5].original_string == "1.0.1");
    CHECK(versions[6].original_string == "1.1");
    CHECK(versions[7].original_string == "1.10.1");
    CHECK(versions[8].original_string == "2");
}

TEST_CASE ("version sort date", "[versionplan]")
{
    std::vector<Versions::DateVersion> versions{unwrap(Versions::DateVersion::from_string("2021-01-01.2")),
                                                unwrap(Versions::DateVersion::from_string("2021-01-01.1")),
                                                unwrap(Versions::DateVersion::from_string("2021-01-01.1.1")),
                                                unwrap(Versions::DateVersion::from_string("2021-01-01.1.0")),
                                                unwrap(Versions::DateVersion::from_string("2021-01-01")),
                                                unwrap(Versions::DateVersion::from_string("2021-01-01")),
                                                unwrap(Versions::DateVersion::from_string("2020-12-25")),
                                                unwrap(Versions::DateVersion::from_string("2020-12-31")),
                                                unwrap(Versions::DateVersion::from_string("2021-01-01.10"))};

    std::sort(std::begin(versions), std::end(versions), [](const auto& lhs, const auto& rhs) -> bool {
        return Versions::compare(lhs, rhs) == Versions::VerComp::lt;
    });

    CHECK(versions[0].original_string == "2020-12-25");
    CHECK(versions[1].original_string == "2020-12-31");
    CHECK(versions[2].original_string == "2021-01-01");
    CHECK(versions[3].original_string == "2021-01-01");
    CHECK(versions[4].original_string == "2021-01-01.1");
    CHECK(versions[5].original_string == "2021-01-01.1.0");
    CHECK(versions[6].original_string == "2021-01-01.1.1");
    CHECK(versions[7].original_string == "2021-01-01.2");
    CHECK(versions[8].original_string == "2021-01-01.10");
}

TEST_CASE ("version install simple semver", "[versionplan]")
{
    MockBaselineProvider bp;
    bp.v["a"] = {"2.0.0", 0};

    MockVersionedPortfileProvider vp;
    vp.emplace("a", {"2.0.0", 0}, Scheme::Semver);
    vp.emplace("a", {"3.0.0", 0}, Scheme::Semver);

    MockCMakeVarProvider var_provider;

    auto install_plan =
        unwrap(create_versioned_install_plan(vp,
                                             bp,
                                             var_provider,
                                             {
                                                 Dependency{"a", {}, {}, {Constraint::Type::Minimum, "3.0.0", 0}},
                                             },
                                             {},
                                             toplevel_spec()));

    REQUIRE(install_plan.size() == 1);
    check_name_and_version(install_plan.install_actions[0], "a", {"3.0.0", 0});
}

TEST_CASE ("version install transitive semver", "[versionplan]")
{
    MockBaselineProvider bp;
    bp.v["a"] = {"2.0.0", 0};
    bp.v["b"] = {"2.0.0", 0};

    MockVersionedPortfileProvider vp;
    vp.emplace("a", {"2.0.0", 0}, Scheme::Semver);
    vp.emplace("a", {"3.0.0", 0}, Scheme::Semver).source_control_file->core_paragraph->dependencies = {
        Dependency{"b", {}, {}, DependencyConstraint{Constraint::Type::Minimum, "3.0.0"}},
    };
    vp.emplace("b", {"2.0.0", 0}, Scheme::Semver);
    vp.emplace("b", {"3.0.0", 0}, Scheme::Semver);

    MockCMakeVarProvider var_provider;

    auto install_plan =
        unwrap(create_versioned_install_plan(vp,
                                             bp,
                                             var_provider,
                                             {
                                                 Dependency{"a", {}, {}, {Constraint::Type::Minimum, "3.0.0", 0}},
                                             },
                                             {},
                                             toplevel_spec()));

    REQUIRE(install_plan.size() == 2);
    check_name_and_version(install_plan.install_actions[0], "b", {"3.0.0", 0});
    check_name_and_version(install_plan.install_actions[1], "a", {"3.0.0", 0});
}

TEST_CASE ("version install diamond semver", "[versionplan]")
{
    MockBaselineProvider bp;
    bp.v["a"] = {"2.0.0", 0};
    bp.v["b"] = {"3.0.0", 0};

    MockVersionedPortfileProvider vp;
    vp.emplace("a", {"2.0.0", 0}, Scheme::Semver);
    vp.emplace("a", {"3.0.0", 0}, Scheme::Semver).source_control_file->core_paragraph->dependencies = {
        Dependency{"b", {}, {}, DependencyConstraint{Constraint::Type::Minimum, "2.0.0", 1}},
        Dependency{"c", {}, {}, DependencyConstraint{Constraint::Type::Minimum, "5.0.0", 1}},
    };
    vp.emplace("b", {"2.0.0", 1}, Scheme::Semver);
    vp.emplace("b", {"3.0.0", 0}, Scheme::Semver).source_control_file->core_paragraph->dependencies = {
        Dependency{"c", {}, {}, DependencyConstraint{Constraint::Type::Minimum, "9.0.0", 2}},
    };
    vp.emplace("c", {"5.0.0", 1}, Scheme::Semver);
    vp.emplace("c", {"9.0.0", 2}, Scheme::Semver);

    MockCMakeVarProvider var_provider;

    auto install_plan =
        unwrap(create_versioned_install_plan(vp,
                                             bp,
                                             var_provider,
                                             {
                                                 Dependency{"a", {}, {}, {Constraint::Type::Minimum, "3.0.0", 0}},
                                                 Dependency{"b", {}, {}, {Constraint::Type::Minimum, "2.0.0", 1}},
                                             },
                                             {},
                                             toplevel_spec()));

    REQUIRE(install_plan.size() == 3);
    check_name_and_version(install_plan.install_actions[0], "c", {"9.0.0", 2});
    check_name_and_version(install_plan.install_actions[1], "b", {"3.0.0", 0});
    check_name_and_version(install_plan.install_actions[2], "a", {"3.0.0", 0});
}

TEST_CASE ("version install simple date", "[versionplan]")
{
    MockBaselineProvider bp;
    bp.v["a"] = {"2020-02-01", 0};

    MockVersionedPortfileProvider vp;
    vp.emplace("a", {"2020-02-01", 0}, Scheme::Date);
    vp.emplace("a", {"2020-03-01", 0}, Scheme::Date);

    MockCMakeVarProvider var_provider;

    auto install_plan =
        unwrap(create_versioned_install_plan(vp,
                                             bp,
                                             var_provider,
                                             {
                                                 Dependency{"a", {}, {}, {Constraint::Type::Minimum, "2020-03-01", 0}},
                                             },
                                             {},
                                             toplevel_spec()));

    REQUIRE(install_plan.size() == 1);
    check_name_and_version(install_plan.install_actions[0], "a", {"2020-03-01", 0});
}

TEST_CASE ("version install transitive date", "[versionplan]")
{
    MockBaselineProvider bp;
    bp.v["a"] = {"2020-01-01.2", 0};
    bp.v["b"] = {"2020-01-01.3", 0};

    MockVersionedPortfileProvider vp;
    vp.emplace("a", {"2020-01-01.2", 0}, Scheme::Date);
    vp.emplace("a", {"2020-01-01.3", 0}, Scheme::Date).source_control_file->core_paragraph->dependencies = {
        Dependency{"b", {}, {}, DependencyConstraint{Constraint::Type::Minimum, "2020-01-01.3"}},
    };
    vp.emplace("b", {"2020-01-01.2", 0}, Scheme::Date);
    vp.emplace("b", {"2020-01-01.3", 0}, Scheme::Date);

    MockCMakeVarProvider var_provider;

    auto install_plan = unwrap(
        create_versioned_install_plan(vp,
                                      bp,
                                      var_provider,
                                      {
                                          Dependency{"a", {}, {}, {Constraint::Type::Minimum, "2020-01-01.3", 0}},
                                      },
                                      {},
                                      toplevel_spec()));

    REQUIRE(install_plan.size() == 2);
    check_name_and_version(install_plan.install_actions[0], "b", {"2020-01-01.3", 0});
    check_name_and_version(install_plan.install_actions[1], "a", {"2020-01-01.3", 0});
}

TEST_CASE ("version install diamond date", "[versionplan]")
{
    MockBaselineProvider bp;
    bp.v["a"] = {"2020-01-02", 0};
    bp.v["b"] = {"2020-01-03", 0};

    MockVersionedPortfileProvider vp;
    vp.emplace("a", {"2020-01-02", 0}, Scheme::Date);
    vp.emplace("a", {"2020-01-03", 0}, Scheme::Date).source_control_file->core_paragraph->dependencies = {
        Dependency{"b", {}, {}, DependencyConstraint{Constraint::Type::Minimum, "2020-01-02", 1}},
        Dependency{"c", {}, {}, DependencyConstraint{Constraint::Type::Minimum, "2020-01-05", 1}},
    };
    vp.emplace("b", {"2020-01-02", 1}, Scheme::Date);
    vp.emplace("b", {"2020-01-03", 0}, Scheme::Date).source_control_file->core_paragraph->dependencies = {
        Dependency{"c", {}, {}, DependencyConstraint{Constraint::Type::Minimum, "2020-01-09", 2}},
    };
    vp.emplace("c", {"2020-01-05", 1}, Scheme::Date);
    vp.emplace("c", {"2020-01-09", 2}, Scheme::Date);

    MockCMakeVarProvider var_provider;

    auto install_plan =
        unwrap(create_versioned_install_plan(vp,
                                             bp,
                                             var_provider,
                                             {
                                                 Dependency{"a", {}, {}, {Constraint::Type::Minimum, "2020-01-03", 0}},
                                                 Dependency{"b", {}, {}, {Constraint::Type::Minimum, "2020-01-02", 1}},
                                             },
                                             {},
                                             toplevel_spec()));

    REQUIRE(install_plan.size() == 3);
    check_name_and_version(install_plan.install_actions[0], "c", {"2020-01-09", 2});
    check_name_and_version(install_plan.install_actions[1], "b", {"2020-01-03", 0});
    check_name_and_version(install_plan.install_actions[2], "a", {"2020-01-03", 0});
}

TEST_CASE ("version install scheme failure", "[versionplan]")
{
    MockVersionedPortfileProvider vp;
    vp.emplace("a", {"1.0.0", 0}, Scheme::Semver);
    vp.emplace("a", {"1.0.1", 0}, Scheme::Relaxed);
    vp.emplace("a", {"1.0.2", 0}, Scheme::Semver);

    MockCMakeVarProvider var_provider;

    SECTION ("lower baseline")
    {
        MockBaselineProvider bp;
        bp.v["a"] = {"1.0.0", 0};

        auto install_plan =
            create_versioned_install_plan(vp,
                                          bp,
                                          var_provider,
                                          {Dependency{"a", {}, {}, {Constraint::Type::Minimum, "1.0.1", 0}}},
                                          {},
                                          toplevel_spec());

        REQUIRE(!install_plan.error().empty());
        CHECK(install_plan.error() == "Version conflict on a@1.0.1: baseline required 1.0.0");
    }
    SECTION ("higher baseline")
    {
        MockBaselineProvider bp;
        bp.v["a"] = {"1.0.2", 0};

        auto install_plan =
            create_versioned_install_plan(vp,
                                          bp,
                                          var_provider,
                                          {Dependency{"a", {}, {}, {Constraint::Type::Minimum, "1.0.1", 0}}},
                                          {},
                                          toplevel_spec());

        REQUIRE(!install_plan.error().empty());
        CHECK(install_plan.error() == "Version conflict on a@1.0.1: baseline required 1.0.2");
    }
}

TEST_CASE ("version install scheme change in port version", "[versionplan]")
{
    MockVersionedPortfileProvider vp;
    vp.emplace("a", {"2", 0}).source_control_file->core_paragraph->dependencies = {
        Dependency{"b", {}, {}, DependencyConstraint{Constraint::Type::Minimum, "1"}},
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

        auto install_plan =
            unwrap(create_versioned_install_plan(vp,
                                                 bp,
                                                 var_provider,
                                                 {
                                                     Dependency{"a", {}, {}, {Constraint::Type::Minimum, "2", 1}},
                                                 },
                                                 {},
                                                 toplevel_spec()));

        REQUIRE(install_plan.size() == 2);
        check_name_and_version(install_plan.install_actions[0], "b", {"1", 1});
        check_name_and_version(install_plan.install_actions[1], "a", {"2", 1});
    }
    SECTION ("higher baseline")
    {
        MockBaselineProvider bp;
        bp.v["a"] = {"2", 1};

        auto install_plan =
            unwrap(create_versioned_install_plan(vp,
                                                 bp,
                                                 var_provider,
                                                 {
                                                     Dependency{"a", {}, {}, {Constraint::Type::Minimum, "2", 0}},
                                                 },
                                                 {},
                                                 toplevel_spec()));

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

        auto install_plan = unwrap(create_versioned_install_plan(vp,
                                                                 bp,
                                                                 var_provider,
                                                                 {
                                                                     Dependency{"a", {"x"}},
                                                                 },
                                                                 {},
                                                                 toplevel_spec()));

        REQUIRE(install_plan.size() == 1);
        check_name_and_version(install_plan.install_actions[0], "a", {"1", 0}, {"x"});
    }

    SECTION ("without baseline")
    {
        MockBaselineProvider bp;

        auto install_plan =
            unwrap(create_versioned_install_plan(vp,
                                                 bp,
                                                 var_provider,
                                                 {
                                                     Dependency{"a", {"x"}, {}, {Constraint::Type::Minimum, "1", 0}},
                                                 },
                                                 {},
                                                 toplevel_spec()));

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

    auto install_plan = unwrap(create_versioned_install_plan(vp,
                                                             bp,
                                                             var_provider,
                                                             {
                                                                 Dependency{"a", {"x"}},
                                                             },
                                                             {},
                                                             toplevel_spec()));

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

    auto install_plan = unwrap(create_versioned_install_plan(vp,
                                                             bp,
                                                             var_provider,
                                                             {
                                                                 Dependency{"a", {"x"}},
                                                             },
                                                             {},
                                                             toplevel_spec()));

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

        auto install_plan =
            unwrap(create_versioned_install_plan(vp,
                                                 bp,
                                                 var_provider,
                                                 {
                                                     Dependency{"b", {}, {}, {Constraint::Type::Minimum, "1"}},
                                                 },
                                                 {},
                                                 toplevel_spec()));

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

        auto install_plan =
            unwrap(create_versioned_install_plan(vp,
                                                 bp,
                                                 var_provider,
                                                 {
                                                     Dependency{"b", {}, {}, {Constraint::Type::Minimum, "2"}},
                                                 },
                                                 {},
                                                 toplevel_spec()));

        REQUIRE(install_plan.size() == 2);
        check_name_and_version(install_plan.install_actions[0], "c", {"1", 0});
        check_name_and_version(install_plan.install_actions[1], "b", {"2", 0});
    }
}

TEST_CASE ("version install overrides", "[versionplan]")
{
    MockCMakeVarProvider var_provider;

    MockVersionedPortfileProvider vp;

    vp.emplace("b", {"1", 0}, Scheme::Relaxed);
    vp.emplace("b", {"2", 0}, Scheme::Relaxed);
    vp.emplace("c", {"1", 0}, Scheme::String);
    vp.emplace("c", {"2", 0}, Scheme::String);

    MockBaselineProvider bp;
    bp.v["b"] = {"2", 0};
    bp.v["c"] = {"2", 0};

    SECTION ("string")
    {
        auto install_plan =
            unwrap(create_versioned_install_plan(vp,
                                                 bp,
                                                 var_provider,
                                                 {Dependency{"c"}},
                                                 {DependencyOverride{"b", "1"}, DependencyOverride{"c", "1"}},
                                                 toplevel_spec()));

        REQUIRE(install_plan.size() == 1);
        check_name_and_version(install_plan.install_actions[0], "c", {"1", 0});
    }

    SECTION ("relaxed")
    {
        auto install_plan =
            unwrap(create_versioned_install_plan(vp,
                                                 bp,
                                                 var_provider,
                                                 {Dependency{"b"}},
                                                 {DependencyOverride{"b", "1"}, DependencyOverride{"c", "1"}},
                                                 toplevel_spec()));

        REQUIRE(install_plan.size() == 1);
        check_name_and_version(install_plan.install_actions[0], "b", {"1", 0});
    }
}

TEST_CASE ("version install transitive overrides", "[versionplan]")
{
    MockCMakeVarProvider var_provider;

    MockVersionedPortfileProvider vp;

    vp.emplace("b", {"1", 0}, Scheme::Relaxed)
        .source_control_file->core_paragraph->dependencies.push_back(
            {"c", {}, {}, {Constraint::Type::Minimum, "2", 1}});
    vp.emplace("b", {"2", 0}, Scheme::Relaxed);
    vp.emplace("c", {"1", 0}, Scheme::String);
    vp.emplace("c", {"2", 1}, Scheme::String);

    MockBaselineProvider bp;
    bp.v["b"] = {"2", 0};
    bp.v["c"] = {"2", 1};

    auto install_plan =
        unwrap(create_versioned_install_plan(vp,
                                             bp,
                                             var_provider,
                                             {Dependency{"b"}},
                                             {DependencyOverride{"b", "1"}, DependencyOverride{"c", "1"}},
                                             toplevel_spec()));

    REQUIRE(install_plan.size() == 2);
    check_name_and_version(install_plan.install_actions[0], "c", {"1", 0});
    check_name_and_version(install_plan.install_actions[1], "b", {"1", 0});
}

TEST_CASE ("version install default features", "[versionplan]")
{
    MockVersionedPortfileProvider vp;

    auto a_x = make_fpgh("x");
    auto& a_scf = vp.emplace("a", {"1", 0}, Scheme::Relaxed).source_control_file;
    a_scf->core_paragraph->default_features.push_back("x");
    a_scf->feature_paragraphs.push_back(std::move(a_x));

    MockCMakeVarProvider var_provider;

    MockBaselineProvider bp;
    bp.v["a"] = {"1", 0};

    auto install_plan =
        unwrap(create_versioned_install_plan(vp, bp, var_provider, {Dependency{"a"}}, {}, toplevel_spec()));

    REQUIRE(install_plan.size() == 1);
    check_name_and_version(install_plan.install_actions[0], "a", {"1", 0}, {"x"});
}

TEST_CASE ("version dont install default features", "[versionplan]")
{
    MockVersionedPortfileProvider vp;

    auto a_x = make_fpgh("x");
    auto& a_scf = vp.emplace("a", {"1", 0}, Scheme::Relaxed).source_control_file;
    a_scf->core_paragraph->default_features.push_back("x");
    a_scf->feature_paragraphs.push_back(std::move(a_x));

    MockCMakeVarProvider var_provider;

    MockBaselineProvider bp;
    bp.v["a"] = {"1", 0};

    auto install_plan =
        unwrap(create_versioned_install_plan(vp, bp, var_provider, {Dependency{"a", {"core"}}}, {}, toplevel_spec()));

    REQUIRE(install_plan.size() == 1);
    check_name_and_version(install_plan.install_actions[0], "a", {"1", 0});
}

TEST_CASE ("version install transitive default features", "[versionplan]")
{
    MockVersionedPortfileProvider vp;

    auto a_x = make_fpgh("x");
    auto& a_scf = vp.emplace("a", {"1", 0}, Scheme::Relaxed).source_control_file;
    a_scf->core_paragraph->default_features.push_back("x");
    a_scf->feature_paragraphs.push_back(std::move(a_x));

    auto& b_scf = vp.emplace("b", {"1", 0}, Scheme::Relaxed).source_control_file;
    b_scf->core_paragraph->dependencies.push_back({"a", {"core"}});

    MockCMakeVarProvider var_provider;

    MockBaselineProvider bp;
    bp.v["a"] = {"1", 0};
    bp.v["b"] = {"1", 0};

    auto install_plan =
        unwrap(create_versioned_install_plan(vp, bp, var_provider, {Dependency{"b"}}, {}, toplevel_spec()));

    REQUIRE(install_plan.size() == 2);
    check_name_and_version(install_plan.install_actions[0], "a", {"1", 0}, {"x"});
    check_name_and_version(install_plan.install_actions[1], "b", {"1", 0});
}

static PlatformExpression::Expr parse_platform(StringView l)
{
    return unwrap(PlatformExpression::parse_platform_expression(l, PlatformExpression::MultipleBinaryOperators::Deny));
}

TEST_CASE ("version install qualified dependencies", "[versionplan]")
{
    MockVersionedPortfileProvider vp;

    vp.emplace("b", {"1", 0}, Scheme::Relaxed);
    vp.emplace("c", {"1", 0}, Scheme::Relaxed);

    MockBaselineProvider bp;
    bp.v["b"] = {"1", 0};
    bp.v["c"] = {"1", 0};

    SECTION ("windows")
    {
        MockCMakeVarProvider var_provider;
        var_provider.dep_info_vars[toplevel_spec()] = {{"VCPKG_CMAKE_SYSTEM_NAME", "Windows"}};

        auto install_plan = unwrap(
            create_versioned_install_plan(vp,
                                          bp,
                                          var_provider,
                                          {{"b", {}, parse_platform("!linux")}, {"c", {}, parse_platform("linux")}},
                                          {},
                                          toplevel_spec()));

        REQUIRE(install_plan.size() == 1);
        check_name_and_version(install_plan.install_actions[0], "b", {"1", 0});
    }

    SECTION ("linux")
    {
        MockCMakeVarProvider var_provider;
        var_provider.dep_info_vars[toplevel_spec()] = {{"VCPKG_CMAKE_SYSTEM_NAME", "Linux"}};

        auto install_plan = unwrap(
            create_versioned_install_plan(vp,
                                          bp,
                                          var_provider,
                                          {{"b", {}, parse_platform("!linux")}, {"c", {}, parse_platform("linux")}},
                                          {},
                                          toplevel_spec()));

        REQUIRE(install_plan.size() == 1);
        check_name_and_version(install_plan.install_actions[0], "c", {"1", 0});
    }
}

TEST_CASE ("version install qualified default suppression", "[versionplan]")
{
    MockVersionedPortfileProvider vp;

    auto& a_scf = vp.emplace("a", {"1", 0}, Scheme::Relaxed).source_control_file;
    a_scf->core_paragraph->default_features.push_back("x");
    a_scf->feature_paragraphs.push_back(make_fpgh("x"));

    vp.emplace("b", {"1", 0}, Scheme::Relaxed)
        .source_control_file->core_paragraph->dependencies.push_back({"a", {"core"}});

    MockCMakeVarProvider var_provider;

    MockBaselineProvider bp;
    bp.v["a"] = {"1", 0};
    bp.v["b"] = {"1", 0};

    auto install_plan = unwrap(
        create_versioned_install_plan(vp,
                                      bp,
                                      var_provider,
                                      {{"b", {}, parse_platform("!linux")}, {"a", {"core"}, parse_platform("linux")}},
                                      {},
                                      toplevel_spec()));

    REQUIRE(install_plan.size() == 2);
    check_name_and_version(install_plan.install_actions[0], "a", {"1", 0}, {"x"});
    check_name_and_version(install_plan.install_actions[1], "b", {"1", 0});
}

TEST_CASE ("version install qualified transitive", "[versionplan]")
{
    MockVersionedPortfileProvider vp;

    vp.emplace("a", {"1", 0}, Scheme::Relaxed);
    vp.emplace("c", {"1", 0}, Scheme::Relaxed);

    auto& b_scf = vp.emplace("b", {"1", 0}, Scheme::Relaxed).source_control_file;
    b_scf->core_paragraph->dependencies.push_back({"a", {}, parse_platform("!linux")});
    b_scf->core_paragraph->dependencies.push_back({"c", {}, parse_platform("linux")});

    MockCMakeVarProvider var_provider;

    MockBaselineProvider bp;
    bp.v["a"] = {"1", 0};
    bp.v["b"] = {"1", 0};
    bp.v["c"] = {"1", 0};

    auto install_plan = unwrap(create_versioned_install_plan(vp, bp, var_provider, {{"b"}}, {}, toplevel_spec()));

    REQUIRE(install_plan.size() == 2);
    check_name_and_version(install_plan.install_actions[0], "a", {"1", 0});
    check_name_and_version(install_plan.install_actions[1], "b", {"1", 0});
}

TEST_CASE ("version install different vars", "[versionplan]")
{
    MockVersionedPortfileProvider vp;

    auto& b_scf = vp.emplace("b", {"1", 0}, Scheme::Relaxed).source_control_file;
    b_scf->core_paragraph->dependencies.push_back({"a", {}, parse_platform("!linux")});

    auto& a_scf = vp.emplace("a", {"1", 0}, Scheme::Relaxed).source_control_file;
    a_scf->core_paragraph->dependencies.push_back({"c", {}, parse_platform("linux")});

    vp.emplace("c", {"1", 0}, Scheme::Relaxed);

    MockCMakeVarProvider var_provider;
    var_provider.dep_info_vars[PackageSpec{"a", Test::X86_WINDOWS}] = {{"VCPKG_CMAKE_SYSTEM_NAME", "Linux"}};

    MockBaselineProvider bp;
    bp.v["a"] = {"1", 0};
    bp.v["b"] = {"1", 0};
    bp.v["c"] = {"1", 0};

    auto install_plan = unwrap(create_versioned_install_plan(vp, bp, var_provider, {{"b"}}, {}, toplevel_spec()));

    REQUIRE(install_plan.size() == 3);
    check_name_and_version(install_plan.install_actions[0], "c", {"1", 0});
    check_name_and_version(install_plan.install_actions[1], "a", {"1", 0});
    check_name_and_version(install_plan.install_actions[2], "b", {"1", 0});
}

TEST_CASE ("version install qualified features", "[versionplan]")
{
    MockVersionedPortfileProvider vp;

    auto& b_scf = vp.emplace("b", {"1", 0}, Scheme::Relaxed).source_control_file;
    b_scf->core_paragraph->default_features.push_back("x");
    b_scf->feature_paragraphs.push_back(make_fpgh("x"));
    b_scf->feature_paragraphs.back()->dependencies.push_back({"a", {}, parse_platform("!linux")});

    auto& a_scf = vp.emplace("a", {"1", 0}, Scheme::Relaxed).source_control_file;
    a_scf->core_paragraph->default_features.push_back("y");
    a_scf->feature_paragraphs.push_back(make_fpgh("y"));
    a_scf->feature_paragraphs.back()->dependencies.push_back({"c", {}, parse_platform("linux")});

    auto& c_scf = vp.emplace("c", {"1", 0}, Scheme::Relaxed).source_control_file;
    c_scf->core_paragraph->default_features.push_back("z");
    c_scf->feature_paragraphs.push_back(make_fpgh("z"));
    c_scf->feature_paragraphs.back()->dependencies.push_back({"d", {}, parse_platform("linux")});

    vp.emplace("d", {"1", 0}, Scheme::Relaxed);

    MockCMakeVarProvider var_provider;
    var_provider.dep_info_vars[PackageSpec{"a", Test::X86_WINDOWS}] = {{"VCPKG_CMAKE_SYSTEM_NAME", "Linux"}};

    MockBaselineProvider bp;
    bp.v["a"] = {"1", 0};
    bp.v["b"] = {"1", 0};
    bp.v["c"] = {"1", 0};
    bp.v["d"] = {"1", 0};

    auto install_plan = unwrap(create_versioned_install_plan(vp, bp, var_provider, {{"b"}}, {}, toplevel_spec()));

    REQUIRE(install_plan.size() == 3);
    check_name_and_version(install_plan.install_actions[0], "c", {"1", 0}, {"z"});
    check_name_and_version(install_plan.install_actions[1], "a", {"1", 0}, {"y"});
    check_name_and_version(install_plan.install_actions[2], "b", {"1", 0}, {"x"});
}

TEST_CASE ("version install self features", "[versionplan]")
{
    MockBaselineProvider bp;
    bp.v["a"] = {"1", 0};

    MockVersionedPortfileProvider vp;
    auto& a_scf = vp.emplace("a", {"1", 0}).source_control_file;
    a_scf->feature_paragraphs.push_back(make_fpgh("x"));
    a_scf->feature_paragraphs.back()->dependencies.push_back({"a", {"core", "y"}});
    a_scf->feature_paragraphs.push_back(make_fpgh("y"));
    a_scf->feature_paragraphs.push_back(make_fpgh("z"));

    MockCMakeVarProvider var_provider;

    auto install_plan =
        unwrap(create_versioned_install_plan(vp, bp, var_provider, {{"a", {"x"}}}, {}, toplevel_spec()));

    REQUIRE(install_plan.size() == 1);
    check_name_and_version(install_plan.install_actions[0], "a", {"1", 0}, {"x", "y"});
}

TEST_CASE ("version overlay ports", "[versionplan]")
{
    MockBaselineProvider bp;
    bp.v["a"] = {"1", 0};
    bp.v["b"] = {"1", 0};
    bp.v["c"] = {"1", 0};

    MockVersionedPortfileProvider vp;
    vp.emplace("a", {"1", 0});
    vp.emplace("a", {"1", 1});
    vp.emplace("a", {"2", 0});
    vp.emplace("b", {"1", 0}).source_control_file->core_paragraph->dependencies.emplace_back(Dependency{"a"});
    vp.emplace("c", {"1", 0})
        .source_control_file->core_paragraph->dependencies.emplace_back(
            Dependency{"a", {}, {}, {Constraint::Type::Minimum, "1", 1}});

    MockCMakeVarProvider var_provider;

    MockOverlayProvider oprovider;
    oprovider.emplace("a", {"overlay", 0});

    SECTION ("no baseline")
    {
        const MockBaselineProvider empty_bp;

        auto install_plan = unwrap(Dependencies::create_versioned_install_plan(
            vp, empty_bp, oprovider, var_provider, {{"a"}}, {}, toplevel_spec()));

        REQUIRE(install_plan.size() == 1);
        check_name_and_version(install_plan.install_actions[0], "a", {"overlay", 0});
    }

    SECTION ("transitive")
    {
        auto install_plan = unwrap(
            Dependencies::create_versioned_install_plan(vp, bp, oprovider, var_provider, {{"b"}}, {}, toplevel_spec()));

        REQUIRE(install_plan.size() == 2);
        check_name_and_version(install_plan.install_actions[0], "a", {"overlay", 0});
        check_name_and_version(install_plan.install_actions[1], "b", {"1", 0});
    }

    SECTION ("transitive constraint")
    {
        auto install_plan = unwrap(
            Dependencies::create_versioned_install_plan(vp, bp, oprovider, var_provider, {{"c"}}, {}, toplevel_spec()));

        REQUIRE(install_plan.size() == 2);
        check_name_and_version(install_plan.install_actions[0], "a", {"overlay", 0});
        check_name_and_version(install_plan.install_actions[1], "c", {"1", 0});
    }

    SECTION ("none")
    {
        auto install_plan = unwrap(
            Dependencies::create_versioned_install_plan(vp, bp, oprovider, var_provider, {{"a"}}, {}, toplevel_spec()));

        REQUIRE(install_plan.size() == 1);
        check_name_and_version(install_plan.install_actions[0], "a", {"overlay", 0});
    }
    SECTION ("constraint")
    {
        auto install_plan = unwrap(Dependencies::create_versioned_install_plan(
            vp,
            bp,
            oprovider,
            var_provider,
            {
                Dependency{"a", {}, {}, {Constraint::Type::Minimum, "1", 1}},
            },
            {},
            toplevel_spec()));

        REQUIRE(install_plan.size() == 1);
        check_name_and_version(install_plan.install_actions[0], "a", {"overlay", 0});
    }
    SECTION ("constraint+override")
    {
        auto install_plan = unwrap(Dependencies::create_versioned_install_plan(
            vp,
            bp,
            oprovider,
            var_provider,
            {
                Dependency{"a", {}, {}, {Constraint::Type::Minimum, "1", 1}},
            },
            {
                DependencyOverride{"a", {"2", 0}},
            },
            toplevel_spec()));

        REQUIRE(install_plan.size() == 1);
        check_name_and_version(install_plan.install_actions[0], "a", {"overlay", 0});
    }
    SECTION ("override")
    {
        auto install_plan = unwrap(Dependencies::create_versioned_install_plan(vp,
                                                                               bp,
                                                                               oprovider,
                                                                               var_provider,
                                                                               {
                                                                                   Dependency{"a"},
                                                                               },
                                                                               {
                                                                                   DependencyOverride{"a", {"2", 0}},
                                                                               },
                                                                               toplevel_spec()));

        REQUIRE(install_plan.size() == 1);
        check_name_and_version(install_plan.install_actions[0], "a", {"overlay", 0});
    }
}
