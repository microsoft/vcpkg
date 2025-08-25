//
// Copyright (c) 2024 xiaozhuai
//

#pragma once
#ifndef WEBGPU_GLFW_HPP
#define WEBGPU_GLFW_HPP

#include "GLFW/glfw3.h"
#include "webgpu/webgpu_cpp.h"

namespace wgpu::glfw {

wgpu::Surface CreateSurfaceForWindow(const wgpu::Instance &instance, GLFWwindow *window);

}  // namespace wgpu::glfw

#endif  // WEBGPU_GLFW_HPP
