#include <catch2/catch.hpp>

#include <iostream>
#include <vcpkg/base/json.h>
#include <vcpkg/base/unicode.h>

// TODO: remove this once we switch to C++20 completely
// This is the worst, but we also can't really deal with it any other way.
#if __cpp_char8_t
template<size_t Sz>
static auto _u8_string_to_char_string(const char8_t (&literal)[Sz]) -> const char (&)[Sz]
{
    return reinterpret_cast<const char(&)[Sz]>(literal);
}

#define U8_STR(s) (::vcpkg::Unicode::_u8_string_to_char_string(u8"" s))
#else
#define U8_STR(s) (u8"" s)
#endif

namespace Json = vcpkg::Json;
using Json::Value;

static std::string mystringify(const Value& val) { return Json::stringify(val, Json::JsonStyle{}); }

TEST_CASE ("JSON stringify weird strings", "[json]")
{
    vcpkg::StringView str = U8_STR("😀 😁 😂 🤣 😃 😄 😅 😆 😉");
    REQUIRE(mystringify(Value::string(str)) == ('"' + str.to_string() + '"'));
    REQUIRE(mystringify(Value::string("\xED\xA0\x80")) == "\"\\ud800\""); // unpaired surrogate
}

TEST_CASE ("JSON parse keywords", "[json]")
{
    auto res = Json::parse("true");
    REQUIRE(res);
    REQUIRE(res.get()->first.is_boolean());
    REQUIRE(res.get()->first.boolean());
    res = Json::parse(" false ");
    REQUIRE(res);
    REQUIRE(res.get()->first.is_boolean());
    REQUIRE(!res.get()->first.boolean());
    res = Json::parse(" null\t ");
    REQUIRE(res);
    REQUIRE(res.get()->first.is_null());
}

TEST_CASE ("JSON parse strings", "[json]")
{
    auto res = Json::parse(R"("")");
    REQUIRE(res);
    REQUIRE(res.get()->first.is_string());
    REQUIRE(res.get()->first.string().size() == 0);

    res = Json::parse(R"("\ud800")"); // unpaired surrogate
    REQUIRE(res);
    REQUIRE(res.get()->first.is_string());
    REQUIRE(res.get()->first.string() == "\xED\xA0\x80");

    const auto make_json_string = [] (vcpkg::StringView sv) {
        return '"' + sv.to_string() + '"';
    };
    const vcpkg::StringView radical = U8_STR("⎷");
    const vcpkg::StringView grin = U8_STR("😁");

    res = Json::parse(R"("\uD83D\uDE01")"); // paired surrogates for grin
    REQUIRE(res);
    REQUIRE(res.get()->first.is_string());
    REQUIRE(res.get()->first.string() == grin.to_string());

    res = Json::parse(make_json_string(radical)); // character in BMP
    REQUIRE(res);
    REQUIRE(res.get()->first.is_string());
    REQUIRE(res.get()->first.string() == radical);

    res = Json::parse(make_json_string(grin)); // character above BMP
    REQUIRE(res);
    REQUIRE(res.get()->first.is_string());
    REQUIRE(res.get()->first.string() == grin);
}

TEST_CASE ("JSON parse numbers", "[json]")
{
    auto res = Json::parse("0");
    REQUIRE(res);
    REQUIRE(res.get()->first.is_number());
    REQUIRE(res.get()->first.number() == 0);
    res = Json::parse("12345");
    REQUIRE(res);
    REQUIRE(res.get()->first.is_number());
    REQUIRE(res.get()->first.number() == 12345);
    res = Json::parse("-12345");
    REQUIRE(res);
    REQUIRE(res.get()->first.is_number());
    REQUIRE(res.get()->first.number() == -12345);
    res = Json::parse("9223372036854775807"); // INT64_MAX
    REQUIRE(res);
    REQUIRE(res.get()->first.is_number());
    REQUIRE(res.get()->first.number() == 9223372036854775807);
    res = Json::parse("-9223372036854775808");
    REQUIRE(res);
    REQUIRE(res.get()->first.is_number());
    REQUIRE(res.get()->first.number() == (-9223372036854775807 - 1)); // INT64_MIN (C++'s parser is fun)
}

TEST_CASE ("JSON parse arrays", "[json]")
{
    auto res = Json::parse("[]");
    REQUIRE(res);
    auto val = std::move(res.get()->first);
    REQUIRE(val.is_array());
    REQUIRE(val.array().size() == 0);

    res = Json::parse("[123]");
    REQUIRE(res);
    val = std::move(res.get()->first);
    REQUIRE(val.is_array());
    REQUIRE(val.array().size() == 1);
    REQUIRE(val.array()[0].is_number());
    REQUIRE(val.array()[0].number() == 123);

    res = Json::parse("[123, 456]");
    REQUIRE(res);
    val = std::move(res.get()->first);
    REQUIRE(val.is_array());
    REQUIRE(val.array().size() == 2);
    REQUIRE(val.array()[0].is_number());
    REQUIRE(val.array()[0].number() == 123);
    REQUIRE(val.array()[1].is_number());
    REQUIRE(val.array()[1].number() == 456);

    res = Json::parse("[123, 456, [null]]");
    REQUIRE(res);
    val = std::move(res.get()->first);
    REQUIRE(val.is_array());
    REQUIRE(val.array().size() == 3);
    REQUIRE(val.array()[2].is_array());
    REQUIRE(val.array()[2].array().size() == 1);
    REQUIRE(val.array()[2].array()[0].is_null());
}

TEST_CASE ("JSON parse objects", "[json]")
{
    auto res = Json::parse("{}");
    REQUIRE(res);
    auto val = std::move(res.get()->first);
    REQUIRE(val.is_object());
    REQUIRE(val.object().size() == 0);
}

TEST_CASE ("JSON parse full file", "[json]")
{
    vcpkg::StringView json =
#include "large-json-document.json.inc"
        ;

    auto res = Json::parse(json);
    REQUIRE(res);
}
