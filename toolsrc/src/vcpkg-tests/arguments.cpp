#include <vcpkg-tests/catch.h>

#include <vcpkg/vcpkgcmdarguments.h>

#include <vector>

using namespace vcpkg;

TEST_CASE("VcpkgCmdArguments", "[arguments]")
{
    SECTION("create from lowercase argument sequence")
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

        REQUIRE(*v.vcpkg_root_dir == "C:\\vcpkg");
        REQUIRE(*v.scripts_root_dir == "C:\\scripts");
        REQUIRE(v.debug);
        REQUIRE(*v.debug.get());
        REQUIRE(v.sendmetrics);
        REQUIRE(*v.sendmetrics.get());
        REQUIRE(v.printmetrics);
        REQUIRE(*v.printmetrics.get());

        REQUIRE(v.overlay_ports->size() == 2);
        REQUIRE(v.overlay_ports->at(0) == "C:\\ports1");
        REQUIRE(v.overlay_ports->at(1) == "C:\\ports2");

        REQUIRE(v.overlay_triplets->size() == 2);
        REQUIRE(v.overlay_triplets->at(0) == "C:\\tripletsA");
        REQUIRE(v.overlay_triplets->at(1) == "C:\\tripletsB");
    }

    SECTION("create from uppercase argument sequence")
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

        REQUIRE(*v.vcpkg_root_dir == "C:\\vcpkg");
        REQUIRE(*v.scripts_root_dir == "C:\\scripts");
        REQUIRE(v.debug);
        REQUIRE(*v.debug.get());
        REQUIRE(v.sendmetrics);
        REQUIRE(*v.sendmetrics.get());
        REQUIRE(v.printmetrics);
        REQUIRE(*v.printmetrics.get());

        REQUIRE(v.overlay_ports->size() == 2);
        REQUIRE(v.overlay_ports->at(0) == "C:\\ports1");
        REQUIRE(v.overlay_ports->at(1) == "C:\\ports2");

        REQUIRE(v.overlay_triplets->size() == 2);
        REQUIRE(v.overlay_triplets->at(0) == "C:\\tripletsA");
        REQUIRE(v.overlay_triplets->at(1) == "C:\\tripletsB");
    }

    SECTION("create from argument sequence with valued options")
    {
        std::array<CommandSetting, 1> settings = {{{"--a", ""}}};
        CommandStructure cmdstruct = {"", 0, SIZE_MAX, {{}, settings}, nullptr};

        std::vector<std::string> t = {"--a=b", "command", "argument"};
        auto v = VcpkgCmdArguments::create_from_arg_sequence(t.data(), t.data() + t.size());
        auto opts = v.parse_arguments(cmdstruct);

        REQUIRE(opts.settings["--a"] == "b");
        REQUIRE(v.command_arguments.size() == 1);
        REQUIRE(v.command_arguments[0] == "argument");
        REQUIRE(v.command == "command");
    }

    SECTION("create from argument sequence with valued options 2")
    {
        std::array<CommandSwitch, 2> switches = {{{"--a", ""}, {"--c", ""}}};
        std::array<CommandSetting, 2> settings = {{{"--b", ""}, {"--d", ""}}};
        CommandStructure cmdstruct = {"", 0, SIZE_MAX, {switches, settings}, nullptr};

        std::vector<std::string> t = {"--a", "--b=c"};
        auto v = VcpkgCmdArguments::create_from_arg_sequence(t.data(), t.data() + t.size());
        auto opts = v.parse_arguments(cmdstruct);

        REQUIRE(opts.settings["--b"] == "c");
        REQUIRE(opts.settings.find("--d") == opts.settings.end());
        REQUIRE(opts.switches.find("--a") != opts.switches.end());
        REQUIRE(opts.settings.find("--c") == opts.settings.end());
        REQUIRE(v.command_arguments.size() == 0);
    }
}
