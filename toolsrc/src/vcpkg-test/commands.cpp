#include <catch2/catch.hpp>

#include <vcpkg/commands.h>
#include <vcpkg/commands.contact.h>
#include <vcpkg/commands.version.h>

TEST_CASE ("test commands are constructible", "[commands]")
{
    vcpkg::Commands::Contact::ContactCommand contact{};
    vcpkg::Commands::Version::VersionCommand version{};
}
