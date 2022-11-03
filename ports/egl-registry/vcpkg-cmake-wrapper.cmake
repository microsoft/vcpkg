if(UNIX)
    _find_package(OpenGL COMPONENTS EGL)
    if(OPENGL_egl_LIBRARY) # Only defined for Linux with GLVND
        set(EGL_LIBRARY "${OPENGL_egl_LIBRARY}" CACHE STRING "")
        set(EGL_INCLUDE_DIR "${OPENGL_EGL_INCLUDE_DIRS}" CACHE STRING "")
    endif()
endif()
_find_package(${ARGS})
