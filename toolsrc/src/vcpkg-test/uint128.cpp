#include <catch2/catch.hpp>

#include <vcpkg/base/uint128.h>

TEST_CASE ("uint128 constructor and assign", "[uint128]") {
	vcpkg::UInt128 x = 120;
	REQUIRE(x.bottom_64_bits() == 120);
	REQUIRE(x.top_64_bits() == 0);

	x = 3201;
	REQUIRE(x.bottom_64_bits() == 3201);
	REQUIRE(x.top_64_bits() == 0);
	
	x = 0xFFFF'FFFF'FFFF'FFFF;
	REQUIRE(x.bottom_64_bits() == 0xFFFF'FFFF'FFFF'FFFF);
	REQUIRE(x.top_64_bits() == 0);
}

TEST_CASE ("uint128 add-assign", "[uint128]") {
	vcpkg::UInt128 x = 0xFFFF'FFFF'FFFF'FFFF;
	x += 1;
	REQUIRE(x.bottom_64_bits() == 0);
	REQUIRE(x.top_64_bits() == 1);
}

TEST_CASE ("uint128 shl-assign", "[uint128]") {
	vcpkg::UInt128 x = 0xFFFF'FFFF'FFFF'FFFF;
	x <<= 32;
	REQUIRE(x.bottom_64_bits() == 0xFFFF'FFFF'0000'0000);
	REQUIRE(x.top_64_bits() == 0x0000'0000'FFFF'FFFF);
	
	x <<= 60;
	REQUIRE(x.bottom_64_bits() == 0);
	REQUIRE(x.top_64_bits() == 0xFFFF'FFFF'F000'0000);

	x = 1;
	x <<= 96;
	REQUIRE(x.bottom_64_bits() == 0);
	REQUIRE(x.top_64_bits() == (uint64_t(1) << 32));
}

TEST_CASE ("uint128 shr-assign", "[uint128]") {
	vcpkg::UInt128 x = 0xFFFF'FFFF'FFFF'FFFF;
	x <<= 64;
	REQUIRE(x.bottom_64_bits() == 0x0000'0000'0000'0000);
	REQUIRE(x.top_64_bits() == 0xFFFF'FFFF'FFFF'FFFF);

	x >>= 32;
	REQUIRE(x.bottom_64_bits() == 0xFFFF'FFFF'0000'0000);
	REQUIRE(x.top_64_bits() == 0x0000'0000'FFFF'FFFF);
	
	x >>= 60;
	REQUIRE(x.bottom_64_bits() == 0x0000'000F'FFFF'FFFF);
	REQUIRE(x.top_64_bits() == 0x0000'0000'0000'0000);

	x = 0x8000'0000'0000'0000;
	x <<= 64;
	REQUIRE(x.bottom_64_bits() == 0);
	REQUIRE(x.top_64_bits() == 0x8000'0000'0000'0000);

	x >>= 96;
	REQUIRE(x.bottom_64_bits() == (uint64_t(1) << 31));
	REQUIRE(x.top_64_bits() == 0);
}
