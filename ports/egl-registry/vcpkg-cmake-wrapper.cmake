
set(VCPKG_FIRST_EGL_CALL OFF)
if(NOT TARGET EGL::EGL)
    set(VCPKG_FIRST_EGL_CALL ON)
endif()

set(HAVE_EGL ON CACHE INTERNAL "")
_find_package(${ARGS})

# TODO: FindEGL.cmake will need more love to find release/debug correctly.
#       For now only fix single config linkage

if(VCPKG_FIRST_EGL_CALL AND "${EGL_LIBRARY}" MATCHES "libEGL\\\.a$")
    find_library(VCPKG_GLESV2_LIBRARY NAMES GLESv2)
    set_property(TARGET EGL::EGL APPEND PROPERTY INTERFACE_LINK_LIBRARIES "${VCPKG_GLESV2_LIBRARY}")
endif()

unset(VCPKG_FIRST_EGL_CALL)
