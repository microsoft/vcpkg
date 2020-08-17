#include <catch2/catch.hpp>

#include <vcpkg/commands.contact.h>
#include <vcpkg/commands.h>
#include <vcpkg/commands.version.h>

using namespace vcpkg;

TEST_CASE ("test commands are constructible", "[commands]")
{
    Commands::Contact::ContactCommand contact{};
    Commands::Version::VersionCommand version{};
}

TEST_CASE ("get_available_basic_commands works", "[commands]")
{
    auto commands_list = Commands::get_available_basic_commands();
    CHECK(commands_list.size() == 2);
    CHECK(Commands::find("version", commands_list) != nullptr);
    CHECK(Commands::find("contact", commands_list) != nullptr);
    CHECK(Commands::find("aang", commands_list) == nullptr);
}

TEST_CASE ("get_available_paths_commands works", "[commands]")
{
    auto commands_list = Commands::get_available_paths_commands();
    CHECK(commands_list.size() == 18);

    CHECK(Commands::find("/?", commands_list) != nullptr);
    CHECK(Commands::find("help", commands_list) != nullptr);
    CHECK(Commands::find("search", commands_list) != nullptr);
    CHECK(Commands::find("list", commands_list) != nullptr);
    CHECK(Commands::find("integrate", commands_list) != nullptr);
    CHECK(Commands::find("owns", commands_list) != nullptr);
    CHECK(Commands::find("update", commands_list) != nullptr);
    CHECK(Commands::find("edit", commands_list) != nullptr);
    CHECK(Commands::find("create", commands_list) != nullptr);
    CHECK(Commands::find("cache", commands_list) != nullptr);
    CHECK(Commands::find("portsdiff", commands_list) != nullptr);
    CHECK(Commands::find("autocomplete", commands_list) != nullptr);
    CHECK(Commands::find("hash", commands_list) != nullptr);
    CHECK(Commands::find("fetch", commands_list) != nullptr);
    CHECK(Commands::find("x-ci-clean", commands_list) != nullptr);
    CHECK(Commands::find("x-history", commands_list) != nullptr);
    CHECK(Commands::find("x-vsinstances", commands_list) != nullptr);
    CHECK(Commands::find("x-format-manifest", commands_list) != nullptr);

    CHECK(Commands::find("korra", commands_list) == nullptr);
}

TEST_CASE ("get_available_commands_type_a works", "[commands]")
{
    auto commands_list = Commands::get_available_triplet_commands();
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
