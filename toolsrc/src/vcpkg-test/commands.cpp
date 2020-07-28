#include <catch2/catch.hpp>

#include <vcpkg/commands.h>
#include <vcpkg/commands.contact.h>
#include <vcpkg/commands.version.h>

using namespace vcpkg;

TEST_CASE ("test commands are constructible", "[commands]")
{
    Commands::Contact::ContactCommand contact{};
    Commands::Version::VersionCommand version{};
}

TEST_CASE ("get_available_commands_type_c works", "[commands]")
{
    auto commands_list = Commands::get_available_commands_type_c();
    CHECK(commands_list.size() == 2);
    CHECK(Commands::find("version", commands_list) != nullptr);
    CHECK(Commands::find("contact", commands_list) != nullptr);
    CHECK(Commands::find("aang", commands_list) == nullptr);
}

TEST_CASE ("get_available_commands_type_a works", "[commands]")
{
    auto commands_list = Commands::get_available_commands_type_a();
    CHECK(commands_list.size() == 10);

    CHECK(Commands::find("install", commands_list) != nullptr);
    CHECK(Commands::find("x-set-installed", commands_list) != nullptr);
    CHECK(Commands::find("ci", commands_list) != nullptr);
    CHECK(Commands::find("remove", commands_list) != nullptr);
    CHECK(Commands::find("upgrade", commands_list) != nullptr);
    CHECK(Commands::find("build", commands_list) != nullptr);
    CHECK(Commands::find("env", commands_list) != nullptr);
    CHECK(Commands::find("build-external", commands_list) != nullptr);
    CHECK(Commands::find("export", commands_list) != nullptr);
    CHECK(Commands::find("depend-info", commands_list) != nullptr);

    CHECK(Commands::find("mai", commands_list) == nullptr);
}
