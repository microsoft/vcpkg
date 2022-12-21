# Wrapper for FindEGL.cmake in extra-cmake-modules (port ecm) and its vendored copies

if(UNIX)
    find_package(OpenGL COMPONENTS EGL)
    if(OPENGL_egl_LIBRARY)
        set(EGL_LIBRARY "${OPENGL_egl_LIBRARY}" CACHE STRING "")
        set(EGL_INCLUDE_DIR "${OPENGL_EGL_INCLUDE_DIRS}" CACHE STRING "")
    endif()
elseif(WIN32)
    find_package(unofficial-angle CONFIG)
    if(TARGET unofficial::angle::libEGL)
        set(EGL_LIBRARY unofficial::angle::libEGL)
        if(NOT TARGET EGL::EGL)
            add_library(EGL::EGL INTERFACE IMPORTED)
            set_target_properties(EGL::EGL PROPERTIES
                INTERFACE_LINK_LIBRARIES unofficial::angle::libEGL
            )
        endif()
    endif()
endif()

_find_package(${ARGS})
