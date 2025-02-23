if(VCPKG_TARGET_IS_LINUX)
    message("Warning: `sparrow` requires Clang12+ or GCC 11+ on Linux")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO man-group/sparrow
    REF "${VERSION}"
    SHA512 f60cf7386955793b34720a2c24ecf29ad2568855c7344a6ab3e72c8bde2899cc9ea0ed880cc84b95feeb32413941e5c895d740c04cd2efd3fecd9b109adac317
    HEAD_REF main
    PATCHES
        find-date.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        date       USE_DATE_POLYFILL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME sparrow CONFIG_PATH share/cmake/sparrow)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
