vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Dav1dde/glad
    REF v${VERSION}
    SHA512 ec964d0080c9714803f0464492b237039d2bede805d21aa9e487f3bf910447fd6440eeca59f3795dc4d5dd3b3df35101714fa21ea19eb29f6a021864a2310acd
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/glad-config.cmake"
     DESTINATION "${SOURCE_PATH}/cmake")

if(NOT GLAD_PROFILE)
    set(GLAD_PROFILE "compatibility")
endif()
message(STATUS "This version of glad uses the compatibility profile. To use the core profile instead, create an overlay port of this with GLAD_PROFILE set to 'core' or set GLAD_PROFILE to 'core' in a custom triplet.")
message(STATUS "This recipe is at ${CMAKE_CURRENT_LIST_DIR}")
message(STATUS "See the overlay ports documentation at https://github.com/microsoft/vcpkg/blob/master/docs/specifications/ports-overlay.md")

# Check for incompatible feature combinations
if("debug" IN_LIST FEATURES AND "mx" IN_LIST FEATURES)
    message(FATAL_ERROR "Error: The 'debug' and 'mx' features are incompatible and cannot be used together.")
endif()
if("on-demand" IN_LIST FEATURES AND "mx" IN_LIST FEATURES)
    message(FATAL_ERROR "Error: The 'on-demand' and 'mx' features are incompatible and cannot be used together.")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        extensions  GLAD_ALL_EXTENSIONS
)

set(GLAD_ARGS_LIST)
if("alias" IN_LIST FEATURES)
    list(APPEND GLAD_ARGS_LIST "ALIAS")
endif()
if("debug" IN_LIST FEATURES)
    list(APPEND GLAD_ARGS_LIST "DEBUG")
endif()
if("loader" IN_LIST FEATURES)
    list(APPEND GLAD_ARGS_LIST "LOADER")
endif()
if("mx" IN_LIST FEATURES)
    list(APPEND GLAD_ARGS_LIST "MX")
endif()
if("on-demand" IN_LIST FEATURES)
    list(APPEND GLAD_ARGS_LIST "ON_DEMAND")
endif()

set(GLAD_API_LIST)

# This needs to be ordered highest to lowest for it to be correct!
if("gl-api-latest" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "gl:${GLAD_PROFILE}=4.6")
elseif("gl-api-46" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "gl:${GLAD_PROFILE}=4.6")
elseif("gl-api-45" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "gl:${GLAD_PROFILE}=4.5")
elseif("gl-api-44" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "gl:${GLAD_PROFILE}=4.4")
elseif("gl-api-43" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "gl:${GLAD_PROFILE}=4.3")
elseif("gl-api-42" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "gl:${GLAD_PROFILE}=4.2")
elseif("gl-api-41" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "gl:${GLAD_PROFILE}=4.1")
elseif("gl-api-40" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "gl:${GLAD_PROFILE}=4.0")
elseif("gl-api-33" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "gl:${GLAD_PROFILE}=3.3")
elseif("gl-api-32" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "gl:${GLAD_PROFILE}=3.2")
elseif("gl-api-31" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "gl:${GLAD_PROFILE}=3.1")
elseif("gl-api-30" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "gl:${GLAD_PROFILE}=3.0")
elseif("gl-api-21" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "gl:${GLAD_PROFILE}=2.1")
elseif("gl-api-20" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "gl:${GLAD_PROFILE}=2.0")
elseif("gl-api-15" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "gl:${GLAD_PROFILE}=1.5")
elseif("gl-api-14" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "gl:${GLAD_PROFILE}=1.4")
elseif("gl-api-13" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "gl:${GLAD_PROFILE}=1.3")
elseif("gl-api-12" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "gl:${GLAD_PROFILE}=1.2")
elseif("gl-api-11" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "gl:${GLAD_PROFILE}=1.1")
elseif("gl-api-10" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "gl:${GLAD_PROFILE}=1.0")
endif()

if("egl-api-latest" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "egl=1.5")
elseif("egl-api-15" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "egl=1.5")
elseif("egl-api-14" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "egl=1.4")
elseif("egl-api-13" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "egl=1.3")
elseif("egl-api-12" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "egl=1.2")
elseif("egl-api-11" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "egl=1.1")
elseif("egl-api-10" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "egl=1.0")
endif()

if("wgl-api-latest" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "wgl=1.0")
elseif("wgl-api-10" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "wgl=1.0")
endif()

if("glx-api-latest" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "glx=1.4")
elseif("glx-api-14" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "glx=1.4")
elseif("glx-api-13" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "glx=1.3")
elseif("glx-api-12" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "glx=1.2")
elseif("glx-api-11" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "glx=1.1")
elseif("glx-api-10" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "glx=1.0")
endif()

if("gles1-api-latest" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "gles1=1.0")
elseif("gles1-api-10" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "gles1=1.0")
endif()

if("gles2-api-latest" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "gles2=3.2")
elseif("gles2-api-32" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "gles2=3.2")
elseif("gles2-api-31" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "gles2=3.1")
elseif("gles2-api-30" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "gles2=3.0")
elseif("gles2-api-20" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "gles2=2.0")
endif()

if("glsc2-api-latest" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "glsc2=2.0")
elseif("glsc2-api-20" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "glsc2=2.0")
endif()

if("vulkan-api-latest" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "vulkan=1.3")
elseif("vulkan-api-13" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "vulkan=1.3")
elseif("vulkan-api-12" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "vulkan=1.2")
elseif("vulkan-api-11" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "vulkan=1.1")
elseif("vulkan-api-10" IN_LIST FEATURES)
    list(APPEND GLAD_API_LIST "vulkan=1.0")
endif()

vcpkg_find_acquire_program(PYTHON3)
x_vcpkg_get_python_packages(
    PYTHON_VERSION 3
    PYTHON_EXECUTABLE "${PYTHON3}"
    PACKAGES "jinja2"
)

# Copy our custom CMakeLists.txt.in to the source directory
configure_file("${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt.in" "${SOURCE_PATH}/CMakeLists.txt" @ONLY)

if(GLAD_ARGS_LIST)
    string(REPLACE ";" "|" GLAD_ARGS_STRING "${GLAD_ARGS_LIST}")
else()
    set(GLAD_ARGS_STRING "")
endif()

# Ensure at least one API is specified
if(NOT GLAD_API_LIST)
    message(STATUS "No API specified, defaulting to gl:${GLAD_PROFILE}=4.6")
    list(APPEND GLAD_API_LIST "gl:${GLAD_PROFILE}=4.6")
endif()
string(REPLACE ";" "|" GLAD_API_STRING "${GLAD_API_LIST}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGLAD_VERSION=${VERSION}
        -DGLAD_ARGS=${GLAD_ARGS_STRING}
        -DGLAD_API=${GLAD_API_STRING}
        -DGLAD_INSTALL=ON
        -DPYTHON_EXECUTABLE=${PYTHON3}
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME "glad")

file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/include/KHR" 
    "${CURRENT_PACKAGES_DIR}/include/EGL"
    "${CURRENT_PACKAGES_DIR}/debug/include" 
    "${CURRENT_PACKAGES_DIR}/debug/lib/cmake"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
