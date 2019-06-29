#include "tests.pch.h"

#include <tests.utils.h>

using namespace Microsoft::VisualStudio::CppUnitTestFramework;

using namespace vcpkg;

namespace UnitTest1
{
    static std::unique_ptr<SourceControlFile> make_control_file(
        const char* name,
        const char* depends,
        const std::vector<std::pair<const char*, const char*>>& features = {},
        const std::vector<const char*>& default_features = {})
    {
        using Pgh = std::unordered_map<std::string, std::string>;
        std::vector<Pgh> scf_pghs;
        scf_pghs.push_back(Pgh{{"Source", name},
                               {"Version", "0"},
                               {"Build-Depends", depends},
                               {"Default-Features", Strings::join(", ", default_features)}});
        for (auto&& feature : features)
        {
            scf_pghs.push_back(Pgh{
                {"Feature", feature.first},
                {"Description", "feature"},
                {"Build-Depends", feature.second},
            });
        }
        auto m_pgh = vcpkg::SourceControlFile::parse_control_file(std::move(scf_pghs));
        Assert::IsTrue(m_pgh.has_value());
        return std::move(*m_pgh.get());
    }

    /// <summary>
    /// Assert that the given action an install of given features from given package.
    /// </summary>
    static void features_check(Dependencies::AnyAction* install_action,
                               std::string pkg_name,
                               std::vector<std::string> vec,
                               const Triplet& triplet = Triplet::X86_WINDOWS)
    {
        Assert::IsTrue(install_action->install_action.has_value());
        const auto& plan = install_action->install_action.value_or_exit(VCPKG_LINE_INFO);
        const auto& feature_list = plan.feature_list;

        Assert::AreEqual(plan.spec.triplet().to_string().c_str(), triplet.to_string().c_str());

        auto* scfl = plan.source_control_file_location.get();
        Assert::AreEqual(pkg_name.c_str(), scfl->source_control_file->core_paragraph->name.c_str());
        Assert::AreEqual(size_t(vec.size()), feature_list.size());

        for (auto&& feature_name : vec)
        {
            if (feature_name == "core" || feature_name == "")
            {
                Assert::IsTrue(Util::find(feature_list, "core") != feature_list.end() ||
                               Util::find(feature_list, "") != feature_list.end());
                continue;
            }
            Assert::IsTrue(Util::find(feature_list, feature_name) != feature_list.end());
        }
    }

    /// <summary>
    /// Assert that the given action is a remove of given package.
    /// </summary>
    static void remove_plan_check(Dependencies::AnyAction* remove_action,
                                  std::string pkg_name,
                                  const Triplet& triplet = Triplet::X86_WINDOWS)
    {
        const auto& plan = remove_action->remove_action.value_or_exit(VCPKG_LINE_INFO);
        Assert::AreEqual(plan.spec.triplet().to_string().c_str(), triplet.to_string().c_str());
        Assert::AreEqual(pkg_name.c_str(), plan.spec.name().c_str());
    }

    /// <summary>
    /// Map of source control files by their package name.
    /// </summary>
    struct PackageSpecMap
    {
        std::unordered_map<std::string, SourceControlFileLocation> map;
        Triplet triplet;
        PackageSpecMap(const Triplet& t = Triplet::X86_WINDOWS) noexcept { triplet = t; }

        PackageSpec emplace(const char* name,
                            const char* depends = "",
                            const std::vector<std::pair<const char*, const char*>>& features = {},
                            const std::vector<const char*>& default_features = {})
        {
            return emplace(std::move(*make_control_file(name, depends, features, default_features)));
        }
        PackageSpec emplace(vcpkg::SourceControlFile&& scf)
        {
            auto spec = PackageSpec::from_name_and_triplet(scf.core_paragraph->name, triplet);
            Assert::IsTrue(spec.has_value());
            map.emplace(scf.core_paragraph->name,
                        SourceControlFileLocation{std::unique_ptr<SourceControlFile>(std::move(&scf)), ""});
            return PackageSpec{*spec.get()};
        }
    };

    class InstallPlanTests : public TestClass<InstallPlanTests>
    {
        TEST_METHOD(basic_install_scheme)
        {
            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;

            PackageSpecMap spec_map;
            auto spec_a = spec_map.emplace("a", "b");
            auto spec_b = spec_map.emplace("b", "c");
            auto spec_c = spec_map.emplace("c");

            Dependencies::MapPortFileProvider map_port(spec_map.map);
            auto install_plan = Dependencies::create_feature_install_plan(
                map_port, {FeatureSpec{spec_a, ""}}, StatusParagraphs(std::move(status_paragraphs)));

            Assert::AreEqual(size_t(3), install_plan.size());
            Assert::AreEqual("c", install_plan[0].spec().name().c_str());
            Assert::AreEqual("b", install_plan[1].spec().name().c_str());
            Assert::AreEqual("a", install_plan[2].spec().name().c_str());
        }

        TEST_METHOD(multiple_install_scheme)
        {
            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;

            PackageSpecMap spec_map;
            auto spec_a = spec_map.emplace("a", "d");
            auto spec_b = spec_map.emplace("b", "d, e");
            auto spec_c = spec_map.emplace("c", "e, h");
            auto spec_d = spec_map.emplace("d", "f, g, h");
            auto spec_e = spec_map.emplace("e", "g");
            auto spec_f = spec_map.emplace("f");
            auto spec_g = spec_map.emplace("g");
            auto spec_h = spec_map.emplace("h");

            Dependencies::MapPortFileProvider map_port(spec_map.map);
            auto install_plan = Dependencies::create_feature_install_plan(
                map_port,
                {FeatureSpec{spec_a, ""}, FeatureSpec{spec_b, ""}, FeatureSpec{spec_c, ""}},
                StatusParagraphs(std::move(status_paragraphs)));

            auto iterator_pos = [&](const PackageSpec& spec) -> int {
                auto it = std::find_if(
                    install_plan.begin(), install_plan.end(), [&](auto& action) { return action.spec() == spec; });
                Assert::IsTrue(it != install_plan.end());
                return (int)(it - install_plan.begin());
            };

            int a_pos = iterator_pos(spec_a), b_pos = iterator_pos(spec_b), c_pos = iterator_pos(spec_c),
                d_pos = iterator_pos(spec_d), e_pos = iterator_pos(spec_e), f_pos = iterator_pos(spec_f),
                g_pos = iterator_pos(spec_g), h_pos = iterator_pos(spec_h);

            Assert::IsTrue(a_pos > d_pos);
            Assert::IsTrue(b_pos > e_pos);
            Assert::IsTrue(b_pos > d_pos);
            Assert::IsTrue(c_pos > e_pos);
            Assert::IsTrue(c_pos > h_pos);
            Assert::IsTrue(d_pos > f_pos);
            Assert::IsTrue(d_pos > g_pos);
            Assert::IsTrue(d_pos > h_pos);
            Assert::IsTrue(e_pos > g_pos);
        }

        TEST_METHOD(existing_package_scheme)
        {
            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;
            status_paragraphs.push_back(make_status_pgh("a"));

            PackageSpecMap spec_map;
            auto spec_a = FullPackageSpec{spec_map.emplace("a")};

            auto install_plan =
                Dependencies::create_feature_install_plan(spec_map.map,
                                                          FullPackageSpec::to_feature_specs({spec_a}),
                                                          StatusParagraphs(std::move(status_paragraphs)));

            Assert::AreEqual(size_t(1), install_plan.size());
            auto p = install_plan[0].install_action.get();
            Assert::IsNotNull(p);
            Assert::AreEqual("a", p->spec.name().c_str());
            Assert::AreEqual(Dependencies::InstallPlanType::ALREADY_INSTALLED, p->plan_type);
            Assert::AreEqual(Dependencies::RequestType::USER_REQUESTED, p->request_type);
        }

        TEST_METHOD(user_requested_package_scheme)
        {
            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;

            PackageSpecMap spec_map;
            auto spec_a = FullPackageSpec{spec_map.emplace("a", "b")};
            auto spec_b = FullPackageSpec{spec_map.emplace("b")};

            auto install_plan =
                Dependencies::create_feature_install_plan(spec_map.map,
                                                          FullPackageSpec::to_feature_specs({spec_a}),
                                                          StatusParagraphs(std::move(status_paragraphs)));

            Assert::AreEqual(size_t(2), install_plan.size());
            auto p = install_plan[0].install_action.get();
            Assert::IsNotNull(p);
            Assert::AreEqual("b", p->spec.name().c_str());
            Assert::AreEqual(Dependencies::InstallPlanType::BUILD_AND_INSTALL, p->plan_type);
            Assert::AreEqual(Dependencies::RequestType::AUTO_SELECTED, p->request_type);

            auto p2 = install_plan[1].install_action.get();
            Assert::IsNotNull(p2);
            Assert::AreEqual("a", p2->spec.name().c_str());
            Assert::AreEqual(Dependencies::InstallPlanType::BUILD_AND_INSTALL, p2->plan_type);
            Assert::AreEqual(Dependencies::RequestType::USER_REQUESTED, p2->request_type);
        }

        TEST_METHOD(long_install_scheme)
        {
            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;
            status_paragraphs.push_back(make_status_pgh("j", "k"));
            status_paragraphs.push_back(make_status_pgh("k"));

            PackageSpecMap spec_map;

            auto spec_a = spec_map.emplace("a", "b, c, d, e, f, g, h, j, k");
            auto spec_b = spec_map.emplace("b", "c, d, e, f, g, h, j, k");
            auto spec_c = spec_map.emplace("c", "d, e, f, g, h, j, k");
            auto spec_d = spec_map.emplace("d", "e, f, g, h, j, k");
            auto spec_e = spec_map.emplace("e", "f, g, h, j, k");
            auto spec_f = spec_map.emplace("f", "g, h, j, k");
            auto spec_g = spec_map.emplace("g", "h, j, k");
            auto spec_h = spec_map.emplace("h", "j, k");
            auto spec_j = spec_map.emplace("j", "k");
            auto spec_k = spec_map.emplace("k");

            Dependencies::MapPortFileProvider map_port(spec_map.map);
            auto install_plan = Dependencies::create_feature_install_plan(
                map_port, {FeatureSpec{spec_a, ""}}, StatusParagraphs(std::move(status_paragraphs)));

            Assert::AreEqual(size_t(8), install_plan.size());
            Assert::AreEqual("h", install_plan[0].spec().name().c_str());
            Assert::AreEqual("g", install_plan[1].spec().name().c_str());
            Assert::AreEqual("f", install_plan[2].spec().name().c_str());
            Assert::AreEqual("e", install_plan[3].spec().name().c_str());
            Assert::AreEqual("d", install_plan[4].spec().name().c_str());
            Assert::AreEqual("c", install_plan[5].spec().name().c_str());
            Assert::AreEqual("b", install_plan[6].spec().name().c_str());
            Assert::AreEqual("a", install_plan[7].spec().name().c_str());
        }

        TEST_METHOD(basic_feature_test_1)
        {
            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;
            status_paragraphs.push_back(make_status_pgh("a", "b, b[b1]"));
            status_paragraphs.push_back(make_status_pgh("b"));
            status_paragraphs.push_back(make_status_feature_pgh("b", "b1"));

            PackageSpecMap spec_map;
            auto spec_a = FullPackageSpec{spec_map.emplace("a", "b, b[b1]", {{"a1", "b[b2]"}}), {"a1"}};
            auto spec_b = FullPackageSpec{spec_map.emplace("b", "", {{"b1", ""}, {"b2", ""}, {"b3", ""}})};

            auto install_plan =
                Dependencies::create_feature_install_plan(spec_map.map,
                                                          FullPackageSpec::to_feature_specs({spec_a}),
                                                          StatusParagraphs(std::move(status_paragraphs)));

            Assert::AreEqual(size_t(4), install_plan.size());
            remove_plan_check(&install_plan[0], "a");
            remove_plan_check(&install_plan[1], "b");
            features_check(&install_plan[2], "b", {"b1", "core", "b1"});
            features_check(&install_plan[3], "a", {"a1", "core"});
        }

        TEST_METHOD(basic_feature_test_2)
        {
            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;

            PackageSpecMap spec_map;

            auto spec_a = FullPackageSpec{spec_map.emplace("a", "b[b1]", {{"a1", "b[b2]"}}), {"a1"}};
            auto spec_b = FullPackageSpec{spec_map.emplace("b", "", {{"b1", ""}, {"b2", ""}, {"b3", ""}})};

            auto install_plan =
                Dependencies::create_feature_install_plan(spec_map.map,
                                                          FullPackageSpec::to_feature_specs({spec_a}),
                                                          StatusParagraphs(std::move(status_paragraphs)));

            Assert::AreEqual(size_t(2), install_plan.size());
            features_check(&install_plan[0], "b", {"b1", "b2", "core"});
            features_check(&install_plan[1], "a", {"a1", "core"});
        }

        TEST_METHOD(basic_feature_test_3)
        {
            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;
            status_paragraphs.push_back(make_status_pgh("a"));

            PackageSpecMap spec_map;

            auto spec_a = FullPackageSpec{spec_map.emplace("a", "b", {{"a1", ""}}), {"core"}};
            auto spec_b = FullPackageSpec{spec_map.emplace("b")};
            auto spec_c = FullPackageSpec{spec_map.emplace("c", "a[a1]"), {"core"}};

            auto install_plan =
                Dependencies::create_feature_install_plan(spec_map.map,
                                                          FullPackageSpec::to_feature_specs({spec_c, spec_a}),
                                                          StatusParagraphs(std::move(status_paragraphs)));

            Assert::AreEqual(size_t(4), install_plan.size());
            remove_plan_check(&install_plan[0], "a");
            features_check(&install_plan[1], "b", {"core"});
            features_check(&install_plan[2], "a", {"a1", "core"});
            features_check(&install_plan[3], "c", {"core"});
        }

        TEST_METHOD(basic_feature_test_4)
        {
            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;
            status_paragraphs.push_back(make_status_pgh("a"));
            status_paragraphs.push_back(make_status_feature_pgh("a", "a1", ""));

            PackageSpecMap spec_map;

            auto spec_a = FullPackageSpec{spec_map.emplace("a", "b", {{"a1", ""}})};
            auto spec_b = FullPackageSpec{spec_map.emplace("b")};
            auto spec_c = FullPackageSpec{spec_map.emplace("c", "a[a1]"), {"core"}};

            auto install_plan =
                Dependencies::create_feature_install_plan(spec_map.map,
                                                          FullPackageSpec::to_feature_specs({spec_c}),
                                                          StatusParagraphs(std::move(status_paragraphs)));

            Assert::AreEqual(size_t(1), install_plan.size());
            features_check(&install_plan[0], "c", {"core"});
        }

        TEST_METHOD(basic_feature_test_5)
        {
            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;

            PackageSpecMap spec_map;

            auto spec_a =
                FullPackageSpec{spec_map.emplace("a", "", {{"a1", "b[b1]"}, {"a2", "b[b2]"}, {"a3", "a[a2]"}}), {"a3"}};
            auto spec_b = FullPackageSpec{spec_map.emplace("b", "", {{"b1", ""}, {"b2", ""}})};

            auto install_plan =
                Dependencies::create_feature_install_plan(spec_map.map,
                                                          FullPackageSpec::to_feature_specs({spec_a}),
                                                          StatusParagraphs(std::move(status_paragraphs)));

            Assert::AreEqual(size_t(2), install_plan.size());
            features_check(&install_plan[0], "b", {"core", "b2"});
            features_check(&install_plan[1], "a", {"core", "a3", "a2"});
        }

        TEST_METHOD(basic_feature_test_6)
        {
            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;
            status_paragraphs.push_back(make_status_pgh("b"));

            PackageSpecMap spec_map;
            auto spec_a = FullPackageSpec{spec_map.emplace("a", "b[core]"), {"core"}};
            auto spec_b = FullPackageSpec{spec_map.emplace("b", "", {{"b1", ""}}), {"b1"}};

            auto install_plan =
                Dependencies::create_feature_install_plan(spec_map.map,
                                                          FullPackageSpec::to_feature_specs({spec_a, spec_b}),
                                                          StatusParagraphs(std::move(status_paragraphs)));

            Assert::AreEqual(size_t(3), install_plan.size());
            remove_plan_check(&install_plan[0], "b");
            features_check(&install_plan[1], "b", {"core", "b1"});
            features_check(&install_plan[2], "a", {"core"});
        }

        TEST_METHOD(basic_feature_test_7)
        {
            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;
            status_paragraphs.push_back(make_status_pgh("x", "b"));
            status_paragraphs.push_back(make_status_pgh("b"));

            PackageSpecMap spec_map;

            auto spec_a = FullPackageSpec{spec_map.emplace("a")};
            auto spec_x = FullPackageSpec{spec_map.emplace("x", "a"), {"core"}};
            auto spec_b = FullPackageSpec{spec_map.emplace("b", "", {{"b1", ""}}), {"b1"}};

            auto install_plan =
                Dependencies::create_feature_install_plan(spec_map.map,
                                                          FullPackageSpec::to_feature_specs({spec_b}),
                                                          StatusParagraphs(std::move(status_paragraphs)));

            Assert::AreEqual(size_t(5), install_plan.size());
            remove_plan_check(&install_plan[0], "x");
            remove_plan_check(&install_plan[1], "b");

            // TODO: order here may change but A < X, and B anywhere
            features_check(&install_plan[2], "b", {"core", "b1"});
            features_check(&install_plan[3], "a", {"core"});
            features_check(&install_plan[4], "x", {"core"});
        }

        TEST_METHOD(basic_feature_test_8)
        {
            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;
            status_paragraphs.push_back(make_status_pgh("a"));
            status_paragraphs.push_back(make_status_pgh("a"));
            status_paragraphs.back()->package.spec =
                PackageSpec::from_name_and_triplet("a", Triplet::X64_WINDOWS).value_or_exit(VCPKG_LINE_INFO);

            PackageSpecMap spec_map(Triplet::X64_WINDOWS);
            auto spec_a_64 = FullPackageSpec{spec_map.emplace("a", "b", {{"a1", ""}}), {"core"}};
            auto spec_b_64 = FullPackageSpec{spec_map.emplace("b")};
            auto spec_c_64 = FullPackageSpec{spec_map.emplace("c", "a[a1]"), {"core"}};

            spec_map.triplet = Triplet::X86_WINDOWS;
            auto spec_a_86 = FullPackageSpec{spec_map.emplace("a", "b", {{"a1", ""}}), {"core"}};
            auto spec_b_86 = FullPackageSpec{spec_map.emplace("b")};
            auto spec_c_86 = FullPackageSpec{spec_map.emplace("c", "a[a1]"), {"core"}};

            auto install_plan = Dependencies::create_feature_install_plan(
                spec_map.map,
                FullPackageSpec::to_feature_specs({spec_c_64, spec_a_86, spec_a_64, spec_c_86}),
                StatusParagraphs(std::move(status_paragraphs)));

            remove_plan_check(&install_plan[0], "a", Triplet::X64_WINDOWS);
            remove_plan_check(&install_plan[1], "a");
            features_check(&install_plan[2], "b", {"core"}, Triplet::X64_WINDOWS);
            features_check(&install_plan[3], "a", {"a1", "core"}, Triplet::X64_WINDOWS);
            features_check(&install_plan[4], "c", {"core"}, Triplet::X64_WINDOWS);
            features_check(&install_plan[5], "b", {"core"});
            features_check(&install_plan[6], "a", {"a1", "core"});
            features_check(&install_plan[7], "c", {"core"});
        }

        TEST_METHOD(install_all_features_test)
        {
            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;

            PackageSpecMap spec_map(Triplet::X64_WINDOWS);
            auto spec_a_64 = FullPackageSpec{spec_map.emplace("a", "", {{"0", ""}, {"1", ""}}), {"core"}};

            auto install_specs = FullPackageSpec::from_string("a[*]", Triplet::X64_WINDOWS);
            Assert::IsTrue(install_specs.has_value());
            if (!install_specs.has_value()) return;
            auto install_plan = Dependencies::create_feature_install_plan(
                spec_map.map,
                FullPackageSpec::to_feature_specs({install_specs.value_or_exit(VCPKG_LINE_INFO)}),
                StatusParagraphs(std::move(status_paragraphs)));

            Assert::IsTrue(install_plan.size() == 1);
            features_check(&install_plan[0], "a", {"0", "1", "core"}, Triplet::X64_WINDOWS);
        }

        TEST_METHOD(install_default_features_test_1)
        {
            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;

            // Add a port "a" with default features "1" and features "0" and "1".
            PackageSpecMap spec_map(Triplet::X64_WINDOWS);
            spec_map.emplace("a", "", {{"0", ""}, {"1", ""}}, {"1"});

            // Install "a" (without explicit feature specification)
            auto install_specs = FullPackageSpec::from_string("a", Triplet::X64_WINDOWS);
            auto install_plan = Dependencies::create_feature_install_plan(
                spec_map.map,
                FullPackageSpec::to_feature_specs({install_specs.value_or_exit(VCPKG_LINE_INFO)}),
                StatusParagraphs(std::move(status_paragraphs)));

            // Expect the default feature "1" to be installed, but not "0"
            Assert::IsTrue(install_plan.size() == 1);
            features_check(&install_plan[0], "a", {"1", "core"}, Triplet::X64_WINDOWS);
        }

        TEST_METHOD(install_default_features_test_2)
        {
            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;
            status_paragraphs.push_back(make_status_pgh("a"));
            status_paragraphs.back()->package.spec =
                PackageSpec::from_name_and_triplet("a", Triplet::X64_WINDOWS).value_or_exit(VCPKG_LINE_INFO);

            // Add a port "a" of which "core" is already installed, but we will
            // install the default features "explicitly"
            // "a" has two features, of which "a1" is default.
            PackageSpecMap spec_map(Triplet::X64_WINDOWS);
            spec_map.emplace("a", "", {{"a0", ""}, {"a1", ""}}, {"a1"});

            // Install "a" (without explicit feature specification)
            auto install_specs = FullPackageSpec::from_string("a", Triplet::X64_WINDOWS);
            auto install_plan = Dependencies::create_feature_install_plan(
                spec_map.map,
                FullPackageSpec::to_feature_specs({install_specs.value_or_exit(VCPKG_LINE_INFO)}),
                StatusParagraphs(std::move(status_paragraphs)));

            // Expect "a" to get removed for rebuild and then installed with default
            // features.
            Assert::IsTrue(install_plan.size() == 2);
            remove_plan_check(&install_plan[0], "a", Triplet::X64_WINDOWS);
            features_check(&install_plan[1], "a", {"a1", "core"}, Triplet::X64_WINDOWS);
        }

        TEST_METHOD(install_default_features_test_3)
        {
            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;

            // "a" has two features, of which "a1" is default.
            PackageSpecMap spec_map(Triplet::X64_WINDOWS);
            spec_map.emplace("a", "", {{"a0", ""}, {"a1", ""}}, {"a1"});

            // Explicitly install "a" without default features
            auto install_specs = FullPackageSpec::from_string("a[core]", Triplet::X64_WINDOWS);
            auto install_plan = Dependencies::create_feature_install_plan(
                spec_map.map,
                FullPackageSpec::to_feature_specs({install_specs.value_or_exit(VCPKG_LINE_INFO)}),
                StatusParagraphs(std::move(status_paragraphs)));

            // Expect the default feature not to get installed.
            Assert::IsTrue(install_plan.size() == 1);
            features_check(&install_plan[0], "a", {"core"}, Triplet::X64_WINDOWS);
        }

        TEST_METHOD(install_default_features_of_dependency_test_1)
        {
            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;

            // Add a port "a" which depends on the core of "b"
            PackageSpecMap spec_map(Triplet::X64_WINDOWS);
            spec_map.emplace("a", "b[core]");
            // "b" has two features, of which "b1" is default.
            spec_map.emplace("b", "", {{"b0", ""}, {"b1", ""}}, {"b1"});

            // Install "a" (without explicit feature specification)
            auto install_specs = FullPackageSpec::from_string("a", Triplet::X64_WINDOWS);
            auto install_plan = Dependencies::create_feature_install_plan(
                spec_map.map,
                FullPackageSpec::to_feature_specs({install_specs.value_or_exit(VCPKG_LINE_INFO)}),
                StatusParagraphs(std::move(status_paragraphs)));

            // Expect "a" to get installed and defaults of "b" through the dependency,
            // as no explicit features of "b" are installed by the user.
            Assert::IsTrue(install_plan.size() == 2);
            features_check(&install_plan[0], "b", {"b1", "core"}, Triplet::X64_WINDOWS);
            features_check(&install_plan[1], "a", {"core"}, Triplet::X64_WINDOWS);
        }

        TEST_METHOD(do_not_install_default_features_of_existing_dependency)
        {
            // Add a port "a" which depends on the core of "b"
            PackageSpecMap spec_map(Triplet::X64_WINDOWS);
            spec_map.emplace("a", "b[core]");
            // "b" has two features, of which "b1" is default.
            spec_map.emplace("b", "", {{"b0", ""}, {"b1", ""}}, {"b1"});

            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;
            // "b[core]" is already installed
            status_paragraphs.push_back(make_status_pgh("b"));
            status_paragraphs.back()->package.spec =
                PackageSpec::from_name_and_triplet("b", Triplet::X64_WINDOWS).value_or_exit(VCPKG_LINE_INFO);

            // Install "a" (without explicit feature specification)
            auto install_specs = FullPackageSpec::from_string("a", Triplet::X64_WINDOWS);
            auto install_plan = Dependencies::create_feature_install_plan(
                spec_map.map,
                FullPackageSpec::to_feature_specs({install_specs.value_or_exit(VCPKG_LINE_INFO)}),
                StatusParagraphs(std::move(status_paragraphs)));

            // Expect "a" to get installed, but not require rebuilding "b"
            Assert::IsTrue(install_plan.size() == 1);
            features_check(&install_plan[0], "a", {"core"}, Triplet::X64_WINDOWS);
        }

        TEST_METHOD(install_default_features_of_dependency_test_2)
        {
            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;
            status_paragraphs.push_back(make_status_pgh("b"));
            status_paragraphs.back()->package.spec =
                PackageSpec::from_name_and_triplet("b", Triplet::X64_WINDOWS).value_or_exit(VCPKG_LINE_INFO);

            // Add a port "a" which depends on the core of "b", which was already
            // installed explicitly
            PackageSpecMap spec_map(Triplet::X64_WINDOWS);
            spec_map.emplace("a", "b[core]");
            // "b" has two features, of which "b1" is default.
            spec_map.emplace("b", "", {{"b0", ""}, {"b1", ""}}, {"b1"});

            // Install "a" (without explicit feature specification)
            auto install_specs = FullPackageSpec::from_string("a", Triplet::X64_WINDOWS);
            auto install_plan = Dependencies::create_feature_install_plan(
                spec_map.map,
                FullPackageSpec::to_feature_specs({install_specs.value_or_exit(VCPKG_LINE_INFO)}),
                StatusParagraphs(std::move(status_paragraphs)));

            // Expect "a" to get installed, not the defaults of "b", as the required
            // dependencies are already there, installed explicitly by the user.
            Assert::IsTrue(install_plan.size() == 1);
            features_check(&install_plan[0], "a", {"core"}, Triplet::X64_WINDOWS);
        }

        TEST_METHOD(install_plan_action_dependencies)
        {
            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;

            // Add a port "a" which depends on the core of "b", which was already
            // installed explicitly
            PackageSpecMap spec_map(Triplet::X64_WINDOWS);
            auto spec_c = spec_map.emplace("c");
            auto spec_b = spec_map.emplace("b", "c");
            spec_map.emplace("a", "b");

            // Install "a" (without explicit feature specification)
            auto install_specs = FullPackageSpec::from_string("a", Triplet::X64_WINDOWS);
            auto install_plan = Dependencies::create_feature_install_plan(
                spec_map.map,
                FullPackageSpec::to_feature_specs({install_specs.value_or_exit(VCPKG_LINE_INFO)}),
                StatusParagraphs(std::move(status_paragraphs)));

            Assert::IsTrue(install_plan.size() == 3);
            features_check(&install_plan[0], "c", {"core"}, Triplet::X64_WINDOWS);

            features_check(&install_plan[1], "b", {"core"}, Triplet::X64_WINDOWS);
            Assert::IsTrue(install_plan[1].install_action.get()->computed_dependencies ==
                           std::vector<PackageSpec>{spec_c});

            features_check(&install_plan[2], "a", {"core"}, Triplet::X64_WINDOWS);
            Assert::IsTrue(install_plan[2].install_action.get()->computed_dependencies ==
                           std::vector<PackageSpec>{spec_b});
        }

        TEST_METHOD(install_plan_action_dependencies_2)
        {
            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;

            // Add a port "a" which depends on the core of "b", which was already
            // installed explicitly
            PackageSpecMap spec_map(Triplet::X64_WINDOWS);
            auto spec_c = spec_map.emplace("c");
            auto spec_b = spec_map.emplace("b", "c");
            spec_map.emplace("a", "c, b");

            // Install "a" (without explicit feature specification)
            auto install_specs = FullPackageSpec::from_string("a", Triplet::X64_WINDOWS);
            auto install_plan = Dependencies::create_feature_install_plan(
                spec_map.map,
                FullPackageSpec::to_feature_specs({install_specs.value_or_exit(VCPKG_LINE_INFO)}),
                StatusParagraphs(std::move(status_paragraphs)));

            Assert::IsTrue(install_plan.size() == 3);
            features_check(&install_plan[0], "c", {"core"}, Triplet::X64_WINDOWS);

            features_check(&install_plan[1], "b", {"core"}, Triplet::X64_WINDOWS);
            Assert::IsTrue(install_plan[1].install_action.get()->computed_dependencies ==
                           std::vector<PackageSpec>{spec_c});

            features_check(&install_plan[2], "a", {"core"}, Triplet::X64_WINDOWS);
            Assert::IsTrue(install_plan[2].install_action.get()->computed_dependencies ==
                           std::vector<PackageSpec>{spec_b, spec_c});
        }

        TEST_METHOD(install_plan_action_dependencies_3)
        {
            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;

            // Add a port "a" which depends on the core of "b", which was already
            // installed explicitly
            PackageSpecMap spec_map(Triplet::X64_WINDOWS);
            spec_map.emplace("a", "", {{"0", ""}, {"1", "a[0]"}}, {"1"});

            // Install "a" (without explicit feature specification)
            auto install_specs = FullPackageSpec::from_string("a", Triplet::X64_WINDOWS);
            auto install_plan = Dependencies::create_feature_install_plan(
                spec_map.map,
                FullPackageSpec::to_feature_specs({install_specs.value_or_exit(VCPKG_LINE_INFO)}),
                StatusParagraphs(std::move(status_paragraphs)));

            Assert::IsTrue(install_plan.size() == 1);
            features_check(&install_plan[0], "a", {"1", "0", "core"}, Triplet::X64_WINDOWS);
            Assert::IsTrue(install_plan[0].install_action.get()->computed_dependencies == std::vector<PackageSpec>{});
        }

        TEST_METHOD(install_with_default_features)
        {
            std::vector<std::unique_ptr<StatusParagraph>> pghs;
            pghs.push_back(make_status_pgh("a", ""));
            StatusParagraphs status_db(std::move(pghs));

            PackageSpecMap spec_map;
            auto b_spec = spec_map.emplace("b", "", {{"0", ""}}, {"0"});
            auto a_spec = spec_map.emplace("a", "b[core]", {{"0", ""}});

            // Install "a" and indicate that "b" should not install default features
            auto install_plan = Dependencies::create_feature_install_plan(
                spec_map.map, {FeatureSpec{a_spec, "0"}, FeatureSpec{b_spec, "core"}}, status_db);

            Assert::IsTrue(install_plan.size() == 3);
            remove_plan_check(&install_plan[0], "a");
            features_check(&install_plan[1], "b", {"core"});
            features_check(&install_plan[2], "a", {"0", "core"});
        }

        TEST_METHOD(upgrade_with_default_features_1)
        {
            std::vector<std::unique_ptr<StatusParagraph>> pghs;
            pghs.push_back(make_status_pgh("a", "", "1"));
            pghs.push_back(make_status_feature_pgh("a", "0"));
            StatusParagraphs status_db(std::move(pghs));

            // Add a port "a" of which "core" and "0" are already installed.
            PackageSpecMap spec_map;
            auto spec_a = spec_map.emplace("a", "", {{"0", ""}, {"1", ""}}, {"1"});

            Dependencies::MapPortFileProvider provider(spec_map.map);
            Dependencies::PackageGraph graph(provider, status_db);

            graph.upgrade(spec_a);
            auto plan = graph.serialize();

            // The upgrade should not install the default feature
            Assert::AreEqual(size_t(2), plan.size());

            Assert::AreEqual("a", plan[0].spec().name().c_str());
            remove_plan_check(&plan[0], "a");
            features_check(&plan[1], "a", {"core", "0"});
        }

        TEST_METHOD(upgrade_with_default_features_2)
        {
            std::vector<std::unique_ptr<StatusParagraph>> pghs;
            // B is currently installed _without_ default feature b0
            pghs.push_back(make_status_pgh("b", "", "b0", "x64-windows"));
            pghs.push_back(make_status_pgh("a", "b[core]", "", "x64-windows"));

            StatusParagraphs status_db(std::move(pghs));

            PackageSpecMap spec_map(Triplet::X64_WINDOWS);
            auto spec_a = spec_map.emplace("a", "b[core]");
            auto spec_b = spec_map.emplace("b", "", {{"b0", ""}, {"b1", ""}}, {"b0", "b1"});

            Dependencies::MapPortFileProvider provider(spec_map.map);
            Dependencies::PackageGraph graph(provider, status_db);

            graph.upgrade(spec_a);
            graph.upgrade(spec_b);
            auto plan = graph.serialize();

            // The upgrade should install the new default feature b1 but not b0
            Assert::AreEqual(size_t(4), plan.size());
            remove_plan_check(&plan[0], "a", Triplet::X64_WINDOWS);
            remove_plan_check(&plan[1], "b", Triplet::X64_WINDOWS);
            features_check(&plan[2], "b", {"core", "b1"}, Triplet::X64_WINDOWS);
            features_check(&plan[3], "a", {"core"}, Triplet::X64_WINDOWS);
        }

        TEST_METHOD(upgrade_with_default_features_3)
        {
            std::vector<std::unique_ptr<StatusParagraph>> pghs;
            // note: unrelated package due to x86 triplet
            pghs.push_back(make_status_pgh("b", "", "", "x86-windows"));
            pghs.push_back(make_status_pgh("a", "", "", "x64-windows"));

            StatusParagraphs status_db(std::move(pghs));

            PackageSpecMap spec_map(Triplet::X64_WINDOWS);
            auto spec_a = spec_map.emplace("a", "b[core]");
            spec_map.emplace("b", "", {{"b0", ""}, {"b1", ""}}, {"b0"});

            Dependencies::MapPortFileProvider provider(spec_map.map);
            Dependencies::PackageGraph graph(provider, status_db);

            graph.upgrade(spec_a);
            auto plan = graph.serialize();

            // The upgrade should install the default feature
            Assert::AreEqual(size_t(3), plan.size());
            remove_plan_check(&plan[0], "a", Triplet::X64_WINDOWS);
            features_check(&plan[1], "b", {"b0", "core"}, Triplet::X64_WINDOWS);
            features_check(&plan[2], "a", {"core"}, Triplet::X64_WINDOWS);
        }

        TEST_METHOD(upgrade_with_new_default_feature)
        {
            std::vector<std::unique_ptr<StatusParagraph>> pghs;
            pghs.push_back(make_status_pgh("a", "", "0", "x86-windows"));

            StatusParagraphs status_db(std::move(pghs));

            PackageSpecMap spec_map;
            auto spec_a = spec_map.emplace("a", "", {{"0", ""}, {"1", ""}, {"2", ""}}, {"0", "1"});

            Dependencies::MapPortFileProvider provider(spec_map.map);
            Dependencies::PackageGraph graph(provider, status_db);

            graph.upgrade(spec_a);
            auto plan = graph.serialize();

            // The upgrade should install the new default feature but not the old default feature 0
            Assert::AreEqual(size_t(2), plan.size());
            remove_plan_check(&plan[0], "a", Triplet::X86_WINDOWS);
            features_check(&plan[1], "a", {"core", "1"}, Triplet::X86_WINDOWS);
        }

        TEST_METHOD(transitive_features_test)
        {
            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;

            PackageSpecMap spec_map(Triplet::X64_WINDOWS);
            auto spec_a_64 = FullPackageSpec{spec_map.emplace("a", "b", {{"0", "b[0]"}}), {"core"}};
            auto spec_b_64 = FullPackageSpec{spec_map.emplace("b", "c", {{"0", "c[0]"}}), {"core"}};
            auto spec_c_64 = FullPackageSpec{spec_map.emplace("c", "", {{"0", ""}}), {"core"}};

            auto install_specs = FullPackageSpec::from_string("a[*]", Triplet::X64_WINDOWS);
            Assert::IsTrue(install_specs.has_value());
            if (!install_specs.has_value()) return;
            auto install_plan = Dependencies::create_feature_install_plan(
                spec_map.map,
                FullPackageSpec::to_feature_specs({install_specs.value_or_exit(VCPKG_LINE_INFO)}),
                StatusParagraphs(std::move(status_paragraphs)));

            Assert::IsTrue(install_plan.size() == 3);
            features_check(&install_plan[0], "c", {"0", "core"}, Triplet::X64_WINDOWS);
            features_check(&install_plan[1], "b", {"0", "core"}, Triplet::X64_WINDOWS);
            features_check(&install_plan[2], "a", {"0", "core"}, Triplet::X64_WINDOWS);
        }

        TEST_METHOD(no_transitive_features_test)
        {
            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;

            PackageSpecMap spec_map(Triplet::X64_WINDOWS);
            auto spec_a_64 = FullPackageSpec{spec_map.emplace("a", "b", {{"0", ""}}), {"core"}};
            auto spec_b_64 = FullPackageSpec{spec_map.emplace("b", "c", {{"0", ""}}), {"core"}};
            auto spec_c_64 = FullPackageSpec{spec_map.emplace("c", "", {{"0", ""}}), {"core"}};

            auto install_specs = FullPackageSpec::from_string("a[*]", Triplet::X64_WINDOWS);
            Assert::IsTrue(install_specs.has_value());
            if (!install_specs.has_value()) return;
            auto install_plan = Dependencies::create_feature_install_plan(
                spec_map.map,
                FullPackageSpec::to_feature_specs({install_specs.value_or_exit(VCPKG_LINE_INFO)}),
                StatusParagraphs(std::move(status_paragraphs)));

            Assert::IsTrue(install_plan.size() == 3);
            features_check(&install_plan[0], "c", {"core"}, Triplet::X64_WINDOWS);
            features_check(&install_plan[1], "b", {"core"}, Triplet::X64_WINDOWS);
            features_check(&install_plan[2], "a", {"0", "core"}, Triplet::X64_WINDOWS);
        }

        TEST_METHOD(only_transitive_features_test)
        {
            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;

            PackageSpecMap spec_map(Triplet::X64_WINDOWS);
            auto spec_a_64 = FullPackageSpec{spec_map.emplace("a", "", {{"0", "b[0]"}}), {"core"}};
            auto spec_b_64 = FullPackageSpec{spec_map.emplace("b", "", {{"0", "c[0]"}}), {"core"}};
            auto spec_c_64 = FullPackageSpec{spec_map.emplace("c", "", {{"0", ""}}), {"core"}};

            auto install_specs = FullPackageSpec::from_string("a[*]", Triplet::X64_WINDOWS);
            Assert::IsTrue(install_specs.has_value());
            if (!install_specs.has_value()) return;
            auto install_plan = Dependencies::create_feature_install_plan(
                spec_map.map,
                FullPackageSpec::to_feature_specs({install_specs.value_or_exit(VCPKG_LINE_INFO)}),
                StatusParagraphs(std::move(status_paragraphs)));

            Assert::IsTrue(install_plan.size() == 3);
            features_check(&install_plan[0], "c", {"0", "core"}, Triplet::X64_WINDOWS);
            features_check(&install_plan[1], "b", {"0", "core"}, Triplet::X64_WINDOWS);
            features_check(&install_plan[2], "a", {"0", "core"}, Triplet::X64_WINDOWS);
        }
    };

    class RemovePlanTests : public TestClass<RemovePlanTests>
    {
        TEST_METHOD(basic_remove_scheme)
        {
            std::vector<std::unique_ptr<StatusParagraph>> pghs;
            pghs.push_back(make_status_pgh("a"));
            StatusParagraphs status_db(std::move(pghs));

            auto remove_plan = Dependencies::create_remove_plan({unsafe_pspec("a")}, status_db);

            Assert::AreEqual(size_t(1), remove_plan.size());
            Assert::AreEqual("a", remove_plan[0].spec.name().c_str());
        }

        TEST_METHOD(recurse_remove_scheme)
        {
            std::vector<std::unique_ptr<StatusParagraph>> pghs;
            pghs.push_back(make_status_pgh("a"));
            pghs.push_back(make_status_pgh("b", "a"));
            StatusParagraphs status_db(std::move(pghs));

            auto remove_plan = Dependencies::create_remove_plan({unsafe_pspec("a")}, status_db);

            Assert::AreEqual(size_t(2), remove_plan.size());
            Assert::AreEqual("b", remove_plan[0].spec.name().c_str());
            Assert::AreEqual("a", remove_plan[1].spec.name().c_str());
        }

        TEST_METHOD(features_depend_remove_scheme)
        {
            std::vector<std::unique_ptr<StatusParagraph>> pghs;
            pghs.push_back(make_status_pgh("a"));
            pghs.push_back(make_status_pgh("b"));
            pghs.push_back(make_status_feature_pgh("b", "0", "a"));
            StatusParagraphs status_db(std::move(pghs));

            auto remove_plan = Dependencies::create_remove_plan({unsafe_pspec("a")}, status_db);

            Assert::AreEqual(size_t(2), remove_plan.size());
            Assert::AreEqual("b", remove_plan[0].spec.name().c_str());
            Assert::AreEqual("a", remove_plan[1].spec.name().c_str());
        }

        TEST_METHOD(features_depend_remove_scheme_once_removed)
        {
            std::vector<std::unique_ptr<StatusParagraph>> pghs;
            pghs.push_back(make_status_pgh("expat"));
            pghs.push_back(make_status_pgh("vtk", "expat"));
            pghs.push_back(make_status_pgh("opencv"));
            pghs.push_back(make_status_feature_pgh("opencv", "vtk", "vtk"));
            StatusParagraphs status_db(std::move(pghs));

            auto remove_plan = Dependencies::create_remove_plan({unsafe_pspec("expat")}, status_db);

            Assert::AreEqual(size_t(3), remove_plan.size());
            Assert::AreEqual("opencv", remove_plan[0].spec.name().c_str());
            Assert::AreEqual("vtk", remove_plan[1].spec.name().c_str());
            Assert::AreEqual("expat", remove_plan[2].spec.name().c_str());
        }

        TEST_METHOD(features_depend_remove_scheme_once_removed_x64)
        {
            std::vector<std::unique_ptr<StatusParagraph>> pghs;
            pghs.push_back(make_status_pgh("expat", "", "", "x64"));
            pghs.push_back(make_status_pgh("vtk", "expat", "", "x64"));
            pghs.push_back(make_status_pgh("opencv", "", "", "x64"));
            pghs.push_back(make_status_feature_pgh("opencv", "vtk", "vtk", "x64"));
            StatusParagraphs status_db(std::move(pghs));

            auto remove_plan = Dependencies::create_remove_plan(
                {unsafe_pspec("expat", Triplet::from_canonical_name("x64"))}, status_db);

            Assert::AreEqual(size_t(3), remove_plan.size());
            Assert::AreEqual("opencv", remove_plan[0].spec.name().c_str());
            Assert::AreEqual("vtk", remove_plan[1].spec.name().c_str());
            Assert::AreEqual("expat", remove_plan[2].spec.name().c_str());
        }

        TEST_METHOD(features_depend_core_remove_scheme)
        {
            std::vector<std::unique_ptr<StatusParagraph>> pghs;
            pghs.push_back(make_status_pgh("curl", "", "", "x64"));
            pghs.push_back(make_status_pgh("cpr", "curl[core]", "", "x64"));
            StatusParagraphs status_db(std::move(pghs));

            auto remove_plan = Dependencies::create_remove_plan(
                {unsafe_pspec("curl", Triplet::from_canonical_name("x64"))}, status_db);

            Assert::AreEqual(size_t(2), remove_plan.size());
            Assert::AreEqual("cpr", remove_plan[0].spec.name().c_str());
            Assert::AreEqual("curl", remove_plan[1].spec.name().c_str());
        }

        TEST_METHOD(features_depend_core_remove_scheme_2)
        {
            std::vector<std::unique_ptr<StatusParagraph>> pghs;
            pghs.push_back(make_status_pgh("curl", "", "", "x64"));
            pghs.push_back(make_status_feature_pgh("curl", "a", "", "x64"));
            pghs.push_back(make_status_feature_pgh("curl", "b", "curl[a]", "x64"));
            StatusParagraphs status_db(std::move(pghs));

            auto remove_plan = Dependencies::create_remove_plan(
                {unsafe_pspec("curl", Triplet::from_canonical_name("x64"))}, status_db);

            Assert::AreEqual(size_t(1), remove_plan.size());
            Assert::AreEqual("curl", remove_plan[0].spec.name().c_str());
        }
    };

    class UpgradePlanTests : public TestClass<UpgradePlanTests>
    {
        TEST_METHOD(basic_upgrade_scheme)
        {
            std::vector<std::unique_ptr<StatusParagraph>> pghs;
            pghs.push_back(make_status_pgh("a"));
            StatusParagraphs status_db(std::move(pghs));

            PackageSpecMap spec_map;
            auto spec_a = spec_map.emplace("a");

            Dependencies::MapPortFileProvider provider(spec_map.map);
            Dependencies::PackageGraph graph(provider, status_db);

            graph.upgrade(spec_a);

            auto plan = graph.serialize();

            Assert::AreEqual(size_t(2), plan.size());
            Assert::AreEqual("a", plan[0].spec().name().c_str());
            Assert::IsTrue(plan[0].remove_action.has_value());
            Assert::AreEqual("a", plan[1].spec().name().c_str());
            Assert::IsTrue(plan[1].install_action.has_value());
        }

        TEST_METHOD(basic_upgrade_scheme_with_recurse)
        {
            std::vector<std::unique_ptr<StatusParagraph>> pghs;
            pghs.push_back(make_status_pgh("a"));
            pghs.push_back(make_status_pgh("b", "a"));
            StatusParagraphs status_db(std::move(pghs));

            PackageSpecMap spec_map;
            auto spec_a = spec_map.emplace("a");
            spec_map.emplace("b", "a");

            Dependencies::MapPortFileProvider provider(spec_map.map);
            Dependencies::PackageGraph graph(provider, status_db);

            graph.upgrade(spec_a);

            auto plan = graph.serialize();

            Assert::AreEqual(size_t(4), plan.size());
            Assert::AreEqual("b", plan[0].spec().name().c_str());
            Assert::IsTrue(plan[0].remove_action.has_value());

            Assert::AreEqual("a", plan[1].spec().name().c_str());
            Assert::IsTrue(plan[1].remove_action.has_value());

            Assert::AreEqual("a", plan[2].spec().name().c_str());
            Assert::IsTrue(plan[2].install_action.has_value());

            Assert::AreEqual("b", plan[3].spec().name().c_str());
            Assert::IsTrue(plan[3].install_action.has_value());
        }

        TEST_METHOD(basic_upgrade_scheme_with_bystander)
        {
            std::vector<std::unique_ptr<StatusParagraph>> pghs;
            pghs.push_back(make_status_pgh("a"));
            pghs.push_back(make_status_pgh("b"));
            StatusParagraphs status_db(std::move(pghs));

            PackageSpecMap spec_map;
            auto spec_a = spec_map.emplace("a");
            spec_map.emplace("b", "a");

            Dependencies::MapPortFileProvider provider(spec_map.map);
            Dependencies::PackageGraph graph(provider, status_db);

            graph.upgrade(spec_a);

            auto plan = graph.serialize();

            Assert::AreEqual(size_t(2), plan.size());
            Assert::AreEqual("a", plan[0].spec().name().c_str());
            Assert::IsTrue(plan[0].remove_action.has_value());
            Assert::AreEqual("a", plan[1].spec().name().c_str());
            Assert::IsTrue(plan[1].install_action.has_value());
        }

        TEST_METHOD(basic_upgrade_scheme_with_new_dep)
        {
            std::vector<std::unique_ptr<StatusParagraph>> pghs;
            pghs.push_back(make_status_pgh("a"));
            StatusParagraphs status_db(std::move(pghs));

            PackageSpecMap spec_map;
            auto spec_a = spec_map.emplace("a", "b");
            spec_map.emplace("b");

            Dependencies::MapPortFileProvider provider(spec_map.map);
            Dependencies::PackageGraph graph(provider, status_db);

            graph.upgrade(spec_a);

            auto plan = graph.serialize();

            Assert::AreEqual(size_t(3), plan.size());
            Assert::AreEqual("a", plan[0].spec().name().c_str());
            Assert::IsTrue(plan[0].remove_action.has_value());
            Assert::AreEqual("b", plan[1].spec().name().c_str());
            Assert::IsTrue(plan[1].install_action.has_value());
            Assert::AreEqual("a", plan[2].spec().name().c_str());
            Assert::IsTrue(plan[2].install_action.has_value());
        }

        TEST_METHOD(basic_upgrade_scheme_with_features)
        {
            std::vector<std::unique_ptr<StatusParagraph>> pghs;
            pghs.push_back(make_status_pgh("a"));
            pghs.push_back(make_status_feature_pgh("a", "a1"));
            StatusParagraphs status_db(std::move(pghs));

            PackageSpecMap spec_map;
            auto spec_a = spec_map.emplace("a", "", {{"a1", ""}});

            Dependencies::MapPortFileProvider provider(spec_map.map);
            Dependencies::PackageGraph graph(provider, status_db);

            graph.upgrade(spec_a);

            auto plan = graph.serialize();

            Assert::AreEqual(size_t(2), plan.size());

            Assert::AreEqual("a", plan[0].spec().name().c_str());
            Assert::IsTrue(plan[0].remove_action.has_value());

            features_check(&plan[1], "a", {"core", "a1"});
        }

        TEST_METHOD(basic_upgrade_scheme_with_new_default_feature)
        {
            // only core of package "a" is installed
            std::vector<std::unique_ptr<StatusParagraph>> pghs;
            pghs.push_back(make_status_pgh("a"));
            StatusParagraphs status_db(std::move(pghs));

            // a1 was added as a default feature and should be installed in upgrade
            PackageSpecMap spec_map;
            auto spec_a = spec_map.emplace("a", "", {{"a1", ""}}, {"a1"});

            Dependencies::MapPortFileProvider provider(spec_map.map);
            Dependencies::PackageGraph graph(provider, status_db);

            graph.upgrade(spec_a);

            auto plan = graph.serialize();

            Assert::AreEqual(size_t(2), plan.size());

            Assert::AreEqual("a", plan[0].spec().name().c_str());
            Assert::IsTrue(plan[0].remove_action.has_value());

            features_check(&plan[1], "a", {"core", "a1"});
        }

        TEST_METHOD(basic_upgrade_scheme_with_self_features)
        {
            std::vector<std::unique_ptr<StatusParagraph>> pghs;
            pghs.push_back(make_status_pgh("a"));
            pghs.push_back(make_status_feature_pgh("a", "a1", ""));
            pghs.push_back(make_status_feature_pgh("a", "a2", "a[a1]"));
            StatusParagraphs status_db(std::move(pghs));

            PackageSpecMap spec_map;
            auto spec_a = spec_map.emplace("a", "", {{"a1", ""}, {"a2", "a[a1]"}});

            Dependencies::MapPortFileProvider provider(spec_map.map);
            Dependencies::PackageGraph graph(provider, status_db);

            graph.upgrade(spec_a);

            auto plan = graph.serialize();

            Assert::AreEqual(size_t(2), plan.size());

            Assert::AreEqual("a", plan[0].spec().name().c_str());
            Assert::IsTrue(plan[0].remove_action.has_value());

            Assert::AreEqual("a", plan[1].spec().name().c_str());
            Assert::IsTrue(plan[1].install_action.has_value());
            Assert::IsTrue(plan[1].install_action.get()->feature_list == std::set<std::string>{"core", "a1", "a2"});
        }
    };

    class ExportPlanTests : public TestClass<ExportPlanTests>
    {
        TEST_METHOD(basic_export_scheme)
        {
            std::vector<std::unique_ptr<StatusParagraph>> pghs;
            pghs.push_back(make_status_pgh("a"));
            StatusParagraphs status_db(std::move(pghs));

            PackageSpecMap spec_map;
            auto spec_a = spec_map.emplace("a");

            auto plan = Dependencies::create_export_plan({spec_a}, status_db);

            Assert::AreEqual(size_t(1), plan.size());
            Assert::AreEqual("a", plan[0].spec.name().c_str());
            Assert::IsTrue(plan[0].plan_type == Dependencies::ExportPlanType::ALREADY_BUILT);
        }

        TEST_METHOD(basic_export_scheme_with_recurse)
        {
            std::vector<std::unique_ptr<StatusParagraph>> pghs;
            pghs.push_back(make_status_pgh("a"));
            pghs.push_back(make_status_pgh("b", "a"));
            StatusParagraphs status_db(std::move(pghs));

            PackageSpecMap spec_map;
            auto spec_a = spec_map.emplace("a");
            auto spec_b = spec_map.emplace("b", "a");

            auto plan = Dependencies::create_export_plan({spec_b}, status_db);

            Assert::AreEqual(size_t(2), plan.size());
            Assert::AreEqual("a", plan[0].spec.name().c_str());
            Assert::IsTrue(plan[0].plan_type == Dependencies::ExportPlanType::ALREADY_BUILT);

            Assert::AreEqual("b", plan[1].spec.name().c_str());
            Assert::IsTrue(plan[1].plan_type == Dependencies::ExportPlanType::ALREADY_BUILT);
        }

        TEST_METHOD(basic_export_scheme_with_bystander)
        {
            std::vector<std::unique_ptr<StatusParagraph>> pghs;
            pghs.push_back(make_status_pgh("a"));
            pghs.push_back(make_status_pgh("b"));
            StatusParagraphs status_db(std::move(pghs));

            PackageSpecMap spec_map;
            auto spec_a = spec_map.emplace("a");
            auto spec_b = spec_map.emplace("b", "a");

            auto plan = Dependencies::create_export_plan({spec_a}, status_db);

            Assert::AreEqual(size_t(1), plan.size());
            Assert::AreEqual("a", plan[0].spec.name().c_str());
            Assert::IsTrue(plan[0].plan_type == Dependencies::ExportPlanType::ALREADY_BUILT);
        }

        TEST_METHOD(basic_export_scheme_with_missing)
        {
            StatusParagraphs status_db;

            PackageSpecMap spec_map;
            auto spec_a = spec_map.emplace("a");

            auto plan = Dependencies::create_export_plan({spec_a}, status_db);

            Assert::AreEqual(size_t(1), plan.size());
            Assert::AreEqual("a", plan[0].spec.name().c_str());
            Assert::IsTrue(plan[0].plan_type == Dependencies::ExportPlanType::NOT_BUILT);
        }

        TEST_METHOD(basic_export_scheme_with_features)
        {
            std::vector<std::unique_ptr<StatusParagraph>> pghs;
            pghs.push_back(make_status_pgh("b"));
            pghs.push_back(make_status_pgh("a"));
            pghs.push_back(make_status_feature_pgh("a", "a1", "b[core]"));
            StatusParagraphs status_db(std::move(pghs));

            PackageSpecMap spec_map;
            auto spec_a = spec_map.emplace("a", "", {{"a1", ""}});

            auto plan = Dependencies::create_export_plan({spec_a}, status_db);

            Assert::AreEqual(size_t(2), plan.size());

            Assert::AreEqual("b", plan[0].spec.name().c_str());
            Assert::IsTrue(plan[0].plan_type == Dependencies::ExportPlanType::ALREADY_BUILT);

            Assert::AreEqual("a", plan[1].spec.name().c_str());
            Assert::IsTrue(plan[1].plan_type == Dependencies::ExportPlanType::ALREADY_BUILT);
        }
    };
}
