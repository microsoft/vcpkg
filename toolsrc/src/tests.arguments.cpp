#include "tests.pch.h"

#if defined(_WIN32)
#pragma comment(lib, "version")
#pragma comment(lib, "winhttp")
#endif

using namespace Microsoft::VisualStudio::CppUnitTestFramework;

using namespace vcpkg;

namespace UnitTest1
{
    class ArgumentTests : public TestClass<ArgumentTests>
    {
        TEST_METHOD(create_from_arg_sequence_options_lower)
        {
            std::vector<std::string> t = {"--vcpkg-root", "C:\\vcpkg", "--debug", "--sendmetrics", "--printmetrics"};
            auto v = VcpkgCmdArguments::create_from_arg_sequence(t.data(), t.data() + t.size());
            Assert::AreEqual("C:\\vcpkg", v.vcpkg_root_dir.get()->c_str());
            Assert::IsTrue(v.debug && *v.debug.get());
            Assert::IsTrue(v.sendmetrics && v.sendmetrics.get());
            Assert::IsTrue(v.printmetrics && *v.printmetrics.get());
        }

        TEST_METHOD(create_from_arg_sequence_options_upper)
        {
            std::vector<std::string> t = {"--VCPKG-ROOT", "C:\\vcpkg", "--DEBUG", "--SENDMETRICS", "--PRINTMETRICS"};
            auto v = VcpkgCmdArguments::create_from_arg_sequence(t.data(), t.data() + t.size());
            Assert::AreEqual("C:\\vcpkg", v.vcpkg_root_dir.get()->c_str());
            Assert::IsTrue(v.debug && *v.debug.get());
            Assert::IsTrue(v.sendmetrics && v.sendmetrics.get());
            Assert::IsTrue(v.printmetrics && *v.printmetrics.get());
        }

        TEST_METHOD(create_from_arg_sequence_valued_options)
        {
            std::array<CommandSetting, 1> settings = {{{"--a", ""}}};
            CommandStructure cmdstruct = {"", 0, SIZE_MAX, {{}, settings}, nullptr};

            std::vector<std::string> t = {"--a=b", "command", "argument"};
            auto v = VcpkgCmdArguments::create_from_arg_sequence(t.data(), t.data() + t.size());
            auto opts = v.parse_arguments(cmdstruct);
            Assert::AreEqual("b", opts.settings["--a"].c_str());
            Assert::AreEqual(size_t{1}, v.command_arguments.size());
            Assert::AreEqual("argument", v.command_arguments[0].c_str());
            Assert::AreEqual("command", v.command.c_str());
        }

        TEST_METHOD(create_from_arg_sequence_valued_options2)
        {
            std::array<CommandSwitch, 2> switches = {{{"--a", ""}, {"--c", ""}}};
            std::array<CommandSetting, 2> settings = {{{"--b", ""}, {"--d", ""}}};
            CommandStructure cmdstruct = {"", 0, SIZE_MAX, {switches, settings}, nullptr};

            std::vector<std::string> t = {"--a", "--b=c"};
            auto v = VcpkgCmdArguments::create_from_arg_sequence(t.data(), t.data() + t.size());
            auto opts = v.parse_arguments(cmdstruct);
            Assert::AreEqual("c", opts.settings["--b"].c_str());
            Assert::IsTrue(opts.settings.find("--d") == opts.settings.end());
            Assert::IsTrue(opts.switches.find("--a") != opts.switches.end());
            Assert::IsTrue(opts.settings.find("--c") == opts.settings.end());
            Assert::AreEqual(size_t{0}, v.command_arguments.size());
        }
    };
}
