#include "CppUnitTest.h"
#include "Paragraphs.h"
#include "BinaryParagraph.h"

#pragma comment(lib,"version")
#pragma comment(lib,"winhttp")

using namespace Microsoft::VisualStudio::CppUnitTestFramework;

namespace Microsoft::VisualStudio::CppUnitTestFramework
{
    template <>
    inline std::wstring ToString<vcpkg::PackageSpecParseResult>(const vcpkg::PackageSpecParseResult& t)
    {
        return ToString(static_cast<uint32_t>(t));
    }
}

namespace UnitTest1
{
    TEST_CLASS(ControlParsing)
    {
    public:
        TEST_METHOD(SourceParagraph_Construct_Minimum)
        {
            vcpkg::SourceParagraph pgh({
                { "Source", "zlib" },
                { "Version", "1.2.8" }
            });

            Assert::AreEqual("zlib", pgh.name.c_str());
            Assert::AreEqual("1.2.8", pgh.version.c_str());
            Assert::AreEqual("", pgh.maintainer.c_str());
            Assert::AreEqual("", pgh.description.c_str());
            Assert::AreEqual(size_t(0), pgh.depends.size());
        }

        TEST_METHOD(SourceParagraph_Construct_Maximum)
        {
            vcpkg::SourceParagraph pgh({
                { "Source", "s" },
                { "Version", "v" },
                { "Maintainer", "m" },
                { "Description", "d" },
                { "Build-Depends", "bd" }
            });
            Assert::AreEqual("s", pgh.name.c_str());
            Assert::AreEqual("v", pgh.version.c_str());
            Assert::AreEqual("m", pgh.maintainer.c_str());
            Assert::AreEqual("d", pgh.description.c_str());
            Assert::AreEqual(size_t(1), pgh.depends.size());
            Assert::AreEqual("bd", pgh.depends[0].name.c_str());
        }

        TEST_METHOD(SourceParagraph_Two_Depends)
        {
            vcpkg::SourceParagraph pgh({
                { "Source", "zlib" },
                { "Version", "1.2.8" },
                { "Build-Depends", "z, openssl" }
            });

            Assert::AreEqual(size_t(2), pgh.depends.size());
            Assert::AreEqual("z", pgh.depends[0].name.c_str());
            Assert::AreEqual("openssl", pgh.depends[1].name.c_str());
        }

        TEST_METHOD(SourceParagraph_Three_Depends)
        {
            vcpkg::SourceParagraph pgh({
                { "Source", "zlib" },
                { "Version", "1.2.8" },
                { "Build-Depends", "z, openssl, xyz" }
            });

            Assert::AreEqual(size_t(3), pgh.depends.size());
            Assert::AreEqual("z", pgh.depends[0].name.c_str());
            Assert::AreEqual("openssl", pgh.depends[1].name.c_str());
            Assert::AreEqual("xyz", pgh.depends[2].name.c_str());
        }

        TEST_METHOD(SourceParagraph_Construct_Qualified_Depends)
        {
            vcpkg::SourceParagraph pgh({
                { "Source", "zlib" },
                { "Version", "1.2.8" },
                { "Build-Depends", "libA [windows], libB [uwp]" }
            });

            Assert::AreEqual("zlib", pgh.name.c_str());
            Assert::AreEqual("1.2.8", pgh.version.c_str());
            Assert::AreEqual("", pgh.maintainer.c_str());
            Assert::AreEqual("", pgh.description.c_str());
            Assert::AreEqual(size_t(2), pgh.depends.size());
            Assert::AreEqual("libA", pgh.depends[0].name.c_str());
            Assert::AreEqual("windows", pgh.depends[0].qualifier.c_str());
            Assert::AreEqual("libB", pgh.depends[1].name.c_str());
            Assert::AreEqual("uwp", pgh.depends[1].qualifier.c_str());
        }

        TEST_METHOD(BinaryParagraph_Construct_Minimum)
        {
            vcpkg::BinaryParagraph pgh({
                { "Package", "zlib" },
                { "Version", "1.2.8" },
                { "Architecture", "x86-windows" },
                { "Multi-Arch", "same" },
            });

            Assert::AreEqual("zlib", pgh.spec.name().c_str());
            Assert::AreEqual("1.2.8", pgh.version.c_str());
            Assert::AreEqual("", pgh.maintainer.c_str());
            Assert::AreEqual("", pgh.description.c_str());
            Assert::AreEqual("x86-windows", pgh.spec.target_triplet().canonical_name().c_str());
            Assert::AreEqual(size_t(0), pgh.depends.size());
        }

        TEST_METHOD(BinaryParagraph_Construct_Maximum)
        {
            vcpkg::BinaryParagraph pgh({
                { "Package", "s" },
                { "Version", "v" },
                { "Architecture", "x86-windows" },
                { "Multi-Arch", "same" },
                { "Maintainer", "m" },
                { "Description", "d" },
                { "Depends", "bd" }
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
                { "Package", "zlib" },
                { "Version", "1.2.8" },
                { "Architecture", "x86-windows" },
                { "Multi-Arch", "same" },
                { "Depends", "a, b, c" },
            });

            Assert::AreEqual(size_t(3), pgh.depends.size());
            Assert::AreEqual("a", pgh.depends[0].c_str());
            Assert::AreEqual("b", pgh.depends[1].c_str());
            Assert::AreEqual("c", pgh.depends[2].c_str());
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
            const char* str =
                "f1: v1\n"
                "f2: v2";
            auto pghs = vcpkg::Paragraphs::parse_paragraphs(str).value_or_exit(VCPKG_LINE_INFO);
            Assert::AreEqual(size_t(1), pghs.size());
            Assert::AreEqual(size_t(2), pghs[0].size());
            Assert::AreEqual("v1", pghs[0]["f1"].c_str());
            Assert::AreEqual("v2", pghs[0]["f2"].c_str());
        }

        TEST_METHOD(parse_paragraphs_two_pgh)
        {
            const char* str =
                "f1: v1\n"
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
            const char* str =
                "1:\n"
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
            const char* str =
                "f1: v1\n"
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
            const char* str =
                "f1:\n"
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
            const char* str =
                "f1: simple\n"
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
            const char* str =
                "f1: v1\r\n"
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
            const char* str =
                "f1: v1\r\n"
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

        TEST_METHOD(BinaryParagraph_serialize_min)
        {
            std::stringstream ss;
            vcpkg::BinaryParagraph pgh({
                { "Package", "zlib" },
                { "Version", "1.2.8" },
                { "Architecture", "x86-windows" },
                { "Multi-Arch", "same" },
            });
            ss << pgh;
            auto pghs = vcpkg::Paragraphs::parse_paragraphs(ss.str()).value_or_exit(VCPKG_LINE_INFO);
            Assert::AreEqual(size_t(1), pghs.size());
            Assert::AreEqual(size_t(4), pghs[0].size());
            Assert::AreEqual("zlib", pghs[0]["Package"].c_str());
            Assert::AreEqual("1.2.8", pghs[0]["Version"].c_str());
            Assert::AreEqual("x86-windows", pghs[0]["Architecture"].c_str());
            Assert::AreEqual("same", pghs[0]["Multi-Arch"].c_str());
        }

        TEST_METHOD(BinaryParagraph_serialize_max)
        {
            std::stringstream ss;
            vcpkg::BinaryParagraph pgh({
                { "Package", "zlib" },
                { "Version", "1.2.8" },
                { "Architecture", "x86-windows" },
                { "Description", "first line\n second line" },
                { "Maintainer", "abc <abc@abc.abc>" },
                { "Depends", "dep" },
                { "Multi-Arch", "same" },
            });
            ss << pgh;
            auto pghs = vcpkg::Paragraphs::parse_paragraphs(ss.str()).value_or_exit(VCPKG_LINE_INFO);
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
            std::stringstream ss;
            vcpkg::BinaryParagraph pgh({
                { "Package", "zlib" },
                { "Version", "1.2.8" },
                { "Architecture", "x86-windows" },
                { "Multi-Arch", "same" },
                { "Depends", "a, b, c" },
            });
            ss << pgh;
            auto pghs = vcpkg::Paragraphs::parse_paragraphs(ss.str()).value_or_exit(VCPKG_LINE_INFO);
            Assert::AreEqual(size_t(1), pghs.size());
            Assert::AreEqual("a, b, c", pghs[0]["Depends"].c_str());
        }

        TEST_METHOD(package_spec_parse)
        {
            vcpkg::Expected<vcpkg::PackageSpec> spec = vcpkg::PackageSpec::from_string("zlib", vcpkg::Triplet::X86_WINDOWS);
            Assert::AreEqual(vcpkg::PackageSpecParseResult::SUCCESS, vcpkg::to_package_spec_parse_result(spec.error_code()));
            Assert::AreEqual("zlib", spec.get()->name().c_str());
            Assert::AreEqual(vcpkg::Triplet::X86_WINDOWS.canonical_name(), spec.get()->target_triplet().canonical_name());
        }

        TEST_METHOD(package_spec_parse_with_arch)
        {
            vcpkg::Expected<vcpkg::PackageSpec> spec = vcpkg::PackageSpec::from_string("zlib:x64-uwp", vcpkg::Triplet::X86_WINDOWS);
            Assert::AreEqual(vcpkg::PackageSpecParseResult::SUCCESS, vcpkg::to_package_spec_parse_result(spec.error_code()));
            Assert::AreEqual("zlib", spec.get()->name().c_str());
            Assert::AreEqual(vcpkg::Triplet::X64_UWP.canonical_name(), spec.get()->target_triplet().canonical_name());
        }

        TEST_METHOD(package_spec_parse_with_multiple_colon)
        {
            auto ec = vcpkg::PackageSpec::from_string("zlib:x86-uwp:", vcpkg::Triplet::X86_WINDOWS).error_code();
            Assert::AreEqual(vcpkg::PackageSpecParseResult::TOO_MANY_COLONS, vcpkg::to_package_spec_parse_result(ec));
        }

        TEST_METHOD(utf8_to_utf16)
        {
            auto str = vcpkg::Strings::utf8_to_utf16("abc");
            Assert::AreEqual(L"abc", str.c_str());
        }

        TEST_METHOD(utf8_to_utf16_with_whitespace)
        {
            auto str = vcpkg::Strings::utf8_to_utf16("abc -x86-windows");
            Assert::AreEqual(L"abc -x86-windows", str.c_str());
        }
    };

    TEST_CLASS(Metrics) { };
}
