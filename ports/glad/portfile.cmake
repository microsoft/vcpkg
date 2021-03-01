vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Dav1dde/glad
    REF v0.1.34
    SHA512 bc20ca8c442068f2fd1170bdb8383fd3f1b5b4826083825d6f6fb4bc69fd99d2db04865f9c9bbe1cf6d0038e036f6d4ae6aac5f68cea8b20ed339bbde5e811e4
    HEAD_REF master
    PATCHES encoding.patch
)

if("core-profile" IN_LIST FEATURES)
    set(GLAD_PROFILE "core")
else()
    set(GLAD_PROFILE "compatibility")
endif()

set(GLAD_SPEC "gl")
set(SPEC_HITS 0)

if("egl" IN_LIST FEATURES)
    set(GLAD_SPEC "egl")
    math(EXPR SPEC_HITS "${SPEC_HITS}+1")
endif()

if("wgl" IN_LIST FEATURES)
    set(GLAD_SPEC "wgl")
    math(EXPR SPEC_HITS "${SPEC_HITS}+1")
endif()

if("glx" IN_LIST FEATURES)
    set(GLAD_SPEC "glx")
    math(EXPR SPEC_HITS "${SPEC_HITS}+1")
endif()

if(SPEC_HITS GREATER 1)
    message(WARNING "Multiple specifications have been specified, but only one can be used to configure glad. Using '${GLAD_SPEC}'...")
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
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
