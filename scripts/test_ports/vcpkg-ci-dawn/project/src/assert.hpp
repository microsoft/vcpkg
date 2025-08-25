//
// Copyright (c) 2024 xiaozhuai
//

#pragma once
#ifndef VCPKG_CI_DAWN_ASSERT_HPP
#define VCPKG_CI_DAWN_ASSERT_HPP

#include "log.hpp"

#if !defined(__PRETTY_FUNCTION__) && !defined(__GNUC__)
#define MY_PRETTY_FUNCTION __FUNCSIG__
#else
#define MY_PRETTY_FUNCTION __PRETTY_FUNCTION__
#endif

#define ASSERT(expr, fmt, ...)                                                         \
    do {                                                                               \
        if (!(expr)) {                                                                 \
            LOGE("Assertion failed: %s:%d, func: \"%s\", expr: \"%s\", message: " /**/ \
                 fmt,                                                             /**/ \
                 __FILE__, __LINE__, MY_PRETTY_FUNCTION, #expr,                   /**/ \
                 ##__VA_ARGS__);                                                       \
            abort();                                                                   \
        }                                                                              \
    } while (0)

#endif  // VCPKG_CI_DAWN_ASSERT_HPP
