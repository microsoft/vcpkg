#include <catch2/catch.hpp>

#include <vcpkg/commands.contact.h>
#include <vcpkg/commands.h>
#include <vcpkg/commands.upload-metrics.h>
#include <vcpkg/commands.version.h>

#include <stddef.h>

using namespace vcpkg;

namespace
{
    template<class CommandListT, size_t ExpectedCount>
    void check_all_commands(const CommandListT& actual_commands, const char* const (&expected_commands)[ExpectedCount])
    {
        CHECK(actual_commands.size() == ExpectedCount); // makes sure this test is updated if we add a command
        for (const char* expected_command : expected_commands)
        {
            CHECK(Commands::find(StringView{expected_command, strlen(expected_command)}, actual_commands) != nullptr);
        }

        CHECK(Commands::find("x-never-will-exist", actual_commands) == nullptr);
    }
} // unnamed namespace

// clang-format tries to wrap the following lists inappropriately

// clang-format off
TEST_CASE ("get_available_basic_commands works", "[commands]")
{
    check_all_commands(Commands::get_available_basic_commands(), {
        "contact",
        "version",
#if VCPKG_ENABLE_X_UPLOAD_METRICS_COMMAND
        "x-upload-metrics",
#endif // VCPKG_ENABLE_X_UPLOAD_METRICS_COMMAND
        });
}

TEST_CASE ("get_available_paths_commands works", "[commands]")
{
    check_all_commands(Commands::get_available_paths_commands(), {
        "/?",
        "help",
        "search",
        "list",
        "integrate",
        "owns",
        "update",
        "edit",
        "create",
        "cache",
        "portsdiff",
        "autocomplete",
        "hash",
        "fetch",
        "format-manifest",
        "x-ci-clean",
        "x-history",
        "x-package-info",
        "x-vsinstances",
        });
}

TEST_CASE ("get_available_commands_type_a works", "[commands]")
{
    check_all_commands(Commands::get_available_triplet_commands(), {
        "install",
        "x-set-installed",
        "ci",
        "remove",
        "upgrade",
        "build",
        "env",
        "build-external",
        "export",
        "depend-info",
        });
}
// clang-format on
