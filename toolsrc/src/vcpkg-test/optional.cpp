#include <catch2/catch.hpp>

#include <vcpkg/base/optional.h>
#include <vcpkg/base/util.h>

#include <vector>

namespace
{
    struct identity_projection
    {
        template<class T>
        const T& operator()(const T& val) noexcept
        {
            return val;
        }
    };
}

TEST_CASE ("equal", "[optional]")
{
    using vcpkg::Optional;

    CHECK(Optional<int>{} == Optional<int>{});
    CHECK_FALSE(Optional<int>{} == Optional<int>{42});
    CHECK_FALSE(Optional<int>{42} == Optional<int>{});
    CHECK_FALSE(Optional<int>{1729} == Optional<int>{42});
    CHECK(Optional<int>{42} == Optional<int>{42});
}

TEST_CASE ("ref conversion", "[optional]")
{
    using vcpkg::Optional;

    Optional<int> i_empty;
    Optional<int> i_1 = 1;
    const Optional<int> ci_1 = 1;

    Optional<int&> ref_empty = i_empty;
    Optional<const int&> cref_empty = i_empty;

    Optional<int&> ref_1 = i_1;
    Optional<const int&> cref_1 = ci_1;

    REQUIRE(ref_empty.has_value() == false);
    REQUIRE(cref_empty.has_value() == false);

    REQUIRE(ref_1.get() == i_1.get());
    REQUIRE(cref_1.get() == ci_1.get());

    ref_empty = i_1;
    cref_empty = ci_1;
    REQUIRE(ref_empty.get() == i_1.get());
    REQUIRE(cref_empty.get() == ci_1.get());

    const int x = 5;
    cref_1 = x;
    REQUIRE(cref_1.get() == &x);
}

TEST_CASE ("value conversion", "[optional]")
{
    using vcpkg::Optional;

    Optional<long> j = 1;
    Optional<int> i = j;
    Optional<const char*> cstr = "hello, world!";
    Optional<std::string> cppstr = cstr;

    std::vector<int> v{1, 2, 3};
    Optional<std::vector<int>&> o_v(v);
    REQUIRE(o_v.has_value());
    REQUIRE(o_v.get()->size() == 3);
    Optional<std::vector<int>> o_w(std::move(o_v));
    REQUIRE(o_w.has_value());
    REQUIRE(o_w.get()->size() == 3);
    // Moving from Optional<&> should not move the underlying object
    REQUIRE(o_v.has_value());
    REQUIRE(o_v.get()->size() == 3);
}

TEST_CASE ("common_projection", "[optional]")
{
    using vcpkg::Util::common_projection;
    std::vector<int> input;
    CHECK(!common_projection(input, identity_projection{}).has_value());
    input.push_back(42);
    CHECK(common_projection(input, identity_projection{}).value_or_exit(VCPKG_LINE_INFO) == 42);
    input.push_back(42);
    CHECK(common_projection(input, identity_projection{}).value_or_exit(VCPKG_LINE_INFO) == 42);
    input.push_back(1729);
    CHECK(!common_projection(input, identity_projection{}).has_value());
}
