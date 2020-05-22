#include <catch2/catch.hpp>

#include <vcpkg/base/strings.h>

#include <stdint.h>
#include <utility>
#include <vector>
#include <string>

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
