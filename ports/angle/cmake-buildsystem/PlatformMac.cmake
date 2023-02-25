find_library(COREGRAPHICS_LIBRARY CoreGraphics)
find_library(FOUNDATION_LIBRARY Foundation)
find_library(IOKIT_LIBRARY IOKit)
find_library(IOSURFACE_LIBRARY IOSurface)
find_library(QUARTZ_LIBRARY Quartz)
find_package(ZLIB REQUIRED)

list(APPEND ANGLE_SOURCES
    ${libangle_gpu_info_util_mac_sources}
    ${libangle_gpu_info_util_sources}
    ${libangle_mac_sources}
)

list(APPEND ANGLEGLESv2_LIBRARIES
    ${COREGRAPHICS_LIBRARY}
    ${FOUNDATION_LIBRARY}
    ${IOKIT_LIBRARY}
    ${IOSURFACE_LIBRARY}
    ${QUARTZ_LIBRARY}
)

# Metal backend
if(USE_METAL)
    find_library(METAL_LIBRARY Metal)
    list(APPEND ANGLE_SOURCES
        ${_metal_backend_sources}

        ${angle_translator_lib_metal_sources}
    
        ${angle_glslang_wrapper}
    )

    list(APPEND ANGLE_DEFINITIONS
        ANGLE_ENABLE_METAL
    )

    list(APPEND ANGLEGLESv2_LIBRARIES
        ${METAL_LIBRARY}
    )
endif()

# OpenGL backend
if(USE_OPENGL)
    # Enable GLSL compiler output.
    list(APPEND ANGLE_DEFINITIONS ANGLE_ENABLE_GLSL)
endif()

if(USE_ANGLE_EGL OR ENABLE_WEBGL)
    list(APPEND ANGLE_SOURCES
        ${_gl_backend_sources}

        ${libangle_gl_egl_dl_sources}
        ${libangle_gl_egl_sources}
        ${libangle_gl_sources}
    )

    list(APPEND ANGLE_DEFINITIONS
        ANGLE_ENABLE_OPENGL
    )
endif()
