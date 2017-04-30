#include "CppUnitTest.h"
#include "SourceParagraph.h"
#include "Triplet.h"

#pragma comment(lib, "version")
#pragma comment(lib, "winhttp")

using namespace Microsoft::VisualStudio::CppUnitTestFramework;

using namespace vcpkg;

namespace UnitTest1
{
    class DependencyTests : public TestClass<DependencyTests>
    {
        TEST_METHOD(parse_depends_one)
        {
            auto v = expand_qualified_dependencies(parse_depends("libA [windows]"));
            Assert::AreEqual(size_t(1), v.size());
            Assert::AreEqual("libA", v[0].name.c_str());
            Assert::AreEqual("windows", v[0].qualifier.c_str());
        }

        TEST_METHOD(filter_depends)
        {
            auto deps = expand_qualified_dependencies(parse_depends("libA [windows], libB, libC [uwp]"));
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
}
