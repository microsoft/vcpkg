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
        auto parsed = create_binary_provider_from_configs_pure("files," ABSOLUTE_PATH ",read", {});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("files," ABSOLUTE_PATH ",write", {});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("files," ABSOLUTE_PATH ",readwrite", {});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("files," ABSOLUTE_PATH ",readwrite,extra", {});
        REQUIRE(!parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("files,,upload", {});
        REQUIRE(!parsed.has_value());
    }
}

TEST_CASE ("BinaryConfigParser nuget source provider", "[binaryconfigparser]")
{
    {
        auto parsed = create_binary_provider_from_configs_pure("nuget", {});
        REQUIRE(!parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("nuget,relative-path", {});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("nuget,http://example.org/", {});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("nuget," ABSOLUTE_PATH, {});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("nuget," ABSOLUTE_PATH ",nonsense", {});
        REQUIRE(!parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("nuget," ABSOLUTE_PATH ",readwrite", {});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("nuget," ABSOLUTE_PATH ",readwrite,extra", {});
        REQUIRE(!parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("nuget,,readwrite", {});
        REQUIRE(!parsed.has_value());
    }
}

TEST_CASE ("BinaryConfigParser nuget config provider", "[binaryconfigparser]")
{
    {
        auto parsed = create_binary_provider_from_configs_pure("nugetconfig", {});
        REQUIRE(!parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("nugetconfig,relative-path", {});
        REQUIRE(!parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("nugetconfig,http://example.org/", {});
        REQUIRE(!parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("nugetconfig," ABSOLUTE_PATH, {});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("nugetconfig," ABSOLUTE_PATH ",nonsense", {});
        REQUIRE(!parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("nugetconfig," ABSOLUTE_PATH ",read", {});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("nugetconfig," ABSOLUTE_PATH ",write", {});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("nugetconfig," ABSOLUTE_PATH ",readwrite", {});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("nugetconfig," ABSOLUTE_PATH ",readwrite,extra", {});
        REQUIRE(!parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("nugetconfig,,readwrite", {});
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
        auto parsed = create_binary_provider_from_configs_pure("default,read", {});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("default,readwrite", {});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("default,write", {});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("default,read,extra", {});
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

TEST_CASE ("BinaryConfigParser interactive provider", "[binaryconfigparser]")
{
    {
        auto parsed = create_binary_provider_from_configs_pure("interactive", {});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("interactive,read", {});
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
        auto parsed = create_binary_provider_from_configs_pure("clear;default,read", {});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("clear;default,write", {});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("clear;default,readwrite", {});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("clear;default,readwrite;clear;clear", {});
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

TEST_CASE ("BinaryConfigParser azblob provider", "[binaryconfigparser]")
{
    {
        auto parsed = create_binary_provider_from_configs_pure("x-azblob,https://azure/container,sas", {});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("x-azblob,https://azure/container,?sas", {});
        REQUIRE(!parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("x-azblob,,sas", {});
        REQUIRE(!parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("x-azblob,https://azure/container", {});
        REQUIRE(!parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("x-azblob,https://azure/container,sas,invalid", {});
        REQUIRE(!parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("x-azblob,https://azure/container,sas,read", {});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("x-azblob,https://azure/container,sas,write", {});
        REQUIRE(parsed.has_value());
    }
    {
        auto parsed = create_binary_provider_from_configs_pure("x-azblob,https://azure/container,sas,readwrite", {});
        REQUIRE(parsed.has_value());
    }
}
