#include <catch2/catch.hpp>

#include <vcpkg/sourceparagraph.h>

using namespace vcpkg;
using Parse::parse_comma_list;

TEST_CASE ("parse supports all", "[supports]")
{
    auto v = Supports::parse({
        "x64",
        "x86",
        "arm",
        "windows",
        "uwp",
        "v140",
        "v141",
        "crt-static",
        "crt-dynamic",
    });

    REQUIRE(v.has_value());

    REQUIRE(v.get()->is_supported(System::CPUArchitecture::X64,
                                  Supports::Platform::UWP,
                                  Supports::Linkage::DYNAMIC,
                                  Supports::ToolsetVersion::V140));
    REQUIRE(v.get()->is_supported(System::CPUArchitecture::ARM,
                                  Supports::Platform::WINDOWS,
                                  Supports::Linkage::STATIC,
                                  Supports::ToolsetVersion::V141));
}

TEST_CASE ("parse supports invalid", "[supports]")
{
    auto v = Supports::parse({"arm64"});

    REQUIRE_FALSE(v.has_value());

    REQUIRE(v.error().size() == 1);
    REQUIRE(v.error().at(0) == "arm64");
}

TEST_CASE ("parse supports case sensitive", "[supports]")
{
    auto v = Supports::parse({"Windows"});

    REQUIRE_FALSE(v.has_value());
    REQUIRE(v.error().size() == 1);
    REQUIRE(v.error().at(0) == "Windows");
}

TEST_CASE ("parse supports some", "[supports]")
{
    auto v = Supports::parse({
        "x64",
        "x86",
        "windows",
    });

    REQUIRE(v.has_value());

    REQUIRE(v.get()->is_supported(System::CPUArchitecture::X64,
                                  Supports::Platform::WINDOWS,
                                  Supports::Linkage::DYNAMIC,
                                  Supports::ToolsetVersion::V140));
    REQUIRE_FALSE(v.get()->is_supported(System::CPUArchitecture::ARM,
                                        Supports::Platform::WINDOWS,
                                        Supports::Linkage::DYNAMIC,
                                        Supports::ToolsetVersion::V140));
    REQUIRE_FALSE(v.get()->is_supported(System::CPUArchitecture::X64,
                                        Supports::Platform::UWP,
                                        Supports::Linkage::DYNAMIC,
                                        Supports::ToolsetVersion::V140));
    REQUIRE(v.get()->is_supported(System::CPUArchitecture::X64,
                                  Supports::Platform::WINDOWS,
                                  Supports::Linkage::STATIC,
                                  Supports::ToolsetVersion::V141));
}
