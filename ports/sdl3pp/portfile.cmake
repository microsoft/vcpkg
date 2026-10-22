vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO talesm/SDL3pp
    REF "${VERSION}"
    SHA512 9734502388b26d377a235afb2a6ee545742b2e3f1dcb837eb38de0f2b8dc72b82b5fd69a0deca9183bfc3aab293d7540018cef4714dacc31e152cef3ebecc5e9
    HEAD_REF main
)

# SDL3pp turns SDL3_image on by default. Keep optional integrations disabled
# unless the matching vcpkg feature is requested.
set(SDL3PP_ENABLE_IMAGE OFF)
set(SDL3PP_ENABLE_MIXER OFF)
set(SDL3PP_ENABLE_TTF OFF)

if("image" IN_LIST FEATURES)
    set(SDL3PP_ENABLE_IMAGE ON)
endif()
if("mixer" IN_LIST FEATURES)
    set(SDL3PP_ENABLE_MIXER ON)
endif()
if("ttf" IN_LIST FEATURES)
    set(SDL3PP_ENABLE_TTF ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSDL3PP_FORCE_BUNDLED=OFF
        -DSDL3PP_ENABLE_IMAGE=${SDL3PP_ENABLE_IMAGE}
        -DSDL3PP_ENABLE_MIXER=${SDL3PP_ENABLE_MIXER}
        -DSDL3PP_ENABLE_TTF=${SDL3PP_ENABLE_TTF}
        -DSDL3PP_BUILD_EXAMPLES=OFF
        -DSDL3PP_BUILD_TESTING=OFF
        -DSDL3PP_GEN_DOCS=OFF
        -DSDL3PP_GEN_HEADERS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME SDL3pp
    CONFIG_PATH lib/cmake/SDL3pp
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
