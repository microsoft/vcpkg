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
            std::vector<std::string> t = {
                "--vcpkg-root", "C:\\vcpkg", 
                "--scripts-root=C:\\scripts", 
                "--debug", 
                "--sendmetrics", 
                "--printmetrics",
                "--overlay-ports=C:\\ports1",
                "--overlay-ports=C:\\ports2",
                "--overlay-triplets=C:\\tripletsA",
                "--overlay-triplets=C:\\tripletsB"
            };
            auto v = VcpkgCmdArguments::create_from_arg_sequence(t.data(), t.data() + t.size());
            Assert::AreEqual("C:\\vcpkg", v.vcpkg_root_dir.get()->c_str());
            Assert::AreEqual("C:\\scripts", v.scripts_root_dir.get()->c_str());
            Assert::IsTrue(v.debug && *v.debug.get());
            Assert::IsTrue(v.sendmetrics && v.sendmetrics.get());
            Assert::IsTrue(v.printmetrics && *v.printmetrics.get());
            
            Assert::IsTrue(v.overlay_ports.get()->size() == 2);
            Assert::AreEqual("C:\\ports1", v.overlay_ports.get()->at(0).c_str());
            Assert::AreEqual("C:\\ports2", v.overlay_ports.get()->at(1).c_str());

            Assert::IsTrue(v.overlay_triplets.get()->size() == 2);
            Assert::AreEqual("C:\\tripletsA", v.overlay_triplets.get()->at(0).c_str());
            Assert::AreEqual("C:\\tripletsB", v.overlay_triplets.get()->at(1).c_str());
        }

        TEST_METHOD(create_from_arg_sequence_options_upper)
        {
            std::vector<std::string> t = {
                "--VCPKG-ROOT", "C:\\vcpkg", 
                "--SCRIPTS-ROOT=C:\\scripts", 
                "--DEBUG", 
                "--SENDMETRICS", 
                "--PRINTMETRICS",
                "--OVERLAY-PORTS=C:\\ports1",
                "--OVERLAY-PORTS=C:\\ports2",
                "--OVERLAY-TRIPLETS=C:\\tripletsA",
                "--OVERLAY-TRIPLETS=C:\\tripletsB"
            };
            auto v = VcpkgCmdArguments::create_from_arg_sequence(t.data(), t.data() + t.size());
            Assert::AreEqual("C:\\vcpkg", v.vcpkg_root_dir.get()->c_str());
            Assert::AreEqual("C:\\scripts", v.scripts_root_dir.get()->c_str());
            Assert::IsTrue(v.debug && *v.debug.get());
            Assert::IsTrue(v.sendmetrics && v.sendmetrics.get());
            Assert::IsTrue(v.printmetrics && *v.printmetrics.get());

            Assert::IsTrue(v.overlay_ports.get()->size() == 2);
            Assert::AreEqual("C:\\ports1", v.overlay_ports.get()->at(0).c_str());
            Assert::AreEqual("C:\\ports2", v.overlay_ports.get()->at(1).c_str());

            Assert::IsTrue(v.overlay_triplets.get()->size() == 2);
            Assert::AreEqual("C:\\tripletsA", v.overlay_triplets.get()->at(0).c_str());
            Assert::AreEqual("C:\\tripletsB", v.overlay_triplets.get()->at(1).c_str());
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
