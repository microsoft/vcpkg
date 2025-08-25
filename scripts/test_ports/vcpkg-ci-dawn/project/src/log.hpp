//
// Copyright (c) 2024 xiaozhuai
//

#pragma once
#ifndef VCPKG_CI_DAWN_LOG_HPP
#define VCPKG_CI_DAWN_LOG_HPP

#include <cstdio>

#define LOGD(fmt, ...) printf("[D] " fmt "\n", ##__VA_ARGS__)
#define LOGI(fmt, ...) printf("[I] " fmt "\n", ##__VA_ARGS__)
#define LOGW(fmt, ...) printf("[W] " fmt "\n", ##__VA_ARGS__)
#define LOGE(fmt, ...) printf("[E] " fmt "\n", ##__VA_ARGS__)

#endif  // VCPKG_CI_DAWN_LOG_HPP
