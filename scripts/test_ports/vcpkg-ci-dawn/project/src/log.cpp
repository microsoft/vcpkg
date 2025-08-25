//
// Copyright (c) 2024 xiaozhuai
//

#include "log.hpp"

#include <memory>

#include "spdlog/sinks/stdout_color_sinks.h"

namespace mylog {

std::shared_ptr<spdlog::logger> get_logger() {
    auto logger = spdlog::get(LOGGER_NAME);
    if (!logger) {
        auto sink = std::make_shared<spdlog::sinks::stdout_color_sink_mt>();
        logger = std::make_shared<spdlog::logger>(LOGGER_NAME, sink);
        logger->flush_on(spdlog::level::warn);
        logger->set_pattern("%^[%H:%M:%S] [%n] [Thread:%t] [%L] %v%$");
        logger->set_level(spdlog::level::debug);
        spdlog::register_logger(logger);
    }
    return logger;
}

}  // namespace mylog
