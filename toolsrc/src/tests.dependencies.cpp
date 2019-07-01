#include "tests.pch.h"

#if defined(_WIN32)
#pragma comment(lib, "version")
#pragma comment(lib, "winhttp")
#endif

using namespace Microsoft::VisualStudio::CppUnitTestFramework;

using namespace vcpkg;
using Parse::parse_comma_list;

namespace UnitTest1
{
    class DependencyTests : public TestClass<DependencyTests>
    {
        TEST_METHOD(parse_depends_one)
        {
            auto v = expand_qualified_dependencies(parse_comma_list("libA (windows)"));
            Assert::AreEqual(size_t(1), v.size());
            Assert::AreEqual("libA", v[0].depend.name.c_str());
            Assert::AreEqual("windows", v[0].qualifier.c_str());
        }

        TEST_METHOD(filter_depends)
        {
            auto deps = expand_qualified_dependencies(parse_comma_list("libA (windows), libB, libC (uwp)"));
            auto v = filter_dependencies(deps, Triplet::X64_WINDOWS);
            Assert::AreEqual(size_t(2), v.size());
            Assert::AreEqual("libA", v[0].c_str());
            Assert::AreEqual("libB", v[1].c_str());

            auto v2 = filter_dependencies(deps, Triplet::ARM_UWP);
            Assert::AreEqual(size_t(2), v.size());
            Assert::AreEqual("libB", v2[0].c_str());
            Assert::AreEqual("libC", v2[1].c_str());
        }
    };

    class SupportsTests : public TestClass<SupportsTests>
    {
        TEST_METHOD(parse_supports_all)
        {
            auto v = Supports::parse({
                "x64",
                "x86",
                "arm",
                "windows",
                "uwp",
                "v140",
                "v141",
                "crt-static",
                "crt-dynamic",
            });
            Assert::AreNotEqual(uintptr_t(0), uintptr_t(v.get()));

            Assert::IsTrue(v.get()->is_supported(System::CPUArchitecture::X64,
                                                 Supports::Platform::UWP,
                                                 Supports::Linkage::DYNAMIC,
                                                 Supports::ToolsetVersion::V140));
            Assert::IsTrue(v.get()->is_supported(System::CPUArchitecture::ARM,
                                                 Supports::Platform::WINDOWS,
                                                 Supports::Linkage::STATIC,
                                                 Supports::ToolsetVersion::V141));
        }

        TEST_METHOD(parse_supports_invalid)
        {
            auto v = Supports::parse({"arm64"});
            Assert::AreEqual(uintptr_t(0), uintptr_t(v.get()));
            Assert::AreEqual(size_t(1), v.error().size());
            Assert::AreEqual("arm64", v.error()[0].c_str());
        }

        TEST_METHOD(parse_supports_case_sensitive)
        {
            auto v = Supports::parse({"Windows"});
            Assert::AreEqual(uintptr_t(0), uintptr_t(v.get()));
            Assert::AreEqual(size_t(1), v.error().size());
            Assert::AreEqual("Windows", v.error()[0].c_str());
        }

        TEST_METHOD(parse_supports_some)
        {
            auto v = Supports::parse({
                "x64",
                "x86",
                "windows",
            });
            Assert::AreNotEqual(uintptr_t(0), uintptr_t(v.get()));

            Assert::IsTrue(v.get()->is_supported(System::CPUArchitecture::X64,
                                                 Supports::Platform::WINDOWS,
                                                 Supports::Linkage::DYNAMIC,
                                                 Supports::ToolsetVersion::V140));
            Assert::IsFalse(v.get()->is_supported(System::CPUArchitecture::ARM,
                                                  Supports::Platform::WINDOWS,
                                                  Supports::Linkage::DYNAMIC,
                                                  Supports::ToolsetVersion::V140));
            Assert::IsFalse(v.get()->is_supported(System::CPUArchitecture::X64,
                                                  Supports::Platform::UWP,
                                                  Supports::Linkage::DYNAMIC,
                                                  Supports::ToolsetVersion::V140));
            Assert::IsTrue(v.get()->is_supported(System::CPUArchitecture::X64,
                                                 Supports::Platform::WINDOWS,
                                                 Supports::Linkage::STATIC,
                                                 Supports::ToolsetVersion::V141));
        }
    };
}
