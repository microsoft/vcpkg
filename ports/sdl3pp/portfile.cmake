vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO talesm/SDL3pp
    REF "${VERSION}"
    SHA512 9734502388b26d377a235afb2a6ee545742b2e3f1dcb837eb38de0f2b8dc72b82b5fd69a0deca9183bfc3aab293d7540018cef4714dacc31e152cef3ebecc5e9
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    image SDL3PP_ENABLE_IMAGE
    mixer SDL3PP_ENABLE_MIXER
    ttf SDL3PP_ENABLE_TTF
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSDL3PP_FORCE_BUNDLED=OFF
        ${FEATURE_OPTIONS}
        -DSDL3PP_BUILD_EXAMPLES=OFF
        -DSDL3PP_BUILD_TESTING=OFF
        -DSDL3PP_GEN_DOCS=OFF
        -DSDL3PP_GEN_HEADERS=OFF
)

vcpkg_cmake_install()

# Header auto-detection must not enable integrations outside the selected features.
set(SDL3PP_FEATURE_DEFINES "// Optional integrations configured by vcpkg.\n")
foreach(integration IN ITEMS IMAGE MIXER TTF)
    if(SDL3PP_ENABLE_${integration})
        string(APPEND SDL3PP_FEATURE_DEFINES "#define SDL3PP_ENABLE_${integration}\n")
    else()
        string(APPEND SDL3PP_FEATURE_DEFINES "#define SDL3PP_DISABLE_${integration}\n")
    endif()
endforeach()
set(SDL3PP_VERSION_HEADER ${CURRENT_PACKAGES_DIR}/include/SDL3pp/SDL3pp_version.h")
file(READ "${SDL3PP_VERSION_HEADER}" SDL3PP_VERSION_CONTENT)
file(WRITE "${SDL3PP_VERSION_HEADER}" ${SDL3PP_FEATURE_DEFINES}${SDL3PP_VERSION_CONTENT}")
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
