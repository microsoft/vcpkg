#include <catch2/catch.hpp>
#include <vcpkg/binarycaching.h>

using namespace vcpkg;

#if defined(_WIN32)
#define ABSOLUTE_PATH "C:\\foo"
#else
#define ABSOLUTE_PATH "/foo"
#endif

TEST_CASE ("BinaryConfigParser empty", "[binaryconfigparser]")
{
    auto parsed = create_binary_provider_from_configs_pure("", {});
    REQUIRE(parsed.has_value());
}

TEST_CASE ("BinaryConfigParser unacceptable provider", "[binaryconfigparser]")
{
    auto parsed = create_binary_provider_from_configs_pure("unacceptable", {});
    REQUIRE(!parsed.has_value());
}

TEST_CASE ("BinaryConfigParser files provider", "[binaryconfigparser]")
{
    {
        auto parsed = create_binary_provider_from_configs_pure("files", {});
        REQUIRE(!parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("files,relative-path", {});
        REQUIRE(!parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("files,C:foo", {});
        REQUIRE(!parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("files," ABSOLUTE_PATH, {});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("files," ABSOLUTE_PATH ",nonsense", {});
        REQUIRE(!parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("files," ABSOLUTE_PATH ",upload", {});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("files," ABSOLUTE_PATH ",upload,extra", {});
        REQUIRE(!parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("files,,upload", {});
        REQUIRE(!parsed.has_value());
    }
}

TEST_CASE ("BinaryConfigParser default provider", "[binaryconfigparser]")
{
    {
        auto parsed = create_binary_provider_from_configs_pure("default", {});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("default,nonsense", {});
        REQUIRE(!parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("default,upload", {});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("default,upload,extra", {});
        REQUIRE(!parsed.has_value());
    }
}

TEST_CASE ("BinaryConfigParser clear provider", "[binaryconfigparser]")
{
    {
        auto parsed = create_binary_provider_from_configs_pure("clear", {});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("clear,upload", {});
        REQUIRE(!parsed.has_value());
    }
}

TEST_CASE ("BinaryConfigParser multiple providers", "[binaryconfigparser]")
{
    {
        auto parsed = create_binary_provider_from_configs_pure("clear;default", {});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("clear;default,upload", {});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("clear;default,upload;clear;clear", {});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("clear;files,relative;default", {});
        REQUIRE(!parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure(";;;clear;;;;", {});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure(";;;,;;;;", {});
        REQUIRE(!parsed.has_value());
    }
}

TEST_CASE ("BinaryConfigParser escaping", "[binaryconfigparser]")
{
    {
        auto parsed = create_binary_provider_from_configs_pure(";;;;;;;`", {});
        REQUIRE(!parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure(";;;;;;;`defaul`t", {});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("files," ABSOLUTE_PATH "`", {});
        REQUIRE(!parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("files," ABSOLUTE_PATH "`,", {});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("files," ABSOLUTE_PATH "``", {});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("files," ABSOLUTE_PATH "```", {});
        REQUIRE(!parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("files," ABSOLUTE_PATH "````", {});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("files," ABSOLUTE_PATH ",", {});
        REQUIRE(!parsed.has_value());
    }
}

TEST_CASE ("BinaryConfigParser args", "[binaryconfigparser]")
{
    {
        auto parsed =
            create_binary_provider_from_configs_pure("files," ABSOLUTE_PATH, std::vector<std::string>{"clear"});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed =
            create_binary_provider_from_configs_pure("files," ABSOLUTE_PATH, std::vector<std::string>{"clear;default"});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("files," ABSOLUTE_PATH,
                                                               std::vector<std::string>{"clear;default,"});
        REQUIRE(!parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("files," ABSOLUTE_PATH,
                                                               std::vector<std::string>{"clear", "clear;default,"});
        REQUIRE(!parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("files," ABSOLUTE_PATH,
                                                               std::vector<std::string>{"clear", "clear"});
        REQUIRE(parsed.has_value());
    }
}
