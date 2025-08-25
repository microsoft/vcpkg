//
// Copyright (c) 2024 xiaozhuai
//

#pragma once
#ifndef VCPKG_CI_DAWN_WGPU_UTILS_HPP
#define VCPKG_CI_DAWN_WGPU_UTILS_HPP

#include "assert.hpp"
#include "log.hpp"
#include "webgpu/webgpu_cpp.h"
#include "webgpu_formatter.hpp"

void inspect_adapter(const wgpu::Adapter &adapter);

void inspect_device(const wgpu::Device &device);

wgpu::Instance create_instance();

wgpu::Adapter request_adapter(wgpu::Instance &instance, wgpu::Surface &surface);

wgpu::Device request_device(wgpu::Instance &instance, wgpu::Adapter &adapter);

wgpu::ShaderModule create_shader(wgpu::Device &device, const std::string &shader_code);

#endif  // VCPKG_CI_DAWN_WGPU_UTILS_HPP
