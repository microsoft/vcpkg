#undef HWY_TARGET_INCLUDE
#define HWY_TARGET_INCLUDE "scale.cpp"
#include "hwy/foreach_target.h"
#include "hwy/highway.h"

HWY_BEFORE_NAMESPACE();
namespace HWY_NAMESPACE {

namespace hn = hwy::HWY_NAMESPACE;

void scale(float *HWY_RESTRICT dst, const float *HWY_RESTRICT src, size_t size, float factor) {
    size_t i = 0;

    constexpr hn::ScalableTag<float> d;
    const auto vf = hn::Set(d, factor);
    const size_t N = hn::Lanes(d);

    for (; i + 4 * N <= size; i += 4 * N) {
        auto x0 = hn::Load(d, src + i + 0 * N);
        auto x1 = hn::Load(d, src + i + 1 * N);
        auto x2 = hn::Load(d, src + i + 2 * N);
        auto x3 = hn::Load(d, src + i + 3 * N);
        hn::Store(hn::Mul(x0, vf), d, dst + i + 0 * N);
        hn::Store(hn::Mul(x1, vf), d, dst + i + 1 * N);
        hn::Store(hn::Mul(x2, vf), d, dst + i + 2 * N);
        hn::Store(hn::Mul(x3, vf), d, dst + i + 3 * N);
    }

    for (; i + N <= size; i += N) {
        auto x = hn::Load(d, src + i);
        hn::Store(hn::Mul(x, vf), d, dst + i);
    }

    for (; i < size; ++i) {
        dst[i] = src[i] * factor;
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
