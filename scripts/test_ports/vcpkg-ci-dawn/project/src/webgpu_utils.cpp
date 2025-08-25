//
// Copyright (c) 2024 xiaozhuai
//

#include "webgpu_utils.hpp"

#if defined(__EMSCRIPTEN__)
#include "emscripten/emscripten.h"
#endif

wgpu::Instance create_instance() {
#if defined(__EMSCRIPTEN__)
    wgpu::InstanceDescriptor instance_desc;
    instance_desc.capabilities.timedWaitAnyEnable = true;
    return wgpu::CreateInstance(&instance_desc);
#else
    wgpu::InstanceDescriptor instance_desc;
    std::vector<wgpu::InstanceFeatureName> required_features = {
        wgpu::InstanceFeatureName::TimedWaitAny,
    };
    instance_desc.requiredFeatureCount = required_features.size();
    instance_desc.requiredFeatures = required_features.data();
    return wgpu::CreateInstance(&instance_desc);
#endif
}

wgpu::Adapter request_adapter(wgpu::Instance &instance, wgpu::Surface &surface) {
    wgpu::RequestAdapterOptions adapter_options;
    adapter_options.compatibleSurface = surface;
    adapter_options.powerPreference = wgpu::PowerPreference::HighPerformance;

    wgpu::Adapter adapter;
    auto adapter_future = instance.RequestAdapter(
        &adapter_options, wgpu::CallbackMode::WaitAnyOnly,
        [&adapter](wgpu::RequestAdapterStatus status, wgpu::Adapter adapter_ret, wgpu::StringView message) {
            ASSERT(status == wgpu::RequestAdapterStatus::Success && adapter_ret != nullptr, "Failed to get an adapter");
            adapter = std::move(adapter_ret);
        });
    ASSERT(instance.WaitAny(adapter_future, wgpu::kLimitU64Undefined) == wgpu::WaitStatus::Success,
           "Failed to wait for adapter request");

    return adapter;
}

wgpu::Device request_device(wgpu::Instance &instance, wgpu::Adapter &adapter) {
    wgpu::DeviceDescriptor device_desc;

    device_desc.SetDeviceLostCallback(
        wgpu::CallbackMode::AllowSpontaneous,
        [](const wgpu::Device &, wgpu::DeviceLostReason reason, wgpu::StringView message) {
            bool is_error = true;

            switch (reason) {
                case wgpu::DeviceLostReason::Unknown:
                case wgpu::DeviceLostReason::FailedCreation:
                    break;
                case wgpu::DeviceLostReason::Destroyed:
                case wgpu::DeviceLostReason::CallbackCancelled:
                    is_error = false;
                    break;
                default:
                    ASSERT(false, "Unknown DeviceLostReason");
            }
            if (is_error) {
                LOGE("%s", message.data);
            } else {
                LOGD("%s", message.data);
            }
        });
    device_desc.SetUncapturedErrorCallback([](const wgpu::Device &, wgpu::ErrorType type, wgpu::StringView message) {
        const char *error_type;
        switch (type) {
            case wgpu::ErrorType::Validation:
                error_type = "Validation";
                break;
            case wgpu::ErrorType::OutOfMemory:
                error_type = "Out of memory";
                break;
            case wgpu::ErrorType::Internal:
                error_type = "Internal";
                break;
            case wgpu::ErrorType::Unknown:
                error_type = "Unknown";
                break;
            default:
                ASSERT(false, "Unknown ErrorType");
        }
        LOGE("Uncaptured Error %s: %s", error_type, message.data);
    });

    wgpu::Device device;
    auto device_future = adapter.RequestDevice(
        &device_desc, wgpu::CallbackMode::WaitAnyOnly,
        [&device](wgpu::RequestDeviceStatus status, wgpu::Device device_ret, wgpu::StringView message) {
            ASSERT(status == wgpu::RequestDeviceStatus::Success && device_ret != nullptr, "Failed to get a device");
            device = std::move(device_ret);
        });
    ASSERT(instance.WaitAny(device_future, wgpu::kLimitU64Undefined) == wgpu::WaitStatus::Success,
           "Failed to wait for device request");

    return device;
}

wgpu::ShaderModule create_shader(wgpu::Device &device, const std::string &shader_code) {
    wgpu::ShaderSourceWGSL shader_code_desc;
    shader_code_desc.sType = wgpu::SType::ShaderSourceWGSL;
    shader_code_desc.code = shader_code.c_str();
    wgpu::ShaderModuleDescriptor shader_desc;
    shader_desc.nextInChain = &shader_code_desc;
    return device.CreateShaderModule(&shader_desc);
}
