#include <type_traits>

#include <half.hpp>

int main()
{
    using namespace half_float::literal;
    auto x = 2.4_h;
    static_assert(std::is_same<decltype(x), half_float::half>::value);
    half_float::half y = half_float::sqrt(x);
}
