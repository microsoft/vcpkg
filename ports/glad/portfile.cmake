vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Dav1dde/glad
    REF 7ece538856bf124d798ab323c8e1e64ebb83cb50
    SHA512 f6a8ba7d0d09b89c23b6f76962d3e6eef1babc8e1a659e238d30e143eb33ccba424957e5a6d46d99a714bfa2967523b193586d0ff24e29ad8d86c92c9faf9c02
    HEAD_REF master
    PATCHES encoding.patch find_python.patch
)

if(NOT GLAD_PROFILE)
    set(GLAD_PROFILE "compatibility")
endif()
message(STATUS "This version of glad uses the compatibility profile. To use the core profile instead, create an overlay port of this with GLAD_PROFILE set to 'core' or set GLAD_PROFILE to 'core' in a custom triplet.")
message(STATUS "This recipe is at ${CMAKE_CURRENT_LIST_DIR}")
message(STATUS "See the overlay ports documentation at https://github.com/microsoft/vcpkg/blob/master/docs/specifications/ports-overlay.md")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        extensions  GLAD_ALL_EXTENSIONS
    INVERTED_FEATURES
        loader      GLAD_NO_LOADER
)

set(GLAD_SPEC "gl")

if("egl" IN_LIST FEATURES)
    string(APPEND GLAD_SPEC ",egl")
endif()

if("wgl" IN_LIST FEATURES)
    string(APPEND GLAD_SPEC ",wgl")
endif()

if("glx" IN_LIST FEATURES)
    string(APPEND GLAD_SPEC ",glx")
endif()

# This needs to be ordered highest to lowest for it to be correct!
if("gl-api-latest" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl=")
elseif("gl-api-46" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl=4.6")
elseif("gl-api-45" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl=4.5")
elseif("gl-api-44" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl=4.4")
elseif("gl-api-43" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl=4.3")
elseif("gl-api-42" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl=4.2")
elseif("gl-api-41" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl=4.1")
elseif("gl-api-40" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl=4.0")
elseif("gl-api-33" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl=3.3")
elseif("gl-api-32" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl=3.2")
elseif("gl-api-31" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl=3.1")
elseif("gl-api-30" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl=3.0")
elseif("gl-api-21" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl=2.1")
elseif("gl-api-20" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl=2.0")
elseif("gl-api-15" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl=1.5")
elseif("gl-api-14" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl=1.4")
elseif("gl-api-13" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl=1.3")
elseif("gl-api-12" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl=1.2")
elseif("gl-api-11" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl=1.1")
elseif("gl-api-10" IN_LIST FEATURES)
    LIST(APPEND GLAD_API "gl=1.0")
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

string(REPLACE ";" "," GLAD_API "${GLAD_API}")

vcpkg_find_acquire_program(PYTHON3)

file(COPY
    "${CURRENT_INSTALLED_DIR}/include/KHR/khrplatform.h"
    "${CURRENT_INSTALLED_DIR}/include/EGL/eglplatform.h"
    "${CURRENT_INSTALLED_DIR}/share/opengl/egl.xml"
    "${CURRENT_INSTALLED_DIR}/share/opengl/gl.xml"
    "${CURRENT_INSTALLED_DIR}/share/opengl/glx.xml"
    "${CURRENT_INSTALLED_DIR}/share/opengl/wgl.xml"
    DESTINATION "${SOURCE_PATH}/glad/files"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGLAD_EXPORT=OFF
        -DGLAD_INSTALL=ON
        -DGLAD_REPRODUCIBLE=ON
        -DGLAD_SPEC=${GLAD_SPEC}
        -DGLAD_API=${GLAD_API}
        -DGLAD_PROFILE=${GLAD_PROFILE}
        -DPYTHON_EXECUTABLE=${PYTHON3}
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DGLAD_GENERATOR="c-debug"
    OPTIONS_RELEASE
        -DGLAD_GENERATOR="c"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/glad)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/include/KHR")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/include/EGL")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
