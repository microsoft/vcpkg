#include <catch2/catch.hpp>

#include <vcpkg/base/strings.h>

#include <cstdint>
#include <utility>
#include <vector>

TEST_CASE ("b32 encoding", "[strings]")
{
    using u64 = std::uint64_t;

    std::vector<std::pair<std::uint64_t, std::string>> map;

    map.emplace_back(0, "AAAAAAAAAAAAA");
    map.emplace_back(1, "BAAAAAAAAAAAA");

    map.emplace_back(u64(1) << 32, "AAAAAAEAAAAAA");
    map.emplace_back((u64(1) << 32) + 1, "BAAAAAEAAAAAA");

    map.emplace_back(0xE4D0'1065'D11E'0229, "JRA4RIXMQAUJO");
    map.emplace_back(0xA626'FE45'B135'07FF, "77BKTYWI6XJMK");
    map.emplace_back(0xEE36'D228'0C31'D405, "FAVDDGAFSWN4O");
    map.emplace_back(0x1405'64E7'FE7E'A88C, "MEK5H774ELBIB");
    map.emplace_back(0xFFFF'FFFF'FFFF'FFFF, "777777777777P");

    std::string result;
    for (const auto& pr : map)
    {
        result = vcpkg::Strings::b32_encode(pr.first);
        REQUIRE(vcpkg::Strings::b32_encode(pr.first) == pr.second);
    }
}
