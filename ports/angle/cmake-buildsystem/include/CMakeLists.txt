string(REGEX REPLACE "(^|;)include/" "\\1" includes "${libangle_includes}")

set(egl_headers ${includes})
list(FILTER egl_headers INCLUDE REGEX "EGL/.*")

set(gles_headers ${includes})
list(FILTER gles_headers INCLUDE REGEX "GLES/.*")

set(gles2_headers ${includes})
list(FILTER gles2_headers INCLUDE REGEX "GLES2/.*")

set(gles3_headers ${includes})
list(FILTER gles3_headers INCLUDE REGEX "GLES3/.*")

set(khr_headers ${includes})
list(FILTER khr_headers INCLUDE REGEX "KHR/.*")

set(glslang_headers
    GLSLANG/ShaderLang.h
    GLSLANG/ShaderVars.h
)

set(ANGLE_PUBLIC_HEADERS ${khr_headers})

if (USE_ANGLE_EGL)
    list(APPEND ANGLE_PUBLIC_HEADERS
        ${egl_headers}
        ${gles_headers}
        ${gles2_headers}
        ${gles3_headers}
    )
endif ()

if (ENABLE_WEBGL)
    set(ANGLE_WEBGL_HEADERS
        export.h
        ${khr_headers}
        ${egl_headers}
        ${gles_headers}
        ${gles2_headers}
        ${gles3_headers}
    )

    WEBKIT_COPY_FILES(ANGLEWebGLHeaders
        DESTINATION ${ANGLE_FRAMEWORK_HEADERS_DIR}/ANGLE
        FILES ${ANGLE_WEBGL_HEADERS}
        FLATTENED
    )
endif ()

# Cocoa expects headers in an ANGLE directory
WEBKIT_COPY_FILES(GLSLANGHeaders
    DESTINATION ${ANGLE_FRAMEWORK_HEADERS_DIR}/ANGLE
    FILES ${glslang_headers}
    FLATTENED
)

WEBKIT_COPY_FILES(ANGLEHeaders
    DESTINATION ${ANGLE_FRAMEWORK_HEADERS_DIR}
    FILES ${ANGLE_PUBLIC_HEADERS}
)
