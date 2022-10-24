# This file was generated with the command:
# "./gni-to-cmake.py" "src/libANGLE/renderer/gl/BUILD.gn" "GL.cmake" "--prepend" "src/libANGLE/renderer/gl/"

# Copyright 2020 The ANGLE Project Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
#
# This file houses the build configuration for the ANGLE GL back-ends.




if(angle_has_build AND ozone_platform_gbm)


endif()




set(_gl_backend_sources
    "src/libANGLE/renderer/gl/BlitGL.cpp"
    "src/libANGLE/renderer/gl/BlitGL.h"
    "src/libANGLE/renderer/gl/BufferGL.cpp"
    "src/libANGLE/renderer/gl/BufferGL.h"
    "src/libANGLE/renderer/gl/ClearMultiviewGL.cpp"
    "src/libANGLE/renderer/gl/ClearMultiviewGL.h"
    "src/libANGLE/renderer/gl/CompilerGL.cpp"
    "src/libANGLE/renderer/gl/CompilerGL.h"
    "src/libANGLE/renderer/gl/ContextGL.cpp"
    "src/libANGLE/renderer/gl/ContextGL.h"
    "src/libANGLE/renderer/gl/DispatchTableGL_autogen.cpp"
    "src/libANGLE/renderer/gl/DispatchTableGL_autogen.h"
    "src/libANGLE/renderer/gl/DisplayGL.cpp"
    "src/libANGLE/renderer/gl/DisplayGL.h"
    "src/libANGLE/renderer/gl/FenceNVGL.cpp"
    "src/libANGLE/renderer/gl/FenceNVGL.h"
    "src/libANGLE/renderer/gl/FramebufferGL.cpp"
    "src/libANGLE/renderer/gl/FramebufferGL.h"
    "src/libANGLE/renderer/gl/FunctionsGL.cpp"
    "src/libANGLE/renderer/gl/FunctionsGL.h"
    "src/libANGLE/renderer/gl/ImageGL.cpp"
    "src/libANGLE/renderer/gl/ImageGL.h"
    "src/libANGLE/renderer/gl/MemoryObjectGL.cpp"
    "src/libANGLE/renderer/gl/MemoryObjectGL.h"
    "src/libANGLE/renderer/gl/ProgramGL.cpp"
    "src/libANGLE/renderer/gl/ProgramGL.h"
    "src/libANGLE/renderer/gl/ProgramPipelineGL.cpp"
    "src/libANGLE/renderer/gl/ProgramPipelineGL.h"
    "src/libANGLE/renderer/gl/QueryGL.cpp"
    "src/libANGLE/renderer/gl/QueryGL.h"
    "src/libANGLE/renderer/gl/RenderbufferGL.cpp"
    "src/libANGLE/renderer/gl/RenderbufferGL.h"
    "src/libANGLE/renderer/gl/RendererGL.cpp"
    "src/libANGLE/renderer/gl/RendererGL.h"
    "src/libANGLE/renderer/gl/SamplerGL.cpp"
    "src/libANGLE/renderer/gl/SamplerGL.h"
    "src/libANGLE/renderer/gl/SemaphoreGL.cpp"
    "src/libANGLE/renderer/gl/SemaphoreGL.h"
    "src/libANGLE/renderer/gl/ShaderGL.cpp"
    "src/libANGLE/renderer/gl/ShaderGL.h"
    "src/libANGLE/renderer/gl/StateManagerGL.cpp"
    "src/libANGLE/renderer/gl/StateManagerGL.h"
    "src/libANGLE/renderer/gl/SurfaceGL.cpp"
    "src/libANGLE/renderer/gl/SurfaceGL.h"
    "src/libANGLE/renderer/gl/SyncGL.cpp"
    "src/libANGLE/renderer/gl/SyncGL.h"
    "src/libANGLE/renderer/gl/TextureGL.cpp"
    "src/libANGLE/renderer/gl/TextureGL.h"
    "src/libANGLE/renderer/gl/TransformFeedbackGL.cpp"
    "src/libANGLE/renderer/gl/TransformFeedbackGL.h"
    "src/libANGLE/renderer/gl/VertexArrayGL.cpp"
    "src/libANGLE/renderer/gl/VertexArrayGL.h"
    "src/libANGLE/renderer/gl/formatutilsgl.cpp"
    "src/libANGLE/renderer/gl/formatutilsgl.h"
    "src/libANGLE/renderer/gl/functionsgl_enums.h"
    "src/libANGLE/renderer/gl/functionsgl_typedefs.h"
    "src/libANGLE/renderer/gl/renderergl_utils.cpp"
    "src/libANGLE/renderer/gl/renderergl_utils.h"
)


if(is_win)
    list(APPEND _gl_backend_sources
        "src/libANGLE/renderer/gl/../../../third_party/khronos/GL/wglext.h"
        "src/libANGLE/renderer/gl/wgl/ContextWGL.cpp"
        "src/libANGLE/renderer/gl/wgl/ContextWGL.h"
        "src/libANGLE/renderer/gl/wgl/D3DTextureSurfaceWGL.cpp"
        "src/libANGLE/renderer/gl/wgl/D3DTextureSurfaceWGL.h"
        "src/libANGLE/renderer/gl/wgl/DXGISwapChainWindowSurfaceWGL.cpp"
        "src/libANGLE/renderer/gl/wgl/DXGISwapChainWindowSurfaceWGL.h"
        "src/libANGLE/renderer/gl/wgl/DisplayWGL.cpp"
        "src/libANGLE/renderer/gl/wgl/DisplayWGL.h"
        "src/libANGLE/renderer/gl/wgl/FunctionsWGL.cpp"
        "src/libANGLE/renderer/gl/wgl/FunctionsWGL.h"
        "src/libANGLE/renderer/gl/wgl/PbufferSurfaceWGL.cpp"
        "src/libANGLE/renderer/gl/wgl/PbufferSurfaceWGL.h"
        "src/libANGLE/renderer/gl/wgl/RendererWGL.cpp"
        "src/libANGLE/renderer/gl/wgl/RendererWGL.h"
        "src/libANGLE/renderer/gl/wgl/SurfaceWGL.h"
        "src/libANGLE/renderer/gl/wgl/WindowSurfaceWGL.cpp"
        "src/libANGLE/renderer/gl/wgl/WindowSurfaceWGL.h"
        "src/libANGLE/renderer/gl/wgl/functionswgl_typedefs.h"
        "src/libANGLE/renderer/gl/wgl/wgl_utils.cpp"
        "src/libANGLE/renderer/gl/wgl/wgl_utils.h"
    )
endif()


if(angle_use_x11)
    list(APPEND _gl_backend_sources
        "src/libANGLE/renderer/gl/glx/DisplayGLX.cpp"
        "src/libANGLE/renderer/gl/glx/DisplayGLX.h"
        "src/libANGLE/renderer/gl/glx/FunctionsGLX.cpp"
        "src/libANGLE/renderer/gl/glx/FunctionsGLX.h"
        "src/libANGLE/renderer/gl/glx/PbufferSurfaceGLX.cpp"
        "src/libANGLE/renderer/gl/glx/PbufferSurfaceGLX.h"
        "src/libANGLE/renderer/gl/glx/PixmapSurfaceGLX.cpp"
        "src/libANGLE/renderer/gl/glx/PixmapSurfaceGLX.h"
        "src/libANGLE/renderer/gl/glx/RendererGLX.cpp"
        "src/libANGLE/renderer/gl/glx/RendererGLX.h"
        "src/libANGLE/renderer/gl/glx/SurfaceGLX.h"
        "src/libANGLE/renderer/gl/glx/WindowSurfaceGLX.cpp"
        "src/libANGLE/renderer/gl/glx/WindowSurfaceGLX.h"
        "src/libANGLE/renderer/gl/glx/functionsglx_typedefs.h"
        "src/libANGLE/renderer/gl/glx/glx_utils.cpp"
        "src/libANGLE/renderer/gl/glx/glx_utils.h"
        "src/libANGLE/renderer/gl/glx/platform_glx.h"
    )
endif()


if(is_android OR is_linux OR is_chromeos)
    list(APPEND _gl_backend_sources
        "src/libANGLE/renderer/gl/egl/ContextEGL.cpp"
        "src/libANGLE/renderer/gl/egl/ContextEGL.h"
        "src/libANGLE/renderer/gl/egl/DisplayEGL.cpp"
        "src/libANGLE/renderer/gl/egl/DisplayEGL.h"
        "src/libANGLE/renderer/gl/egl/DmaBufImageSiblingEGL.cpp"
        "src/libANGLE/renderer/gl/egl/DmaBufImageSiblingEGL.h"
        "src/libANGLE/renderer/gl/egl/ExternalImageSiblingEGL.h"
        "src/libANGLE/renderer/gl/egl/FunctionsEGL.cpp"
        "src/libANGLE/renderer/gl/egl/FunctionsEGL.h"
        "src/libANGLE/renderer/gl/egl/FunctionsEGLDL.cpp"
        "src/libANGLE/renderer/gl/egl/FunctionsEGLDL.h"
        "src/libANGLE/renderer/gl/egl/ImageEGL.cpp"
        "src/libANGLE/renderer/gl/egl/ImageEGL.h"
        "src/libANGLE/renderer/gl/egl/PbufferSurfaceEGL.cpp"
        "src/libANGLE/renderer/gl/egl/PbufferSurfaceEGL.h"
        "src/libANGLE/renderer/gl/egl/RendererEGL.cpp"
        "src/libANGLE/renderer/gl/egl/RendererEGL.h"
        "src/libANGLE/renderer/gl/egl/SurfaceEGL.cpp"
        "src/libANGLE/renderer/gl/egl/SurfaceEGL.h"
        "src/libANGLE/renderer/gl/egl/SyncEGL.cpp"
        "src/libANGLE/renderer/gl/egl/SyncEGL.h"
        "src/libANGLE/renderer/gl/egl/WindowSurfaceEGL.cpp"
        "src/libANGLE/renderer/gl/egl/WindowSurfaceEGL.h"
        "src/libANGLE/renderer/gl/egl/egl_utils.cpp"
        "src/libANGLE/renderer/gl/egl/egl_utils.h"
        "src/libANGLE/renderer/gl/egl/functionsegl_typedefs.h"
    )
endif()


if(ozone_platform_gbm)
    list(APPEND _gl_backend_sources
        "src/libANGLE/renderer/gl/egl/gbm/DisplayGbm.cpp"
        "src/libANGLE/renderer/gl/egl/gbm/DisplayGbm.h"
        "src/libANGLE/renderer/gl/egl/gbm/SurfaceGbm.cpp"
        "src/libANGLE/renderer/gl/egl/gbm/SurfaceGbm.h"
    )


endif()


if(is_android)
    list(APPEND _gl_backend_sources
        "src/libANGLE/renderer/gl/egl/android/DisplayAndroid.cpp"
        "src/libANGLE/renderer/gl/egl/android/DisplayAndroid.h"
        "src/libANGLE/renderer/gl/egl/android/NativeBufferImageSiblingAndroid.cpp"
        "src/libANGLE/renderer/gl/egl/android/NativeBufferImageSiblingAndroid.h"
    )
endif()


if(angle_enable_cgl)
    list(APPEND _gl_backend_sources
        "src/libANGLE/renderer/gl/cgl/ContextCGL.cpp"
        "src/libANGLE/renderer/gl/cgl/ContextCGL.h"
        "src/libANGLE/renderer/gl/cgl/DeviceCGL.cpp"
        "src/libANGLE/renderer/gl/cgl/DeviceCGL.h"
        "src/libANGLE/renderer/gl/cgl/DisplayCGL.h"
        "src/libANGLE/renderer/gl/cgl/DisplayCGL.mm"
        "src/libANGLE/renderer/gl/cgl/IOSurfaceSurfaceCGL.cpp"
        "src/libANGLE/renderer/gl/cgl/IOSurfaceSurfaceCGL.h"
        "src/libANGLE/renderer/gl/cgl/PbufferSurfaceCGL.cpp"
        "src/libANGLE/renderer/gl/cgl/PbufferSurfaceCGL.h"
        "src/libANGLE/renderer/gl/cgl/RendererCGL.cpp"
        "src/libANGLE/renderer/gl/cgl/RendererCGL.h"
        "src/libANGLE/renderer/gl/cgl/WindowSurfaceCGL.h"
        "src/libANGLE/renderer/gl/cgl/WindowSurfaceCGL.mm"
    )
endif()


if(angle_enable_eagl)
    list(APPEND _gl_backend_sources
        "src/libANGLE/renderer/gl/eagl/ContextEAGL.cpp"
        "src/libANGLE/renderer/gl/eagl/ContextEAGL.h"
        "src/libANGLE/renderer/gl/eagl/DeviceEAGL.cpp"
        "src/libANGLE/renderer/gl/eagl/DeviceEAGL.h"
        "src/libANGLE/renderer/gl/eagl/DisplayEAGL.h"
        "src/libANGLE/renderer/gl/eagl/DisplayEAGL.mm"
        "src/libANGLE/renderer/gl/eagl/FunctionsEAGL.h"
        "src/libANGLE/renderer/gl/eagl/FunctionsEAGL.mm"
        "src/libANGLE/renderer/gl/eagl/IOSurfaceSurfaceEAGL.h"
        "src/libANGLE/renderer/gl/eagl/IOSurfaceSurfaceEAGL.mm"
        "src/libANGLE/renderer/gl/eagl/PbufferSurfaceEAGL.cpp"
        "src/libANGLE/renderer/gl/eagl/PbufferSurfaceEAGL.h"
        "src/libANGLE/renderer/gl/eagl/RendererEAGL.cpp"
        "src/libANGLE/renderer/gl/eagl/RendererEAGL.h"
        "src/libANGLE/renderer/gl/eagl/WindowSurfaceEAGL.h"
        "src/libANGLE/renderer/gl/eagl/WindowSurfaceEAGL.mm"
    )
endif()


if(angle_enable_gl_null)
    list(APPEND _gl_backend_sources
        "src/libANGLE/renderer/gl/null_functions.cpp"
        "src/libANGLE/renderer/gl/null_functions.h"
    )
endif()

