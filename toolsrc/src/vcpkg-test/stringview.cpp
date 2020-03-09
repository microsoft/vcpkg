#include <catch2/catch.hpp>

#include <vcpkg/base/stringview.h>

template <std::size_t N>
static vcpkg::StringView sv(const char (&cstr)[N]) {
	return cstr;
}

TEST_CASE("string view operator==", "[stringview]") {
	// these are due to a bug in operator==
	// see commit 782723959399a1a0725ac49
	REQUIRE(sv("hey") != sv("heys"));
	REQUIRE(sv("heys") != sv("hey"));
	REQUIRE(sv("hey") == sv("hey"));
	REQUIRE(sv("hey") != sv("hex"));
}
