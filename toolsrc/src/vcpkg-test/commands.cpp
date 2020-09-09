#include <catch2/catch.hpp>

#include <vcpkg/commands.contact.h>
#include <vcpkg/commands.h>
#include <vcpkg/commands.upload-metrics.h>
#include <vcpkg/commands.version.h>

using namespace vcpkg;

TEST_CASE ("test commands are constructible", "[commands]")
{
    Commands::Contact::ContactCommand contact{};
    Commands::Version::VersionCommand version{};
#if !VCPKG_DISABLE_METRICS && defined(_WIN32)
    Commands::UploadMetrics::UploadMetricsCommand upload_metrics{};
#endif // !VCPKG_DISABLE_METRICS && defined(_WIN32)
}

TEST_CASE ("get_available_basic_commands works", "[commands]")
{
    auto commands_list = Commands::get_available_basic_commands();
#if !VCPKG_DISABLE_METRICS && defined(_WIN32)
    CHECK(commands_list.size() == 3);
    CHECK(Commands::find("x-upload-metrics", commands_list) != nullptr);
#else  // ^^^ !VCPKG_DISABLE_METRICS && defined(_WIN32) // VCPKG_DISABLE_METRICS || !defined(_WIN32) vvv
    CHECK(commands_list.size() == 2);
#endif // ^^^ VCPKG_DISABLE_METRICS || !defined(_WIN32)
    CHECK(Commands::find("version", commands_list) != nullptr);
    CHECK(Commands::find("contact", commands_list) != nullptr);
    CHECK(Commands::find("aang", commands_list) == nullptr);
}

TEST_CASE ("get_available_paths_commands works", "[commands]")
{
    auto commands_list = Commands::get_available_paths_commands();
    CHECK(commands_list.size() == 19);

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
    CHECK(Commands::find("x-package-info", commands_list) != nullptr);
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
