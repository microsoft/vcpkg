#include "tests.pch.h"

#include <tests.utils.h>

#if defined(_WIN32)
#pragma comment(lib, "version")
#pragma comment(lib, "winhttp")
#endif

using namespace Microsoft::VisualStudio::CppUnitTestFramework;

namespace UnitTest1
{
    using namespace vcpkg;

    class SpecifierConversion : public TestClass<SpecifierConversion>
    {
        TEST_METHOD(full_package_spec_to_feature_specs)
        {
            auto a_spec = PackageSpec::from_name_and_triplet("a", Triplet::X64_WINDOWS).value_or_exit(VCPKG_LINE_INFO);
            auto b_spec = PackageSpec::from_name_and_triplet("b", Triplet::X64_WINDOWS).value_or_exit(VCPKG_LINE_INFO);

            auto fspecs = FullPackageSpec::to_feature_specs({{a_spec, {"0", "1"}}, {b_spec, {"2", "3"}}});

            Assert::AreEqual(size_t(6), fspecs.size());

            std::array<const char*, 6> features = {"", "0", "1", "", "2", "3"};
            std::array<PackageSpec*, 6> specs = {&a_spec, &a_spec, &a_spec, &b_spec, &b_spec, &b_spec};

            for (size_t i = 0; i < features.size(); ++i)
            {
                Assert::AreEqual(features[i], fspecs[i].feature().c_str());
                Assert::AreEqual(*specs[i], fspecs[i].spec());
            }
        }
    };

    class SpecifierParsing : public TestClass<SpecifierParsing>
    {
        TEST_METHOD(parsed_specifier_from_string)
        {
            auto maybe_spec = vcpkg::ParsedSpecifier::from_string("zlib");
            Assert::AreEqual(vcpkg::PackageSpecParseResult::SUCCESS, maybe_spec.error());
            auto spec = maybe_spec.get();
            Assert::AreEqual("zlib", spec->name.c_str());
            Assert::AreEqual(size_t(0), spec->features.size());
            Assert::AreEqual("", spec->triplet.c_str());
        }

        TEST_METHOD(parsed_specifier_from_string_with_triplet)
        {
            auto maybe_spec = vcpkg::ParsedSpecifier::from_string("zlib:x64-uwp");
            Assert::AreEqual(vcpkg::PackageSpecParseResult::SUCCESS, maybe_spec.error());
            auto spec = maybe_spec.get();
            Assert::AreEqual("zlib", spec->name.c_str());
            Assert::AreEqual("x64-uwp", spec->triplet.c_str());
        }

        TEST_METHOD(parsed_specifier_from_string_with_colons)
        {
            auto ec = vcpkg::ParsedSpecifier::from_string("zlib:x86-uwp:").error();
            Assert::AreEqual(vcpkg::PackageSpecParseResult::TOO_MANY_COLONS, ec);
        }

        TEST_METHOD(parsed_specifier_from_string_with_feature)
        {
            auto maybe_spec = vcpkg::ParsedSpecifier::from_string("zlib[feature]:x64-uwp");
            Assert::AreEqual(vcpkg::PackageSpecParseResult::SUCCESS, maybe_spec.error());
            auto spec = maybe_spec.get();
            Assert::AreEqual("zlib", spec->name.c_str());
            Assert::IsTrue(spec->features.size() == 1);
            Assert::AreEqual("feature", spec->features.front().c_str());
            Assert::AreEqual("x64-uwp", spec->triplet.c_str());
        }

        TEST_METHOD(parsed_specifier_from_string_with_many_features)
        {
            auto maybe_spec = vcpkg::ParsedSpecifier::from_string("zlib[0, 1,2]");
            Assert::AreEqual(vcpkg::PackageSpecParseResult::SUCCESS, maybe_spec.error());
            auto spec = maybe_spec.get();
            Assert::AreEqual("zlib", spec->name.c_str());
            Assert::IsTrue(spec->features.size() == 3);
            Assert::AreEqual("0", spec->features[0].c_str());
            Assert::AreEqual("1", spec->features[1].c_str());
            Assert::AreEqual("2", spec->features[2].c_str());
            Assert::AreEqual("", spec->triplet.c_str());
        }

        TEST_METHOD(parsed_specifier_wildcard_feature)
        {
            auto maybe_spec = vcpkg::ParsedSpecifier::from_string("zlib[*]");
            Assert::AreEqual(vcpkg::PackageSpecParseResult::SUCCESS, maybe_spec.error());
            auto spec = maybe_spec.get();
            Assert::AreEqual("zlib", spec->name.c_str());
            Assert::IsTrue(spec->features.size() == 1);
            Assert::AreEqual("*", spec->features[0].c_str());
            Assert::AreEqual("", spec->triplet.c_str());
        }

        TEST_METHOD(expand_wildcards)
        {
            auto zlib =
                vcpkg::FullPackageSpec::from_string("zlib[0,1]", Triplet::X86_UWP).value_or_exit(VCPKG_LINE_INFO);
            auto openssl =
                vcpkg::FullPackageSpec::from_string("openssl[*]", Triplet::X86_UWP).value_or_exit(VCPKG_LINE_INFO);
            auto specs = FullPackageSpec::to_feature_specs({zlib, openssl});
            Util::sort(specs);
            auto spectargets = FeatureSpec::from_strings_and_triplet(
                {
                    "openssl",
                    "zlib",
                    "openssl[*]",
                    "zlib[0]",
                    "zlib[1]",
                },
                Triplet::X86_UWP);
            Util::sort(spectargets);
            Assert::IsTrue(specs.size() == spectargets.size());
            Assert::IsTrue(Util::all_equal(specs, spectargets));
        }

        TEST_METHOD(utf8_to_utf16)
        {
            auto str = vcpkg::Strings::to_utf16("abc");
            Assert::AreEqual(L"abc", str.c_str());
        }

        TEST_METHOD(utf8_to_utf16_with_whitespace)
        {
            auto str = vcpkg::Strings::to_utf16("abc -x86-windows");
            Assert::AreEqual(L"abc -x86-windows", str.c_str());
        }
    };

    TEST_CLASS(Metrics){};
}
