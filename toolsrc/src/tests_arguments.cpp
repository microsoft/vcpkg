#include "CppUnitTest.h"
#include "VcpkgCmdArguments.h"

#pragma comment(lib,"version")
#pragma comment(lib,"winhttp")

using namespace Microsoft::VisualStudio::CppUnitTestFramework;

using namespace vcpkg;

namespace UnitTest1
{
    TEST_CLASS(ArgumentTests)
    {
    public:
        TEST_METHOD(create_from_arg_sequence_options_lower)
        {
            std::vector<std::string> t = {
                "--vcpkg-root", "C:\vcpkg",
                "--debug",
                "--sendmetrics",
                "--printmetrics"
            };
            auto v = VcpkgCmdArguments::create_from_arg_sequence(t.data(), t.data() + t.size());
            Assert::AreEqual("C:\vcpkg", v.vcpkg_root_dir.get()->c_str());
            Assert::IsTrue(vcpkg::OptBoolC::ENABLED == v.debug);
            Assert::IsTrue(vcpkg::OptBoolC::ENABLED == v.sendmetrics);
            Assert::IsTrue(vcpkg::OptBoolC::ENABLED == v.printmetrics);
        }

        TEST_METHOD(create_from_arg_sequence_options_upper)
        {
            std::vector<std::string> t = {
                "--VCPKG-ROOT", "C:\vcpkg",
                "--DEBUG",
                "--SENDMETRICS",
                "--PRINTMETRICS"
            };
            auto v = VcpkgCmdArguments::create_from_arg_sequence(t.data(), t.data() + t.size());
            Assert::AreEqual("C:\vcpkg", v.vcpkg_root_dir.get()->c_str());
            Assert::IsTrue(vcpkg::OptBoolC::ENABLED == v.debug);
            Assert::IsTrue(vcpkg::OptBoolC::ENABLED == v.sendmetrics);
            Assert::IsTrue(vcpkg::OptBoolC::ENABLED == v.printmetrics);
        }
    };
}
