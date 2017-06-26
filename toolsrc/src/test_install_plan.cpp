#include "CppUnitTest.h"
#include "vcpkg_Dependencies.h"

using namespace Microsoft::VisualStudio::CppUnitTestFramework;

using namespace vcpkg;

namespace UnitTest1
{
    class InstallPlanTests : public TestClass<InstallPlanTests>
    {
        TEST_METHOD(basic_install_scheme)
        {
            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;

            std::unordered_map<PackageSpec, SourceControlFile> map;
            auto add_scf = [&](std::vector<std::unordered_map<std::string, std::string>>&& fields) -> PackageSpec {
                auto m_pgh = vcpkg::SourceControlFile::parse_control_file(std::move(fields));
                Assert::IsTrue(m_pgh.has_value());
                auto& scf = *m_pgh.get();

                auto spec = PackageSpec::from_name_and_triplet(scf.core_paragraph.name, Triplet::X86_WINDOWS);
                Assert::IsTrue(spec.has_value());
                map.emplace(*spec.get(), std::move(*m_pgh.get()));
                return PackageSpec{*spec.get()};
            };

            auto spec_a = add_scf({{{"Source", "a"}, {"Version", "1.2.8"}, {"Build-Depends", "b"}}});
            auto spec_b = add_scf({{{"Source", "b"}, {"Version", "1.3"}, {"Build-Depends", "c"}}});
            auto spec_c = add_scf({{{"Source", "c"}, {"Version", "2.5.3"}, {"Build-Depends", ""}}});

            auto map_port = Dependencies::MapPortFile(map);
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

            std::unordered_map<PackageSpec, SourceControlFile> map;
            auto add_scf = [&](std::vector<std::unordered_map<std::string, std::string>>&& fields) -> PackageSpec {
                auto m_pgh = vcpkg::SourceControlFile::parse_control_file(std::move(fields));
                Assert::IsTrue(m_pgh.has_value());
                auto& scf = *m_pgh.get();

                auto spec = PackageSpec::from_name_and_triplet(scf.core_paragraph.name, Triplet::X86_WINDOWS);
                Assert::IsTrue(spec.has_value());
                map.emplace(*spec.get(), std::move(*m_pgh.get()));
                return PackageSpec{*spec.get()};
            };

            auto spec_a = add_scf({{{"Source", "a"}, {"Version", "1.2.8"}, {"Build-Depends", "d"}}});
            auto spec_b = add_scf({{{"Source", "b"}, {"Version", "1.3"}, {"Build-Depends", "d, e"}}});
            auto spec_c = add_scf({{{"Source", "c"}, {"Version", "2.5.3"}, {"Build-Depends", "e, h"}}});
            auto spec_d = add_scf({{{"Source", "d"}, {"Version", "4.0"}, {"Build-Depends", "f, g, h"}}});
            auto spec_e = add_scf({{{"Source", "e"}, {"Version", "1.0"}, {"Build-Depends", "g"}}});
            auto spec_f = add_scf({{{"Source", "f"}, {"Version", "1.0"}, {"Build-Depends", ""}}});
            auto spec_g = add_scf({{{"Source", "g"}, {"Version", "1.0"}, {"Build-Depends", ""}}});
            auto spec_h = add_scf({{{"Source", "h"}, {"Version", "1.0"}, {"Build-Depends", ""}}});

            auto map_port = Dependencies::MapPortFile(map);
            auto install_plan = Dependencies::create_install_plan(
                map_port, {spec_a, spec_b, spec_c}, StatusParagraphs(std::move(status_paragraphs)));

            auto iterator_pos = [&](const PackageSpec& spec) -> int {
                int counter = 0;
                for (auto&& install_p : install_plan)
                {
                    if (install_p.spec == spec)
                    {
                        return counter;
                    }
                    counter++;
                }
                return -1;
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

        TEST_METHOD(long_install_scheme)
        {
            using Pgh = std::unordered_map<std::string, std::string>;
            std::vector<std::unique_ptr<StatusParagraph>> status_paragraphs;
            status_paragraphs.push_back(std::make_unique<StatusParagraph>(Pgh{{"Package", "j"},
                                                                              {"Version", "1.2.8"},
                                                                              {"Architecture", "x86-windows"},
                                                                              {"Multi-Arch", "same"},
                                                                              {"Build-Depends", "k"},
                                                                              {"Status", "install ok installed"}}));
            status_paragraphs.push_back(std::make_unique<StatusParagraph>(Pgh{{"Package", "k"},
                                                                              {"Version", "1.2.8"},
                                                                              {"Architecture", "x86-windows"},
                                                                              {"Multi-Arch", "same"},
                                                                              {"Build-Depends", ""},
                                                                              {"Status", "install ok installed"}}));

            std::unordered_map<PackageSpec, SourceControlFile> map;
            auto add_scf = [&](std::vector<std::unordered_map<std::string, std::string>>&& fields) -> PackageSpec {
                auto m_pgh = vcpkg::SourceControlFile::parse_control_file(std::move(fields));
                Assert::IsTrue(m_pgh.has_value());
                auto& scf = *m_pgh.get();

                auto spec = PackageSpec::from_name_and_triplet(scf.core_paragraph.name, Triplet::X86_WINDOWS);
                Assert::IsTrue(spec.has_value());
                map.emplace(*spec.get(), std::move(*m_pgh.get()));
                return PackageSpec{*spec.get()};
            };

            auto spec_h = add_scf({{{"Source", "h"}, {"Version", "1.2.8"}, {"Build-Depends", "j, k"}}});
            auto spec_c = add_scf({{{"Source", "c"}, {"Version", "1.2.8"}, {"Build-Depends", "d, e, f, g, h, j, k"}}});
            auto spec_k = add_scf({{{"Source", "k"}, {"Version", "1.2.8"}, {"Build-Depends", ""}}});
            auto spec_b =
                add_scf({{{"Source", "b"}, {"Version", "1.2.8"}, {"Build-Depends", "c, d, e, f, g, h, j, k"}}});
            auto spec_d = add_scf({{{"Source", "d"}, {"Version", "1.2.8"}, {"Build-Depends", "e, f, g, h, j, k"}}});
            auto spec_j = add_scf({{{"Source", "j"}, {"Version", "1.2.8"}, {"Build-Depends", "k"}}});
            auto spec_f = add_scf({{{"Source", "f"}, {"Version", "1.2.8"}, {"Build-Depends", "g, h, j, k"}}});
            auto spec_e = add_scf({{{"Source", "e"}, {"Version", "1.2.8"}, {"Build-Depends", "f, g, h, j, k"}}});
            auto spec_a =
                add_scf({{{"Source", "a"}, {"Version", "1.2.8"}, {"Build-Depends", "b, c, d, e, f, g, h, j, k"}}});
            auto spec_g = add_scf({{{"Source", "g"}, {"Version", "1.2.8"}, {"Build-Depends", "h, j, k"}}});

            auto map_port = Dependencies::MapPortFile(map);
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
    };
}