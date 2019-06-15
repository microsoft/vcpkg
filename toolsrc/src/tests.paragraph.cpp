#include "tests.pch.h"

#if defined(_WIN32)
#pragma comment(lib, "version")
#pragma comment(lib, "winhttp")
#endif

using namespace Microsoft::VisualStudio::CppUnitTestFramework;

namespace Strings = vcpkg::Strings;

namespace UnitTest1
{
    class ControlParsing : public TestClass<ControlParsing>
    {
        TEST_METHOD(SourceParagraph_Construct_Minimum)
        {
            auto m_pgh =
                vcpkg::SourceControlFile::parse_control_file(std::vector<std::unordered_map<std::string, std::string>>{{
                    {"Source", "zlib"},
                    {"Version", "1.2.8"},
                }});

            Assert::IsTrue(m_pgh.has_value());
            auto& pgh = *m_pgh.get();

            Assert::AreEqual("zlib", pgh->core_paragraph->name.c_str());
            Assert::AreEqual("1.2.8", pgh->core_paragraph->version.c_str());
            Assert::AreEqual("", pgh->core_paragraph->maintainer.c_str());
            Assert::AreEqual("", pgh->core_paragraph->description.c_str());
            Assert::AreEqual(size_t(0), pgh->core_paragraph->depends.size());
        }

        TEST_METHOD(SourceParagraph_Construct_Maximum)
        {
            auto m_pgh =
                vcpkg::SourceControlFile::parse_control_file(std::vector<std::unordered_map<std::string, std::string>>{{
                    {"Source", "s"},
                    {"Version", "v"},
                    {"Maintainer", "m"},
                    {"Description", "d"},
                    {"Build-Depends", "bd"},
                    {"Default-Features", "df"},
                    {"Supports", "x64"},
                }});
            Assert::IsTrue(m_pgh.has_value());
            auto& pgh = *m_pgh.get();

            Assert::AreEqual("s", pgh->core_paragraph->name.c_str());
            Assert::AreEqual("v", pgh->core_paragraph->version.c_str());
            Assert::AreEqual("m", pgh->core_paragraph->maintainer.c_str());
            Assert::AreEqual("d", pgh->core_paragraph->description.c_str());
            Assert::AreEqual(size_t(1), pgh->core_paragraph->depends.size());
            Assert::AreEqual("bd", pgh->core_paragraph->depends[0].name().c_str());
            Assert::AreEqual(size_t(1), pgh->core_paragraph->default_features.size());
            Assert::AreEqual("df", pgh->core_paragraph->default_features[0].c_str());
            Assert::AreEqual(size_t(1), pgh->core_paragraph->supports.size());
            Assert::AreEqual("x64", pgh->core_paragraph->supports[0].c_str());
        }

        TEST_METHOD(SourceParagraph_Two_Depends)
        {
            auto m_pgh =
                vcpkg::SourceControlFile::parse_control_file(std::vector<std::unordered_map<std::string, std::string>>{{
                    {"Source", "zlib"},
                    {"Version", "1.2.8"},
                    {"Build-Depends", "z, openssl"},
                }});
            Assert::IsTrue(m_pgh.has_value());
            auto& pgh = *m_pgh.get();

            Assert::AreEqual(size_t(2), pgh->core_paragraph->depends.size());
            Assert::AreEqual("z", pgh->core_paragraph->depends[0].name().c_str());
            Assert::AreEqual("openssl", pgh->core_paragraph->depends[1].name().c_str());
        }

        TEST_METHOD(SourceParagraph_Three_Depends)
        {
            auto m_pgh =
                vcpkg::SourceControlFile::parse_control_file(std::vector<std::unordered_map<std::string, std::string>>{{
                    {"Source", "zlib"},
                    {"Version", "1.2.8"},
                    {"Build-Depends", "z, openssl, xyz"},
                }});
            Assert::IsTrue(m_pgh.has_value());
            auto& pgh = *m_pgh.get();

            Assert::AreEqual(size_t(3), pgh->core_paragraph->depends.size());
            Assert::AreEqual("z", pgh->core_paragraph->depends[0].name().c_str());
            Assert::AreEqual("openssl", pgh->core_paragraph->depends[1].name().c_str());
            Assert::AreEqual("xyz", pgh->core_paragraph->depends[2].name().c_str());
        }

        TEST_METHOD(SourceParagraph_Three_Supports)
        {
            auto m_pgh =
                vcpkg::SourceControlFile::parse_control_file(std::vector<std::unordered_map<std::string, std::string>>{{
                    {"Source", "zlib"},
                    {"Version", "1.2.8"},
                    {"Supports", "x64, windows, uwp"},
                }});
            Assert::IsTrue(m_pgh.has_value());
            auto& pgh = *m_pgh.get();

            Assert::AreEqual(size_t(3), pgh->core_paragraph->supports.size());
            Assert::AreEqual("x64", pgh->core_paragraph->supports[0].c_str());
            Assert::AreEqual("windows", pgh->core_paragraph->supports[1].c_str());
            Assert::AreEqual("uwp", pgh->core_paragraph->supports[2].c_str());
        }

        TEST_METHOD(SourceParagraph_Construct_Qualified_Depends)
        {
            auto m_pgh =
                vcpkg::SourceControlFile::parse_control_file(std::vector<std::unordered_map<std::string, std::string>>{{
                    {"Source", "zlib"},
                    {"Version", "1.2.8"},
                    {"Build-Depends", "libA (windows), libB (uwp)"},
                }});
            Assert::IsTrue(m_pgh.has_value());
            auto& pgh = *m_pgh.get();

            Assert::AreEqual("zlib", pgh->core_paragraph->name.c_str());
            Assert::AreEqual("1.2.8", pgh->core_paragraph->version.c_str());
            Assert::AreEqual("", pgh->core_paragraph->maintainer.c_str());
            Assert::AreEqual("", pgh->core_paragraph->description.c_str());
            Assert::AreEqual(size_t(2), pgh->core_paragraph->depends.size());
            Assert::AreEqual("libA", pgh->core_paragraph->depends[0].name().c_str());
            Assert::AreEqual("windows", pgh->core_paragraph->depends[0].qualifier.c_str());
            Assert::AreEqual("libB", pgh->core_paragraph->depends[1].name().c_str());
            Assert::AreEqual("uwp", pgh->core_paragraph->depends[1].qualifier.c_str());
        }

        TEST_METHOD(SourceParagraph_Default_Features)
        {
            auto m_pgh =
                vcpkg::SourceControlFile::parse_control_file(std::vector<std::unordered_map<std::string, std::string>>{{
                    {"Source", "a"},
                    {"Version", "1.0"},
                    {"Default-Features", "a1"},
                }});
            Assert::IsTrue(m_pgh.has_value());
            auto& pgh = *m_pgh.get();

            Assert::AreEqual(size_t(1), pgh->core_paragraph->default_features.size());
            Assert::AreEqual("a1", pgh->core_paragraph->default_features[0].c_str());
        }

        TEST_METHOD(BinaryParagraph_Construct_Minimum)
        {
            vcpkg::BinaryParagraph pgh({
                {"Package", "zlib"},
                {"Version", "1.2.8"},
                {"Architecture", "x86-windows"},
                {"Multi-Arch", "same"},
            });

            Assert::AreEqual("zlib", pgh.spec.name().c_str());
            Assert::AreEqual("1.2.8", pgh.version.c_str());
            Assert::AreEqual("", pgh.maintainer.c_str());
            Assert::AreEqual("", pgh.description.c_str());
            Assert::AreEqual("x86-windows", pgh.spec.triplet().canonical_name().c_str());
            Assert::AreEqual(size_t(0), pgh.depends.size());
        }

        TEST_METHOD(BinaryParagraph_Construct_Maximum)
        {
            vcpkg::BinaryParagraph pgh({
                {"Package", "s"},
                {"Version", "v"},
                {"Architecture", "x86-windows"},
                {"Multi-Arch", "same"},
                {"Maintainer", "m"},
                {"Description", "d"},
                {"Depends", "bd"},
            });
            Assert::AreEqual("s", pgh.spec.name().c_str());
            Assert::AreEqual("v", pgh.version.c_str());
            Assert::AreEqual("m", pgh.maintainer.c_str());
            Assert::AreEqual("d", pgh.description.c_str());
            Assert::AreEqual(size_t(1), pgh.depends.size());
            Assert::AreEqual("bd", pgh.depends[0].c_str());
        }

        TEST_METHOD(BinaryParagraph_Three_Depends)
        {
            vcpkg::BinaryParagraph pgh({
                {"Package", "zlib"},
                {"Version", "1.2.8"},
                {"Architecture", "x86-windows"},
                {"Multi-Arch", "same"},
                {"Depends", "a, b, c"},
            });

            Assert::AreEqual(size_t(3), pgh.depends.size());
            Assert::AreEqual("a", pgh.depends[0].c_str());
            Assert::AreEqual("b", pgh.depends[1].c_str());
            Assert::AreEqual("c", pgh.depends[2].c_str());
        }

        TEST_METHOD(BinaryParagraph_Abi)
        {
            vcpkg::BinaryParagraph pgh({
                {"Package", "zlib"},
                {"Version", "1.2.8"},
                {"Architecture", "x86-windows"},
                {"Multi-Arch", "same"},
                {"Abi", "abcd123"},
            });

            Assert::AreEqual(size_t(0), pgh.depends.size());
            Assert::IsTrue(pgh.abi == "abcd123");
        }

        TEST_METHOD(BinaryParagraph_Default_Features)
        {
            vcpkg::BinaryParagraph pgh({
                {"Package", "a"},
                {"Version", "1.0"},
                {"Architecture", "x86-windows"},
                {"Multi-Arch", "same"},
                {"Default-Features", "a1"},
            });

            Assert::AreEqual(size_t(0), pgh.depends.size());
            Assert::AreEqual(size_t(1), pgh.default_features.size());
            Assert::IsTrue(pgh.default_features[0] == "a1");
        }

        TEST_METHOD(parse_paragraphs_empty)
        {
            const char* str = "";
            auto pghs = vcpkg::Paragraphs::parse_paragraphs(str).value_or_exit(VCPKG_LINE_INFO);
            Assert::IsTrue(pghs.empty());
        }

        TEST_METHOD(parse_paragraphs_one_field)
        {
            const char* str = "f1: v1";
            auto pghs = vcpkg::Paragraphs::parse_paragraphs(str).value_or_exit(VCPKG_LINE_INFO);
            Assert::AreEqual(size_t(1), pghs.size());
            Assert::AreEqual(size_t(1), pghs[0].size());
            Assert::AreEqual("v1", pghs[0]["f1"].c_str());
        }

        TEST_METHOD(parse_paragraphs_one_pgh)
        {
            const char* str = "f1: v1\n"
                              "f2: v2";
            auto pghs = vcpkg::Paragraphs::parse_paragraphs(str).value_or_exit(VCPKG_LINE_INFO);
            Assert::AreEqual(size_t(1), pghs.size());
            Assert::AreEqual(size_t(2), pghs[0].size());
            Assert::AreEqual("v1", pghs[0]["f1"].c_str());
            Assert::AreEqual("v2", pghs[0]["f2"].c_str());
        }

        TEST_METHOD(parse_paragraphs_two_pgh)
        {
            const char* str = "f1: v1\n"
                              "f2: v2\n"
                              "\n"
                              "f3: v3\n"
                              "f4: v4";
            auto pghs = vcpkg::Paragraphs::parse_paragraphs(str).value_or_exit(VCPKG_LINE_INFO);
            Assert::AreEqual(size_t(2), pghs.size());
            Assert::AreEqual(size_t(2), pghs[0].size());
            Assert::AreEqual("v1", pghs[0]["f1"].c_str());
            Assert::AreEqual("v2", pghs[0]["f2"].c_str());
            Assert::AreEqual(size_t(2), pghs[1].size());
            Assert::AreEqual("v3", pghs[1]["f3"].c_str());
            Assert::AreEqual("v4", pghs[1]["f4"].c_str());
        }

        TEST_METHOD(parse_paragraphs_field_names)
        {
            const char* str = "1:\n"
                              "f:\n"
                              "F:\n"
                              "0:\n"
                              "F-2:\n";
            auto pghs = vcpkg::Paragraphs::parse_paragraphs(str).value_or_exit(VCPKG_LINE_INFO);
            Assert::AreEqual(size_t(1), pghs.size());
            Assert::AreEqual(size_t(5), pghs[0].size());
        }

        TEST_METHOD(parse_paragraphs_multiple_blank_lines)
        {
            const char* str = "f1: v1\n"
                              "f2: v2\n"
                              "\n"
                              "\n"
                              "f3: v3\n"
                              "f4: v4";
            auto pghs = vcpkg::Paragraphs::parse_paragraphs(str).value_or_exit(VCPKG_LINE_INFO);
            Assert::AreEqual(size_t(2), pghs.size());
        }

        TEST_METHOD(parse_paragraphs_empty_fields)
        {
            const char* str = "f1:\n"
                              "f2: ";
            auto pghs = vcpkg::Paragraphs::parse_paragraphs(str).value_or_exit(VCPKG_LINE_INFO);
            Assert::AreEqual(size_t(1), pghs.size());
            Assert::AreEqual(size_t(2), pghs[0].size());
            Assert::AreEqual("", pghs[0]["f1"].c_str());
            Assert::AreEqual("", pghs[0]["f2"].c_str());
            Assert::AreEqual(size_t(2), pghs[0].size());
        }

        TEST_METHOD(parse_paragraphs_multiline_fields)
        {
            const char* str = "f1: simple\n"
                              " f1\r\n"
                              "f2:\r\n"
                              " f2\r\n"
                              " continue\r\n";
            auto pghs = vcpkg::Paragraphs::parse_paragraphs(str).value_or_exit(VCPKG_LINE_INFO);
            Assert::AreEqual(size_t(1), pghs.size());
            Assert::AreEqual("simple\n f1", pghs[0]["f1"].c_str());
            Assert::AreEqual("\n f2\n continue", pghs[0]["f2"].c_str());
        }

        TEST_METHOD(parse_paragraphs_crlfs)
        {
            const char* str = "f1: v1\r\n"
                              "f2: v2\r\n"
                              "\r\n"
                              "f3: v3\r\n"
                              "f4: v4";
            auto pghs = vcpkg::Paragraphs::parse_paragraphs(str).value_or_exit(VCPKG_LINE_INFO);
            Assert::AreEqual(size_t(2), pghs.size());
            Assert::AreEqual(size_t(2), pghs[0].size());
            Assert::AreEqual("v1", pghs[0]["f1"].c_str());
            Assert::AreEqual("v2", pghs[0]["f2"].c_str());
            Assert::AreEqual(size_t(2), pghs[1].size());
            Assert::AreEqual("v3", pghs[1]["f3"].c_str());
            Assert::AreEqual("v4", pghs[1]["f4"].c_str());
        }

        TEST_METHOD(parse_paragraphs_comment)
        {
            const char* str = "f1: v1\r\n"
                              "#comment\r\n"
                              "f2: v2\r\n"
                              "#comment\r\n"
                              "\r\n"
                              "#comment\r\n"
                              "f3: v3\r\n"
                              "#comment\r\n"
                              "f4: v4";
            auto pghs = vcpkg::Paragraphs::parse_paragraphs(str).value_or_exit(VCPKG_LINE_INFO);
            Assert::AreEqual(size_t(2), pghs.size());
            Assert::AreEqual(size_t(2), pghs[0].size());
            Assert::AreEqual("v1", pghs[0]["f1"].c_str());
            Assert::AreEqual("v2", pghs[0]["f2"].c_str());
            Assert::AreEqual(size_t(2), pghs[1].size());
            Assert::AreEqual("v3", pghs[1]["f3"].c_str());
            Assert::AreEqual("v4", pghs[1]["f4"].c_str());
        }

        TEST_METHOD(parse_comment_before_single_slashN)
        {
            const char* str = "f1: v1\r\n"
                              "#comment\n";
            auto pghs = vcpkg::Paragraphs::parse_paragraphs(str).value_or_exit(VCPKG_LINE_INFO);
            Assert::AreEqual(size_t(1), pghs[0].size());
            Assert::AreEqual("v1", pghs[0]["f1"].c_str());
        }

        TEST_METHOD(BinaryParagraph_serialize_min)
        {
            vcpkg::BinaryParagraph pgh({
                {"Package", "zlib"},
                {"Version", "1.2.8"},
                {"Architecture", "x86-windows"},
                {"Multi-Arch", "same"},
            });
            std::string ss = Strings::serialize(pgh);
            auto pghs = vcpkg::Paragraphs::parse_paragraphs(ss).value_or_exit(VCPKG_LINE_INFO);
            Assert::AreEqual(size_t(1), pghs.size());
            Assert::AreEqual(size_t(4), pghs[0].size());
            Assert::AreEqual("zlib", pghs[0]["Package"].c_str());
            Assert::AreEqual("1.2.8", pghs[0]["Version"].c_str());
            Assert::AreEqual("x86-windows", pghs[0]["Architecture"].c_str());
            Assert::AreEqual("same", pghs[0]["Multi-Arch"].c_str());
        }

        TEST_METHOD(BinaryParagraph_serialize_max)
        {
            vcpkg::BinaryParagraph pgh({
                {"Package", "zlib"},
                {"Version", "1.2.8"},
                {"Architecture", "x86-windows"},
                {"Description", "first line\n second line"},
                {"Maintainer", "abc <abc@abc.abc>"},
                {"Depends", "dep"},
                {"Multi-Arch", "same"},
            });
            std::string ss = Strings::serialize(pgh);
            auto pghs = vcpkg::Paragraphs::parse_paragraphs(ss).value_or_exit(VCPKG_LINE_INFO);
            Assert::AreEqual(size_t(1), pghs.size());
            Assert::AreEqual(size_t(7), pghs[0].size());
            Assert::AreEqual("zlib", pghs[0]["Package"].c_str());
            Assert::AreEqual("1.2.8", pghs[0]["Version"].c_str());
            Assert::AreEqual("x86-windows", pghs[0]["Architecture"].c_str());
            Assert::AreEqual("same", pghs[0]["Multi-Arch"].c_str());
            Assert::AreEqual("first line\n second line", pghs[0]["Description"].c_str());
            Assert::AreEqual("dep", pghs[0]["Depends"].c_str());
        }

        TEST_METHOD(BinaryParagraph_serialize_multiple_deps)
        {
            vcpkg::BinaryParagraph pgh({
                {"Package", "zlib"},
                {"Version", "1.2.8"},
                {"Architecture", "x86-windows"},
                {"Multi-Arch", "same"},
                {"Depends", "a, b, c"},
            });
            std::string ss = Strings::serialize(pgh);
            auto pghs = vcpkg::Paragraphs::parse_paragraphs(ss).value_or_exit(VCPKG_LINE_INFO);
            Assert::AreEqual(size_t(1), pghs.size());
            Assert::AreEqual("a, b, c", pghs[0]["Depends"].c_str());
        }

        TEST_METHOD(BinaryParagraph_serialize_abi)
        {
            vcpkg::BinaryParagraph pgh({
                {"Package", "zlib"},
                {"Version", "1.2.8"},
                {"Architecture", "x86-windows"},
                {"Multi-Arch", "same"},
                {"Depends", "a, b, c"},
                {"Abi", "123abc"},
            });
            std::string ss = Strings::serialize(pgh);
            auto pghs = vcpkg::Paragraphs::parse_paragraphs(ss).value_or_exit(VCPKG_LINE_INFO);
            Assert::AreEqual(size_t(1), pghs.size());
            Assert::AreEqual("123abc", pghs[0]["Abi"].c_str());
        }
    };
}
