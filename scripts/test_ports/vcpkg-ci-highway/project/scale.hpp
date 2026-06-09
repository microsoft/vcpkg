#pragma once

#include <cstddef>

#if !defined(HWY_RESTRICT)
#if defined(_MSC_VER)
#define HWY_RESTRICT __restrict
#else
#define HWY_RESTRICT __restrict__
#endif
#endif

void scale(float *HWY_RESTRICT dst, const float *HWY_RESTRICT src, size_t size, float factor);
