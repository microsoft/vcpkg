//
// Copyright (c) 2025 xiaozhuai
//

#pragma once
#ifndef VCPKG_CI_DAWN_WEBGPU_FORMATTER_HPP
#define VCPKG_CI_DAWN_WEBGPU_FORMATTER_HPP

#include "log.hpp"
#include "webgpu/webgpu_cpp.h"

template <>
struct fmt::formatter<wgpu::StringView> : fmt::formatter<std::string_view> {
    auto format(const wgpu::StringView &sv, format_context &ctx) const -> decltype(ctx.out()) {
        return formatter<string_view>::format(std::string_view(sv), ctx);
    }
};

#define WGPU_FEATURE_NAME(name)   \
    case wgpu::FeatureName::name: \
        return #name;

inline const char *feature_name_str(wgpu::FeatureName feature) {
    switch (feature) {
        WGPU_FEATURE_NAME(CoreFeaturesAndLimits)
        WGPU_FEATURE_NAME(DepthClipControl)
        WGPU_FEATURE_NAME(Depth32FloatStencil8)
        WGPU_FEATURE_NAME(TextureCompressionBC)
        WGPU_FEATURE_NAME(TextureCompressionBCSliced3D)
        WGPU_FEATURE_NAME(TextureCompressionETC2)
        WGPU_FEATURE_NAME(TextureCompressionASTC)
        WGPU_FEATURE_NAME(TextureCompressionASTCSliced3D)
        WGPU_FEATURE_NAME(TimestampQuery)
        WGPU_FEATURE_NAME(IndirectFirstInstance)
        WGPU_FEATURE_NAME(ShaderF16)
        WGPU_FEATURE_NAME(RG11B10UfloatRenderable)
        WGPU_FEATURE_NAME(BGRA8UnormStorage)
        WGPU_FEATURE_NAME(Float32Filterable)
        WGPU_FEATURE_NAME(Float32Blendable)
        WGPU_FEATURE_NAME(ClipDistances)
        WGPU_FEATURE_NAME(DualSourceBlending)
        WGPU_FEATURE_NAME(Subgroups)
        WGPU_FEATURE_NAME(Unorm16TextureFormats)
        WGPU_FEATURE_NAME(Snorm16TextureFormats)
        WGPU_FEATURE_NAME(MultiDrawIndirect)
#if !defined(__EMSCRIPTEN__)
        WGPU_FEATURE_NAME(TextureFormatsTier1)
        WGPU_FEATURE_NAME(DawnInternalUsages)
        WGPU_FEATURE_NAME(DawnMultiPlanarFormats)
        WGPU_FEATURE_NAME(DawnNative)
        WGPU_FEATURE_NAME(ChromiumExperimentalTimestampQueryInsidePasses)
        WGPU_FEATURE_NAME(ImplicitDeviceSynchronization)
        WGPU_FEATURE_NAME(TransientAttachments)
        WGPU_FEATURE_NAME(MSAARenderToSingleSampled)
        WGPU_FEATURE_NAME(D3D11MultithreadProtected)
        WGPU_FEATURE_NAME(ANGLETextureSharing)
        WGPU_FEATURE_NAME(PixelLocalStorageCoherent)
        WGPU_FEATURE_NAME(PixelLocalStorageNonCoherent)
        WGPU_FEATURE_NAME(MultiPlanarFormatExtendedUsages)
        WGPU_FEATURE_NAME(MultiPlanarFormatP010)
        WGPU_FEATURE_NAME(HostMappedPointer)
        WGPU_FEATURE_NAME(MultiPlanarRenderTargets)
        WGPU_FEATURE_NAME(MultiPlanarFormatNv12a)
        WGPU_FEATURE_NAME(FramebufferFetch)
        WGPU_FEATURE_NAME(BufferMapExtendedUsages)
        WGPU_FEATURE_NAME(AdapterPropertiesMemoryHeaps)
        WGPU_FEATURE_NAME(AdapterPropertiesD3D)
        WGPU_FEATURE_NAME(AdapterPropertiesVk)
        WGPU_FEATURE_NAME(R8UnormStorage)
        WGPU_FEATURE_NAME(DawnFormatCapabilities)
        WGPU_FEATURE_NAME(DawnDrmFormatCapabilities)
        WGPU_FEATURE_NAME(Norm16TextureFormats)
        WGPU_FEATURE_NAME(MultiPlanarFormatNv16)
        WGPU_FEATURE_NAME(MultiPlanarFormatNv24)
        WGPU_FEATURE_NAME(MultiPlanarFormatP210)
        WGPU_FEATURE_NAME(MultiPlanarFormatP410)
        WGPU_FEATURE_NAME(SharedTextureMemoryVkDedicatedAllocation)
        WGPU_FEATURE_NAME(SharedTextureMemoryAHardwareBuffer)
        WGPU_FEATURE_NAME(SharedTextureMemoryDmaBuf)
        WGPU_FEATURE_NAME(SharedTextureMemoryOpaqueFD)
        WGPU_FEATURE_NAME(SharedTextureMemoryZirconHandle)
        WGPU_FEATURE_NAME(SharedTextureMemoryDXGISharedHandle)
        WGPU_FEATURE_NAME(SharedTextureMemoryD3D11Texture2D)
        WGPU_FEATURE_NAME(SharedTextureMemoryIOSurface)
        WGPU_FEATURE_NAME(SharedTextureMemoryEGLImage)
        WGPU_FEATURE_NAME(SharedFenceVkSemaphoreOpaqueFD)
        WGPU_FEATURE_NAME(SharedFenceSyncFD)
        WGPU_FEATURE_NAME(SharedFenceVkSemaphoreZirconHandle)
        WGPU_FEATURE_NAME(SharedFenceDXGISharedHandle)
        WGPU_FEATURE_NAME(SharedFenceMTLSharedEvent)
        WGPU_FEATURE_NAME(SharedBufferMemoryD3D12Resource)
        WGPU_FEATURE_NAME(StaticSamplers)
        WGPU_FEATURE_NAME(YCbCrVulkanSamplers)
        WGPU_FEATURE_NAME(ShaderModuleCompilationOptions)
        WGPU_FEATURE_NAME(DawnLoadResolveTexture)
        WGPU_FEATURE_NAME(DawnPartialLoadResolveTexture)
        WGPU_FEATURE_NAME(DawnTexelCopyBufferRowAlignment)
        WGPU_FEATURE_NAME(FlexibleTextureViews)
        WGPU_FEATURE_NAME(ChromiumExperimentalSubgroupMatrix)
        WGPU_FEATURE_NAME(SharedFenceEGLSync)
        WGPU_FEATURE_NAME(DawnDeviceAllocatorControl)
        WGPU_FEATURE_NAME(TextureComponentSwizzle)
#endif
        default:
            return "Unknown";
    }
}

#undef WGPU_FEATURE_NAME

template <>
struct fmt::formatter<wgpu::FeatureName> : fmt::formatter<std::string> {
    auto format(wgpu::FeatureName feature, format_context &ctx) const -> decltype(ctx.out()) {
        return format_to(ctx.out(), "{} (0x{:08X})", feature_name_str(feature), uint32_t(feature));
    }
};

#define WGPU_BACKEND_NAME(name)   \
    case wgpu::BackendType::name: \
        return #name;

inline const char *backend_type_str(wgpu::BackendType backend_type) {
    switch (backend_type) {
        WGPU_BACKEND_NAME(Null)
        WGPU_BACKEND_NAME(WebGPU)
        WGPU_BACKEND_NAME(D3D11)
        WGPU_BACKEND_NAME(D3D12)
        WGPU_BACKEND_NAME(Metal)
        WGPU_BACKEND_NAME(Vulkan)
        WGPU_BACKEND_NAME(OpenGL)
        WGPU_BACKEND_NAME(OpenGLES)
        default:
            return "Unknown";
    }
}

#undef WGPU_BACKEND_NAME

template <>
struct fmt::formatter<wgpu::BackendType> : fmt::formatter<std::string> {
    auto format(wgpu::BackendType type, format_context &ctx) const -> decltype(ctx.out()) {
        return format_to(ctx.out(), "{} (0x{:08X})", backend_type_str(type), uint32_t(type));
    }
};

#define WGPU_ADAPTER_TYPE_NAME(name) \
    case wgpu::AdapterType::name:    \
        return #name;

inline const char *adapter_type_str(wgpu::AdapterType adapter_type) {
    switch (adapter_type) {
        WGPU_ADAPTER_TYPE_NAME(DiscreteGPU)
        WGPU_ADAPTER_TYPE_NAME(IntegratedGPU)
        WGPU_ADAPTER_TYPE_NAME(CPU)
        // WGPU_ADAPTER_TYPE_NAME(Unknown)
        default:
            return "Unknown";
    }
}

#undef WGPU_ADAPTER_TYPE_NAME

template <>
struct fmt::formatter<wgpu::AdapterType> : fmt::formatter<std::string> {
    auto format(wgpu::AdapterType type, format_context &ctx) const -> decltype(ctx.out()) {
        return format_to(ctx.out(), "{} (0x{:08X})", adapter_type_str(type), uint32_t(type));
    }
};

#endif  // VCPKG_CI_DAWN_WEBGPU_FORMATTER_HPP
