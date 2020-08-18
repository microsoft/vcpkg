#include <catch2/catch.hpp>

#include <vcpkg/base/optional.h>

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

TEST_CASE ("common_projection", "[optional]")
{
    using vcpkg::common_projection;
    std::vector<int> input;
    CHECK(!common_projection(input, identity_projection{}).has_value());
    input.push_back(42);
    CHECK(common_projection(input, identity_projection{}).value_or_exit(VCPKG_LINE_INFO) == 42);
    input.push_back(42);
    CHECK(common_projection(input, identity_projection{}).value_or_exit(VCPKG_LINE_INFO) == 42);
    input.push_back(1729);
    CHECK(!common_projection(input, identity_projection{}).has_value());
}
