find_package(ZLIB REQUIRED)

list(APPEND ANGLE_SOURCES
    ${libangle_gpu_info_util_mac_sources}
    ${libangle_gpu_info_util_sources}
    ${libangle_mac_sources}
)

list(APPEND ANGLEGLESv2_LIBRARIES
    "-framework CoreGraphics"
    "-framework Foundation"
    "-framework IOKit"
    "-framework IOSurface"
    "-framework Quartz"
)

# Metal backend
if(USE_METAL)
    list(APPEND ANGLE_SOURCES
        ${metal_backend_sources}

        ${angle_translator_lib_msl_sources}

        ${angle_translator_glsl_apple_sources}
    )

    list(APPEND ANGLE_DEFINITIONS
        ANGLE_ENABLE_METAL
    )

    list(APPEND ANGLEGLESv2_LIBRARIES
        "-framework Metal"
    )
endif()

# OpenGL backend
if(USE_OPENGL)
    list(APPEND ANGLE_SOURCES
        ${angle_translator_glsl_base_sources}
        ${angle_translator_glsl_sources}
    )
    # Enable GLSL compiler output.
    list(APPEND ANGLE_DEFINITIONS ANGLE_ENABLE_GLSL ANGLE_ENABLE_GL_DESKTOP_BACKEND ANGLE_ENABLE_APPLE_WORKAROUNDS ANGLE_ENABLE_CGL)
endif()

if(USE_OPENGL OR ENABLE_WEBGL)
    list(APPEND ANGLE_SOURCES
        ${gl_backend_sources}

        ${libangle_gl_egl_dl_sources}
        ${libangle_gl_egl_sources}
        ${libangle_gl_sources}
    )

    list(APPEND ANGLE_DEFINITIONS
        ANGLE_ENABLE_OPENGL
    )
endif()
