vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Dav1dde/glad
    REF 7ece538856bf124d798ab323c8e1e64ebb83cb50
    SHA512 f6a8ba7d0d09b89c23b6f76962d3e6eef1babc8e1a659e238d30e143eb33ccba424957e5a6d46d99a714bfa2967523b193586d0ff24e29ad8d86c92c9faf9c02
    HEAD_REF master
    PATCHES encoding.patch
)

if("core-profile" IN_LIST FEATURES)
    set(GLAD_PROFILE "core")
else()
    set(GLAD_PROFILE "compatibility")
endif()

set(GLAD_SPEC "gl")

if("egl" IN_LIST FEATURES)
    set(GLAD_SPEC "${GLAD_SPEC},egl")
    #list(APPEND GLAD_SPEC "egl")
endif()

if("wgl" IN_LIST FEATURES)
    set(GLAD_SPEC "${GLAD_SPEC},wgl")
    #list(APPEND GLAD_SPEC "wgl")
endif()

if("glx" IN_LIST FEATURES)
    set(GLAD_SPEC "${GLAD_SPEC},glx")
    #list(APPEND GLAD_SPEC "glx")
endif()

if("no-loader" IN_LIST FEATURES)
    set(DISABLE_LOADER ON)
else()
    set(DISABLE_LOADER OFF)
endif()

if ("extensions" IN_LIST FEATURES)
    set(WITH_EXTENSIONS ON)
else()
    set(WITH_EXTENSIONS OFF)
endif()

vcpkg_find_acquire_program(PYTHON3)

file(COPY
    ${CURRENT_INSTALLED_DIR}/include/KHR/khrplatform.h
    ${CURRENT_INSTALLED_DIR}/include/EGL/eglplatform.h
    ${CURRENT_INSTALLED_DIR}/share/egl-registry/egl.xml
    ${CURRENT_INSTALLED_DIR}/share/opengl-registry/gl.xml
    ${CURRENT_INSTALLED_DIR}/share/opengl-registry/glx.xml
    ${CURRENT_INSTALLED_DIR}/share/opengl-registry/wgl.xml
    DESTINATION ${SOURCE_PATH}/glad/files
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DGLAD_NO_LOADER=${DISABLE_LOADER}
        -DGLAD_EXPORT=OFF
        -DGLAD_INSTALL=ON
        -DGLAD_REPRODUCIBLE=ON
        -DGLAD_SPEC="${GLAD_SPEC}"
        -DGLAD_PROFILE="${GLAD_PROFILE}"
        -DGLAD_ALL_EXTENSIONS=${WITH_EXTENSIONS}
        -DPYTHON_EXECUTABLE=${PYTHON3}
    OPTIONS_DEBUG
        -DGLAD_GENERATOR="c-debug"
    OPTIONS_RELEASE
        -DGLAD_GENERATOR="c"
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/glad)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/include/KHR)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/include/EGL)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
