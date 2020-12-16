#include <catch2/catch.hpp>

#include <vcpkg/base/strings.h>

#include <stdint.h>

#include <string>
#include <utility>
#include <vector>

#if defined(_MSC_VER)
#pragma warning(disable : 6237)
#endif

TEST_CASE ("b32 encoding", "[strings]")
{
    using u64 = uint64_t;

    std::vector<std::pair<u64, std::string>> map;

    map.emplace_back(0, "AAAAAAAAAAAAA");
    map.emplace_back(1, "BAAAAAAAAAAAA");

    map.emplace_back(u64(1) << 32, "AAAAAAEAAAAAA");
    map.emplace_back((u64(1) << 32) + 1, "BAAAAAEAAAAAA");

    map.emplace_back(0xE4D0'1065'D11E'0229, "JRA4RIXMQAUJO");
    map.emplace_back(0xA626'FE45'B135'07FF, "77BKTYWI6XJMK");
    map.emplace_back(0xEE36'D228'0C31'D405, "FAVDDGAFSWN4O");
    map.emplace_back(0x1405'64E7'FE7E'A88C, "MEK5H774ELBIB");
    map.emplace_back(0xFFFF'FFFF'FFFF'FFFF, "777777777777P");

    for (const auto& pr : map)
    {
        REQUIRE(vcpkg::Strings::b32_encode(pr.first) == pr.second);
    }
}

TEST_CASE ("split by char", "[strings]")
{
    using vcpkg::Strings::split;
    using result_t = std::vector<std::string>;
    REQUIRE(split(",,,,,,", ',').empty());
    REQUIRE(split(",,a,,b,,", ',') == result_t{"a", "b"});
    REQUIRE(split("hello world", ' ') == result_t{"hello", "world"});
    REQUIRE(split("    hello  world    ", ' ') == result_t{"hello", "world"});
    REQUIRE(split("no delimiters", ',') == result_t{"no delimiters"});
}

TEST_CASE ("find_first_of", "[strings]")
{
    using vcpkg::Strings::find_first_of;
    REQUIRE(find_first_of("abcdefg", "hij") == std::string());
    REQUIRE(find_first_of("abcdefg", "a") == std::string("abcdefg"));
    REQUIRE(find_first_of("abcdefg", "g") == std::string("g"));
    REQUIRE(find_first_of("abcdefg", "bg") == std::string("bcdefg"));
    REQUIRE(find_first_of("abcdefg", "gb") == std::string("bcdefg"));
}

TEST_CASE ("edit distance", "[strings]")
{
    using vcpkg::Strings::byte_edit_distance;
    REQUIRE(byte_edit_distance("", "") == 0);
    REQUIRE(byte_edit_distance("a", "a") == 0);
    REQUIRE(byte_edit_distance("abcd", "abcd") == 0);
    REQUIRE(byte_edit_distance("aaa", "aa") == 1);
    REQUIRE(byte_edit_distance("aa", "aaa") == 1);
    REQUIRE(byte_edit_distance("abcdef", "bcdefa") == 2);
    REQUIRE(byte_edit_distance("hello", "world") == 4);
    REQUIRE(byte_edit_distance("CAPITAL", "capital") == 7);
    REQUIRE(byte_edit_distance("", "hello") == 5);
    REQUIRE(byte_edit_distance("world", "") == 5);
}
