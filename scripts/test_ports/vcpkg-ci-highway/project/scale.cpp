#undef HWY_TARGET_INCLUDE
#define HWY_TARGET_INCLUDE "scale.cpp"
#include "hwy/foreach_target.h"
#include "hwy/highway.h"

HWY_BEFORE_NAMESPACE();
namespace HWY_NAMESPACE {

namespace hn = hwy::HWY_NAMESPACE;

void scale(float *HWY_RESTRICT dst, const float *HWY_RESTRICT src, size_t size, float factor) {
    auto scale_one = [](auto d, float *HWY_RESTRICT dst, const float *HWY_RESTRICT src, auto s) {
        const auto x = hn::Load(d, src);
        const auto o = hn::Mul(x, s);
        hn::Store(o, d, dst);
    };

    size_t i = 0;

    constexpr hn::ScalableTag<float> dn;
    const auto sn = hn::Set(dn, factor);
    const size_t N = hn::Lanes(dn);
    for (; i + N <= size; i += N) {
        scale_one(dn, dst + i, src + i, sn);
    }

    constexpr hn::CappedTag<float, 1> d1;
    const auto s1 = hn::Set(d1, factor);
    for (; i < size; ++i) {
        scale_one(d1, dst + i, src + i, s1);
    }
}

}  // namespace HWY_NAMESPACE
HWY_AFTER_NAMESPACE();

#if HWY_ONCE

#include "scale.hpp"

HWY_EXPORT(scale);
void scale(float *HWY_RESTRICT dst, const float *HWY_RESTRICT src, size_t size, float factor) {
    HWY_DYNAMIC_DISPATCH(scale)(dst, src, size, factor);
}

#endif  // HWY_ONCE
