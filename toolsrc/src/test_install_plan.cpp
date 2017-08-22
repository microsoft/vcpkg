#include "CppUnitTest.h"
#include "vcpkg_Dependencies.h"
#include "vcpkg_Util.h"

using namespace Microsoft::VisualStudio::CppUnitTestFramework;

using namespace vcpkg;

namespace Microsoft::VisualStudio::CppUnitTestFramework
{
    template<>
    inline std::wstring ToString<vcpkg::Dependencies::InstallPlanType>(const vcpkg::Dependencies::InstallPlanType& t)
    {
        switch (t)
        {
            case Dependencies::InstallPlanType::ALREADY_INSTALLED: return L"ALREADY_INSTALLED";
            case Dependencies::InstallPlanType::BUILD_AND_INSTALL: return L"BUILD_AND_INSTALL";
            case Dependencies::InstallPlanType::INSTALL: return L"INSTALL";
            case Dependencies::InstallPlanType::UNKNOWN: return L"UNKNOWN";
            default: return ToString((int)t);
        }
    }

    template<>
    inline std::wstring ToString<vcpkg::Dependencies::RequestType>(const vcpkg::Dependencies::RequestType& t)
    {
        switch (t)
        {
            case Dependencies::RequestType::AUTO_SELECTED: return L"AUTO_SELECTED";
            case Dependencies::RequestType::USER_REQUESTED: return L"USER_REQUESTED";
            case Dependencies::RequestType::UNKNOWN: return L"UNKNOWN";
            default: return ToString((int)t);
        }
    }
}

namespace UnitTest1
{
    class InstallPlanTests : public TestClass<InstallPlanTests>
    {
        static std::unique_ptr<SourceControlFile> make_control_file(
            const char* name,
            const char* depends,
            const std::vector<std::pair<const char*, const char*>>& features = {})
        {
            using Pgh = std::unordered_map<std::string, std::string>;
            std::vector<Pgh> scf_pghs;
            scf_pghs.push_back(Pgh{
                {"Source", name},
                {"Version", "0"},
                {"Build-Depends", depends},
            });
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

        static void features_check(Dependencies::AnyAction* install_action,
                                   std::string pkg_name,
                                   std::vector<std::string> vec,
                                   const Triplet& triplet = Triplet::X86_WINDOWS)
        {
            const auto& plan = install_action->install_plan.value_or_exit(VCPKG_LINE_INFO);
            const auto& feature_list = plan.feature_list;

            Assert::AreEqual(plan.spec.triplet().to_string().c_str(), triplet.to_string().c_str());

            Assert::AreEqual(pkg_name.c_str(),
                             (*plan.any_paragraph.source_control_file.get())->core_paragraph->name.c_str());
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

        static void remove_plan_check(Dependencies::AnyAction* remove_action,
                                      std::string pkg_name,
                                      const Triplet& triplet = Triplet::X86_WINDOWS)
        {
            const auto& plan = remove_action->remove_plan.value_or_exit(VCPKG_LINE_INFO);
            Assert::AreEqual(plan.spec.triplet().to_string().c_str(), triplet.to_string().c_str());
            Assert::AreEqual(pkg_name.c_str(), plan.spec.name().c_str());
        }

        static std::unique_ptr<StatusParagraph> make_status_pgh(const char* name, const char* depends = "")
        {
            using Pgh = std::unordered_map<std::string, std::string>;
            return std::make_unique<StatusParagraph>(Pgh{{"Package", name},
                                                         {"Version", "1"},
                                                         {"Architecture", "x86-windows"},
                                                         {"Multi-Arch", "same"},
                                                         {"Depends", depends},
                                                         {"Status", "install ok installed"}});
        }
        static std::unique_ptr<StatusParagraph> make_status_feature_pgh(const char* name,
                                                                        const char* feature,
                                                                        const char* depends = "")
        {
            using Pgh = std::unordered_map<std::string, std::string>;
            return std::make_unique<StatusParagraph>(Pgh{{"Package", name},
                                                         {"Version", "1"},
                                                         {"Feature", feature},
                                                         {"Architecture", "x86-windows"},
                                                         {"Multi-Arch", "same"},
                                                         {"Depends", depends},
                                                         {"Status", "install ok installed"}});
        }
        struct PackageSpecMap
        {
            std::unordered_map<std::string, SourceControlFile> map;
            Triplet triplet;
            PackageSpecMap(const Triplet& t) { triplet = t; }

            PackageSpec emplace(const char* name,
                                const char* depends = "",
                                const std::vector<std::pair<const char*, const char*>>& features = {})
            {
                return emplace(std::move(*make_control_file(name, depends, features)));
            }
            PackageSpec emplace(vcpkg::SourceControlFile&& scf)
            {
                auto spec = PackageSpec::from_name_and_triplet(scf.core_paragraph->name, triplet);
                Assert::IsTrue(spec.has_value());
                map.emplace(scf.core_paragraph->name, std::move(scf));
                return PackageSpec{*spec.get()};
            }
        };

        TEST_METHOD(basic_install_scheme)
        {
            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;

            PackageSpecMap spec_map(Triplet::X86_WINDOWS);
            auto spec_a = spec_map.emplace("a", "b");
            auto spec_b = spec_map.emplace("b", "c");
            auto spec_c = spec_map.emplace("c");

            Dependencies::MapPortFile map_port(spec_map.map);
            auto install_plan =
                Dependencies::create_install_plan(map_port, {spec_a}, StatusParagraphs(std::move(status_paragraphs)));

            Assert::AreEqual(size_t(3), install_plan.size());
            Assert::AreEqual("c", install_plan[0].spec.name().c_str());
            Assert::AreEqual("b", install_plan[1].spec.name().c_str());
            Assert::AreEqual("a", install_plan[2].spec.name().c_str());
        }

        TEST_METHOD(multiple_install_scheme)
        {
            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;

            PackageSpecMap spec_map(Triplet::X86_WINDOWS);
            auto spec_a = spec_map.emplace("a", "d");
            auto spec_b = spec_map.emplace("b", "d, e");
            auto spec_c = spec_map.emplace("c", "e, h");
            auto spec_d = spec_map.emplace("d", "f, g, h");
            auto spec_e = spec_map.emplace("e", "g");
            auto spec_f = spec_map.emplace("f");
            auto spec_g = spec_map.emplace("g");
            auto spec_h = spec_map.emplace("h");

            Dependencies::MapPortFile map_port(spec_map.map);
            auto install_plan = Dependencies::create_install_plan(
                map_port, {spec_a, spec_b, spec_c}, StatusParagraphs(std::move(status_paragraphs)));

            auto iterator_pos = [&](const PackageSpec& spec) -> int {
                auto it = std::find_if(
                    install_plan.begin(), install_plan.end(), [&](auto& action) { return action.spec == spec; });
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

            PackageSpecMap spec_map(Triplet::X86_WINDOWS);
            auto spec_a = FullPackageSpec{spec_map.emplace("a")};

            auto install_plan =
                Dependencies::create_feature_install_plan(spec_map.map,
                                                          FullPackageSpec::to_feature_specs({spec_a}),
                                                          StatusParagraphs(std::move(status_paragraphs)));

            Assert::AreEqual(size_t(1), install_plan.size());
            auto p = install_plan[0].install_plan.get();
            Assert::IsNotNull(p);
            Assert::AreEqual("a", p->spec.name().c_str());
            Assert::AreEqual(Dependencies::InstallPlanType::ALREADY_INSTALLED, p->plan_type);
            Assert::AreEqual(Dependencies::RequestType::USER_REQUESTED, p->request_type);
        }

        TEST_METHOD(user_requested_package_scheme)
        {
            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;

            PackageSpecMap spec_map(Triplet::X86_WINDOWS);
            auto spec_a = FullPackageSpec{spec_map.emplace("a", "b")};
            auto spec_b = FullPackageSpec{spec_map.emplace("b")};

            auto install_plan =
                Dependencies::create_feature_install_plan(spec_map.map,
                                                          FullPackageSpec::to_feature_specs({spec_a}),
                                                          StatusParagraphs(std::move(status_paragraphs)));

            Assert::AreEqual(size_t(2), install_plan.size());
            auto p = install_plan[0].install_plan.get();
            Assert::IsNotNull(p);
            Assert::AreEqual("b", p->spec.name().c_str());
            Assert::AreEqual(Dependencies::InstallPlanType::BUILD_AND_INSTALL, p->plan_type);
            Assert::AreEqual(Dependencies::RequestType::AUTO_SELECTED, p->request_type);

            auto p2 = install_plan[1].install_plan.get();
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

            PackageSpecMap spec_map(Triplet::X86_WINDOWS);

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

            Dependencies::MapPortFile map_port(spec_map.map);
            auto install_plan =
                Dependencies::create_install_plan(map_port, {spec_a}, StatusParagraphs(std::move(status_paragraphs)));

            Assert::AreEqual(size_t(8), install_plan.size());
            Assert::AreEqual("h", install_plan[0].spec.name().c_str());
            Assert::AreEqual("g", install_plan[1].spec.name().c_str());
            Assert::AreEqual("f", install_plan[2].spec.name().c_str());
            Assert::AreEqual("e", install_plan[3].spec.name().c_str());
            Assert::AreEqual("d", install_plan[4].spec.name().c_str());
            Assert::AreEqual("c", install_plan[5].spec.name().c_str());
            Assert::AreEqual("b", install_plan[6].spec.name().c_str());
            Assert::AreEqual("a", install_plan[7].spec.name().c_str());
        }

        TEST_METHOD(basic_feature_test_1)
        {
            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;
            status_paragraphs.push_back(make_status_pgh("a", "b, b[b1]"));
            status_paragraphs.push_back(make_status_pgh("b"));
            status_paragraphs.push_back(make_status_feature_pgh("b", "b1"));

            PackageSpecMap spec_map(Triplet::X86_WINDOWS);
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

            PackageSpecMap spec_map(Triplet::X86_WINDOWS);

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

            PackageSpecMap spec_map(Triplet::X86_WINDOWS);

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

            PackageSpecMap spec_map(Triplet::X86_WINDOWS);

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

            PackageSpecMap spec_map(Triplet::X86_WINDOWS);

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

            PackageSpecMap spec_map(Triplet::X86_WINDOWS);
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

            PackageSpecMap spec_map(Triplet::X86_WINDOWS);

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

            /*Assert::AreEqual(size_t(8), install_plan.size());
            auto iterator_pos = [&](const PackageSpec& spec, size_t start) -> int {
                auto it = std::find_if(install_plan.begin() + start, install_plan.end(), [&](auto& action) {
                    return action.spec == spec;
                });
                Assert::IsTrue(it != install_plan.end());
                return (int)(it - install_plan.begin());
            };
            int a_64_1 = iterator_pos(spec_a_64.package_spec, 0), a_86_1 = iterator_pos(spec_a_86.package_spec, 0),
                b_64 = iterator_pos(spec_b_64.package_spec, 0), b_86 = iterator_pos(spec_b_86.package_spec, 0),
                c_64 = iterator_pos(spec_c_64.package_spec, 0), c_86 = iterator_pos(spec_c_86.package_spec, 0),
                a_64_2 = iterator_pos(spec_a_64.package_spec, a_64_1 + 1),
                a_86_2 = iterator_pos(spec_a_86.package_spec, a_86_1 + 1);*/

            remove_plan_check(&install_plan[0], "a", Triplet::X64_WINDOWS);
            remove_plan_check(&install_plan[1], "a");
            features_check(&install_plan[2], "b", {"core"}, Triplet::X64_WINDOWS);
            features_check(&install_plan[3], "a", {"a1", "core"}, Triplet::X64_WINDOWS);
            features_check(&install_plan[4], "c", {"core"}, Triplet::X64_WINDOWS);
            features_check(&install_plan[5], "b", {"core"});
            features_check(&install_plan[6], "a", {"a1", "core"});
            features_check(&install_plan[7], "c", {"core"});
        }
    };
}