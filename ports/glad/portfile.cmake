vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Dav1dde/glad
    REF 73db193f853e2ee079bf3ca8a64aa2eaf6459043 # 2.0.8
    SHA512 f20873b108cda958c9a3d48dad46d09636e98ed7a6b3d176a8164d2994cafbb06b2b8692217afd95e5278c96cc430f70ceda68057ca059e25ba3f4b719316eaa
    HEAD_REF master
)

set(GLAD_API "gl:compatibility=4.6")
foreach(version IN ITEMS 46 45 44 43 42 41 40 33 32 31 30 21 20 15 14 13 12 11 10)
    if("gl-api-${version}" IN_LIST FEATURES)
        string(SUBSTRING "${version}" 0 1 major)
        string(SUBSTRING "${version}" 1 1 minor)
        set(GLAD_API "gl:compatibility=${major}.${minor}")
        break()
    endif()
endforeach()
if("gl-api-latest" IN_LIST FEATURES)
    set(GLAD_API "gl:compatibility=4.6")
endif()
if("gles1-api-10" IN_LIST FEATURES OR "gles1-api-latest" IN_LIST FEATURES)
    list(APPEND GLAD_API "gles1=1.0")
endif()
if("gles2-api-latest" IN_LIST FEATURES OR "gles2-api-32" IN_LIST FEATURES)
    list(APPEND GLAD_API "gles2=3.2")
elseif("gles2-api-31" IN_LIST FEATURES)
    list(APPEND GLAD_API "gles2=3.1")
elseif("gles2-api-30" IN_LIST FEATURES)
    list(APPEND GLAD_API "gles2=3.0")
elseif("gles2-api-20" IN_LIST FEATURES)
    list(APPEND GLAD_API "gles2=2.0")
endif()
if("glsc2-api-20" IN_LIST FEATURES OR "glsc2-api-latest" IN_LIST FEATURES)
    list(APPEND GLAD_API "glsc2=2.0")
endif()
if("egl" IN_LIST FEATURES)
    list(APPEND GLAD_API "egl=1.5")
endif()
if("glx" IN_LIST FEATURES)
    list(APPEND GLAD_API "glx=1.4")
endif()
if("wgl" IN_LIST FEATURES)
    list(APPEND GLAD_API "wgl=1.0")
endif()

string(REPLACE ";" "," GLAD_API "${GLAD_API}")

set(GLAD_LOADER)
if("loader" IN_LIST FEATURES)
    set(GLAD_LOADER LOADER)
endif()
set(GLAD_ALL_EXTENSIONS OFF)
if("extensions" IN_LIST FEATURES)
    set(GLAD_ALL_EXTENSIONS ON)
endif()

file(COPY
    "${CURRENT_INSTALLED_DIR}/share/opengl/egl.xml"
    "${CURRENT_INSTALLED_DIR}/share/opengl/gl.xml"
    "${CURRENT_INSTALLED_DIR}/share/opengl/glx.xml"
    "${CURRENT_INSTALLED_DIR}/share/opengl/wgl.xml"
    DESTINATION "${SOURCE_PATH}"
)
file(COPY
    "${CURRENT_INSTALLED_DIR}/include/KHR/khrplatform.h"
    "${CURRENT_INSTALLED_DIR}/include/EGL/eglplatform.h"
    DESTINATION "${SOURCE_PATH}/glad/files"
)

x_vcpkg_get_python_packages(
    PYTHON_VERSION 3
    PACKAGES jinja2
    OUT_PYTHON_VAR PYTHON3
)

file(WRITE "${SOURCE_PATH}/CMakeLists.txt" [=[
cmake_minimum_required(VERSION 3.15)
project(glad C)

set(GLAD_SOURCES_DIR "${CMAKE_CURRENT_SOURCE_DIR}" CACHE PATH "" FORCE)
include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/GladConfig.cmake")
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
set(GLAD_ARGS STATIC REPRODUCIBLE)
if(GLAD_LOADER)
    list(APPEND GLAD_ARGS LOADER)
endif()
list(APPEND GLAD_ARGS API ${GLAD_API})
if(NOT GLAD_ALL_EXTENSIONS)
    list(APPEND GLAD_ARGS EXTENSIONS NONE)
endif()
glad_add_library(glad ${GLAD_ARGS})
set_property(TARGET glad PROPERTY INTERFACE_INCLUDE_DIRECTORIES
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/gladsources/glad/include>;$<INSTALL_INTERFACE:include>"
)

include(CMakePackageConfigHelpers)
install(TARGETS glad EXPORT glad-targets ARCHIVE DESTINATION lib INCLUDES DESTINATION include)
install(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/gladsources/glad/include/" DESTINATION include)
install(EXPORT glad-targets FILE glad-targets.cmake NAMESPACE glad:: DESTINATION share/glad)
configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/glad-config.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/glad-config.cmake"
    INSTALL_DESTINATION share/glad
)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/glad-config.cmake" DESTINATION share/glad)
]=])
file(WRITE "${SOURCE_PATH}/glad-config.cmake.in" [=[
@PACKAGE_INIT@
include("${CMAKE_CURRENT_LIST_DIR}/glad-targets.cmake")
]=])

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGLAD_API:STRING=${GLAD_API}
        -DGLAD_LOADER:BOOL=${GLAD_LOADER}
        -DGLAD_ALL_EXTENSIONS:BOOL=${GLAD_ALL_EXTENSIONS}
        "-DPython_EXECUTABLE=${PYTHON3}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH share/glad)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/include/KHR")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/include/EGL")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(COPY "${SOURCE_PATH}/glad" DESTINATION "${CURRENT_PACKAGES_DIR}/tools")
file(WRITE "${CURRENT_PACKAGES_DIR}/include/glad/glad.h" [=[
#pragma once
#include <glad/gl.h>
typedef GLADloadfunc GLADloadproc;
static inline int gladLoadGLLoader(GLADloadproc load) {
    return gladLoadGL(load);
}
#ifdef __cplusplus
static inline int gladLoadGL() {
    return gladLoaderLoadGL();
}
#endif
]=])
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
