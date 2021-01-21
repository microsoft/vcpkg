#include <catch2/catch.hpp>

#include <vcpkg/vcpkgcmdarguments.h>

#include <vector>

using vcpkg::CommandSetting;
using vcpkg::CommandStructure;
using vcpkg::CommandSwitch;
using vcpkg::VcpkgCmdArguments;

TEST_CASE ("VcpkgCmdArguments from lowercase argument sequence", "[arguments]")
{
    std::vector<std::string> t = {"--vcpkg-root",
                                  "C:\\vcpkg",
                                  "--x-scripts-root=C:\\scripts",
                                  "--x-builtin-ports-root=C:\\ports",
                                  "--x-builtin-registry-versions-dir=C:\\versions",
                                  "--debug",
                                  "--sendmetrics",
                                  "--printmetrics",
                                  "--overlay-ports=C:\\ports1",
                                  "--overlay-ports=C:\\ports2",
                                  "--overlay-triplets=C:\\tripletsA",
                                  "--overlay-triplets=C:\\tripletsB"};
    auto v = VcpkgCmdArguments::create_from_arg_sequence(t.data(), t.data() + t.size());

    REQUIRE(*v.vcpkg_root_dir == "C:\\vcpkg");
    REQUIRE(*v.scripts_root_dir == "C:\\scripts");
    REQUIRE(*v.builtin_ports_root_dir == "C:\\ports");
    REQUIRE(*v.builtin_registry_versions_dir == "C:\\versions");
    REQUIRE(v.debug);
    REQUIRE(*v.debug.get());
    REQUIRE(v.send_metrics);
    REQUIRE(*v.send_metrics.get());
    REQUIRE(v.print_metrics);
    REQUIRE(*v.print_metrics.get());

    REQUIRE(v.overlay_ports.size() == 2);
    REQUIRE(v.overlay_ports.at(0) == "C:\\ports1");
    REQUIRE(v.overlay_ports.at(1) == "C:\\ports2");

    REQUIRE(v.overlay_triplets.size() == 2);
    REQUIRE(v.overlay_triplets.at(0) == "C:\\tripletsA");
    REQUIRE(v.overlay_triplets.at(1) == "C:\\tripletsB");
}

TEST_CASE ("VcpkgCmdArguments from uppercase argument sequence", "[arguments]")
{
    std::vector<std::string> t = {"--VCPKG-ROOT",
                                  "C:\\vcpkg",
                                  "--X-SCRIPTS-ROOT=C:\\scripts",
                                  "--X-BUILTIN-PORTS-ROOT=C:\\ports",
                                  "--X-BUILTIN-REGISTRY-VERSIONS-DIR=C:\\versions",
                                  "--DEBUG",
                                  "--SENDMETRICS",
                                  "--PRINTMETRICS",
                                  "--OVERLAY-PORTS=C:\\ports1",
                                  "--OVERLAY-PORTS=C:\\ports2",
                                  "--OVERLAY-TRIPLETS=C:\\tripletsA",
                                  "--OVERLAY-TRIPLETS=C:\\tripletsB"};
    auto v = VcpkgCmdArguments::create_from_arg_sequence(t.data(), t.data() + t.size());

    REQUIRE(*v.vcpkg_root_dir == "C:\\vcpkg");
    REQUIRE(*v.scripts_root_dir == "C:\\scripts");
    REQUIRE(*v.builtin_ports_root_dir == "C:\\ports");
    REQUIRE(*v.builtin_registry_versions_dir == "C:\\versions");
    REQUIRE(v.debug);
    REQUIRE(*v.debug.get());
    REQUIRE(v.send_metrics);
    REQUIRE(*v.send_metrics.get());
    REQUIRE(v.print_metrics);
    REQUIRE(*v.print_metrics.get());

    REQUIRE(v.overlay_ports.size() == 2);
    REQUIRE(v.overlay_ports.at(0) == "C:\\ports1");
    REQUIRE(v.overlay_ports.at(1) == "C:\\ports2");

    REQUIRE(v.overlay_triplets.size() == 2);
    REQUIRE(v.overlay_triplets.at(0) == "C:\\tripletsA");
    REQUIRE(v.overlay_triplets.at(1) == "C:\\tripletsB");
}

TEST_CASE ("VcpkgCmdArguments from argument sequence with valued options", "[arguments]")
{
    SECTION ("case 1")
    {
        std::array<CommandSetting, 1> settings = {{{"a", ""}}};
        CommandStructure cmdstruct = {"", 0, SIZE_MAX, {{}, settings}, nullptr};

        std::vector<std::string> t = {"--a=b", "command", "argument"};
        auto v = VcpkgCmdArguments::create_from_arg_sequence(t.data(), t.data() + t.size());
        auto opts = v.parse_arguments(cmdstruct);

        REQUIRE(opts.settings["a"] == "b");
        REQUIRE(v.command_arguments.size() == 1);
        REQUIRE(v.command_arguments[0] == "argument");
        REQUIRE(v.command == "command");
    }

    SECTION ("case 2")
    {
        std::array<CommandSwitch, 2> switches = {{{"a", ""}, {"c", ""}}};
        std::array<CommandSetting, 2> settings = {{{"b", ""}, {"d", ""}}};
        CommandStructure cmdstruct = {"", 0, SIZE_MAX, {switches, settings}, nullptr};

        std::vector<std::string> t = {"--a", "--b=c"};
        auto v = VcpkgCmdArguments::create_from_arg_sequence(t.data(), t.data() + t.size());
        auto opts = v.parse_arguments(cmdstruct);

        REQUIRE(opts.settings["b"] == "c");
        REQUIRE(opts.settings.find("d") == opts.settings.end());
        REQUIRE(opts.switches.find("a") != opts.switches.end());
        REQUIRE(opts.settings.find("c") == opts.settings.end());
        REQUIRE(v.command_arguments.size() == 0);
    }
}

TEST_CASE ("vcpkg_root parse with arg separator", "[arguments]")
{
    std::vector<std::string> t = {"--vcpkg-root", "C:\\vcpkg"};
    auto v = VcpkgCmdArguments::create_from_arg_sequence(t.data(), t.data() + t.size());
    auto& vcpkg_root_dir = v.vcpkg_root_dir;
    REQUIRE(vcpkg_root_dir);
    REQUIRE(*vcpkg_root_dir == "C:\\vcpkg");
}

TEST_CASE ("vcpkg_root parse with equal separator", "[arguments]")
{
    std::vector<std::string> t = {"--vcpkg-root=C:\\vcpkg"};
    auto v = VcpkgCmdArguments::create_from_arg_sequence(t.data(), t.data() + t.size());
    auto& vcpkg_root_dir = v.vcpkg_root_dir;
    REQUIRE(vcpkg_root_dir);
    REQUIRE(*vcpkg_root_dir == "C:\\vcpkg");
}
