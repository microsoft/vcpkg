if(VCPKG_TARGET_IS_LINUX)
    message("Warning: `sparrow-extensions` requires Clang18+ or GCC 11.2+ on Linux")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO QuantStack/sparrow-extensions
    REF "${VERSION}"
    SHA512 d7da993b2c587bc909b044c28a676220e81a32ea3dac1a3dd54532a82d91fb8a9bc49638306aae97fed259666d55ec0a5491679e9047778a812ba62ef1e8896d
    HEAD_REF main
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(SPARROW_EXTENSIONS_BUILD_SHARED ON)
else()
    set(SPARROW_EXTENSIONS_BUILD_SHARED OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DSPARROW_EXTENSIONS_BUILD_SHARED=${SPARROW_EXTENSIONS_BUILD_SHARED}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME sparrow-extensions CONFIG_PATH share/cmake/sparrow-extensions)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
