#include <catch2/catch.hpp>
#include <vcpkg/binarycaching.private.h>

using namespace vcpkg;

TEST_CASE ("reformat_version semver-ish", "[reformat_version]")
{
    REQUIRE(reformat_version("0.0.0", "abitag") == "0.0.0-abitag");
    REQUIRE(reformat_version("1.0.1", "abitag") == "1.0.1-abitag");
    REQUIRE(reformat_version("1.01.000", "abitag") == "1.1.0-abitag");
    REQUIRE(reformat_version("1.2", "abitag") == "1.2.0-abitag");
    REQUIRE(reformat_version("v52", "abitag") == "52.0.0-abitag");
    REQUIRE(reformat_version("v09.01.02", "abitag") == "9.1.2-abitag");
    REQUIRE(reformat_version("1.1.1q", "abitag") == "1.1.1-abitag");
    REQUIRE(reformat_version("1", "abitag") == "1.0.0-abitag");
}

TEST_CASE ("reformat_version date", "[reformat_version]")
{
    REQUIRE(reformat_version("2020-06-26", "abitag") == "2020.6.26-abitag");
    REQUIRE(reformat_version("20-06-26", "abitag") == "0.0.0-abitag");
    REQUIRE(reformat_version("2020-06-26-release", "abitag") == "2020.6.26-abitag");
    REQUIRE(reformat_version("2020-06-26000", "abitag") == "2020.6.26-abitag");
}

TEST_CASE ("reformat_version generic", "[reformat_version]")
{
    REQUIRE(reformat_version("apr", "abitag") == "0.0.0-abitag");
    REQUIRE(reformat_version("", "abitag") == "0.0.0-abitag");
}
