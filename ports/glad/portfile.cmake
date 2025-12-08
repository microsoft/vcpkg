vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Dav1dde/glad
    REF "${VERSION}"
    SHA512 ec964d0080c9714803f0464492b237039d2bede805d21aa9e487f3bf910447fd6440eeca59f3795dc4d5dd3b3df35101714fa21ea19eb29f6a021864a2310acd
    HEAD_REF glad2
)

set(GLAD_PROFILE "compatibility")
message(STATUS "This version of glad uses the compatibility profile. To use the core profile instead, create an overlay port of this with GLAD_PROFILE set to 'core' or set GLAD_PROFILE to 'core' in a custom triplet.")
message(STATUS "This recipe is at ${CMAKE_CURRENT_LIST_DIR}")
message(STATUS "See the overlay ports documentation at https://github.com/microsoft/vcpkg/blob/master/docs/specifications/ports-overlay.md")

if("egl" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "egl=")
elseif("wgl" IN_LIST FEATURES)
    string(APPEND GLAD_API "wgl=")
elseif("glx" IN_LIST FEATURES)
    string(APPEND GLAD_API "glx=")
endif()

# This needs to be ordered highest to lowest for it to be correct!
if("gl-api-latest" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl:${GLAD_PROFILE}=")
elseif("gl-api-46" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl:${GLAD_PROFILE}=4.6")
elseif("gl-api-45" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl:${GLAD_PROFILE}=4.5")
elseif("gl-api-44" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl:${GLAD_PROFILE}=4.4")
elseif("gl-api-43" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl:${GLAD_PROFILE}=4.3")
elseif("gl-api-42" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl:${GLAD_PROFILE}=4.2")
elseif("gl-api-41" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl:${GLAD_PROFILE}=4.1")
elseif("gl-api-40" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl:${GLAD_PROFILE}=4.0")
elseif("gl-api-33" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl:${GLAD_PROFILE}=3.3")
elseif("gl-api-32" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl:${GLAD_PROFILE}=3.2")
elseif("gl-api-31" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl:${GLAD_PROFILE}=3.1")
elseif("gl-api-30" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl:${GLAD_PROFILE}=3.0")
elseif("gl-api-21" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl:${GLAD_PROFILE}=2.1")
elseif("gl-api-20" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl:${GLAD_PROFILE}=2.0")
elseif("gl-api-15" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl:${GLAD_PROFILE}=1.5")
elseif("gl-api-14" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl:${GLAD_PROFILE}=1.4")
elseif("gl-api-13" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl:${GLAD_PROFILE}=1.3")
elseif("gl-api-12" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl:${GLAD_PROFILE}=1.2")
elseif("gl-api-11" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl:${GLAD_PROFILE}=1.1")
elseif("gl-api-10" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl:${GLAD_PROFILE}=1.0")
endif()

# This needs to be ordered highest to lowest for it to be correct!
if("gles1-api-latest" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gles1=")
elseif("gles1-api-10" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gles1=1.0")
endif()

# This needs to be ordered highest to lowest for it to be correct!
if("gles2-api-latest" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gles2=")
elseif("gles2-api-32" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gles2=3.2")
elseif("gles2-api-31" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gles2=3.1")
elseif("gles2-api-30" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gles2=3.0")
elseif("gles2-api-20" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gles2=2.0")
endif()

# This needs to be ordered highest to lowest for it to be correct!
if("glsc2-api-latest" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "glsc2=")
elseif("glsc2-api-20" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "glsc2=2.0")
endif()

vcpkg_find_acquire_program(PYTHON3)
x_vcpkg_get_python_packages(PYTHON_EXECUTABLE "${PYTHON3}" PACKAGES jinja2)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}/cmake")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/cmake"
    OPTIONS
        -DGLAD_API=${GLAD_API}
	-DGLAD_SOURCES_DIR=${SOURCE_PATH}
        -DPython_EXECUTABLE=${PYTHON3}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/include/KHR"
    "${CURRENT_PACKAGES_DIR}/include/EGL"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/GladConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
