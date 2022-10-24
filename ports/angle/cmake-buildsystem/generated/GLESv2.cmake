# This file was generated with the command:
# "./gni-to-cmake.py" "src/libGLESv2.gni" "GLESv2.cmake"

# Copyright 2013 The ANGLE Project Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.


set(libangle_common_sources
    "src/common/CircularBuffer.h"
    "src/common/Color.h"
    "src/common/Color.inc"
    "src/common/FastVector.h"
    "src/common/FixedVector.h"
    "src/common/Float16ToFloat32.cpp"
    "src/common/MemoryBuffer.cpp"
    "src/common/MemoryBuffer.h"
    "src/common/Optional.h"
    "src/common/PackedEGLEnums_autogen.cpp"
    "src/common/PackedEGLEnums_autogen.h"
    "src/common/PackedEnums.cpp"
    "src/common/PackedEnums.h"
    "src/common/PackedGLEnums_autogen.cpp"
    "src/common/PackedGLEnums_autogen.h"
    "src/common/PoolAlloc.cpp"
    "src/common/PoolAlloc.h"
    "src/common/Spinlock.h"
    "src/common/SynchronizedValue.h"
    "src/common/aligned_memory.cpp"
    "src/common/aligned_memory.h"
    "src/common/android_util.cpp"
    "src/common/android_util.h"
    "src/common/angleutils.cpp"
    "src/common/angleutils.h"
    "src/common/apple_platform_utils.h"
    "src/common/bitset_utils.h"
    "src/common/debug.cpp"
    "src/common/debug.h"
    "src/common/entry_points_enum_autogen.cpp"
    "src/common/entry_points_enum_autogen.h"
    "src/common/event_tracer.cpp"
    "src/common/event_tracer.h"
    "src/common/hash_utils.h"
    "src/common/mathutil.cpp"
    "src/common/mathutil.h"
    "src/common/matrix_utils.cpp"
    "src/common/matrix_utils.h"
    "src/common/platform.h"
    "src/common/string_utils.cpp"
    "src/common/string_utils.h"
    "src/common/system_utils.cpp"
    "src/common/system_utils.h"
    "src/common/third_party/base/anglebase/base_export.h"
    "src/common/third_party/base/anglebase/containers/mru_cache.h"
    "src/common/third_party/base/anglebase/logging.h"
    "src/common/third_party/base/anglebase/macros.h"
    "src/common/third_party/base/anglebase/no_destructor.h"
    "src/common/third_party/base/anglebase/numerics/checked_math.h"
    "src/common/third_party/base/anglebase/numerics/checked_math_impl.h"
    "src/common/third_party/base/anglebase/numerics/clamped_math.h"
    "src/common/third_party/base/anglebase/numerics/clamped_math_impl.h"
    "src/common/third_party/base/anglebase/numerics/math_constants.h"
    "src/common/third_party/base/anglebase/numerics/ranges.h"
    "src/common/third_party/base/anglebase/numerics/safe_conversions.h"
    "src/common/third_party/base/anglebase/numerics/safe_conversions_arm_impl.h"
    "src/common/third_party/base/anglebase/numerics/safe_conversions_impl.h"
    "src/common/third_party/base/anglebase/numerics/safe_math.h"
    "src/common/third_party/base/anglebase/numerics/safe_math_arm_impl.h"
    "src/common/third_party/base/anglebase/numerics/safe_math_clang_gcc_impl.h"
    "src/common/third_party/base/anglebase/numerics/safe_math_shared_impl.h"
    "src/common/third_party/base/anglebase/sha1.cc"
    "src/common/third_party/base/anglebase/sha1.h"
    "src/common/third_party/base/anglebase/sys_byteorder.h"
    "src/common/third_party/smhasher/src/PMurHash.cpp"
    "src/common/third_party/smhasher/src/PMurHash.h"
    "src/common/tls.cpp"
    "src/common/tls.h"
    "src/common/uniform_type_info_autogen.cpp"
    "src/common/utilities.cpp"
    "src/common/utilities.h"
    "src/common/vector_utils.h"
)


set(libangle_common_cl_sources
    "src/common/PackedCLEnums_autogen.cpp"
    "src/common/PackedCLEnums_autogen.h"
)


set(xxhash_sources
    "src/common/third_party/xxhash/xxhash.c"
    "src/common/third_party/xxhash/xxhash.h"
)


if(is_linux OR is_chromeos OR is_android OR is_fuchsia)
    list(APPEND libangle_common_sources
        "src/common/system_utils_linux.cpp"
        "src/common/system_utils_posix.cpp"
    )
endif()


if(is_apple)
    list(APPEND libangle_common_sources
        "src/common/apple/SoftLinking.h"
        "src/common/apple/apple_platform.h"
        "src/common/apple_platform_utils.mm"
        "src/common/gl/cgl/FunctionsCGL.cpp"
        "src/common/gl/cgl/FunctionsCGL.h"
        "src/common/system_utils_apple.cpp"
        "src/common/system_utils_posix.cpp"
    )
    if(is_mac)
        list(APPEND libangle_common_sources "src/common/system_utils_mac.cpp" )
    endif()
    if(is_ios)
        list(APPEND libangle_common_sources "src/common/system_utils_ios.cpp" )
    endif()
endif()


if(is_win)
    list(APPEND libangle_common_sources "src/common/system_utils_win.cpp" )
    if(target_os STREQUAL "winuwp")
        list(APPEND libangle_common_sources "src/common/system_utils_winuwp.cpp" )
    else()
        list(APPEND libangle_common_sources "src/common/system_utils_win32.cpp" )
    endif()
endif()


set(libangle_image_util_headers
    "src/image_util/copyimage.h"
    "src/image_util/copyimage.inc"
    "src/image_util/generatemip.h"
    "src/image_util/generatemip.inc"
    "src/image_util/imageformats.h"
    "src/image_util/loadimage.h"
    "src/image_util/loadimage.inc"
)


set(libangle_image_util_sources
    "src/image_util/copyimage.cpp"
    "src/image_util/imageformats.cpp"
    "src/image_util/loadimage.cpp"
    "src/image_util/loadimage_astc.cpp"
    "src/image_util/loadimage_etc.cpp"
)


set(libangle_gpu_info_util_sources
    "src/gpu_info_util/SystemInfo.cpp"
    "src/gpu_info_util/SystemInfo.h"
    "src/gpu_info_util/SystemInfo_internal.h"
)


set(libangle_gpu_info_util_win_sources "src/gpu_info_util/SystemInfo_win.cpp" )


set(libangle_gpu_info_util_android_sources
     "src/gpu_info_util/SystemInfo_android.cpp" )


set(libangle_gpu_info_util_linux_sources
     "src/gpu_info_util/SystemInfo_linux.cpp" )


set(libangle_gpu_info_util_fuchsia_sources
     "src/gpu_info_util/SystemInfo_fuchsia.cpp" )


set(libangle_gpu_info_util_vulkan_sources
    "src/gpu_info_util/SystemInfo_vulkan.cpp"
    "src/gpu_info_util/SystemInfo_vulkan.h"
)


set(libangle_gpu_info_util_libpci_sources
     "src/gpu_info_util/SystemInfo_libpci.cpp" )


set(libangle_gpu_info_util_x11_sources "src/gpu_info_util/SystemInfo_x11.cpp" )


set(libangle_gpu_info_util_mac_sources
    "src/gpu_info_util/SystemInfo_apple.mm"
    "src/gpu_info_util/SystemInfo_macos.mm"
)


set(libangle_gpu_info_util_ios_sources
    "src/gpu_info_util/SystemInfo_apple.mm"
    "src/gpu_info_util/SystemInfo_ios.cpp"
)


set(libangle_includes
    "include/angle_gl.h"
    "include/export.h"
    "include/EGL/egl.h"
    "include/EGL/eglext.h"
    "include/EGL/eglext_angle.h"
    "include/EGL/eglplatform.h"
    "include/GLES/gl.h"
    "include/GLES/glplatform.h"
    "include/GLES/glext.h"
    "include/GLES2/gl2.h"
    "include/GLES2/gl2ext.h"
    "include/GLES2/gl2ext_angle.h"
    "include/GLES2/gl2platform.h"
    "include/GLES3/gl3.h"
    "include/GLES3/gl3platform.h"
    "include/GLES3/gl31.h"
    "include/GLES3/gl32.h"
    "include/KHR/khrplatform.h"
    "include/WGL/wgl.h"
    "include/platform/Feature.h"
    "include/platform/FeaturesD3D_autogen.h"
    "include/platform/FeaturesGL_autogen.h"
    "include/platform/FeaturesMtl_autogen.h"
    "include/platform/FeaturesVk_autogen.h"
    "include/platform/FrontendFeatures_autogen.h"
    "include/platform/Platform.h"
    "include/platform/PlatformMethods.h"
    "include/vulkan/vulkan_fuchsia_ext.h"
)


set(libangle_headers
    "src/libANGLE/AttributeMap.h"
    "src/libANGLE/BinaryStream.h"
    "src/libANGLE/BlobCache.h"
    "src/libANGLE/Buffer.h"
    "src/libANGLE/Caps.h"
    "src/libANGLE/Compiler.h"
    "src/libANGLE/Config.h"
    "src/libANGLE/Constants.h"
    "src/libANGLE/Context.h"
    "src/libANGLE/Context.inl.h"
    "src/libANGLE/Context_gl_1_autogen.h"
    "src/libANGLE/Context_gl_2_autogen.h"
    "src/libANGLE/Context_gl_3_autogen.h"
    "src/libANGLE/Context_gl_4_autogen.h"
    "src/libANGLE/Context_gles_1_0_autogen.h"
    "src/libANGLE/Context_gles_2_0_autogen.h"
    "src/libANGLE/Context_gles_3_0_autogen.h"
    "src/libANGLE/Context_gles_3_1_autogen.h"
    "src/libANGLE/Context_gles_3_2_autogen.h"
    "src/libANGLE/Context_gles_ext_autogen.h"
    "src/libANGLE/Debug.h"
    "src/libANGLE/Device.h"
    "src/libANGLE/Display.h"
    "src/libANGLE/EGLSync.h"
    "src/libANGLE/Error.h"
    "src/libANGLE/Error.inc"
    "src/libANGLE/ErrorStrings.h"
    "src/libANGLE/Fence.h"
    "src/libANGLE/Framebuffer.h"
    "src/libANGLE/FramebufferAttachment.h"
    "src/libANGLE/GLES1Renderer.h"
    "src/libANGLE/GLES1Shaders.inc"
    "src/libANGLE/GLES1State.h"
    "src/libANGLE/HandleAllocator.h"
    "src/libANGLE/Image.h"
    "src/libANGLE/ImageIndex.h"
    "src/libANGLE/IndexRangeCache.h"
    "src/libANGLE/InfoLog.h"
    "src/libANGLE/LoggingAnnotator.h"
    "src/libANGLE/MemoryObject.h"
    "src/libANGLE/MemoryProgramCache.h"
    "src/libANGLE/Observer.h"
    "src/libANGLE/Overlay.h"
    "src/libANGLE/OverlayWidgets.h"
    "src/libANGLE/Overlay_autogen.h"
    "src/libANGLE/Overlay_font_autogen.h"
    "src/libANGLE/Program.h"
    "src/libANGLE/ProgramExecutable.h"
    "src/libANGLE/ProgramLinkedResources.h"
    "src/libANGLE/ProgramPipeline.h"
    "src/libANGLE/Query.h"
    "src/libANGLE/RefCountObject.h"
    "src/libANGLE/Renderbuffer.h"
    "src/libANGLE/ResourceManager.h"
    "src/libANGLE/ResourceMap.h"
    "src/libANGLE/Sampler.h"
    "src/libANGLE/Semaphore.h"
    "src/libANGLE/Shader.h"
    "src/libANGLE/SizedMRUCache.h"
    "src/libANGLE/State.h"
    "src/libANGLE/Stream.h"
    "src/libANGLE/Surface.h"
    "src/libANGLE/Texture.h"
    "src/libANGLE/Thread.h"
    "src/libANGLE/TransformFeedback.h"
    "src/libANGLE/Uniform.h"
    "src/libANGLE/VaryingPacking.h"
    "src/libANGLE/Version.h"
    "src/libANGLE/Version.inc"
    "src/libANGLE/VertexArray.h"
    "src/libANGLE/VertexAttribute.h"
    "src/libANGLE/VertexAttribute.inc"
    "src/libANGLE/WorkerThread.h"
    "src/libANGLE/angletypes.h"
    "src/libANGLE/angletypes.inc"
    "src/libANGLE/entry_points_utils.h"
    "src/libANGLE/features.h"
    "src/libANGLE/formatutils.h"
    "src/libANGLE/gles_extensions_autogen.h"
    "src/libANGLE/histogram_macros.h"
    "src/libANGLE/queryconversions.h"
    "src/libANGLE/queryutils.h"
    "src/libANGLE/trace.h"
    "src/libANGLE/renderer/BufferImpl.h"
    "src/libANGLE/renderer/CompilerImpl.h"
    "src/libANGLE/renderer/ContextImpl.h"
    "src/libANGLE/renderer/driver_utils.h"
    "src/libANGLE/renderer/DeviceImpl.h"
    "src/libANGLE/renderer/DisplayImpl.h"
    "src/libANGLE/renderer/EGLImplFactory.h"
    "src/libANGLE/renderer/EGLReusableSync.h"
    "src/libANGLE/renderer/EGLSyncImpl.h"
    "src/libANGLE/renderer/FenceNVImpl.h"
    "src/libANGLE/renderer/FormatID_autogen.h"
    "src/libANGLE/renderer/Format.h"
    "src/libANGLE/renderer/FramebufferAttachmentObjectImpl.h"
    "src/libANGLE/renderer/FramebufferImpl.h"
    "src/libANGLE/renderer/GLImplFactory.h"
    "src/libANGLE/renderer/gl/functionsgl_enums.h"
    "src/libANGLE/renderer/ImageImpl.h"
    "src/libANGLE/renderer/MemoryObjectImpl.h"
    "src/libANGLE/renderer/OverlayImpl.h"
    "src/libANGLE/renderer/ProgramImpl.h"
    "src/libANGLE/renderer/ProgramPipelineImpl.h"
    "src/libANGLE/renderer/QueryImpl.h"
    "src/libANGLE/renderer/RenderbufferImpl.h"
    "src/libANGLE/renderer/RenderTargetCache.h"
    "src/libANGLE/renderer/SamplerImpl.h"
    "src/libANGLE/renderer/SemaphoreImpl.h"
    "src/libANGLE/renderer/ShaderImpl.h"
    "src/libANGLE/renderer/StreamProducerImpl.h"
    "src/libANGLE/renderer/SurfaceImpl.h"
    "src/libANGLE/renderer/SyncImpl.h"
    "src/libANGLE/renderer/TextureImpl.h"
    "src/libANGLE/renderer/TransformFeedbackImpl.h"
    "src/libANGLE/renderer/VertexArrayImpl.h"
    "src/libANGLE/renderer/copyvertex.h"
    "src/libANGLE/renderer/copyvertex.inc.h"
    "src/libANGLE/renderer/load_functions_table.h"
    "src/libANGLE/renderer/renderer_utils.h"
    "src/libANGLE/renderer/serial_utils.h"
    "src/libANGLE/validationEGL.h"
    "src/libANGLE/validationEGL_autogen.h"
    "src/libANGLE/validationES.h"
    "src/libANGLE/validationES1.h"
    "src/libANGLE/validationES1_autogen.h"
    "src/libANGLE/validationES2.h"
    "src/libANGLE/validationES2_autogen.h"
    "src/libANGLE/validationES3.h"
    "src/libANGLE/validationES31.h"
    "src/libANGLE/validationES31_autogen.h"
    "src/libANGLE/validationES32.h"
    "src/libANGLE/validationES32_autogen.h"
    "src/libANGLE/validationES3_autogen.h"
    "src/libANGLE/validationESEXT.h"
    "src/libANGLE/validationESEXT_autogen.h"
    "src/libANGLE/validationGL1_autogen.h"
    "src/libANGLE/validationGL2_autogen.h"
    "src/libANGLE/validationGL3_autogen.h"
    "src/libANGLE/validationGL4_autogen.h"
    "src/third_party/trace_event/trace_event.h"
)


set(libangle_sources
    "src/libANGLE/AttributeMap.cpp"
    "src/libANGLE/BlobCache.cpp"
    "src/libANGLE/Buffer.cpp"
    "src/libANGLE/Caps.cpp"
    "src/libANGLE/Compiler.cpp"
    "src/libANGLE/Config.cpp"
    "src/libANGLE/Context.cpp"
    "src/libANGLE/Context_gl.cpp"
    "src/libANGLE/Context_gles_1_0.cpp"
    "src/libANGLE/Debug.cpp"
    "src/libANGLE/Device.cpp"
    "src/libANGLE/Display.cpp"
    "src/libANGLE/EGLSync.cpp"
    "src/libANGLE/Error.cpp"
    "src/libANGLE/Fence.cpp"
    "src/libANGLE/Framebuffer.cpp"
    "src/libANGLE/FramebufferAttachment.cpp"
    "src/libANGLE/GLES1Renderer.cpp"
    "src/libANGLE/GLES1State.cpp"
    "src/libANGLE/HandleAllocator.cpp"
    "src/libANGLE/Image.cpp"
    "src/libANGLE/ImageIndex.cpp"
    "src/libANGLE/IndexRangeCache.cpp"
    "src/libANGLE/LoggingAnnotator.cpp"
    "src/libANGLE/MemoryObject.cpp"
    "src/libANGLE/MemoryProgramCache.cpp"
    "src/libANGLE/Observer.cpp"
    "src/libANGLE/Overlay.cpp"
    "src/libANGLE/OverlayWidgets.cpp"
    "src/libANGLE/Overlay_autogen.cpp"
    "src/libANGLE/Overlay_font_autogen.cpp"
    "src/libANGLE/Platform.cpp"
    "src/libANGLE/Program.cpp"
    "src/libANGLE/ProgramExecutable.cpp"
    "src/libANGLE/ProgramLinkedResources.cpp"
    "src/libANGLE/ProgramPipeline.cpp"
    "src/libANGLE/Query.cpp"
    "src/libANGLE/Renderbuffer.cpp"
    "src/libANGLE/ResourceManager.cpp"
    "src/libANGLE/Sampler.cpp"
    "src/libANGLE/Semaphore.cpp"
    "src/libANGLE/Shader.cpp"
    "src/libANGLE/State.cpp"
    "src/libANGLE/Stream.cpp"
    "src/libANGLE/Surface.cpp"
    "src/libANGLE/Texture.cpp"
    "src/libANGLE/Thread.cpp"
    "src/libANGLE/TransformFeedback.cpp"
    "src/libANGLE/Uniform.cpp"
    "src/libANGLE/VaryingPacking.cpp"
    "src/libANGLE/VertexArray.cpp"
    "src/libANGLE/VertexAttribute.cpp"
    "src/libANGLE/WorkerThread.cpp"
    "src/libANGLE/angletypes.cpp"
    "src/libANGLE/es3_copy_conversion_table_autogen.cpp"
    "src/libANGLE/format_map_autogen.cpp"
    "src/libANGLE/format_map_desktop.cpp"
    "src/libANGLE/formatutils.cpp"
    "src/libANGLE/gles_extensions_autogen.cpp"
    "src/libANGLE/queryconversions.cpp"
    "src/libANGLE/queryutils.cpp"
    "src/libANGLE/renderer/BufferImpl.cpp"
    "src/libANGLE/renderer/ContextImpl.cpp"
    "src/libANGLE/renderer/DeviceImpl.cpp"
    "src/libANGLE/renderer/DisplayImpl.cpp"
    "src/libANGLE/renderer/EGLReusableSync.cpp"
    "src/libANGLE/renderer/EGLSyncImpl.cpp"
    "src/libANGLE/renderer/Format_table_autogen.cpp"
    "src/libANGLE/renderer/FramebufferImpl.cpp"
    "src/libANGLE/renderer/ImageImpl.cpp"
    "src/libANGLE/renderer/ProgramImpl.cpp"
    "src/libANGLE/renderer/ProgramPipelineImpl.cpp"
    "src/libANGLE/renderer/QueryImpl.cpp"
    "src/libANGLE/renderer/RenderbufferImpl.cpp"
    "src/libANGLE/renderer/ShaderImpl.cpp"
    "src/libANGLE/renderer/SurfaceImpl.cpp"
    "src/libANGLE/renderer/TextureImpl.cpp"
    "src/libANGLE/renderer/TransformFeedbackImpl.cpp"
    "src/libANGLE/renderer/VertexArrayImpl.cpp"
    "src/libANGLE/renderer/driver_utils.cpp"
    "src/libANGLE/renderer/load_functions_table_autogen.cpp"
    "src/libANGLE/renderer/renderer_utils.cpp"
    "src/libANGLE/validationEGL.cpp"
    "src/libANGLE/validationES.cpp"
    "src/libANGLE/validationES1.cpp"
    "src/libANGLE/validationES2.cpp"
    "src/libANGLE/validationES3.cpp"
    "src/libANGLE/validationES31.cpp"
    "src/libANGLE/validationES32.cpp"
    "src/libANGLE/validationESEXT.cpp"
    "src/libANGLE/validationGL1.cpp"
    "src/libANGLE/validationGL2.cpp"
    "src/libANGLE/validationGL3.cpp"
    "src/libANGLE/validationGL4.cpp"
)


set(cl_includes
    "include/angle_cl.h"
    "include/export.h"
    "include/CL/cl.h"
    "include/CL/cl_d3d10.h"
    "include/CL/cl_d3d11.h"
    "include/CL/cl_dx9_media_sharing.h"
    "include/CL/cl_dx9_media_sharing_intel.h"
    "include/CL/cl_egl.h"
    "include/CL/cl_ext.h"
    "include/CL/cl_ext_intel.h"
    "include/CL/cl_gl.h"
    "include/CL/cl_gl_ext.h"
    "include/CL/cl_half.h"
    "include/CL/cl_icd.h"
    "include/CL/cl_layer.h"
    "include/CL/cl_platform.h"
    "include/CL/cl_va_api_media_sharing_intel.h"
    "include/CL/cl_version.h"
    "include/CL/opencl.h"
)


set(libangle_cl_headers
    "src/libANGLE/CLBitField.h"
    "src/libANGLE/CLBuffer.h"
    "src/libANGLE/CLCommandQueue.h"
    "src/libANGLE/CLContext.h"
    "src/libANGLE/CLDevice.h"
    "src/libANGLE/CLEvent.h"
    "src/libANGLE/CLImage.h"
    "src/libANGLE/CLKernel.h"
    "src/libANGLE/CLMemory.h"
    "src/libANGLE/CLObject.h"
    "src/libANGLE/CLPlatform.h"
    "src/libANGLE/CLProgram.h"
    "src/libANGLE/CLRefPointer.h"
    "src/libANGLE/CLSampler.h"
    "src/libANGLE/CLtypes.h"
    "src/libANGLE/cl_utils.h"
    "src/libANGLE/renderer/CLCommandQueueImpl.h"
    "src/libANGLE/renderer/CLContextImpl.h"
    "src/libANGLE/renderer/CLDeviceImpl.h"
    "src/libANGLE/renderer/CLEventImpl.h"
    "src/libANGLE/renderer/CLExtensions.h"
    "src/libANGLE/renderer/CLKernelImpl.h"
    "src/libANGLE/renderer/CLMemoryImpl.h"
    "src/libANGLE/renderer/CLPlatformImpl.h"
    "src/libANGLE/renderer/CLProgramImpl.h"
    "src/libANGLE/renderer/CLSamplerImpl.h"
    "src/libANGLE/renderer/CLtypes.h"
    "src/libANGLE/validationCL.h"
    "src/libANGLE/validationCL_autogen.h"
)


set(libangle_cl_sources
    "src/libANGLE/CLBuffer.cpp"
    "src/libANGLE/CLCommandQueue.cpp"
    "src/libANGLE/CLContext.cpp"
    "src/libANGLE/CLDevice.cpp"
    "src/libANGLE/CLEvent.cpp"
    "src/libANGLE/CLImage.cpp"
    "src/libANGLE/CLKernel.cpp"
    "src/libANGLE/CLMemory.cpp"
    "src/libANGLE/CLObject.cpp"
    "src/libANGLE/CLPlatform.cpp"
    "src/libANGLE/CLProgram.cpp"
    "src/libANGLE/CLSampler.cpp"
    "src/libANGLE/cl_utils.cpp"
    "src/libANGLE/renderer/CLCommandQueueImpl.cpp"
    "src/libANGLE/renderer/CLContextImpl.cpp"
    "src/libANGLE/renderer/CLDeviceImpl.cpp"
    "src/libANGLE/renderer/CLEventImpl.cpp"
    "src/libANGLE/renderer/CLExtensions.cpp"
    "src/libANGLE/renderer/CLKernelImpl.cpp"
    "src/libANGLE/renderer/CLMemoryImpl.cpp"
    "src/libANGLE/renderer/CLPlatformImpl.cpp"
    "src/libANGLE/renderer/CLProgramImpl.cpp"
    "src/libANGLE/renderer/CLSamplerImpl.cpp"
    "src/libANGLE/validationCL.cpp"
)


set(libangle_mac_sources
    "src/libANGLE/renderer/driver_utils_mac.mm"
    "src/libANGLE/renderer/gl/apple/DisplayApple_api.cpp"
    "src/libANGLE/renderer/gl/apple/DisplayApple_api.h"
)

# The frame capture headers are always visible to libANGLE.
list(APPEND libangle_sources
    "src/libANGLE/capture/FrameCapture.h"
    "src/libANGLE/capture/capture_egl.h"
    "src/libANGLE/capture/capture_gles_1_0_autogen.h"
    "src/libANGLE/capture/capture_gles_2_0_autogen.h"
    "src/libANGLE/capture/capture_gles_3_0_autogen.h"
    "src/libANGLE/capture/capture_gles_3_1_autogen.h"
    "src/libANGLE/capture/capture_gles_3_2_autogen.h"
    "src/libANGLE/capture/capture_gles_ext_autogen.h"
    "src/libANGLE/capture/frame_capture_utils.h"
    "src/libANGLE/capture/frame_capture_utils_autogen.h"
    "src/libANGLE/capture/gl_enum_utils.h"
    "src/libANGLE/capture/gl_enum_utils_autogen.h"
)


set(libangle_capture_sources
    "src/libANGLE/capture/FrameCapture.cpp"
    "src/libANGLE/capture/capture_egl.cpp"
    "src/libANGLE/capture/capture_gles_1_0_autogen.cpp"
    "src/libANGLE/capture/capture_gles_1_0_params.cpp"
    "src/libANGLE/capture/capture_gles_2_0_autogen.cpp"
    "src/libANGLE/capture/capture_gles_2_0_params.cpp"
    "src/libANGLE/capture/capture_gles_3_0_autogen.cpp"
    "src/libANGLE/capture/capture_gles_3_0_params.cpp"
    "src/libANGLE/capture/capture_gles_3_1_autogen.cpp"
    "src/libANGLE/capture/capture_gles_3_1_params.cpp"
    "src/libANGLE/capture/capture_gles_3_2_autogen.cpp"
    "src/libANGLE/capture/capture_gles_3_2_params.cpp"
    "src/libANGLE/capture/capture_gles_ext_autogen.cpp"
    "src/libANGLE/capture/capture_gles_ext_params.cpp"
    "src/libANGLE/capture/frame_capture_replay_autogen.cpp"
    "src/libANGLE/capture/frame_capture_utils_autogen.cpp"
    "src/libANGLE/capture/gl_enum_utils.cpp"
    "src/libANGLE/capture/gl_enum_utils_autogen.cpp"
    "src/libGLESv2/global_state.h"
    "src/third_party/ceval/ceval.h"
)


set(libglesv2_sources
    "src/libGLESv2/egl_ext_stubs.cpp"
    "src/libGLESv2/egl_ext_stubs_autogen.h"
    "src/libGLESv2/egl_stubs.cpp"
    "src/libGLESv2/egl_stubs_autogen.h"
    "src/libGLESv2/entry_points_egl_autogen.cpp"
    "src/libGLESv2/entry_points_egl_autogen.h"
    "src/libGLESv2/entry_points_egl_ext_autogen.cpp"
    "src/libGLESv2/entry_points_egl_ext_autogen.h"
    "src/libGLESv2/entry_points_gles_1_0_autogen.cpp"
    "src/libGLESv2/entry_points_gles_1_0_autogen.h"
    "src/libGLESv2/entry_points_gles_2_0_autogen.cpp"
    "src/libGLESv2/entry_points_gles_2_0_autogen.h"
    "src/libGLESv2/entry_points_gles_3_0_autogen.cpp"
    "src/libGLESv2/entry_points_gles_3_0_autogen.h"
    "src/libGLESv2/entry_points_gles_3_1_autogen.cpp"
    "src/libGLESv2/entry_points_gles_3_1_autogen.h"
    "src/libGLESv2/entry_points_gles_3_2_autogen.cpp"
    "src/libGLESv2/entry_points_gles_3_2_autogen.h"
    "src/libGLESv2/entry_points_gles_ext_autogen.cpp"
    "src/libGLESv2/entry_points_gles_ext_autogen.h"
    "src/libGLESv2/global_state.cpp"
    "src/libGLESv2/global_state.h"
    "src/libGLESv2/libGLESv2_autogen.cpp"
    "src/libGLESv2/proc_table_egl.h"
    "src/libGLESv2/proc_table_egl_autogen.cpp"
    "src/libGLESv2/resource.h"
)


set(libglesv2_gl_sources
    "src/libGLESv2/entry_points_gl_1_autogen.cpp"
    "src/libGLESv2/entry_points_gl_1_autogen.h"
    "src/libGLESv2/entry_points_gl_2_autogen.cpp"
    "src/libGLESv2/entry_points_gl_2_autogen.h"
    "src/libGLESv2/entry_points_gl_3_autogen.cpp"
    "src/libGLESv2/entry_points_gl_3_autogen.h"
    "src/libGLESv2/entry_points_gl_4_autogen.cpp"
    "src/libGLESv2/entry_points_gl_4_autogen.h"
)


set(libglesv2_cl_sources
    "src/libGLESv2/cl_dispatch_table.cpp"
    "src/libGLESv2/cl_dispatch_table.h"
    "src/libGLESv2/cl_stubs.cpp"
    "src/libGLESv2/cl_stubs_autogen.h"
    "src/libGLESv2/entry_points_cl_autogen.cpp"
    "src/libGLESv2/entry_points_cl_autogen.h"
    "src/libGLESv2/entry_points_cl_utils.cpp"
    "src/libGLESv2/entry_points_cl_utils.h"
    "src/libGLESv2/proc_table_cl.h"
    "src/libGLESv2/proc_table_cl_autogen.cpp"
)


set(libglesv1_cm_sources
    "src/libGLESv1_CM/libGLESv1_CM.cpp"
    "src/libGLESv1_CM/resource.h"
)


if(is_win)
    list(APPEND libglesv1_cm_sources "src/libGLESv1_CM/libGLESv1_CM.rc" )
endif()


set(libegl_sources
    "src/libEGL/egl_loader_autogen.h"
    "src/libEGL/libEGL_autogen.cpp"
    "src/libEGL/resource.h"
    "src/libGLESv2/entry_points_egl_autogen.h"
    "src/libGLESv2/entry_points_egl_ext_autogen.h"
)
