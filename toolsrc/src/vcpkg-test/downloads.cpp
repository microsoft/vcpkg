#include <catch2/catch.hpp>

#include <vcpkg/base/downloads.h>

using namespace vcpkg;

TEST_CASE ("Downloads::details::split_uri_view", "[downloads]")
{
    {
        auto x = Downloads::details::split_uri_view("https://github.com/Microsoft/vcpkg");
        REQUIRE(x.has_value());
        REQUIRE(x.get()->scheme == "https");
        REQUIRE(x.get()->authority.value_or("") == "//github.com");
        REQUIRE(x.get()->path_query_fragment == "/Microsoft/vcpkg");
    }
    {
        auto x = Downloads::details::split_uri_view("");
        REQUIRE(!x.has_value());
    }
    {
        auto x = Downloads::details::split_uri_view("hello");
        REQUIRE(!x.has_value());
    }
    {
        auto x = Downloads::details::split_uri_view("file:");
        REQUIRE(x.has_value());
        REQUIRE(x.get()->scheme == "file");
        REQUIRE(!x.get()->authority.has_value());
        REQUIRE(x.get()->path_query_fragment == "");
    }
    {
        auto x = Downloads::details::split_uri_view("file:path");
        REQUIRE(x.has_value());
        REQUIRE(x.get()->scheme == "file");
        REQUIRE(!x.get()->authority.has_value());
        REQUIRE(x.get()->path_query_fragment == "path");
    }
    {
        auto x = Downloads::details::split_uri_view("file:/path");
        REQUIRE(x.has_value());
        REQUIRE(x.get()->scheme == "file");
        REQUIRE(!x.get()->authority.has_value());
        REQUIRE(x.get()->path_query_fragment == "/path");
    }
    {
        auto x = Downloads::details::split_uri_view("file://user:pw@host");
        REQUIRE(x.has_value());
        REQUIRE(x.get()->scheme == "file");
        REQUIRE(x.get()->authority.value_or({}) == "//user:pw@host");
        REQUIRE(x.get()->path_query_fragment == "");
    }
    {
        auto x = Downloads::details::split_uri_view("ftp://host:port/");
        REQUIRE(x.has_value());
        REQUIRE(x.get()->scheme == "ftp");
        REQUIRE(x.get()->authority.value_or({}) == "//host:port");
        REQUIRE(x.get()->path_query_fragment == "/");
    }
}
