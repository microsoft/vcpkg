//
// Copyright (c) 2024 xiaozhuai
//

#pragma once
#ifndef VCPKG_CI_DAWN_LOG_HPP
#define VCPKG_CI_DAWN_LOG_HPP

#include "spdlog/logger.h"
#include "spdlog/spdlog.h"

#define LOGGER_NAME    "vcpkg-ci-dawn"

#define LOGD(fmt, ...) mylog::get_logger()->debug(fmt, ##__VA_ARGS__)
#define LOGI(fmt, ...) mylog::get_logger()->info(fmt, ##__VA_ARGS__)
#define LOGW(fmt, ...) mylog::get_logger()->warn(fmt, ##__VA_ARGS__)
#define LOGE(fmt, ...) mylog::get_logger()->error(fmt, ##__VA_ARGS__)

namespace mylog {

std::shared_ptr<spdlog::logger> get_logger();

}  // namespace mylog

#endif  // VCPKG_CI_DAWN_LOG_HPP
